local winLose = {}

umg.definePacket("lootplot.singleplayer:gameEnded", {typelist={"boolean"}})

if server then

---@param clientId string|nil
---@param win boolean
function winLose.endGame(clientId, win)
    local run = assert(lp.singleplayer.getRun())

    if clientId then
        server.unicast(clientId, "lootplot.singleplayer:gameEnded", win)
    else
        server.broadcast("lootplot.singleplayer:gameEnded", win)
    end

    umg.analytics.collect("lootplot.singleplayer:endGame", {
        win = not not win,
        runMeta = run:getMetadata()
    })
end

else

local endGameCallback = nil

---@param callback fun(win:boolean)
function winLose.setEndGameCallback(callback)
    endGameCallback = callback
end

client.on("lootplot.singleplayer:gameEnded", function(win)
    if endGameCallback then
        endGameCallback(win)
    end
end)

end

return winLose
