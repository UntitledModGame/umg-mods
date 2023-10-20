
local common = require("shared.common")
local holding = require("shared.holding")

local holdables = {}


holdables.getHoldItem = common.getHoldItem
holdables.getHoldDistance = common.getHoldDistance


holdables.equipItem = holding.equipItem
holdables.unequipItem = holding.unequipItem
holdables.updateHoldItemDirectly = holding.updateHoldItemDirectly



umg.expose("holdables", holdables)
