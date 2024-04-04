
local context = {}


if server then

function context.setContext(ctx)
    --[[
        allows setting of the game-context,
        which tells the system how points/money should be handled.

        Different gamemodes/addons will handle points and money differently.
        Therefore, it's important to abstract them out.
    ]]
    typecheck.assertKeys(ctx, {"getMoney", "getPoints"})
    if server then
        -- only server has setMoney, setPoints
        typecheck.assertKeys(ctx, {"setMoney", "setPoints"})
    end
    for k,func in pairs(ctx) do
        assert(type(func) == "function", "Context values must be functions!")
        context[k] = func
    end
end

end

return context


