
--[[

base Context skeleton.

(Provides a "skeleton" of methods to be implemented.
Think of this as a base-class.)


]]

local Context = objects.Class("lootplot:Game")


function Context:init()
    -- initialize stuff here
end


function Context:start()
    error("should be overidden.")    
end


function Context:playerJoin(clientId)
    local p =server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end


--[[
    in this family of functions, `ent` is the entity that we are obtaining
    the points/money for.
    (`ent` will (usually) be a slot or an item.)

    NOTE: `ent` doesn't neccessarily "own" the money; we are just using `ent`
    to access the *container* for whereever the money is actually stored.

    Why...???
    Well, if we added multiplayer, and players owned different items,
    and had different wallets,
    then we would override `:setMoney()`, `:getMoney()` to account for this.
    
    (Likewise, if we want each player to have their own point-count,
        then we could override `:getPoints()`, `:setPoints()`)
]]
function Context:setPoints(ent, x)
    -- sets points for `ent`s context
end
function Context:getPoints(ent)
    -- gets points for `ent`s context
end

function Context:setMoney(ent, x)
    -- gets money for `ent`s context
end
function Context:getMoney(ent)
    return self.money
end



return Context
