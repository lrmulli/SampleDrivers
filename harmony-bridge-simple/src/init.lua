-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local utils = require "st.utils"
local log = require "log"
local bit = require 'bitop.funcs'
local socket = require'socket'
local json = require "dkjson"
--local http = require('socket.http')
local cosock = require "cosock"
local http = cosock.asyncify "socket.http"
ltn12 = require("ltn12")
local Listener = require "listener"

-- Custom capabilities
local capdefs = require "capdefs"
local harmonycommand = capabilities.build_cap_from_json_string(capdefs.harmonyCommandJson)
capabilities["universevoice35900.harmonycommand3"] = harmonycommand

local devicelist = capabilities.build_cap_from_json_string(capdefs.devicelistJson)
capabilities["universevoice35900.devicelist"] = devicelist
-- require custom handlers from driver package
local command_handlers = require "command_handlers"
local hbactivity_message_broker = require "hbactivity_message_broker"
local discovery = require "discovery"
local logger = capabilities["universevoice35900.log"]

-----------------------------------------------------------------
-- local functions
-----------------------------------------------------------------
-- this is called once a device is added by the cloud and synchronized down to the hub
local function device_added(driver, device)
  log.info("[" .. device.id .. "] Adding new Harmony device")

end

-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)
  log.info("[" .. device.id .. "] Initializing Harmony device")
  -- mark device as online so it can be controlled from the app
  device:online()
  if (device:component_exists("testbutton")) then --this means that it is a harmony hub
    if (device.preferences.deviceaddr ~= "192.168.1.n") then
      local ipAddress = device.preferences.deviceaddr
      device:set_field("harmony_hub_ip",device.preferences.deviceaddr)
      getHarmonyHubId(device,ipAddress)
      --connect_ws_harmony(device)
      device.thread:call_with_delay(5, function() connect_ws_harmony(device) end)
    end
    device:emit_event(logger.logger("Bridge Device [" .. device.id .. "] - Initialising"))
    device:emit_event(logger.logger("Bridge Device [" .. device.id .. "] - Setting up current activity poll"))
    driver:call_on_schedule(60, function () poll(driver,device) end, 'POLLING - '..device.id)
  end
  if(device:component_exists("activitylogger")) then --this means that it is activity device
    --device:emit_event(capabilities.switch.switch.off())
  end
end

local function device_info_changed(driver, device, event, args)
  -- Did my preference value change
  if (device:component_exists("testbutton")) then --this means that it is a harmony hub
    if args.old_st_store.preferences.configonconnect ~= device.preferences.configonconnect then
      if (device.preferences.configonconnect == true) then
        getConfig(device)
      end
    end
    if args.old_st_store.preferences.deviceaddr ~= device.preferences.deviceaddr then
      log.info(" [" .. device.id .. "] IP Address Changed"..device.preferences.deviceaddr)
      ipAddress = device.preferences.deviceaddr
      device:set_field("harmony_hub_ip",device.preferences.deviceaddr)
      log.info(" [" .. device.id .. "] stored_harmony_ip : "..device:get_field("harmony_hub_ip"))
      getHarmonyHubId(device,ipAddress)
      log.info(" [" .. device.id .. "] stored_harmony_hub_id : "..device:get_field("harmony_hub_id"))
      --connect_ws_harmony(device)
      device.thread:call_with_delay(5, function() connect_ws_harmony(device) end)
    end
    --check for deviceid changes
    if args.old_st_store.preferences.deviceid ~= device.preferences.deviceid then
      log.info(" [" .. device.id .. "] Additional Device Id field changed - "..device.preferences.deviceid)
      if (device.preferences.deviceid ~= "1") then
        local did = device.preferences.deviceid
        local metadata = {
          type = "LAN",
          -- the DNI must be unique across your hub, using static ID here so that we
          -- only ever have a single instance of this "device"
          device_network_id = "harmony_bridge_v2_"..did,
          label = "Harmony Bridge Simple V2 - "..did,
          profile = "harmony-bridge-simple.v1",
          manufacturer = "SmartThingsCommunity",
          model = "v2",
          vendor_provided_label = nil
        }
        driver:try_create_device(metadata)
      end
    end
    if args.old_st_store.preferences.activitydevices ~= device.preferences.activitydevices then
      log.info("[" .. device.id .. "] Activity Devices setting changed")
      local hubId = device:get_field("harmony_hub_id")
      if (device.preferences.activitydevices == true) then
        local activityList = device:get_field("activityList")
        for i, a in pairs(activityList) do
          log.info("[" .. device.id .. "] Creating Activity Device for - ",a.label)
          --deviceListString = deviceListString..a.label..[[{"activityId":"]]..a.id..[[","action":"startActivity"}]]..string.char(10)..string.char(13)
          local dni = "harmony_bridge_activity_"..a.id
          if(a.id == "-1") then
            --this is the poweroff activity
            dni = "harmony_bridge_"..hubId.."_activity_"..a.id
          end
          local metadata = {
            type = "LAN",
            -- the DNI must be unique across your hub, using static ID here so that we
            -- only ever have a single instance of this "device"
            device_network_id = dni,
            label = "HB "..hubId.." Activity - "..a.label,
            profile = "harmony-bridge-activity.v1",
            manufacturer = "HBActivity",
            model = "HBActivity",
            vendor_provided_label = a.id,
            parent_device_id = device.id
          }
          driver:try_create_device(metadata)
        end
      end
    end
  end
end


-- this is called when a device is removed by the cloud and synchronized down to the hub
local function device_removed(driver, device)
  if (device:component_exists("testbutton")) then --this means that it is a harmony hub
    local ws = device:get_field("ws")
    driver:unregister_channel_handler(ws.sock)
    ws:close(4001,'lost interest')
  end
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
    },
  },
  sub_drivers = { require("hbactivity")}
})

--Harmony Websockets
local params = {
  mode = "client",
  protocol = "any",
  verify = "none",
  options = "all"
}


function ws_connect(device)
  local hubId = device:get_field("harmony_hub_id")
  local ipAddress = device:get_field("harmony_hub_ip")
  if ipAddress ~= "" and hubId ~= ""  then
    local listener = Listener.create_device_event_listener(hello_world_driver, device)
    device:set_field("listener", listener)
    listener:start()
  
    if (device.preferences.configonconnect == true) then
      getConfig(device)
    end
  else
    log.info("[" .. device.id .. "] Check IP Address Configuration")
  end
end

function getConfig(device)
  local ws = device:get_field("ws")
  local hubId = device:get_field("harmony_hub_id")
  local ipAddress = device:get_field("harmony_hub_ip")
  local payload = '{"hubId": "'..hubId..'","timeout": 60,"hbus": {"cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?config","id": "0","params": {"verb": "get"}}}'
  local listener = device:get_field("listener")
  listener:send_msg(payload)
  if (device.preferences.verboserecdlog == true) then
    device:emit_event(logger.logger("Payload Sent: "..(payload or "")))
  end
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
  local activityList = config.data.activity
  device:set_field("activityList",activityList)
  --youview skip 56828046
end
function sendHarmonyCommand(device,deviceId,command,action,time)
  local ws = device:get_field("ws")
  local hubId = device:get_field("harmony_hub_id")
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
  local listener = device:get_field("listener")
  listener:send_msg(payload)
  if (device.preferences.verboserecdlog == true) then
    device:emit_event(logger.logger("Payload Sent: "..(payload or "")))
  end
end
function sendHarmonyStartActivity(device,activityId,time)
  local ws = device:get_field("ws")
  local hubId = device:get_field("harmony_hub_id")
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
  local listener = device:get_field("listener")
  listener:send_msg(payload)
  if (device.preferences.verboserecdlog == true) then
    device:emit_event(logger.logger("Payload Sent: "..(payload or "")))
  end
end
function sendHarmonyGetCurrentActivity(device,time)
  local ws = device:get_field("ws")
  local hubId = device:get_field("harmony_hub_id")
  local payload = [[{
    "hubId": "]]..hubId..[[",
    "timeout": 60,
    "hbus": {
      "cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?getCurrentActivity",
      "id": "0",
      "params": {
        "verb": "get"
        }
      }
    }]]
  print(payload)
  local listener = device:get_field("listener")
  listener:send_msg(payload)
  if (device.preferences.verboserecdlog == true) then
    device:emit_event(logger.logger("Payload Sent: "..(payload or "")))
  end
end

--End Harmony Websockets
--Harmony HTTP
function getHarmonyHubId(device,ipAddress)
  log.info("[" .. device.id .. "] Attempting to get hubID for ipAddress "..ipAddress)
  local reqbody = [[{"id":124,"cmd":"setup.account?getProvisionInfo","timeout":90000}]]
  local respbody = {} -- for the response body
  http.TIMEOUT = 50;
  log.info("[" .. device.id .. "] Sending request...")

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
  log.debug("[" .. device.id .. "] Response Body :"..respbody)
  print(result,respcode,respstatus)
  local resp = json.decode(respbody)
  print(resp.data.activeRemoteId)
  device:set_field("harmony_hub_id",resp.data.activeRemoteId)
end
--End Harmony HTTP
function connect_ws_harmony(device)
  local hubId = device:get_field("harmony_hub_id")
  local ipAddress = device:get_field("harmony_hub_ip")
  log.info("[" .. device.id .. "] connecting over websockets ip: "..ipAddress.."HubId: "..hubId)
  hello_world_driver:call_with_delay(1, function ()
    ws_connect(device)
  end, 'WS START TIMER')
end

function poll(driver,device)
  if device.preferences.deviceaddr ~= "192.168.1.n" then
    --we have an ip address
    log.info("[" .. device.id .. "] Polling for activity updates - ",device.id)
    sendHarmonyGetCurrentActivity(device,0)
  end
end

-- run the driver
hello_world_driver:run()
