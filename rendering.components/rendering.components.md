

# `rendering.components` mod

Bunch of useful components for the rendering mod.

Example of creating a shockwave on screen:

```lua
local DEFAULT_LIFETIME = 0.32

local function shockwave(args)
    local ent = client.entities.empty()
    local startSize = args.startSize or 10
    local endSize = args.endSize or 100
    local fullLifetime = args.lifetime or DEFAULT_LIFETIME
    ent.color = args.color or objects.Color.WHITE
    ent.x = args.x
    ent.y = args.y
    if args.dimension then
        ent.dimension = args.dimension
    end
    ent.circle = {
        getSize = function(e)
            local t = fullLifetime - e.lifetime
            local dSize = endSize-startSize 
            return startSize + dSize*t
        end
    }
    ent.fade = {
        component = "lifetime",
        multiplier = 1/fullLifetime -- we want to scale from 0->1
    }
    ent.lifetime = fullLifetime
    return ent
end

```

