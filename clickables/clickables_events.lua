


-- Called on server AND client when an entity is clicked.
umg.defineEvent("clickables:entityClicked")


if client then
    -- when an entity is clicked on client-side, 
    -- (Works with the current client ONLY)
    umg.defineEvent("clickables:entityClickedClient")
end






-- (internal use only)
umg.definePacket("clickables:entityClickedOnClient", {
    typelist = {"entity", "number", "number", "number", "string"}
})

