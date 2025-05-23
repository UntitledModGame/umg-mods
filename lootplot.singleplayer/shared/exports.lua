
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
        lp.initialize(
            currentRun:getAttributeSetters(), currentRun:getSingleplayerArgs()
        )
    else
        umg.log.fatal("FATAL::: Duplicate lootplot.singleplayer context created!!")
    end
end)

---Availability: Client and Server
---@return lootplot.singleplayer.Run|nil
function singleplayer.getRun()
    -- assert(currentRun, "Not ready yet! (Check using lp.singleplayer.isReady() )")
    return currentRun
end




umg.definePacket("lootplot.singleplayer:setHUDEnabled", {
    typelist = {"boolean"}
})


local hudEnabled = true

---@param isEnabled boolean
function singleplayer.setHUDEnabled(isEnabled)
    if server then
        server.broadcast("lootplot.singleplayer:setHUDEnabled", isEnabled)
    end
    hudEnabled = isEnabled
end

function singleplayer.isHUDEnabled()
    return hudEnabled
end

if client then
client.on("lootplot.singleplayer:setHUDEnabled", function (isEnabled)
    hudEnabled = isEnabled
end)
end





umg.definePacket("lootplot.singleplayer:skipPipeline", {typelist = {}})

function singleplayer.clearPipeline()
    if client then
        client.send("lootplot.singleplayer:skipPipeline")
    elseif server then
        local run = lp.singleplayer.getRun()
        local plot = run and run:getPlot()
        if plot then
            plot:clearPipeline()
        else
            umg.log.error("HUH???? No Run object!")
        end
    end
end

if server then
server.on("lootplot.singleplayer:skipPipeline", function(clientId)
    singleplayer.clearPipeline()
end)
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
