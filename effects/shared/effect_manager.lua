

local EffectManager = objects.Class("effects:EffectManager")


function EffectManager:init()

    self.activeEffects = objects.Set()

    self.effectHandlers = {--[[
        []
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
