

local shouldApplyEffect = require("shared.should_apply")



local QuestionEffects = objects.Class("effects:QuestionEffects")



function QuestionEffects:init(ownerEnt)
    self.ownerEnt = ownerEnt
    self.questionEffects = objects.Set()

    self.questionToEffectSet = {--[[
        Keeps track of what effectEntities are used for each effect.

        [questionName] -> List<effectEnt>
    ]]}
end


local function canAnswer(ownerEnt, effectEnt, ...)
    if not shouldApplyEffect(effectEnt, ownerEnt) then
        return false
    end

    local qEffect = effectEnt.questionEffect
    if qEffect.shouldTrigger then
        return qEffect.shouldAnswer(effectEnt, ownerEnt, ...)
    end
    return true -- all ok!
end


local function getAnswer(ownerEnt, effectEnt, ...)
    local qEffect = effectEnt.questionEffect
    if type(qEffect.answer) == "function" then
        return qEffect.answer(effectEnt, ownerEnt, ...)
    else
        return qEffect.answer -- it must be a direct answer!
    end
end


local function findFirstValidAnswer(effectSet, ownerEnt, ...)
    for i=1, #effectSet do
        local effectEnt = effectSet[i]
        if canAnswer(ownerEnt, effectEnt, ...) then
            return i
        end
    end
    return nil -- no answer!
end


function QuestionEffects:ask(questionName, ...)
    local set = self.questionToEffectSet[questionName]
    if (not set) or (#set <= 0) then
        return -- no questions listening. RIP.
        -- Returning nil *should* be safe here...
    end

    -- Find the first non-nil answer:
    local ownerEnt = self.ownerEnt
    local startIndex = findFirstValidAnswer(set, ownerEnt, ...)
    if not startIndex then
        return
    end

    -- Now, do a manual reduction of answers:
    local ans1, ans2, ans3
    local reducer = umg.getQuestionReducer(questionName)
    do 
    local effectEnt = set[startIndex]
    ans1, ans2, ans3 = getAnswer(ownerEnt, effectEnt, ...)
    end

    for i=startIndex+1, #set do
        local effectEnt = set[i]
        local a1, a2, a3 = getAnswer(ownerEnt, effectEnt, ...)
        ans1, ans2, ans3 = reducer(ans1,a1,  ans2,a2,  ans3,a3)
        -- Yes, this is how reducers work ^^^^^^^
        -- (I know its weird)
    end

    return ans1, ans2, ans3
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

    umg.answer(questionName, function(ent, ...)
        if ent.questionEffects then
            return ent.questionEffects:ask(questionName, ...)
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

