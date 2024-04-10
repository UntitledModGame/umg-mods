

local uiSizeGroup = umg.group("uiSize", "ui")


local function round(x)
    return math.floor(x+0.5)
end


local function getClosestMultiple(target, factor)
    --[[
        target: The target number we want to hit
        factor: the multiplier

        Examples:
            target: 521
            factor: 600
            answer: (600) (* 1)

            target: 902
            factor: 600
            answer: (1200) (* 2)

            target: 201
            factor: 600
            answer: 200  (/ 3)
    ]]
    if target <= factor then
        -- we are making it smaller!
        local divv = round(factor / target)
        return factor / divv
    else
        -- else, we are making it bigger
        local mult = round(target / factor)
        return factor * mult
    end
end




local function getSize(targetSize, factorOf)
    if factorOf then
        return getClosestMultiple(targetSize, factorOf)
    else
        return targetSize
    end
end



local function getWHRatio(uiSize)
    if (uiSize.widthFactorOf and uiSize.heightFactorOf) then
        return uiSize.heightFactorOf / uiSize.widthFactorOf
    else
        assert(uiSize.height, "uiSize needs a .height value, OR needs to define BOTH width/height factorsOfs!")
        return uiSize.height / uiSize.width
    end
end


local function getWidthHeight(uiSize, sceneRegion)
    local _,_, sW,sH = sceneRegion:get()

    -- compute width
    local width = getSize(sW * uiSize.width, uiSize.widthFactorOf)

    -- once we have computed width, we need to use width to compute height.
    -- This is because w/h are generally fixed in ratio.
    local whRatio = getWHRatio(uiSize)
    local height
    if uiSize.noRatio then
        height = getSize(sH * uiSize.height, uiSize.heightFactorOf)
    else
        height = width * whRatio
    end
    return width, height
end




umg.on("@update", function()
    local sceneRegion = ui.basics.getSceneRegion()

    for _, ent in ipairs(uiSizeGroup) do
        local ui = ent.ui
        ui.region = ui.region or ui.Region(0,0, 0,0)
        local region = ui.region

        -- oops, we really shouldn't be mutating w,h here, as Kirigami regions
        -- are supposed to be immutable. Oh well!! :-)
        region.w, region.h = getWidthHeight(ent.uiSize, sceneRegion)
    end
end)

