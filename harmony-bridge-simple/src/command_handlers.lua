local log = require "log"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local json = require "dkjson"
local harmony_commands = require "harmony_commands"
local command_handlers = {}

-- callback to handle an `on` capability command
function command_handlers.harmonycommand(driver, device, command)
  log.debug("[" .. device.id .. "] Execute Command---"..command.args.value)
  harmony_commands.handleHarmonyCommand(device,command.args.value)
end
function command_handlers.push(driver, device, command)
  log.info("[" .. device.id .. "] test button pushed");
  if device.preferences.buttoncommand ~= "" and device.preferences.buttoncommand ~= "{put your harmony command here}" then
    harmony_commands.handleHarmonyCommand(device,device.preferences.buttoncommand)
  end
end

return command_handlers
