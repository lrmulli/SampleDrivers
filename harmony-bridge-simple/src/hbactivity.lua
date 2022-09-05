-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"

local function device_added(driver, device)
    log.info("[" .. device.id .. "] Adding new Harmony Activity device")
  
    -- set a default or queried state for each capability attribute
    device:emit_event(capabilities.switch.switch.off())
  end
  
  -- this is called both when a device is added (but after `added`) and after a hub reboots.
  local function device_init(driver, device)
    log.info("[" .. device.id .. "] Initializing Harmony Activity device")
  
    -- mark device as online so it can be controlled from the app
    device:online()
  end
  
  -- this is called when a device is removed by the cloud and synchronized down to the hub
  local function device_removed(driver, device)
    log.info("[" .. device.id .. "] Removing Harmony Activity device")
  end
  
  -- this is called when a device setting is changed
  local function device_info_changed(driver, device, event, args)
    log.info("[" .. device.id .. "] Device Info Changed")
  end

local hbactivity_handler = {
  NAME = "HBActivity"
  },
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed,
    infoChanged = device_info_changed
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
    [capabilities.switch.commands.on.NAME] = command_handlers.switch_on,
    [capabilities.switch.commands.off.NAME] = command_handlers.switch_off,
    }
  },
  sub_drivers = {}, -- could optionally nest further.  The can_handles would be chained
  can_handle = function(opts, driver, device, ...)
    return device:get_manufacturer() == "HBActivity"
  end,
}

return hbactivity_handler