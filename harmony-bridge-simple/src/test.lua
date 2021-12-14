local json = require "dkjson"
local utils = require "st.utils"

local jstring = [[
    {
        "cmd": "vnd.logitech.harmony/vnd.logitech.harmony.engine?config",
        "code": 200,
        "id": "0",
        "msg": "OK",
        "data": {
          "dataConsent": false,
          "sequence": [
            {
              "id": "1369600",
              "name": "SkipAds"
            },
            {
              "id": "1630677",
              "name": "SkipAds"
            }
          ],
          "global": {
            "timeStampHash": "9615825c-b93f-451b-9048-e117178acb37a291b7ff-6f72-4919-be62-a1d7d43a9dd2/bf0db096-05fd-414c-96fa-733ae62c946515dfeb0c-d558-41c0-9c4b-82cfe4e5a422fdfa2ede-6937-456b-a5aa-7f1ab5791b3c13372140Mullineux+Harmony+Huben-USlmullineux@gmail.comUKMS-5c914b7c-d99c-4c20-a900-a531f7aa884301141470424False1938143563europe%2flondonTrue-4123718471;3c3e6e3ecbd2ea461f20bb83688b3d89",
            "locale": "en-US"
          },
          "device": [
            {
              "label": "Humax DVR",
              "deviceAddedDate": "/Date(1535140184763+0000)/",
              "ControlPort": 7,
              "contentProfileKey": 56827429,
              "deviceProfileUri": "svcs.myharmony.com/res/device/56827429-ikSOp2jmwy2JzQclF2ucGk618NAV3lqXlxgGSS+A+ms=",
              "manufacturer": "Humax",
              "icon": "18",
              "Capabilities": [
                1,
                3,
                5,
                6
              ],
              "deviceTypeDisplayName": "PVR",
              "powerFeatures": [],
              "isManualPower": "false",
              "controlGroup": [
                {
                  "name": "Power",
                  "function": [
                    {
                      "action": "{\"command\":\"PowerToggle\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "PowerToggle",
                      "label": "Power Toggle"
                    }
                  ]
                },
                {
                  "name": "NumericBasic",
                  "function": [
                    {
                      "action": "{\"command\":\"0\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number0",
                      "label": "0"
                    },
                    {
                      "action": "{\"command\":\"1\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number1",
                      "label": "1"
                    },
                    {
                      "action": "{\"command\":\"2\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number2",
                      "label": "2"
                    },
                    {
                      "action": "{\"command\":\"3\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number3",
                      "label": "3"
                    },
                    {
                      "action": "{\"command\":\"4\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number4",
                      "label": "4"
                    },
                    {
                      "action": "{\"command\":\"5\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number5",
                      "label": "5"
                    },
                    {
                      "action": "{\"command\":\"6\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number6",
                      "label": "6"
                    },
                    {
                      "action": "{\"command\":\"7\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number7",
                      "label": "7"
                    },
                    {
                      "action": "{\"command\":\"8\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number8",
                      "label": "8"
                    },
                    {
                      "action": "{\"command\":\"9\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Number9",
                      "label": "9"
                    }
                  ]
                },
                {
                  "name": "Volume",
                  "function": [
                    {
                      "action": "{\"command\":\"Mute\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Mute",
                      "label": "Mute"
                    },
                    {
                      "action": "{\"command\":\"VolumeDown\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "VolumeDown",
                      "label": "Volume Down"
                    },
                    {
                      "action": "{\"command\":\"VolumeUp\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "VolumeUp",
                      "label": "Volume Up"
                    }
                  ]
                },
                {
                  "name": "Channel",
                  "function": [
                    {
                      "action": "{\"command\":\"ChannelDown\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "ChannelDown",
                      "label": "Channel Down"
                    },
                    {
                      "action": "{\"command\":\"ChannelUp\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "ChannelUp",
                      "label": "Channel Up"
                    }
                  ]
                },
                {
                  "name": "NavigationBasic",
                  "function": [
                    {
                      "action": "{\"command\":\"DirectionDown\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "DirectionDown",
                      "label": "Direction Down"
                    },
                    {
                      "action": "{\"command\":\"DirectionLeft\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "DirectionLeft",
                      "label": "Direction Left"
                    },
                    {
                      "action": "{\"command\":\"DirectionRight\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "DirectionRight",
                      "label": "Direction Right"
                    },
                    {
                      "action": "{\"command\":\"DirectionUp\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "DirectionUp",
                      "label": "Direction Up"
                    },
                    {
                      "action": "{\"command\":\"OK\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Select",
                      "label": "Select"
                    }
                  ]
                },
                {
                  "name": "TransportBasic",
                  "function": [
                    {
                      "action": "{\"command\":\"Stop\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Stop",
                      "label": "Stop"
                    },
                    {
                      "action": "{\"command\":\"Play\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Play",
                      "label": "Play"
                    },
                    {
                      "action": "{\"command\":\"Rewind\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Rewind",
                      "label": "Rewind"
                    },
                    {
                      "action": "{\"command\":\"Pause\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Pause",
                      "label": "Pause"
                    },
                    {
                      "action": "{\"command\":\"FastForward\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "FastForward",
                      "label": "Fast Forward"
                    }
                  ]
                },
                {
                  "name": "TransportRecording",
                  "function": [
                    {
                      "action": "{\"command\":\"Record\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Record",
                      "label": "Record"
                    }
                  ]
                },
                {
                  "name": "TransportExtended",
                  "function": [
                    {
                      "action": "{\"command\":\"Slow\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "FrameAdvance",
                      "label": "Frame Advance"
                    },
                    {
                      "action": "{\"command\":\"SkipBack\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "SkipBackward",
                      "label": "Skip Backward"
                    },
                    {
                      "action": "{\"command\":\"SkipForward\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "SkipForward",
                      "label": "Skip Forward"
                    }
                  ]
                },
                {
                  "name": "NavigationDVD",
                  "function": [
                    {
                      "action": "{\"command\":\"Menu\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Menu",
                      "label": "Menu"
                    },
                    {
                      "action": "{\"command\":\"Subtitle\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Subtitle",
                      "label": "Subtitle"
                    },
                    {
                      "action": "{\"command\":\"Audio\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Audio",
                      "label": "Audio"
                    },
                    {
                      "action": "{\"command\":\"Back\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Back",
                      "label": "Back"
                    }
                  ]
                },
                {
                  "name": "Program",
                  "function": [
                    {
                      "action": "{\"command\":\"Bookmark\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Bookmark",
                      "label": "Bookmark"
                    }
                  ]
                },
                {
                  "name": "Teletext",
                  "function": [
                    {
                      "action": "{\"command\":\"Teletext\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Teletext",
                      "label": "Teletext"
                    }
                  ]
                },
                {
                  "name": "NavigationDSTB",
                  "function": [
                    {
                      "action": "{\"command\":\"List\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "List",
                      "label": "List"
                    }
                  ]
                },
                {
                  "name": "Setup",
                  "function": [
                    {
                      "action": "{\"command\":\"Sleep\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Sleep",
                      "label": "Sleep"
                    }
                  ]
                },
                {
                  "name": "ColoredButtons",
                  "function": [
                    {
                      "action": "{\"command\":\"Green\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Green",
                      "label": "Green"
                    },
                    {
                      "action": "{\"command\":\"Red\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Red",
                      "label": "Red"
                    },
                    {
                      "action": "{\"command\":\"Blue\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Blue",
                      "label": "Blue"
                    },
                    {
                      "action": "{\"command\":\"Yellow\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Yellow",
                      "label": "Yellow"
                    }
                  ]
                },
                {
                  "name": "NavigationExtended",
                  "function": [
                    {
                      "action": "{\"command\":\"Guide\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Guide",
                      "label": "Guide"
                    },
                    {
                      "action": "{\"command\":\"Info\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Info",
                      "label": "Info"
                    },
                    {
                      "action": "{\"command\":\"PageDown\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "PageDown",
                      "label": "Page Down"
                    },
                    {
                      "action": "{\"command\":\"PageUp\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "PageUp",
                      "label": "Page Up"
                    },
                    {
                      "action": "{\"command\":\"Exit\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Exit",
                      "label": "Exit"
                    }
                  ]
                },
                {
                  "name": "DisplayMode",
                  "function": [
                    {
                      "action": "{\"command\":\"Wide\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Aspect",
                      "label": "Aspect"
                    }
                  ]
                },
                {
                  "name": "Miscellaneous",
                  "function": [
                    {
                      "action": "{\"command\":\"BookmarkList\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "BookmarkList",
                      "label": "BookmarkList"
                    },
                    {
                      "action": "{\"command\":\"Media\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Media",
                      "label": "Media"
                    },
                    {
                      "action": "{\"command\":\"Opt+\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Opt+",
                      "label": "Opt+"
                    },
                    {
                      "action": "{\"command\":\"Schedule\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Schedule",
                      "label": "Schedule"
                    },
                    {
                      "action": "{\"command\":\"Source\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "Source",
                      "label": "Source"
                    },
                    {
                      "action": "{\"command\":\"TvRadio\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "TvRadio",
                      "label": "TvRadio"
                    },
                    {
                      "action": "{\"command\":\"VFormat\",\"type\":\"IRCommand\",\"deviceId\":\"56827429\"}",
                      "name": "VFormat",
                      "label": "VFormat"
                    }
                  ]
                }
              ],
              "model": "Foxsat-HDR",
              "IsKeyboardAssociated": false,
              "DongleRFID": 0,
              "id": "56827429",
              "type": "PVR",
              "suggestedDisplay": "DEFAULT",
              "Transport": 1
            }
            ]
        }
    }
]]

local ds = json.decode(jstring)
local deviceListString = ""
for k, d in pairs(ds.data.device) do
    deviceListString = deviceListString..d.id.." - "..d.label..string.char(10)..string.char(13)

    for i,cg in pairs(d.controlGroup) do
        for x, action in pairs(cg["function"]) do
            --print(utils.stringify_table(action))
            print([[{"deviceId":"]]..d.id..[[","command":"]]..action.name..[[","action":"press"}]])
        end
    end
end
print(deviceListString)