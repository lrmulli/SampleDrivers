local log = require "log"
local capabilities = require "st.capabilities"

local hbactivity_command_handlers = {}

-- callback to handle an `on` capability command
function hbactivity_command_handlers.switch_on(driver, device, command)
  log.debug(string.format("[%s] calling set_power(on)", device.device_network_id))
  --device:emit_event(capabilities.switch.switch.on())
  parent = hbactivity_command_handlers.getParentDevice(driver,device)
  activityid = device.vendor_provided_label
  sendHarmonyStartActivity(parent,activityid,0)
end

-- callback to handle an `off` capability command
function hbactivity_command_handlers.switch_off(driver, device, command)
  log.debug(string.format("[%s] calling set_power(off)", device.device_network_id))
  --device:emit_event(capabilities.switch.switch.off())
  parent = hbactivity_command_handlers.getParentDevice(driver,device)
  sendHarmonyStartActivity(parent,"-1",0)
end

function hbactivity_command_handlers.getParentDevice(driver,device)
    local device_list = driver:get_devices()
    local dev = {}
    for _, d in ipairs(device_list) do
        if device.parent_device_id == d.id then
            dev = d
        end
    end
    log.info("Returning Parent: ",dev.id)
    return dev
end
return hbactivity_command_handlers