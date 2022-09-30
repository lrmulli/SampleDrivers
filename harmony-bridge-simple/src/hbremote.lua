-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"

local hbremote_command_handlers = require "hbremote_command_handlers"


local hbremote_handler = {
NAME = "HBRemoteHandler",
  capability_handlers = {
    [capabilities.switch.ID] = {
        [capabilities.switch.commands.on.NAME] = hbremote_command_handlers.switch_on,
        [capabilities.switch.commands.off.NAME] = hbremote_command_handlers.switch_off,
        },
    [capabilities.keypadInput.ID] = {
          [capabilities.keypadInput.commands.sendKey.NAME] = hbremote_command_handlers.keyPress,
          },
    },
  can_handle = function(opts, driver, device, ...)
    return device:component_exists("remotelogger")
  end,
}

return hbremote_handler