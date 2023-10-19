

local EffectHandler = objects.Class("effects:EffectHandler")


function EffectHandler:init()

    self.activeEffects = objects.Set()

    self.propertyEffects = {--[[
        
    ]]}
end







function EffectHandler:addEffect(effectEntity)
    
end

function EffectHandler:removeEffect(effectEntity)

end



function EffectHandler:getMultiplier(effectEntity)

end


function EffectHandler:tick()

end





return EffectHandler
