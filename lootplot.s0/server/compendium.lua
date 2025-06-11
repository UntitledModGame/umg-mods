



assert(server,"?")

local compendium = {}



local SEP_PATTERN = "%:"

local function assertNamespaced(nsStr)
    local s,_ = nsStr:find(SEP_PATTERN)
    if not s then
        -- eh this doesnt actually check the mod, but its "good enough"
        umg.melt("string must be namespaced: " .. tostring(nsStr))
    end
end



local COMPENDIUM_FILE = "lootplot.s0.compendium.json"

local compendiumTable = {--[[
    table of flag-values. Keyed by string
    [itemType] -> bool
]]}
local outOfDate = false


local isEnabled = true
-- compendium should be disabled in sandbox mode


if server then
    local dat = server.getSaveFilesystem()
        :read(COMPENDIUM_FILE)
    if dat then
        compendiumTable = json.decode(dat)
    end
end




local function assertServer()
    assert(server, "Can only be called on server-side!")
end



---@param itemId string
---@return boolean
function compendium.isSeen(itemId)
    return compendiumTable[itemId]
end


function compendium.setEnabled(bool)
    isEnabled = false
end




---@param itemId string 
local function setSeen(itemId)
    assertServer()
    assertNamespaced(itemId)

    if compendiumTable[itemId] then
        return false
    end
    compendiumTable[itemId] = true
    local data = json.encode(compendiumTable)
    local fsys = server.getSaveFilesystem()
    local ok, err = fsys:write(COMPENDIUM_FILE, data)
    if not ok then
        umg.log.error("Coudlnt write to compendium: ", itemId, err)
    else
        umg.log.info("wrote to compendium: ", itemId)
    end
end


umg.on("lootplot:entityTriggered", function (triggerName, ent)
    if triggerName == "BUY" and lp.isItemEntity(ent) and isEnabled then
        setSeen(ent:getEntityType():getTypename())
    end
end)


local function trySaveTables()
    if outOfDate then
        local fsys = server.getSaveFilesystem()
        fsys:write(COMPENDIUM_FILE, json.encode(compendiumTable))
        outOfDate = false
    end
end



local NUM_SKIP_TICKS = 50
local ct = 1
umg.on("@tick", function()
    ct = ct + 1
    if ct % NUM_SKIP_TICKS == 0 then
        trySaveTables()
    end
end)





return compendium




