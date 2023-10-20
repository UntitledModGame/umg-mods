

--[[

TODO:

A bunch of these need to be pulled out,
and placed into the new `usables` mod.


]]

-- an entity equips an item
umg.defineEvent("holdables:equipItem")

-- an entity un-equips an item
umg.defineEvent("holdables:unequipItem")


-- An item is used:
umg.defineEvent("holdables:useItem")

-- item usage is denied:
umg.defineEvent("holdables:useItemDeny")


-- A hold item is updated. 
-- Called every frame whilst an item is being held
umg.defineEvent("holdables:updateHoldItem")

