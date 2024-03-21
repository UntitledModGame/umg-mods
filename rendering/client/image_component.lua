

local drawImage = require("client.helper.draw_image")




local images = client.assets.images


local entityProperties = require("client.helper.entity_properties")


local getImage = entityProperties.getImage




umg.on("rendering:drawEntity", function(ent, x,y, rot, sx,sy, kx,ky)
    local img = getImage(ent)
    if not img then
        return -- no image, don't draw.
    end

    local quad = images[img]
    if not quad then
        if type(img) ~= "string" then
            error(("Incorrect type for entity image. Expected string, got: %s"):format(type(ent.image)))
        end
        error(("Unknown ent.image value: %s\nMake sure you put all images in the assets folder and name them!"):format(tostring(ent.image)))
    end

    drawImage(
        img, 
        x, y,
        rot, 
        sx, sy,
        ox, oy,
        kx,ky
    )
end)

