umg.defineEvent("sound:transform") -- parameters: soundName, source, entity

umg.defineQuestion("sound:getVolume", reducers.MULTIPLY) -- parameters: soundName, source, entity
umg.defineQuestion("sound:getSemitoneOffset", reducers.ADD) -- parameters: soundName, source, entity
