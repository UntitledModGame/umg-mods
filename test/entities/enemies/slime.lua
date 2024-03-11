




return {
    testMoveToPlayer = true,
    drawable = true,
    slime = true,

    spawnOnDeath = {
        {type = "slime", chance = 0.13, count = 2}
    },

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

    animation = {
        frames = {
            "slime1_000",
            "slime1_001",
            "slime1_002",
            "slime1_003",
            "slime1_004",
            "slime1_005",
            "slime1_006",
            "slime1_007",
            "slime1_008",
        },
        speed = 0.6
    },

    initXY = true
}

