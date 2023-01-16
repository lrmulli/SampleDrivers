local log = require "log"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local json = require "dkjson"

local harmony_commands = {}

-- harmony commands
function harmony_commands.pushRelease(device,req)
  if req.action == "press" then
    local starttime = 0
    local how_many_times =1
    if req.replay ~= nil then
      how_many_times = req.replay
    end
    for i=1, how_many_times do
      sendHarmonyCommand(device,req.deviceId,req.command,req.action,starttime)
      starttime = starttime + 100
      sendHarmonyCommand(device,req.deviceId,req.command,"release",(starttime))
      starttime = starttime + 100
    end
  end
  
end
function harmony_commands.startActivity(device,req)
  log.info("[" .. device.id .. "] Starting Activity")
  if req.action == "startActivity" then
    sendHarmonyStartActivity(device,req.activityId,0)
  end
end
function harmony_commands.getCurrentActivity(device,req)
  log.info("[" .. device.id .. "] Getting Current Activity")
  if req.action == "getCurrentActivity" then
    sendHarmonyGetCurrentActivity(device,0)
  end
end
function harmony_commands.refreshConnection(device,req)
  log.info("[" .. device.id .. "] Refreshing Connection")
  if req.action == "refreshConnection" then
    refreshConnection(device)
  end
end
function harmony_commands.handleHarmonyCommand(device,commandString)
  log.debug("[" .. device.id .. "] Command String: "..commandString)
  local req = json.decode(commandString)
  
  if harmony_commands.is_array(req) then
    log.debug("[" .. device.id .. "] This is an array of commands")
    for _, r in ipairs(req) do
      log.debug(utils.stringify_table(r))
      harmony_commands.handleIndividualHarmonyCommand(device,r)
    end
  else
    harmony_commands.handleIndividualHarmonyCommand(device,req)
  end
end
function harmony_commands.handleIndividualHarmonyCommand(device,req)
  if req.action == "press" then
    harmony_commands.pushRelease(device,req)
  elseif req.action == "startActivity" then
    harmony_commands.startActivity(device,req)
  elseif req.action == "getCurrentActivity" then
    harmony_commands.getCurrentActivity(device,req)
  elseif req.action == "refreshConnection" then
    harmony_commands.refreshConnection(device,req)
  end
end

function harmony_commands.is_array(t)
  local i = 0
  for _ in pairs(t) do
      i = i + 1
      if t[i] == nil then return false end
  end
  return true
end

return harmony_commands
