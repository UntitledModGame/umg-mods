

local RENDER_BEFORE_ENTITY_ORDER = -1
local RENDER_AFTER_ENTITY_ORDER = 1

local BOB_SPEED = 6

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x,y, rot, sx,sy)
    if ent.doomCount then
        local q, dy
        if lp.isSlotEntity(ent) then
            dy = 0
            if ent.doomCount <= 1 then
                q = client.assets.images.crack_big
            else
                q = client.assets.images.crack_small
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




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.5, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.lives and ent.lives > 0 then
        local ox, oy = 0, 0
        if lp.isItemEntity(ent) then
            ox, oy = 6, 6
            local img = client.assets.images.life_visual
            rendering.drawImage(img, x + ox, y + oy, rot, sx,sy, kx,ky)
        elseif lp.isSlotEntity(ent) then
            local img = client.assets.images.slot_life_visual
            rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
        end
    end
end)



umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.1, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.manaCount and ent.manaCount > 0 and lp.isSlotEntity(ent) then
        local img = client.assets.images.slot_mana_count_visual
        rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
    end
end)




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.5, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.grubMoneyCap then
        if lp.isItemEntity(ent) then
            local dy = 1 * math.sin(love.timer.getTime() * BOB_SPEED)
            local img = client.assets.images.grub_visual
            rendering.drawImage(img, x, y+dy, rot, sx,sy, kx,ky)
        elseif lp.isSlotEntity(ent) then
            -- TODO: Grubby-visual for slots!
            -- local img = client.assets.images.slot_life_visual
            -- rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
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


local SPIN_SPEED = 5

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.repeatActivations and lp.isItemEntity(ent) then
        love.graphics.setColor(1,1,1)
        local dx = 3
        local flipx = math.sin(love.timer.getTime() * SPIN_SPEED)
        local dy = -6 + 1*math.sin(love.timer.getTime() * BOB_SPEED)
        local img = client.assets.images.ruby_repeater_visual
        rendering.drawImage(img, x+dx, y+dy, rot , sx*flipx,sy, kx,ky)
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
    if moneyEarn and moneyEarn > 0 then
        rendering.drawImage("gold_strip_slot_visual", x,y,rot,sx,sy,kx,ky)
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


