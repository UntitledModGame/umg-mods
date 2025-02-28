
--[[
    lootplot.singleplayer does not do any global exports;
        but rather, exports a `main` table to the existing `lp` namespace.
]]

-- selene: allow(incorrect_standard_library_use)
assert(not lp.singleplayer, "invalid mod setup")
---@class lootplot.singleplayer
local singleplayer = {}

singleplayer.PLAYER_TEAM = "@player" -- Player team


local currentRun = nil

local lpWorldGroup = umg.group("lootplotMainRun")
lpWorldGroup:onAdded(function(ent)
    --[[
    TODO: this whole code feels hacky and weirdddd
    ]]
    if not currentRun then
        currentRun = ent.lootplotMainRun
        lp.initialize(currentRun:getAttributeSetters())
    else
        umg.log.fatal("WARNING::: Duplicate lootplot.singleplayer context created!!")
    end
end)

---Availability: Client and Server
---@return lootplot.singleplayer.Run|nil
function singleplayer.getRun()
    -- assert(currentRun, "Not ready yet! (Check using lp.singleplayer.isReady() )")
    return currentRun
end




if server then

---@param isWin boolean
function singleplayer.endGame(isWin)
    local run = assert(lp.singleplayer.getRun())

    umg.analytics.collect("lootplot.singleplayer:endGame", {
        win = not not isWin,
        runMeta = run:getMetadata()
    })

    umg.call("lootplot.singleplayer:endGame", isWin)
end

end



---Availability: Client and Server
singleplayer.constants = setmetatable({
    --[[
        feel free to override any of these.
        Access via `lootplot.singleplayer.constants`
    ]] 
    WORLD_PLOT_SIZE = {60, 40},
},{__index=function(msg,k,v) error("undefined const: " .. tostring(k)) end})

---Availability: Client and Server
lp.singleplayer = singleplayer
