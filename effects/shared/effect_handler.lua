

-- This class is abstract!
local EffectHandler = objects.Class("effect:EffectHandler")


function EffectHandler:addEffect()
    error("This should be overridden!")
end

function EffectHandler:removeEffect()
    error("This should be overridden!")
end

function EffectHandler:tick()
    -- this doesn't need to be overriden,
    -- but most EffectHandlers SHOULD override this.
end


return EffectHandler
