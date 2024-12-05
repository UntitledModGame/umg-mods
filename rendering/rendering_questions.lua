

if not client then
    return
end


local ADD = reducers.ADD
local MULT = reducers.MULTIPLY


-- Camera positioning:

-- Flat camera offset. Answers should return 2 numbers
umg.defineQuestion("rendering:getCameraOffset", reducers.ADD_VECTOR)
umg.answer("rendering:getCameraOffset", function() -- default answer
    return 0, 0
end)

-- Total camera position in world.
-- Answers should return x,y position, and then a priority.
-- The highest priority position is then chosen.
umg.defineQuestion("rendering:getCameraPosition", reducers.PRIORITY_DOUBLE)






--[[
    MODDER, BEWARE!!!!

    These questions below are asked very frequently.
    (Specifically, they are asked every time we draw an entity.)

    Do NOT include complex code in your answers!!!
    Every answer should be a fast, simple O(1) check.

    Also, try to not answers questions like these *too* many times,
    as it will cause a slight performance hit.
]]

-- Is the entity hidden? answers should return true or false
umg.defineQuestion("rendering:isHidden", reducers.OR)
umg.answer("rendering:isHidden", function() -- default answer
    return false
end)

-- get entity rotation
umg.defineQuestion("rendering:getRotation", ADD)
umg.answer("rendering:getRotation", function() -- default answer
    return 0
end)

-- visual scale of entity
umg.defineQuestion("rendering:getScale", MULT)
umg.answer("rendering:getScale", function() -- default answer
    return 1
end)

umg.defineQuestion("rendering:getScaleXY", reducers.MULTIPLY_VECTOR)
umg.answer("rendering:getScaleXY", function()
    return 1, 1
end)

-- gets offsets of an entity for draw position
umg.defineQuestion("rendering:getOffsetXY", reducers.ADD_VECTOR)
umg.answer("rendering:getOffsetXY", function()
    return 0, 0
end)

-- shear of entity
umg.defineQuestion("rendering:getShearXY", reducers.ADD_VECTOR)
umg.answer("rendering:getShearXY", function()
    return 0, 0
end)



--[[
    TODO: do we really want to multiplicitively combine like this?
    Would it be possible to combine through OKLAB, or HSV or something?
]]
local function colorReducer(r1,r2, g1,g2, b1,b2)
    return ((r1 or 1)*(r2 or 1)), ((g1 or 1)*(g2 or 1)), ((b1 or 1)*(b2 or 1))
end

-- color of entity
umg.defineQuestion("rendering:getColor", colorReducer)
umg.answer("rendering:getColor", function()
    return 1, 1, 1
end)

-- Opacity of entity
umg.defineQuestion("rendering:getOpacity", MULT)
umg.answer("rendering:getOpacity", function()
    return 1
end)


-- ability to override image
umg.defineQuestion("rendering:getImage", reducers.PRIORITY)

