local log = require "log"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local json = require "dkjson"

local harmony_commands = {}

-- harmony commands
function harmony_commands.pushRelease(device,req)
  if req.action == "press" then
    sendHarmonyCommand(device,req.deviceId,req.command,req.action,0)
    sendHarmonyCommand(device,req.deviceId,req.command,"release",100)
  end
  
end
function harmony_commands.startActivity(device,req)
  log.info("Starting Activity")
  if req.action == "startActivity" then
    sendHarmonyStartActivity(device,req.activityId,0)
  end
end
function harmony_commands.handleHarmonyCommand(device,commandString)
  log.debug("Command String: "..commandString)
  local req = json.decode(commandString)
  log.debug(utils.stringify_table(req))
  if req.action == "press" then
    harmony_commands.pushRelease(device,req)
  elseif req.action == "startActivity" then
    harmony_commands.startActivity(device,req)
  end
end

return harmony_commands
