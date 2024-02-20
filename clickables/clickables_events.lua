


-- Called on server AND client when an entity is clicked.
umg.defineEvent("clickables:entityClicked")



umg.definePacket("clickables:entityClickedOnClient", {
    typelist = {"entity", "number", "number", "number", "string"}
})

