-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local utils = require "st.utils"
local log = require "log"
local bit = require 'bitop.funcs'
local socket = require'socket'
local ws = require('websocket.client').sync({ timeout = 30 })
local json = require "dkjson"
local http = require('socket.http')
ltn12 = require("ltn12")
local ipAddress = ""
local hubId = ""


-- Custom capabilities
local capdefs = require "capdefs"
local harmonycommand = capabilities.build_cap_from_json_string(capdefs.harmonyCommandJson)
capabilities["universevoice35900.harmonycommand3"] = harmonycommand

local devicelist = capabilities.build_cap_from_json_string(capdefs.devicelistJson)
capabilities["universevoice35900.devicelist"] = devicelist
-- require custom handlers from driver package
local command_handlers = require "command_handlers"
local discovery = require "discovery"

-----------------------------------------------------------------
-- local functions
-----------------------------------------------------------------
-- this is called once a device is added by the cloud and synchronized down to the hub
local function device_added(driver, device)
  log.info("[" .. device.id .. "] Adding new Harmony device")

  -- set a default or queried state for each capability attribute
  --device:emit_event(harmonycommand.harmonyCommand("StartUp"))
  --device:emit_event(devicelist.devicelist("StartUp"))
  --device:emit_component_event(device.profile.components.testbutton, capabilities.momentary.commands.push)
end

-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)
  log.info("[" .. device.id .. "] Initializing Harmony device")
  -- mark device as online so it can be controlled from the app
  device:online()
  if (device.preferences.deviceaddr ~= "192.168.1.n") then
    ipAddress = device.preferences.deviceaddr
    getHarmonyHubId(device,ipAddress)
    --connect_ws_harmony(device)
    device.thread:call_with_delay(5, function() connect_ws_harmony(device) end)
  end
  device:online()
end

local function device_info_changed(driver, device, event, args)
  -- Did my preference value change
    if args.old_st_store.preferences.deviceaddr ~= device.preferences.deviceaddr then
      log.info("IP Address Changed"..device.preferences.deviceaddr)
      ipAddress = device.preferences.deviceaddr
      getHarmonyHubId(device,ipAddress)
      connect_ws_harmony(device)
    end
    
end


-- this is called when a device is removed by the cloud and synchronized down to the hub
local function device_removed(driver, device)
  log.info("[" .. device.id .. "] Removing Harmony device")
end




-- create the driver object
local hello_world_driver = Driver("harmony-bridge-simple.v1", {
  discovery = discovery.handle_discovery,
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed,
    infoChanged = device_info_changed
  },
  capability_handlers = {
    [capabilities["universevoice35900.harmonycommand3"].ID] = {
    [capabilities["universevoice35900.harmonycommand3"].commands.setHarmonyCommand.ID] = command_handlers.harmonycommand,
    },
    [capabilities.momentary.ID] = {
      [capabilities.momentary.commands.push.NAME] = command_handlers.push,
    }
  }
})

--Harmony Websockets
local params = {
  mode = "client",
  protocol = "any",
  verify = "none",
  options = "all"
}


function ws_connect(device)
  if ipAddress ~= "" and hubId ~= ""  then
    log.info("Configured IP Address is : "..ipAddress)
    local hub_url = "ws://"..ipAddress..":8088/?domain=svcs.myharmony.com&hubId="..hubId
    log.debug("Getting Hub ID")
    log.debug("WS_CONNECT - Connecting")
    local r, code, _, sock = ws:connect(hub_url,"echo", params)
    print('WS_CONNECT - STATUS', r, code)
  
    
    if r then
      log.debug("Registering Channel Handler")
      log.debug()
      hello_world_driver:register_channel_handler(ws.sock, function ()
        my_ws_tick(device)
      end,"SocketChannelHandler")
      log.debug("Registering Channel Handler Code finished")
    end
    getConfig()
  else
    log.info("Check IP Address Configuration")
  end
end
function my_ws_tick(device)
  print("In Tick Function")
  local payload, opcode, c, d, err = ws:receive()
  --print("Payload: ",payload)
  print("Opcode: ",opcode)
  print("Error: ",err)
  if opcode == 9.0 then  -- PING 
    print('SEND PONG:', ws:send(payload, 10)) -- Send PONG
  end
  if err then
    ws_connect(device)   -- Reconnect on error
  end
  local response = json.decode(payload)
--  print("Response: ",utils.stringify_table(response))
  if response.cmd == "vnd.logitech.harmony/vnd.logitech.harmony.engine?config" then
    receiveConfig(device,response)
  end
end

function getConfig()
  local payload = '{"hubId": "'..hubId..'","timeout": 60,"hbus": {"cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?config","id": "0","params": {"verb": "get"}}}'
  print(ws:send(payload))
end
function receiveConfig(device,config)
  print("Config Received")
  local deviceListString = ""..string.char(10)..string.char(13)
  for k, d in pairs(config.data.device) do
    deviceListString = deviceListString..string.char(10)..string.char(13)..d.id.." - "..d.label..string.char(10)..string.char(13)
    for i,cg in pairs(d.controlGroup) do
      for x, action in pairs(cg["function"]) do
          --print(utils.stringify_table(action))
          deviceListString = deviceListString..[[{"deviceId":"]]..d.id..[[","command":"]]..action.name..[[","action":"press"}]]..string.char(10)..string.char(13)
      end
    end
  end
  local thisline = ""
  for i, a in pairs(config.data.activity) do
    deviceListString = deviceListString..a.label..[[{"activityId":"]]..a.id..[[","action":"startActivity"}]]..string.char(10)..string.char(13)
  end
  print(deviceListString)
  device:emit_event(devicelist.devicelist(deviceListString))
  --youview skip 56828046
end
function sendHarmonyCommand(device,deviceId,command,action,time)
  local payload = [[{
    "hubId": "]]..hubId..[[",
    "timeout": 30,
    "hbus": {
      "cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?holdAction",
      "id": "0",
      "params": {
        "status": "]]..action..[[",
        "timestamp": "]]..time..[[",
        "verb": "render",
        "action": "{\"command\":\"]]..command..[[\",\"type\":\"IRCommand\",\"deviceId\":\"]]..deviceId..[[\"}"
      }
    }
  }]]
  print(payload)
  local ok,close_was_clean,close_code,close_reason = ws:send(payload)
  print(ok,close_was_clean,close_code,close_reason)

end
function sendHarmonyStartActivity(device,activityId,time)
  local payload = [[{
    "hubId": "]]..hubId..[[",
    "timeout": 60,
    "hbus": {
      "cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?startactivity",
      "id": "0",
      "params": {
        "async": "true",
        "timestamp": "]]..time..[[",
        "args": {
          "rule": "start"
        },
        "activityId": "]]..activityId..[["
      }
    }
  }]]
  print(payload)
  local ok,close_was_clean,close_code,close_reason = ws:send(payload)
  print(ok,close_was_clean,close_code,close_reason)

end

--End Harmony Websockets
--Harmony HTTP
function getHarmonyHubId(device,ipAddress)
  log.info("Attempting to get hubID for ipAddress "..ipAddress)
  local reqbody = [[{"id":124,"cmd":"setup.account?getProvisionInfo","timeout":90000}]]
  local respbody = {} -- for the response body
  http.TIMEOUT = 65;
  local result, respcode, respheaders, respstatus = http.request {
    method = "POST",
    url = "http://"..ipAddress..":8088",
    source = ltn12.source.string(reqbody),
    headers = {
        ["content-type"] = "application/json",
        ["accept"] = "utf-8",
        ["origin"] = "http://sl.dhg.myharmony.com",
        ["content-length"] = string.len(reqbody)
    },
    sink = ltn12.sink.table(respbody)
    }
  -- get body as string by concatenating table filled by sink
  respbody = table.concat(respbody)
  print(result,respcode,respstatus)
  local resp = json.decode(respbody)
  print(resp.data.activeRemoteId)
  hubId = resp.data.activeRemoteId;
end
--End Harmony HTTP
function connect_ws_harmony(device)
  log.info("connecting over websockets ip: "..ipAddress.."HubId: "..hubId)
  hello_world_driver:call_with_delay(1, function ()
    ws_connect(device)
  end, 'WS START TIMER')
end

-- run the driver
hello_world_driver:run()
