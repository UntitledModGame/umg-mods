



local initUIGroup = umg.view("initUI")

initUIGroup:onAdded(function(ent)
    if not ent.uiElement then
        ent:initUI()
    end
end)


