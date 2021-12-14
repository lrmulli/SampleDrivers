local harmonyCommandJson = [[{
    "id": "universevoice35900.harmonycommand3",
    "version": 1,
    "status": "proposed",
    "name": "harmonycommand3",
    "ephemeral": false,
    "attributes": {
        "harmonyCommand": {
            "schema": {
                "type": "object",
                "properties": {
                    "value": {
                        "type": "string"
                    }
                },
                "additionalProperties": false,
                "required": [
                    "value"
                ]
            },
            "setter": "setHarmonyCommand",
            "enumCommands": []
        }
    },
    "commands": {
        "setHarmonyCommand": {
            "name": "setHarmonyCommand",
            "arguments": [
                {
                    "name": "value",
                    "optional": false,
                    "schema": {
                        "type": "string"
                    }
                }
            ]
        }
    }
  }]]
  local devicelistJson = [[{
    "id": "universevoice35900.devicelist",
    "version": 1,
    "status": "proposed",
    "name": "devicelist",
    "ephemeral": false,
    "attributes": {
        "devicelist": {
            "schema": {
                "type": "object",
                "properties": {
                    "value": {
                        "type": "string"
                    }
                },
                "additionalProperties": false,
                "required": [
                    "value"
                ]
            },
            "enumCommands": []
        }
    },
    "commands": {}
}]]
  return {
	harmonyCommandJson = harmonyCommandJson,
    devicelistJson = devicelistJson
}