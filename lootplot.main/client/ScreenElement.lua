

local ScreenElement = ui.Element("lootplot.main:Main")
--[[
    Screen-element:

    Should take up the whole screen.
]]


function ScreenElement:init(args)
    typecheck.assertKeys(args, {"nextRound", "getProgress"})

    self.progressBar = ui.elements.LootplotMonsterBar({
        getProgress = args.getProgress
    })
    self.startButton = ui.elements.Button({
        onClick = args.nextRound
    })

    self:setPassthrough(true)
end


function ScreenElement:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    
    local header, _main = r:splitVertical(0.15, 0.85)
    local startRound, _, progressBar = header:splitHorizontal(0.2, 0.05, 0.8)

    self.startButton:render(startRound:pad(0.1):get())

    self.progressBar:render(progressBar:pad(0.1))
    --[[
        TODO: Put other shit here.
        (Like, money-count box n stuff.)
    ]]
end



return ScreenElement

