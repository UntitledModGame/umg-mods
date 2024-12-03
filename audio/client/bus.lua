umg.defineEvent("audio:transform") -- parameters: audioName, source, entity

umg.defineQuestion("audio:getVolume", reducers.MULTIPLY) -- parameters: audioName, source, entity
umg.defineQuestion("audio:getSemitoneOffset", reducers.ADD) -- parameters: audioName, source, entity

umg.answer("audio:getVolume", function()
    return client.getMasterVolume()
end)

umg.answer("audio:getVolume", function(_, _, e)
    return e and e.audioVolume or 1
end)

umg.answer("audio:getSemitoneOffset", function()
    return 0
end)

umg.answer("audio:getSemitoneOffset", function(_, _, e)
    return e and e.audioSemitoneOffset or 0
end)
