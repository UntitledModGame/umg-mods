
-- actionButton component



-- Custom buttons:
umg.answer("lootplot:collectSelectionButtons", function(array, ppos)
    return {
        text = "Cancel",
        color = objects.Color(0.66,0.2,0.27),
        onClick = selection.reset,
        priority = math.huge
    }
end)


