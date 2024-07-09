---@class text.Effect: objects.Class
local Effect = objects.Class("text:Effect")

---@param args table<string, number>
function Effect:init(args)
    umg.melt("Cannot instantiate abstract class 'Effect'")
end

---Called by Text object to determine if the effect is a per-character effect or it can be grouped.
---
---For example: Simple effect that set color to all text should returns false to this function for optimization
---purpose. Meanwhile effect that shakes each character should return true to this function to be applied properly.
function Effect:isEffectPerCharacter()
    return true
end

---Called by Text when the Text wants to apply effect to a subtext.
---@param dt number Time elapsed since last call.
---@param text text.SubText Subtext of character(s) the effect is processing right now.
function Effect:updateSubtext(text, dt)
end

---Called by Text object when the whole Text object effects are being reset.
---
---For dynamic effect, this may reset the duration to 0.
function Effect:reset()
end

return Effect
