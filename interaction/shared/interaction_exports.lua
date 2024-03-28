

local interaction = {}


function interaction.getSceneRegion()
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


function interaction.openUI(ent)
    assertUIEnt(ent)
    scene:addChild(ent.ui.element)
end

function interaction.closeUI(ent)
    assertUIEnt(ent)
    scene:removeChild(ent.ui.element)
end

function interaction.isOpen(ent)
    local elem = ent.ui.element
    return scene:hasChild(elem)
end

function interaction.getOpenElements()
    return scene:getChildren()
end

function interaction.getMainScene()
    return scene
end

function interaction.isElement(ent)
    -- an entity is a valid UI element if it has `ui` component
    return ent.ui
end




return interaction
