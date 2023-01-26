local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local utils = require "st.utils"
local log = require "log"
local socket = require'socket'
local json = require "dkjson"
local cosock = require "cosock"
local http = cosock.asyncify "socket.http"
ltn12 = require("ltn12")


local utils = {}

---
--- @param device table
--- @return string the serial number of the device
utils.get_serial_number = function(device)
  return device:get_field("harmony_hub_id")
end

utils.getHarmonyHubId = function(device,ipAddress)
    log.info("[" .. device.id .. "] Attempting to get hubID for ipAddress "..ipAddress)
    local reqbody = [[{"id":124,"cmd":"setup.account?getProvisionInfo","timeout":90000}]]
    local respbody = {} -- for the response body
    http.TIMEOUT = 50;
    log.info("[" .. device.id .. "] Sending request...")
  
    local result, respcode, respheaders, respstatus = http.request {
      method = "POST",
      url = "http://"..ipAddress..":8088",
      source = ltn12.source.string(reqbody),
      headers = {
          ["content-type"] = "application/json",
          ["accept"] = "utf-8",
          ["origin"] = "http://sl.dhg.myharmony.com",
          ["content-length"] = string.len(reqbody)
      },
      sink = ltn12.sink.table(respbody)
      }
    -- get body as string by concatenating table filled by sink
    respbody = table.concat(respbody)
    log.debug("[" .. device.id .. "] Response Body :"..respbody)
    print(result,respcode,respstatus)
    local resp = json.decode(respbody)
    if utils.isempty(resp) 
    then
      log.debug("[" .. device.id .. "] Get Harmony Hub ID failed")
      return ""
    else
      print(resp.data.activeRemoteId)
      device:set_field("harmony_hub_id",resp.data.activeRemoteId)
      return resp.data.activeRemoteId
    end
end

utils.isempty = function(s)
  return s == nil or s == ''
end

return utils