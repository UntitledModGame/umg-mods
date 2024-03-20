

local function defineSlime(name, args)
    local etype = {
        testMoveToPlayer = true,
        drawable = true,
        slime = true,
        deathSound = {
            name = "splat1",
            vol = 0.5
        },
        healthBar = {
            offset = 14,
            drawWidth = 16,
            color = {0.7,0,0}
        },

        maxHealth = 10,

        physics = {
            shape = love.physics.newCircleShape(3);
            friction = 7
        },
        initXY = true
    }
    for k,v in pairs(args) do
        etype[k] = v
    end
    umg.defineEntityType(name, etype)
end


local function makeAnimation(prefix)
    local frames = objects.Array()
    for i=0,8 do
        frames:add(prefix .. "00" .. tostring(i))
    end
    local animation = {
        frames = frames,
        speed = 0.6
    }
    return animation
end



defineSlime("slime", {
    animation = makeAnimation("slime1_"),
    spawnOnDeath = {
        {type = "slime", chance = 0.13, count = 2}
    },
})



defineSlime("slime2", {
    animation = makeAnimation("slime2_"),
    spawnOnDeath = {
        {type = "slime", chance = 1, count = 2},
        {type = "slime2", chance = 0.07, count = 2},
    },
})



defineSlime("slime3", {
    animation = makeAnimation("slime5_"),
    spawnOnDeath = {
        {type = "slime", chance = 1, count = 1},
        {type = "slime3", chance = 0.15, count = 2},
        {type = "slime2", chance = 1, count = 1},
    },
})

