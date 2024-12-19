local settingManager = {
    ---@package
    data = {}
}

local FILENAME = "settings.json"

umg.definePacket("lootplot.main:syncSetting", {typelist = {"string", "string"}})

local function saveSetting()
    assert(server)
    local save = server.getSaveFilesystem()
    assert(save:write(FILENAME, json.encode(settingManager.data)))
end

if client then
    client.on("lootplot.main:syncSetting", function(name, encVal)
        settingManager.data[name] = json.decode(encVal)
    end)
else
    server.on("lootplot.main:syncSetting", function (clientId, name, encVal)
        if server.getHostClient() == clientId then
            settingManager.data[name] = json.decode(encVal)
            saveSetting()
        end
    end)
end

if server then
    umg.on("@load", function()
        local save = server.getSaveFilesystem()
        local loadedData = save:read(FILENAME)

        if loadedData then
            local success, vals = pcall(json.decode, loadedData)

            if success then
                for k in pairs(settingManager.data) do
                    if vals[k] ~= nil then
                        settingManager.data[k] = vals[k]
                    end
                end
            else
                umg.log.error("Cannot load setting data: "..vals)
            end
        end
    end)

    umg.on("@playerJoin", function(clientId)
        for k, v in pairs(settingManager.data) do
            server.unicast(clientId, "lootplot.main:syncSetting", k, json.encode(v))
        end
    end)
end

---@generic T
---@param name string
---@param defval T
---@return fun():T
---@return fun(value:T)
local function defineSetting(name, defval)
    settingManager.data[name] = defval

    local function getter()
        return settingManager.data[name]
    end

    local function setter(value)
        if client then
            client.send("lootplot.main:syncSetting", name, json.encode(value))
        end

        settingManager.data[name] = value

        if server then
            saveSetting()
            server.broadcast("lootplot.main:syncSetting", name, json.encode(value))
        end
    end

    return getter, setter
end

settingManager.getSpeedFactor, settingManager.setSpeedFactor = defineSetting("SPEED_FACTOR", 0)
settingManager.getLastSelectedBackground, settingManager.setLastSelectedBackground = defineSetting("BACKGROUND", "")

return settingManager
