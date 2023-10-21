

local EffectManager = objects.Class("effects:EffectManager")


function EffectManager:init(owner)
    self.activeEffects = objects.Set()

    self.owner = owner

    self.hasEffectHandler = {--[[
        [EffectHandlerClass] -> true

        to check whether a EffectManager has an EffectHandler type
    ]]}

    self.effectHandlers = objects.Array(--[[
        a list of effectHandlers that belong to this particular instance
    ]])

    self.nameToEffectHandler = {--[[
        Maps names to EffectHandler instances.
        (These are the same instances as in the `self.effectHandlers` array.)

        [name] -> EffectHandler
    ]]}
end




local nameToEffectHandlerClass = {--[[
    [name] = EffectHandlerClass
]]}

local effectHandlerClassList = objects.Array()


local function assertFunc(ehClass, funcName)
    if not ehClass[funcName] then
        error(("EffectHandlers need a .%s method"):format(funcName))
    end
end

local function assertValidEffectHandler(ehClass)
    assertFunc(ehClass, "shouldTakeEffect")
    assertFunc(ehClass, "addEffect")
    assertFunc(ehClass, "removeEffect")
    assert(not ehClass._name, "_name in EffectHandlers is reserved")
end



local defineEffectHandlerTc = typecheck.assert("string", "table")
function EffectManager.defineEffectHandler(handlerName, effectHandlerClass)
    --[[
        defines an effect handler
    ]]
    defineEffectHandlerTc(handlerName, effectHandlerClass)
    assertValidEffectHandler(effectHandlerClass)
    assert(not nameToEffectHandlerClass[handlerName], "Duplicate effect handler definition")

    effectHandlerClass._name = handlerName
    effectHandlerClassList:add(effectHandlerClass)
end




local function ensureEffectHandler(self, effectHandlerClass)
    --[[
        ensures that we have an effect handler of the given type.
        (If we don't have the effect handler, then create one.)
    ]]
    if self.hasEffectHandler[effectHandlerClass] then
        return -- we already have it!
    end

    self.hasEffectHandler[effectHandlerClass] = true
    local effectHandler = effectHandlerClass(self.activeEffects)
    self.effectHandlers:add(effectHandler)
    self.nameToEffectHandler[effectHandler._name] = effectHandler
end



function EffectManager:addEffect(effectEntity)
    for _, effectHandlerClass in ipairs(effectHandlerClassList) do
        -- note that effectHandlerClass is the CLASS, not an instance!!!
        if effectHandlerClass:shouldTakeEffect(effectEntity) then
            -- if we should take the effect, add it.
            ensureEffectHandler(self, effectHandlerClass)
        end
    end
    self.activeEffects:add(effectEntity)
end


function EffectManager:removeEffect(effectEntity)
    for _, handler in ipairs(self.effectHandlers) do
        handler:remove(effectEntity)
    end
    self.activeEffects:remove(effectEntity)
end


function EffectManager:getEffectHandler(name)
    return self.nameToEffectHandler[name]
end


function EffectManager:tick(dt)
    for _, effectHandler in ipairs(self.effectHandlers) do
        if effectHandler.tick then
            effectHandler:tick(dt)
        end
    end
end



return EffectManager
