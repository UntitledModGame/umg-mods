
--[[

lua files in client/ are automatically loaded on clientside.

]]

umg.on("@keypressed", function(key)
    print("Key pressed: ", key)
end)

