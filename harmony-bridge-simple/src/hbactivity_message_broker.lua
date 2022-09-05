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
    log.info("Activity Message Broker - Received: ",msg)
end


return hbactivity_message_broker