
--[[

Basic game context.


points are shared between all players.
money is shared between all players.

]]

local Game = objects.Class("lootplot:Game")


function Game:init()
    self.money = 0
    self.points = 0
end



--[[
    in this family of functions, `ent` is the entity that we are obtaining
    the points/money for.

    `ent` will (usually) be a slot or an item.

    Why...???
    Well, if we added multiplayer, and players owned different items 
    and had different wallets,
    then we would override `:setMoney()`, `:getMoney()` to account for this.
    
    Likewise, if we want each player to have their own point-count,
    then we could override `:getPoints()`, `:setPoints()`
]]
function Game:setPoints(ent, x)
    self.points = x
end
function Game:getPoints(ent)
    return self.points
end

function Game:setMoney(ent, x)
    self.money = x
end
function Game:getMoney(ent)
    return self.money
end



return Game
