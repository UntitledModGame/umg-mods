

local PLAYER_SPEED = 120



return {
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

    shadow = {
        size=6
    };

    bobbing = {},
    
    topdownControl = {};

    nametag = {};

    physics = {
        shape = love.physics.newCircleShape(5);
        friction = 7
    };

    light = {
        size = 150;
        color = {1,1,1}
    };

    glow = {
        color = {1,0.8,0.1, 0.4}
    },

    moveAnimation = {
        up = {"red_player_up_1", "red_player_up_2", "red_player_up_3", "red_player_up_4"},
        down = {"red_player_down_1", "red_player_down_2", "red_player_down_3", "red_player_down_4"}, 
        left = {"red_player_left_1", "red_player_left_2", "red_player_left_3", "red_player_left_4"}, 
        right = {"red_player_right_1", "red_player_right_2", "red_player_right_3", "red_player_right_4"},
        speed = 0.7;
        activation = 15
    };

    baseSpeed = PLAYER_SPEED;
    baseAgility = 0.9;

    inventoryName = "player inv",
    openable = {},

    init = function(e, x, y, uname)
        e.health = e.maxHealth
        e.controller = uname
        e.inventory = items.Inventory({
            size = 30
        })
    end,

    initVxVy = true,
    initLook = true
}


