local winLose = {}

umg.definePacket("lootplot.main:gameEnded", {typelist={"boolean"}})

if server then

---@param clientId string|nil
---@param win boolean
function winLose.endGame(clientId, win)
    if win then
        local plot = assert(lp.main.getRun()):getPlot()
        lp.metaprogression.winAndUnlockItems(plot)
    end
    if clientId then
        server.unicast(clientId, "lootplot.main:gameEnded", win)
    else
        server.broadcast("lootplot.main:gameEnded", win)
    end
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
