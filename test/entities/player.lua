

local PLAYER_SPEED = 120



return umg.defineEntityType("player", {
    maxHealth = 100,

    lookAtMouse = true,
    cameraFollow = true;

    healthBar = {
        offset = 20,
        drawWidth = 60,
        color = {0,1,0}
    },

    category = "player",

    canPickUpItems = true,

    holdItemSlot = {
        slot = 1
    }, 
    clickToUseHoldItem = true,

    bobbing = {},
    
    topdownControl = {};

    nametag = {oy = -14};

    physics = {
        shape = love.physics.newCircleShape(5);
        friction = 7
    };

    light = {
        size = 160;
        color = {1,1,1},
        dark = false
    };

    glow = {
        color = {1,0.8,0.1, 0.4}
    },

    moveAnimation = {
        up = {"red_player_up_1", "red_player_up_2", "red_player_up_3", "red_player_up_4"},
        down = {"red_player_down_1", "red_player_down_2", "red_player_down_3", "red_player_down_4"}, 
        left = {"red_player_left_1", "red_player_left_2", "red_player_left_3", "red_player_left_4"}, 
        right = {"red_player_right_1", "red_player_right_2", "red_player_right_3", "red_player_right_4"},
        period = 0.7;
        activation = 15
    };

    baseSpeed = PLAYER_SPEED;
    baseAgility = 0.9;

    init = function(e, x, y, uname)
        e.health = e.maxHealth
        e.controller = uname
        e.inventory = items.Inventory({
            entity = e,
            size = 30
        })
    end,

    basicUI = {},
    uiSize = {width = 0.3, height = 0.25},

    onCreate = function(e)
        if client then
            local GridInventory = require("client.GridInventoryElement")

            e.ui = {
                element = GridInventory({
                    inventory = e.inventory,
                    width = 6,
                    height = 5
                }),
                region = layout.Region(0,0,0,0)
            }
        end
    end,

    initXY = true,
    initVxVy = true,
    initLook = true
})


