local log = require "log"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local json = require "dkjson"
local logger = capabilities["universevoice35900.log"]

local hbactivity_message_broker = {}

function hbactivity_message_broker.messageReceived(driver,device,msg)
    if msg.type == "connect.stateDigest?notify" then
        hbactivity_message_broker.activityMessageReceived(driver,device,msg)
    end
    if msg.type == "harmony.engine?startActivityFinished" then
       hbactivity_message_broker.activityMessageReceived(driver,device,msg)
    end
end
function hbactivity_message_broker.activityMessageReceived(driver,device,msg)
    log.info("Activity Message Broker - Received: ",utils.stringify_table(msg,"Activity Message: ",true))
    local device_list = driver:get_devices()
    for _, d in ipairs(device_list) do
        if d.parent_device_id == device.id then
            --this means that the child device is owned by the device that received the message
            log.info("DeviceID: ",d.id)
            log.info("Device Parent: ",d.parent_device_id)
            log.info("Device Activity:",d.vendor_provided_label)
            if msg.type == "connect.stateDigest?notify" then
                d:emit_component_event(d.profile.components.activitylogger,logger.logger("Activity Message Recd: "..(utils.stringify_table(msg,"Activity Message: ",true) or "")))
                if (msg.data.activityId == d.vendor_provided_label) then
                    --this means this is a message about this activity for this device
                    if(msg.data.activityStatus=="2") then
                        --make sure the switch is 'on'
                        d:emit_event(capabilities.switch.switch.on())
                    else
                        --make sure the switch is 'off'
                        d:emit_event(capabilities.switch.switch.off())
                    end
                end
            end
        end
    end
end


return hbactivity_message_broker