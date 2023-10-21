

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




local nameToEffectHandlerClass = {--[[
    [name] = EffectHandlerClass
]]}

local effectHandlerList = objects.Array()


local function assertFunc(ehClass, funcName)
    if not ehClass[funcName] then
        error(("EffectHandlers need a .%s method"):format(funcName))
    end
end

local function assertValidEffectHandler(ehClass)
    assertFunc(ehClass, "shouldTakeEffect")
    assertFunc(ehClass, "tick")
    assertFunc(ehClass, "addEffect")
    assertFunc(ehClass, "removeEffect")
end


local defineEffectHandlerTc = typecheck.assert("string", "table")
function EffectManager.defineEffectHandler(handlerName, effectHandlerClass)
    --[[
        defines an effect handler
    ]]
    assertValidEffectHandler(effectHandlerClass)
    defineEffectHandlerTc(handlerName, effectHandlerClass)
    assert(not nameToEffectHandlerClass[handlerName], "Duplicate effect handler definition")
    effectHandlerList:add(effectHandlerClass)
end


local function ensureEffectHandler(self, effectHandlerClass)
    --[[
        ensures that we have an effect handler of the given type.
        If we don't have the effect handler, then delete
    ]]
    if self.hasEffectHandler[effectHandlerClass] then
        return -- we already have it!
    end

    self.hasEffectHandler[effectHandlerClass] = true
    local effectHander = effectHandlerClass(self.activeEffects)
    self.effectHanders:add(effectHander)
end



function EffectManager:addEffect(effectEntity)
    
end


function EffectManager:removeEffect(effectEntity)

end


function EffectManager:tick(dt)

end



return EffectManager
