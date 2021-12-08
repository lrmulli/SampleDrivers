-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local bit = require 'bitop.funcs'
local socket = require'socket'
local ws = require('websocket.client').sync({ timeout = 30 })

-- require custom handlers from driver package
local command_handlers = require "command_handlers"
local discovery = require "discovery"

-----------------------------------------------------------------
-- local functions
-----------------------------------------------------------------
-- this is called once a device is added by the cloud and synchronized down to the hub
local function device_added(driver, device)
  log.info("[" .. device.id .. "] Adding new Hello World device")

  -- set a default or queried state for each capability attribute
  device:emit_event(capabilities.switch.switch.on())
end

-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)
  log.info("[" .. device.id .. "] Initializing Hello World device")
  -- mark device as online so it can be controlled from the app
  device:online()
end

-- this is called when a device is removed by the cloud and synchronized down to the hub
local function device_removed(driver, device)
  log.info("[" .. device.id .. "] Removing Hello World device")
end

-- create the driver object
local hello_world_driver = Driver("helloworld", {
  discovery = discovery.handle_discovery,
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] = command_handlers.switch_on,
      [capabilities.switch.commands.off.NAME] = command_handlers.switch_off,
    },
  }
})


local params = {
  mode = "client",
  protocol = "any",
  verify = "none",
  options = "all"
}

function ws_connect()
  log.debug("WS_CONNECT - Connecting")
  local r, code, _, sock = ws:connect('ws://192.168.1.40:8088/?domain=svcs.myharmony.com&hubId=13372140',"", params)
  print('WS_CONNECT', r, code)

  if r then
    hello_world_driver:register_channel_handler(sock, function ()
      my_ws_tick()
    end)
  end
end

function my_ws_tick()
  local payload, opcode, c, d, err = ws:receive()
  if opcode == 9.0 then  -- PING 
    print('SEND PONG:', ws:send(payload, 10)) -- Send PONG
  end
  if err then
    ws_connect()   -- Reconnect on error
  end
end

hello_world_driver:call_with_delay(1, function ()
  ws_connect()
end, 'WS START TIMER')
-- run the driver
hello_world_driver:run()
