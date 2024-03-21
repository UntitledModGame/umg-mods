
# juice components

```lua


--[[
    TODO: Change this to progressBar.
    Have healthBar component project onto progressBar
]]
ent.healthBar = { -- health bar above entity!
    -- All of these are optional values:
    offset = 10, -- how high it's drawn
    drawWidth = 20,
    drawHeight = 5,
    healthColor = {1,0.2,0.2},
    outlineColor = {0,0,0},
    backgroundColor = {0.4,0.4,0.4,0.4}
}




ent.nametag = true -- entity will have a nametag above its head :)
-- the nametag will be the value of the `.controllable` component



-- renders text in front of the entity
-- (Similar to nametag component)
ent.text = {
    -- we can set value of text through a component:
    component = "controller" -- txt value == ent.controllable
    -- specify a default value:
    default = "unnamed player"

    -- or, set text value directly:
    value = "hello, i am text",

    disableScaling = false, -- disable passed scaling

    ox = 0, oy = -20, -- draw offsets
    scale = 1,
    overlay = true, -- (text will look nicer with this enabled)
    color = {1,1,1}, -- text color
    background = {0.2,0.2,0.2,0.5} -- background color
}



-- please note that entities with particles break auto batching.
-- Don't use particles EVERYWHERE; it'll be slow
ent.particles = ParticleSystem



-- modifies the opacity of `ent`
ent.fade = {
    -- set the value of fade through a component:
    component = "lifetime",
    -- or set value directly:
    value = 10,
    -- OR, use a function:
    getValue = function(ent) return 0.5 end
    -- multiplier: (default=1)
    multipler = 1
}




ent.animation = {
    frames = {"img1", "img2", "img3"}, 
    speed = 3
}



ent.moveAnimation = {
    up = {"up1", "up2", ...},
    down = ...,  left = ..., right = ...
    speed = 3;

    activation = 10 -- moveAnimation activates when entity is travelling at 
    -- at least 10 units per second.
}




ent.rainbow = {
    period = 5, -- has a default value
    brightness = 0.2 -- has a default value
}


ent.swaying = {
    magnitude = 1;
    period = 2
}


ent.bobbing = {
    period = 0.8;
    magnitude = 0.15
}


ent.spinning = {
    period = 2;
    magnitude = 1
}


```
