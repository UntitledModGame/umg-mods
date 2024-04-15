
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

local function resetFields(self)
    -- reset points:
    self.round = 0
    self.points = 0
    -- TODO: Some visual-update should be done here, 
    -- to the loot-monster maybe?
    self.level = self.level + 1
    self.requiredPoints = 0
    self:syncAll()
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

    self.round = self.round + 1
    
    umg.call("lootplot.main:finishRound")

    if ws.get("points") > ws.get("requiredPoints") then
        -- win condition!!
        nextLevel(self)
    end
    if self.round >= lp.main.constants.ROUNDS_PER_LEVEL then
        -- lose!
        lose(self)
    end
end

-- Just trust the client :shrug:
server.on("lootplot.main:nextRound", nextRound)

else

function requestNextRound()
    client.send("lootplot.main:nextRound")
end

end



