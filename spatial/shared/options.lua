
--[[


TODO:

In the future, we should provide an API for changing options.
Maybe we should have a generic way of changing/defining options...?


]]


local options = {
    DEFAULT_SPEED = 100,

    SYNC_LEIGHWAY = 40, --[[
        players have X times sync leighway. This essentially means that
        hacked clients can technically move-hack to go X times as fast;
        (but on the positive side, legit clients won't be lagged backwards.)

        (We are just setting it to be super high for now, because i
            CBA dealing with lagback.)
    ]]

    DEFAULT_FRICTION = 6;
}



return options
