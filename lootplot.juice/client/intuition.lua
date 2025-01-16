

local RENDER_BEFORE_ENTITY_ORDER = -1
local RENDER_AFTER_ENTITY_ORDER = 1

local BOB_SPEED = 6

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x,y, rot, sx,sy)
    if ent.doomCount then
        local q, dy
        if lp.isSlotEntity(ent) then
            dy = 0
            if ent.doomCount <= 1 then
                q = client.assets.images.doom_slot_visual_1
            elseif ent.doomCount <= 3 then
                q = client.assets.images.doom_slot_visual_3
            else
                q = client.assets.images.doom_slot_visual_small
            end
        elseif lp.isItemEntity(ent) then
            dy = 2 * math.sin(love.timer.getTime() * BOB_SPEED)
            if ent.doomCount <= 1 then
                q = client.assets.images.doom_count_visual
            else
                q = client.assets.images.doom_count_warning_visual
            end
        end

        if q then
            rendering.drawImage(q, x, y+dy, rot, sx,sy)
        end
    end
end)



umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.01, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isItemEntity(ent) then
        if ent.stuck or ent.sticky then
            local opacity = 1
            local t = love.timer.getTime() * 8
            if not ent.stuck then
                -- then, blink the visual over time,
                -- to indicate that its not stuck YET.
                opacity = (math.sin(t) + 1)/2
            end
            local img = client.assets.images.sticky_item_visual_final
            local ox, oy = 8, math.sin(t/2)
            love.graphics.push("all")
            love.graphics.setColor(1,1,1,opacity)
            rendering.drawImage(img, x + ox, y + oy)
            love.graphics.pop()
        end
    else
        if ent.stickySlot then
            -- local img = client.assets.images.sticky_slot_visual
            local img = client.assets.images.sticky_slot_visual_final
            rendering.drawImage(img, x, y, rot, sx,sy,kx,ky)
        end
    end
end)




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.5, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.lives and ent.lives > 0 then
        if lp.isItemEntity(ent) then
            local t = love.timer.getTime()
            local ox, oy = 6, 6 + math.sin(t)
            local img = client.assets.images.life_visual
            rendering.drawImage(img, x + ox, y + oy, rot, sx,sy, kx,ky)
        elseif lp.isSlotEntity(ent) then
            local img = client.assets.images.slot_life_visual
            rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
        end
    end
end)



umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.1, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isSlotEntity(ent) then
        if ent.manaCount and ent.manaCount > 0 and lp.isSlotEntity(ent) then
            local index = math.clamp(math.floor(ent.manaCount), 1, 4)
            local img = client.assets.images["slot_mana_charge_" .. index]
            rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
        end
        if (ent.multGenerated) and ent.multGenerated > 0.05 then
            local img = "slot_multiplier_visual"
            rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
        end
    end
end)




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.5, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isItemEntity(ent) then
        if ent.grubMoneyCap then
            local dy = 1 * math.sin(love.timer.getTime() * BOB_SPEED)
            local img = client.assets.images.money_limit_visual
            rendering.drawImage(img, x, y+dy, rot, sx,sy, kx,ky)
        elseif ent.moneyGenerated and ent.moneyGenerated < 0 then
            local dy = 1 * math.sin(love.timer.getTime() * BOB_SPEED)
            local img = client.assets.images.money_cost_visual
            rendering.drawImage(img, x, y+dy, rot, sx,sy, kx,ky)
        end
    end
end)






local WING_FLAG_SPEED = 3

local WING_ROT_OFFSET = -0.4
local WING_ROTATION = math.pi / 2

umg.on("rendering:drawEntity", RENDER_BEFORE_ENTITY_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isItemEntity(ent) and lp.canItemFloat(ent) then
        love.graphics.push("all")
        local wing = client.assets.images.floating_item_wing_visual
        local t = love.timer.getTime() * WING_FLAG_SPEED + (ent.id / 3)
        local dy = 5 * math.sin(t + 0.5)
        local r = WING_ROTATION * ((math.sin(t) + 1)/2) + WING_ROT_OFFSET
        local offset = 10
        if ent.imageShadow then
            local o = ent.imageShadow.offset
            love.graphics.setColor(0,0,0, 0.4)
            rendering.drawImage(wing, x + offset + o, y + dy + o, r, sx,sy, kx,ky)
            rendering.drawImage(wing, x - offset - o, y + dy + o, -r, sx*-1,sy, kx,ky)
        end

        love.graphics.setColor(1,1,1)
        rendering.drawImage(wing, x + offset, y + dy, r, sx,sy, kx,ky)
        rendering.drawImage(wing, x - offset, y + dy, -r, sx*-1,sy, kx,ky)

        love.graphics.pop()
    end
end)


local SPIN_SPEED = 3

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    if lp.isItemEntity(ent) then
        if ent.repeatActivations then
            love.graphics.setColor(1,1,1)
            local t = (love.timer.getTime() * SPIN_SPEED)
            local AMPL = 8
            local dx, dy
            local img = client.assets.images.item_repeater_visual

            dx, dy = AMPL * math.sin(t), AMPL * math.cos(t)
            rendering.drawImage(img, x+dx, y+dy, rot, sx,sy, kx,ky)

            local off = math.pi
            dx, dy = AMPL * math.sin(t + off), AMPL * math.cos(t + off)
            rendering.drawImage(img, x+dx, y+dy, rot, sx,sy, kx,ky)
        end

        if ent.manaCost and ent.manaCost > 0 then
            local img = client.assets.images.mana_cost_item_visual
            local dy = 2 * math.sin(love.timer.getTime() * BOB_SPEED + math.pi)
            rendering.drawImage(img, x + 6, y - 5 + dy, 0, sx,sy)
        end
    end
end)




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 1, function(ent, x,y, rot, sx,sy, kx,ky)
    if not lp.isSlotEntity(ent) then
        return
    end
    local pgen = ent.pointsGenerated
    if pgen and pgen ~= 0 and lp.isSlotEntity(ent) then
        local img
        if pgen > 0 then
            img = "point_up_slot_visual"
        else
            img = "point_down_slot_visual"
        end
        rendering.drawImage(img, x,y,rot,sx,sy,kx,ky)
    end
    local moneyEarn = ent.moneyGenerated
    if moneyEarn and math.abs(moneyEarn) > 0.1 then
        if not ent.buttonSlot then
            -- KINDA HACKY:
            -- button-slots will generally have a COST text on them;
            -- so we explicitly skip them.
            rendering.drawImage("gold_strip_slot_visual", x,y,rot,sx,sy,kx,ky)
        end
    end
end)



local RENDER_ON_TOP_ORDER = 20

local PI2=math.pi*2

umg.on("rendering:drawEntity", RENDER_ON_TOP_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    local BOUNCE_SPEED = 2
    if lp.isItemEntity(ent) then
        local sel = lp.getCurrentSelection()
        if sel and sel.item then
            if ent ~= sel.item and lp.canCombineItems(sel.item, ent) then
                love.graphics.setColor(lp.COLORS.COMBINE_COLOR)
                local time = love.timer.getTime() * BOUNCE_SPEED
                local sc = 1 + math.sin(time*PI2)/12
                rendering.drawImage("combine_item_visual", x,y, rot, sc,sc)
            end
        end
    end
end)


