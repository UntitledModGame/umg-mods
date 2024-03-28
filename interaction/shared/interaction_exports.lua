

local interaction = {}


function ui.getSceneRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


local function assertUIEnt(ent)
    local ui = ent.ui
    if not ui then
        error("Entity must have a .ui component!", 2)
    end
    if not (ui.element and ui.region) then
        error("Entity ui must have region and element!", 2)
    end
end


function ui.open(ent)
    assertUIEnt(ent)
    scene:addChild(ent.ui.element)
end

function ui.close(ent)
    assertUIEnt(ent)
    scene:removeChild(ent.ui.element)
end

function ui.isOpen(ent)
    local elem = ent.ui.element
    return scene:hasChild(elem)
end

function ui.getOpenElements()
    return scene:getChildren()
end

function ui.getMainScene()
    return scene
end

function ui.isElement(ent)
    -- an entity is a valid UI element if it has `ui` component
    return ent.ui
end




return interaction
