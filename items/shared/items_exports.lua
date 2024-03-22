

local items = {}


items.Inventory = require("shared.Inventory")
items.SlotHandle = require("shared.SlotHandle")



if server then
    local groundAPI = require("server.ground_items")
    items.drop = groundAPI.drop
end


if client then
    items.SlotElement = require("client.SlotElement")
end


umg.expose("items", items)
