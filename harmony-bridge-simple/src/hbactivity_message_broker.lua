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
    if msg.cmd == "vnd.logitech.harmony/vnd.logitech.harmony.engine?getCurrentActivity" and msg.code == 200 then
        hbactivity_message_broker.activityMessageReceived(driver,device,msg)
     end
end
function hbactivity_message_broker.activityMessageReceived(driver,device,msg)
    log.info("[" .. device.id .. "] Activity Message Broker - Received: ",utils.stringify_table(msg,"Activity Message: ",true))
    local device_list = driver:get_devices()
    for _, d in ipairs(device_list) do
        if (d.parent_device_id == device.id and d:component_exists("activitylogger")) then
            --this means that the child device is owned by the device that received the message (and it is as activity device)
            if msg.type == "connect.stateDigest?notify" then
                --d:emit_component_event(d.profile.components.activitylogger,logger.logger("Activity Message Recd: "..(utils.stringify_table(msg,"Activity Message: ",true) or "")))
                if (msg.data.activityId == d.vendor_provided_label and msg.data.activityStatus==2) then
                    --this means this is a message about this activity for this device
                    log.info("Matching Activity & Device: ",msg.data.activityId)
                    log.info("Activity Status: ",msg.data.activityStatus)
                    
                    --make sure the switch is 'on'
                    log.info("Switching Activity On")
                    d:emit_event(capabilities.switch.switch.on())
                else
                    --make sure the switch is 'off'
                    log.info("Switching Activity Off")
                    d:emit_event(capabilities.switch.switch.off())
                end
            elseif msg.cmd == "vnd.logitech.harmony/vnd.logitech.harmony.engine?getCurrentActivity" then
                if (msg.data.result == d.vendor_provided_label) then
                    log.info("Matching Activity & Device: ",msg.data.result)
                    log.info("Switching Activity On")
                    d:emit_event(capabilities.switch.switch.on())
                else
                    --make sure the switch is 'off'
                    log.info("Switching Activity Off")
                    d:emit_event(capabilities.switch.switch.off())
                end
            end
        end
    end
end


return hbactivity_message_broker