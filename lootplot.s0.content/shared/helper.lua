
local helper = {}




local function hasRerollTrigger(ent)
    for _,t in ipairs(ent.triggers)do
        if t == "REROLL" then
            return true
        end
    end
    return false
end


local function shouldReroll(ppos)
    local slot = lp.posToSlot(ppos)
    if slot and hasRerollTrigger(slot) then
        return true
    end
    local item = lp.posToItem(ppos)
    if item and hasRerollTrigger(item) then
        return true
    end
end


function helper.rerollPlot(plot)
    lp.Bufferer()
        :all(plot)
        :filter(shouldReroll)
        :withDelay(0.05)
        :to("SLOT_OR_ITEM")
        :execute(function(ppos, ent)
            lp.resetCombo(ent)
            lp.tryTriggerEntity("REROLL", ent)
        end)
end


local loc = localization.localize

local PROP_DISPLAY_NAMES = {
    pointsGenerated = loc("Points-Generated"),
    moneyGenerated = loc("Money-Earned"),
    price = loc("Price"),
    maxActivations = loc("Max-Activations"),
}

local PROP_UPGRADE_DESC = localization.newInterpolator("Increases %{prop} by %{val}")


local propertyUpgradeTc = typecheck.assert("string", "number", "number?")
---@param prop string
---@param startValue number
---@param growthRate? number
---@return table
function helper.propertyUpgrade(prop, startValue, growthRate)
    --[[
    propertyUpgrade("pointsGenerated", 2, 5)
    tier-1: 2x(5^0) = 2
    tier-2: 2x(5^1) = 10
    tier-3: 2x(5^2) = 50
    tier-4: 2x(5^3) = 250
    ]]
    propertyUpgradeTc(prop, startValue, growthRate)
    growthRate = growthRate or 3
    local baseProp = assert(properties.getBase(prop))

    local tierUpgrade = {
        upgrade = function(ent, _srcEnt, oldTier, newTier)
            local exponent = newTier - 1
            local newVal = startValue * (growthRate ^ exponent)
            newVal = math.floor(newVal + 0.5)
            ent[baseProp] = newVal
            -- we dont need to sync `baseProp`; coz the property 
            --  is computed serverside only, and sent over to client anyway.
        end,
        description = function(ent)
            return PROP_UPGRADE_DESC({
                prop = PROP_DISPLAY_NAMES[prop],
                val = (ent[baseProp] * (growthRate-1))
            })
        end
    }
    return tierUpgrade
end



local POINT_MULT_UPGR_DESC = localization.newInterpolator("Gives a %{mult} multiplier to Points-Generated")

---@param mult number
---@return table
function helper.pointsMultUpgrade(mult)
    assert(mult,"?")
    local tierUpgrade = {
        upgrade = function(ent, _srcEnt, oldTier, newTier)
        end,
        description = POINT_MULT_UPGR_DESC({
            mult = mult
        })
    }
    return tierUpgrade
end





local TEXT_MAX_WIDTH = 200
---@param text string
---@param x number
---@param y number
---@param rot number
---@param sx number
---@param sy number
---@param oy number
---@param kx number
---@param ky number
local function printCenterWithOutline(text, x, y, rot, sx, sy, oy, kx, ky)
    local r, g, b, a = love.graphics.getColor()
    local ox = TEXT_MAX_WIDTH / 2
    love.graphics.setColor(0, 0, 0, a)
    for outY = -1, 1 do
        for outX = -1, 1 do
            if not (outX == 0 and outY == 0) then
                love.graphics.printf(text, x + outX * sx, y + outY * sy, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
            end
        end
    end
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, x, y, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
end



local NICE_GREEN = objects.Color(49/255,189/255,32/255)

local function drawDelayItemNumber(ent, delayCount)
    local totActivs = (ent.totalActivationCount or 0)
    local remaining = delayCount - totActivs
    if totActivs > 0 then
        local txt,color
        local dx,dy=0,3
        if remaining <= 1 then
            txt = "[!]"
            color = NICE_GREEN
            local t = (love.timer.getTime() * 10)
            dx = 2 * math.sin(t)
        else
            txt = tostring(remaining)
            color = lp.COLORS.INFO_COLOR
        end
        love.graphics.push("all")
        love.graphics.setColor(color)
        printCenterWithOutline(txt, ent.x + dx, ent.y + dy, 0, 1,1, 20, 0, 0)
        love.graphics.pop()
    end
end



local DELAY_DESC = localization.newInterpolator("After {lootplot:INFO_COLOR}%{count} activations{/lootplot:INFO_COLOR}: %{delayDescription}")

function helper.defineDelayItem(id, name, etype)
    typecheck.assertKeys(etype, {
        "delayCount", "delayDescription", "delayAction"
    })
    local delayCount = etype.delayCount
    local delayDescription = loc(etype.delayDescription)
    local func = etype.delayAction

    -- dont want to pollute the etype with random shcomps for ergonomic reasons!
    etype.delayCount = nil
    etype.delayAction = nil
    etype.delayDescription = nil

    local itemType = {
        image = id,
        name = loc(name),

        description = function(ent)
            return DELAY_DESC({
                count = delayCount - (ent.totalActivationCount or 0),
                delayDescription = delayDescription
            })
        end,

        onActivate = function(ent)
            if (ent.totalActivationCount or 0) > (delayCount-1) then
                func(ent)
            end
        end,

        onDraw = function(ent)
            drawDelayItemNumber(ent, delayCount)
        end
    }

    for k,v in pairs(etype) do
        itemType[k] = v
    end
    lp.defineItem("lootplot.s0.content:"..id, itemType)
end



local TRANSFORM_ACTION_DESC = localization.newInterpolator("Turn into a {lootplot:INFO_COLOR}%{transformName}")

---@param id string
---@param name string
---@param etype table
function helper.defineTransformItem(id, name, etype)
    typecheck.assertKeys(etype, {
        "delayCount", "transformId", "transformName"
    })

    local tname = loc(etype.transformName)
    local transId = etype.transformId
    local transformFunc = etype.transformFunc
    local delayCount = etype.delayCount
    -- clear shcomps so (they dont exist within entity-type)
    etype.transformId = nil
    etype.transformName = nil
    etype.transformFunc = nil

    local function transform(ent)
        local ppos = lp.getPos(ent)
        local transEType = server.entities[transId]
        assert(transEType,"?")
        if ppos and transEType then
            local itemEnt = lp.forceSpawnItem(ppos, transEType, ent.lootplotTeam)
            if itemEnt then
                transformFunc(itemEnt)
            end
        end
    end

    etype.delayAction = transform
    etype.delayCount = delayCount
    etype.delayDescription = TRANSFORM_ACTION_DESC({
        transformName = tname
    })
    helper.defineDelayItem(id, name, etype)
end






return helper
