
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
        targetActivationDescription = loc(trigger.." target."),
        targetActivate = function(selfEnt, ppos, targetEnt)
            return lp.tryTriggerEntity(trigger, targetEnt)
        end
    })
end

defineCap("cap_red", "Red Cap", "PULSE")
defineCap("cap_green", "Green Cap", "REROLL")

lp.defineItem("lootplot.content.s0:cap_purple", {
    image = "cap_purple",
    name = loc("Purple Cap"),
    description = loc("When sold/destroyed, transform into random item."),
    triggers = {"DESTROY"},

    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos then
            local etype = server.entities[lp.ITEM_GENERATOR:query()]
            if etype then
                lp.forceSpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    end
})
