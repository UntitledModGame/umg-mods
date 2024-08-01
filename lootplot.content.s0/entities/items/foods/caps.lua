
--[[

define all caps in here

red_cap, green_cap, purple cap

]]

local loc = localization.localize

local function defineCap(image, name, trigger)
    return lp.defineItem("lootplot.content.s0:"..image, {
        image = image,
        name = loc(name),
        triggers = {"DESTROY"},

        targetType = "SLOT",
        targetShape = lp.targets.PlusShape(2, "ROOK-2"),
        targetActivationDescription = loc("When sold/destroyed, "..trigger.." target."),
        targetActivate = function(selfEnt, ppos, targetEnt)
            return lp.tryTriggerEntity(trigger, targetEnt)
        end
    })
end

defineCap("cap_red", "Red Cap", "PULSE")
defineCap("cap_green", "Green Cap", "REROLL")
local randomizer = lp.ITEM_GENERATOR:createQuery():addAllEntries()

lp.defineItem("lootplot.content.s0:cap_purple", {
    image = "cap_purple",
    name = loc("Purple Cap"),
    description = loc("When sold/destroyed, transform into random item."),
    triggers = {"DESTROY"},

    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos then
            local etype = server.entities[randomizer()]
            if etype then
                lp.forceSpawnItem(ppos, etype)
            end
        end
    end
})
