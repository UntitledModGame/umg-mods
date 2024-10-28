
local util = require("shared.util")

--[[



OK:::
This is a very hard problem to do efficiently.
We have a few different options, tho:


OPTION-ALFA:
For All ents that are being listened to, 
keep a list of ents that are currently listening to them.
- BIG DOWNSIDE: What happens when a listener STOPS targeting them?
There's no way for us to know, and we get outdated state! argh!



OPTION-BRAVO:
All listen-ents keep a SET of all entities that they are currently
listening to.

Then, we ALSO keep a hash of all listen-entities that are on the plot,
keyed by trigger:
{
    [triggerType] -> Set{ lisEnt1, lisEnt2, ... }
}
Then, when something `triggers`, we iterate over `lisEnt1,lisEnt2,...`
and check if they contain the entity that was triggered.

This is not particularly efficient, but it's robust, 
and it will get us 99% of the way there.
It's also only O(n), (and its a weak O(n) for that matter too)



OKAY:
FINAL DECISION:  OPTION-BRAVO.
Its efficient enough, and more importantly, its robust.

]]


local triggerToListenEnt = {--[[
    [trigger] -> Set<Entity>
]]}


local listenEntToListenedEnts = {--[[
    [listenEnt] -> Set<target-Ent>
]]}



local listenGroup = umg.group("shape", "listen")

listenGroup:onAdded(function(ent)
    local trigger = assert(ent.listen.trigger, "Listen ents need a trigger!")
    triggerToListenEnt[trigger] = triggerToListenEnt[trigger] or objects.Set()
    triggerToListenEnt[trigger]:add(ent)
end)

listenGroup:onRemoved(function(ent)
    local trigger = assert(ent.listen.trigger, "Listen ents need a trigger!")
    triggerToListenEnt[trigger] = triggerToListenEnt[trigger] or objects.Set()
    triggerToListenEnt[trigger]:remove(ent)

    listenEntToListenedEnts[ent] = nil
end)





local function updateListenTargets(ent)
    ---@cast ent lootplot.ItemEntity
    local ppos = lp.getPos(ent)
    if not ppos then
        return -- its not inside a plot!
    end

    local pposLis = lp.targets.getShapePositions(ent)
    if not pposLis then
        umg.log.fatal("Couldn't listen, had no shape-positions ", ent)
        return
    end
    local set = listenEntToListenedEnts[ent]
    if not set then
        set = objects.Set()
        listenEntToListenedEnts[ent] = set
    end

    -- this is kinda inefficient, clearing the set each frame...
    -- but its WAYYY better than the alternative.
    set:clear()

    for _, ppos in ipairs(pposLis) do
        local targItem = lp.posToItem(ppos)
        if targItem and util.canListen(ent, ppos) then
            set:add(targItem)
        end
    end
end


umg.on("@tick", function()
    for _, ent in ipairs(listenGroup) do
        updateListenTargets(ent)
    end
end)



local function triggerEntity(listenerEnt, entThatWasTriggered)
    --[[
    it would be AMAZING if we could delay the listener-action here...
    but its not really possible, because we can't guarantee that
    `entThatWasTriggered` will still be alive.
    
    For example: 
    for `DESTROY` trigger:  the ent is deleted before the trigger runs.
    for `REROLL` trigger shop-item: the ent is deleted before the trigger runs.

    Theres really no "good" solution to this.
    So, we just activate immediately :/
    ]]
    local canActivate = lp.canActivateEntity(listenerEnt)
    if canActivate then
        local ppos = lp.getPos(entThatWasTriggered)
        if ppos and util.canListen(listenerEnt, ppos) then
            lp.tryActivateEntity(listenerEnt)
            local listen = listenerEnt.listen
            if listen.activate then
                listen.activate(listenerEnt, ppos, entThatWasTriggered)
            end
        end
    end
end

local EMPTY_SET = objects.Set()

local function triggerListen(trigger, ent)
    local set = triggerToListenEnt[trigger] or EMPTY_SET
    for _, listenEnt in ipairs(set) do
        local listenEntities = listenEntToListenedEnts[listenEnt] or EMPTY_SET
        if listenEntities:contains(ent) then
            -- triggered!!!
            triggerEntity(listenEnt, ent)
        end
    end
end


umg.on("lootplot:entityTriggerFailed", triggerListen)
umg.on("lootplot:entityTriggered", triggerListen)

