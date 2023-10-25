
require("effect_events")
require("effect_questions")


local QuestionEffects = objects.Class("effects:QuestionEffects")



function QuestionEffects:init(ownerEnt)
    self.ownerEnt = ownerEnt
    self.questionEffects = objects.Set()

    self.questionToEffectSet = {--[[
        Keeps track of what effectEntities are used for each effect.

        [questionName] -> List<effectEnt>
    ]]}
end


local function canTrigger(ownerEnt, effectEnt, ...)
    local blocked = umg.ask("effects:isEffectBlocked", effectEnt, ownerEnt)
    if blocked then
        return false
    end

    local evEffect = effectEnt.questionEffect
    if evEffect.shouldTrigger then
        return evEffect.shouldTrigger(effectEnt, ownerEnt, ...)
    end
    return true -- all ok!
end


local function activateEffect(ownerEnt, effectEnt, ...)
    local evEffect = effectEnt.questionEffect
    if evEffect.usable and effectEnt.usable then
        error("todo")
    end

    if evEffect.trigger then
        evEffect.trigger(effectEnt, ownerEnt, ...)
    end

    umg.call("effects:questionEffectTriggered", effectEnt, ownerEnt)
end


function QuestionEffects:call(questionName, ...)
    local set = self.questionToEffectSet[questionName]
    if not set then
        return -- no questions listening. RIP
    end

    local ownerEnt = self.ownerEnt
    for _, effectEnt in ipairs(set) do
        if canTrigger(ownerEnt, effectEnt, ...) then
            activateEffect(ownerEnt, effectEnt, ...)
        end
    end
end



function QuestionEffects:shouldTakeEffect(effectEnt)
    return effectEnt.questionEffect
end




local answeredQuestions = {--[[
    Checks whether we already have a listener setup for this question

    [questionName] -> true
]]}



local function ensureAnswerer(questionName)
    --[[
        creates an question-listener for `questionName` at runtime,
        (if one doesn't already exist.)

        This function only works when the effect entity is
            the first argument passed into the question.
    ]]
    if answeredQuestions[questionName] then
        return -- we already have a listener here
    end

    umg.on(questionName, function(ent, ...)
        if ent.questionEffects then
            ent.questionEffects:call(questionName, ...)
        end
    end)

    answeredQuestions[questionName] = true
end



function QuestionEffects:addEffect(effectEnt)
    local question = effectEnt.questionEffect.question
    local set = self.questionToEffectSet[question]
    if not set then
        set = objects.Set()
        self.questionToEffectSet[question] = set
    end

    ensureAnswerer(question)
    set:add(effectEnt)
end


function QuestionEffects:removeEffect(effectEnt)
    local question = effectEnt.questionEffect.question
    local set = self.questionToEffectSet[question]
    set:remove(effectEnt)
    if set:size() <= 0 then
        self.questionToEffectSet[question] = nil
    end
end



umg.on("effects:effectAdded", function(effectEnt, ent)
    if effectEnt.questionEffect then
        ent.questionEffects = ent.questionEffects or QuestionEffects(ent)
        ent.questionEffects:addEffect(effectEnt)
    end
end)


umg.on("effects:effectRemoved", function(effectEnt, ent)
    if ent.questionEffects then
        ent.questionEffects:removeEffect(effectEnt)
    end
end)

