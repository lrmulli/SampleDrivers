local log = require "log"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local json = require "dkjson"

local hbactivity_message_broker = {}

function hbactivity_message_broker.messageReceived(device,msg)
    if msg.type == "connect.stateDigest?notify" then
        hbactivity_message_broker.activityMessageReceived(device,msg)
    end
    if msg.type == "harmony.engine?startActivityFinished" then
       hbactivity_message_broker.activityMessageReceived(device,msg)
    end
end
function hbactivity_message_broker.activityMessageReceived(device,msg)
    log.info("Activity Message Broker - Received: ",utils.stringify_table(msg,"Activity Message: ",true))
    local activityList = device:get_field("activityList")
    local device_list = hello_world_driver:get_devices()
    for i, a in pairs(activityList) do
        log.info("Processing Mesages For - ",a.label," ",a.id)
    end
    
end


return hbactivity_message_broker