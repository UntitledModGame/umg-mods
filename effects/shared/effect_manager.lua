

local EffectManager = objects.Class("effects:EffectManager")


function EffectManager:init(owner)
    self.activeEffects = objects.Set()

    self.owner = owner

    self.hasEffectHandler = {--[[
        [EffectHandlerClass] -> true

        to check whether a EffectManager has an EffectHandler type
    ]]}

    self.effectHandlers = objects.Array()
end



function EffectManager:addEffect(effectEntity)
    
end


function EffectManager:removeEffect(effectEntity)

end


function EffectManager:tick()

end





return EffectManager
