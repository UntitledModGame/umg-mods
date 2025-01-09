local loc = localization.localize

local NONE_TEXT = loc"{lootplot:BAD_COLOR}{wavy amp=0.5 k=0.5}{outline}None!"


return lp.defineSlot("lootplot.s0.content:item_pulse_button_slot", {

    name = loc("Item Pulse button"),
    activateDescription = loc("Click to trigger {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} on the above item!"),

    baseMaxActivations = 3,

    onDraw = function(ent, x, y, rot, sx,sy)
        local font = love.graphics.getFont()
        local limit = 0xffff

        local activs = (ent.activationCount or 0)
        local maxAct = (ent.maxActivations or 0)
        local remaining = maxAct - activs
        if remaining > 0 then
            text.printRichCentered("{c r=0.3 g=1 b=0.2}{wavy amp=0.5 k=0.5}{outline}" .. tostring(remaining) .. "/" .. tostring(maxAct), font, x, y - 16, limit, "left", rot, sx,sy)
        else
            text.printRichCentered(NONE_TEXT, font, x, y - 16, limit, "left", rot, sx,sy)
        end
    end,

    image = "item_pulse_button_up",
    activateAnimation = {
        activate = "item_pulse_button_hold",
        idle = "item_pulse_button_up",
        duration = 0.1
    },

    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local up = ppos and ppos:move(0, -1)
        if up then
            local itemEnt = lp.posToItem(up)
            if itemEnt then
                lp.tryTriggerEntity("PULSE", itemEnt)
            end
        end
    end,
})
