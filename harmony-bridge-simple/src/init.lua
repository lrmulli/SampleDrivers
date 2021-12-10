-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local utils = require "st.utils"
local log = require "log"
local bit = require 'bitop.funcs'
local socket = require'socket'
local ws = require('websocket.client').sync({ timeout = 30 })
local json = require "dkjson"

-- Custom capabilities


local harmonycommandcapstring = [[{
  "id": "universevoice35900.harmonyCommand",
  "version": 1,
  "status": "proposed",
  "name": "Harmony Command",
  "ephemeral": false,
  "attributes": {
      "harmonyCommand": {
          "schema": {
              "type": "object",
              "properties": {
                  "value": {
                      "type": "string"
                  }
              },
              "additionalProperties": false,
              "required": [
                  "value"
              ]
          },
          "setter": "setHarmonyCommand",
          "enumCommands": []
      }
  },
  "commands": {
      "setHarmonyCommand": {
          "name": "setHarmonyCommand",
          "arguments": [
              {
                  "name": "value",
                  "optional": false,
                  "schema": {
                      "type": "string"
                  }
              }
          ]
      }
  }
}
]]
local hc_cap = capabilities.build_cap_from_json_string(harmonycommandcapstring)
capabilities["universevoice35900.harmonyCommand"] = hc_cap
local harmonycommand = capabilities["universevoice35900.harmonyCommand"]
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
  device:emit_event(harmonycommand.harmonyCommand("StartUp"))
end

-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)
  log.info("[" .. device.id .. "] Initializing Harmony device")
  -- mark device as online so it can be controlled from the app
  device:online()
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
    removed = device_removed
  },
  capability_handlers = {
    [capabilities["universevoice35900.harmonyCommand"].ID] = {
    [capabilities["universevoice35900.harmonyCommand"].commands.setHarmonyCommand.ID] = command_handlers.harmonycommand,
    },
  }
})

--Harmony Websockets
local params = {
  mode = "client",
  protocol = "any",
  verify = "none",
  options = "all"
}
local hubId="13372140"
local hub_url = "ws://192.168.1.40:8088/?domain=svcs.myharmony.com&hubId="..hubId
function ws_connect()
  log.debug("WS_CONNECT - Connecting")
  local r, code, _, sock = ws:connect(hub_url,"echo", params)
  print('WS_CONNECT - STATUS', r, code)

  
  if r then
    log.debug("Registering Channel Handler")
    log.debug()
    hello_world_driver:register_channel_handler(ws.sock, function ()
      my_ws_tick()
    end,"SocketChannelHandler")
    log.debug("Registering Channel Handler Code finished")
  end
  getConfig()
end
function my_ws_tick()
  print("In Tick Function")
  local payload, opcode, c, d, err = ws:receive()
  --print("Payload: ",payload)
  print("Opcode: ",opcode)
  print("Error: ",err)
  if opcode == 9.0 then  -- PING 
    print('SEND PONG:', ws:send(payload, 10)) -- Send PONG
  end
  if err then
    ws_connect()   -- Reconnect on error
  end
  local response = json.decode(payload)
--  print("Response: ",utils.stringify_table(response))
  if response.cmd == "vnd.logitech.harmony/vnd.logitech.harmony.engine?config" then
    receiveConfig(response)
  end
end

function getConfig()
  local payload = '{"hubId": "'..hubId..'","timeout": 60,"hbus": {"cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?config","id": "0","params": {"verb": "get"}}}'
  print(ws:send(payload))
end
function receiveConfig(config)
  print("Config Received")
  for k, device in pairs(config.data.device) do
    print(k, device.label, device.id)
    --print(utils.stringify_table(device.controlGroup))
  end
  --youview skip 56828046

end
function sendHarmonyCommand(deviceId,command,action)
  local time= os.time(os.date("!*t"))*1000
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
  print(ws:send(payload))
end

--End Harmony Websockets

hello_world_driver:call_with_delay(1, function ()
  ws_connect()
end, 'WS START TIMER')
-- run the driver
hello_world_driver:run()
