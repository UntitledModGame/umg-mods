
local loc = localization.localize


---@param plot lootplot.Plot
---@param ppos lootplot.PPos
---@param team string
---@param radius integer
local function circularFogClear(plot, ppos, team, radius)
    local rsq = radius * radius

    for y = -radius, radius do
        for x = -radius, radius do
            local newPPos = ppos:move(x, y)

            if newPPos then
                local sq = x * x + y * y
                if sq <= rsq then
                    plot:setFogRevealed(newPPos, team, true)
                end
            end
        end
    end
end


--[[

An item that spawns all the stuff 
for the default gamemode.


]]
lp.defineItem("lootplot.main:doom_egg", {
    doomCount = 1,
    image = "doom_egg",
    name = loc("Doom Egg"),
    activateDescription = loc("Spawns the Doom Clock."),

    canItemFloat = true,

    rarity = lp.rarities.UNIQUE,

    onActivateOnce = function(ent)
        local plot = lp.getPos(ent):getPlot()
        local team = assert(ent.lootplotTeam)
        local ppos = assert(lp.getPos(ent))

        local dclock = server.entities.doom_clock()
        dclock._plotX, dclock._plotY = ppos:getCoords()
        plot:set(dclock._plotX, dclock._plotY, dclock)
        local ppos = plot:getPPos(dclock._plotX, dclock._plotY)
        local dvec = ppos:getWorldPos()
        dclock.x = dvec.x
        dclock.y = dvec.y
        dclock.dimension = dvec.dimension

        -- Clear fog around doom clock
        circularFogClear(plot, ppos, team, 3)

        -- Meta-buttons
        lp.forceSpawnSlot(
            assert(ppos:move(-4,0)),
            server.entities.pulse_button_slot,
            team
        )
        lp.forceSpawnSlot(
            assert(ppos:move(-3,0)),
            server.entities.next_level_button_slot,
            team
        )
    end
})

