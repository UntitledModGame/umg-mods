
--[[

roundService.

Handles progression between rounds, 
and *kinda* acts like a game-state-y object.

]]


local ws = require("shared.worldService")



umg.definePacket("lootplot.main:nextRound", {
    typelist = {}
})

if server then

local function nextLevel()
    -- reset points:
    ws.set("round", 0)
    ws.set("points", 0)
    -- TODO: Some visual-update should be done here, 
    -- to the loot-monster maybe?
    ws.set("level", ws.get("level") + 1)
    ws.set("requiredPoints", 0)
end


local function lose()
    -- todo; prolly need to send some message to client-side,
    -- and make the client open up some widget or something displaying:
    -- "YOU LOST".
end


local function nextRound()
    -- Progresses to next round.
    assert(server,"wot wot")

    umg.call("lootplot.main:startRound")

    -- activate all slots:
    lp.Bufferer()
        :all()
        :slots() -- ppos-->slot
        :execute(function(slotEnt)
            lp.activate(slotEnt)
        end)

    -- TODO: Give reward-money at end of round

    local round1 = ws.get("round") + 1
    ws.set("round", round1)
    
    umg.call("lootplot.main:finishRound")

    if ws.get("points") > ws.get("requiredPoints") then
        -- win condition!!
        nextLevel()
    end
    if round1 >= lp.main.constants.ROUNDS_PER_LEVEL then
        -- lose!
        lose()
    end
end

-- Just trust the client :shrug:
server.on("lootplot.main:nextRound", nextRound)

else

function requestNextRound()
    client.send("lootplot.main:nextRound")
end

end



