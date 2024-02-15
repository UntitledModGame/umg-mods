



local initUIGroup = umg.group("initUI")

initUIGroup:onAdded(function(ent)
    if not ent.uiElement then
        ent:initUI()
    end
end)


