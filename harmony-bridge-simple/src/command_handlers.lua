local log = require "log"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local json = require "dkjson"

local command_handlers = {}

-- callback to handle an `on` capability command
function command_handlers.harmonycommand(driver, device, command)
  log.debug("Execute Command---"..command.args.value)
  local req = json.decode(command.args.value)
  log.debug(utils.stringify_table(req))
  sendHarmonyCommand(req.deviceId,req.command,req.action)
end

return command_handlers
