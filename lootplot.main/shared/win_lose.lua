local winLose = {}

umg.definePacket("lootplot.main:gameEnded", {typelist={"boolean"}})

if server then

---@param clientId string|nil
---@param win boolean
function winLose.endGame(clientId, win)
    local run = assert(lp.main.getRun())

    if win then
        local plot = run:getPlot()
        lp.metaprogression.winAndUnlockItems(plot)
    end

    if clientId then
        server.unicast(clientId, "lootplot.main:gameEnded", win)
    else
        server.broadcast("lootplot.main:gameEnded", win)
    end

    umg.analytics.collect("lootplot.main:endGame", {
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

client.on("lootplot.main:gameEnded", function(win)
    if endGameCallback then
        endGameCallback(win)
    end
end)

end

return winLose
