

require("effect_events")


local EffectManager = objects.Class("effects:EffectManager")


function EffectManager:init(owner)
    self.activeEffects = objects.Set()

    self.owner = owner

    self.effectHandlers = objects.Array(--[[
        a list of effectHandlers that belong to this particular instance
    ]])

    self.classToInstance = {--[[
        Maps EffectHandlerClasses to EffectHandler instances.
        (These are the same instances as in the `self.effectHandlers` array.)
        (This also guarantees only 1 instance per EffectHandlerClass.)

        [EffectHandlerClass] -> EffectHandler instance
    ]]}
end



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



local defineEffectHandlerTc = typecheck.assert("table")
function EffectManager.defineEffectHandler(effectHandlerClass)
    --[[
        defines an effect handler
    ]]
    defineEffectHandlerTc(effectHandlerClass)
    assertValidEffectHandler(effectHandlerClass)

    effectHandlerClassList:add(effectHandlerClass)
end




local function ensureEffectHandler(self, effectHandlerClass)
    --[[
        ensures that we have an effect handler of the given type.
        (If we don't have the effect handler, then create one.)
    ]]
    if self:getEffectHandler(effectHandlerClass) then
        return -- we already have it, no need to add again
    end

    local effectHandler = effectHandlerClass(self.activeEffects)
    self.effectHandlers:add(effectHandler)
    self.classToInstance[effectHandlerClass] = effectHandler
end






--[[

TODO TODO TODO:

We need to do syncing here!
Sync when adding/remove effects.


]]


function EffectManager:addEffect(effectEntity)
    if self.activeEffects:contains(effectEntity) then
        return -- dont add twice
    end

    for _, effectHandlerClass in ipairs(effectHandlerClassList) do
        -- note that effectHandlerClass is the CLASS, not an instance!!!
        if effectHandlerClass:shouldTakeEffect(effectEntity) then
            -- if we should take the effect, add it.
            ensureEffectHandler(self, effectHandlerClass)
        end
    end
    self.activeEffects:add(effectEntity)
    local ownerEntity = self.owner
    umg.call("effects:effectAdded", effectEntity, ownerEntity)
end


function EffectManager:removeEffect(effectEntity)
    if not self.activeEffects:contains(effectEntity) then
        return -- nothing to remove!
    end

    for _, handler in ipairs(self.effectHandlers) do
        handler:remove(effectEntity)
    end
    self.activeEffects:remove(effectEntity)
    local ownerEntity = self.owner
    umg.call("effects:effectRemoved", effectEntity, ownerEntity)
end



function EffectManager:getEffectHandler(effectHandlerClass)
    return self.classToInstance[effectHandlerClass]
end



function EffectManager:tick(dt)
    for _, effectHandler in ipairs(self.effectHandlers) do
        if effectHandler.tick then
            effectHandler:tick(dt)
        end
    end
end



return EffectManager
