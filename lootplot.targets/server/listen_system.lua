
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
and im pretty confident that it will get us 99% of the way there.
It's also only O(n), (and its a weak O(n) for that matter too)

]]

local WEAK={__mode="k"}


local function createWeakSet()
    return setmetatable({}, WEAK)
end


---@alias ListenerHash {[Entity]: table<Entity, true>}


---@type table<string, ListenerHash>
local triggerToListenerHash = {--[[
    [TRIGGER] -> {
        [listenedEnt] -> WeakSet{e1, e2, ...}

        -- `listenedEnt` is the ent that is targetted.
        -- e1,e2 are entities with `.listen` component.
    }
]]}




local listenGroup = umg.group("shape", "listen")


---comment
---@param triggerType string
---@param listenItem Entity
---@param triggerItem Entity
local function add(triggerType, listenItem, targItem)
    local lisHash = triggerToListenerHash[triggerType]
    if not lisHash then
        lisHash = createWeakSet()
        triggerToListenerHash[triggerType] = lisHash
    end

    ---@cast lisHash ListenerHash
    local set = lisHash[targItem]
end


local function updateListenEnts(ent)
    ---@cast ent lootplot.ItemEntity
    local pposLis = assert(lp.targets.getShapePositions(ent))
    local listen = ent.listen

    for _, ppos in ipairs(pposLis) do
        local targItem = lp.posToItem(ppos)
        if targItem and util.canListen(ent, ppos) then
            add(listen.trigger, ent, targItem)
        end
    end
end


umg.on("@tick", function()
    for _, ent in ipairs(listenGroup) do
        updateListenEnts(ent)
    end
end)





