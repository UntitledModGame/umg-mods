

local EffectManager = objects.Class("effects:EffectManager")


function EffectManager:init(owner)
    self.activeEffects = objects.Set()

    self.owner = owner

    self.effectHandlers = {--[[
        [j]
    ]]}
end







function EffectManager:addEffect(effectEntity)
    
end

function EffectManager:removeEffect(effectEntity)

end



function EffectManager:getMultiplier(effectEntity)

end

function EffectManager:tick()

end





return EffectManager
