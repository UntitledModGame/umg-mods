

--[[

"Mana" exists as a property of slots.
(Represented by the rcomp `manaCount`.)
It can be added/removed, and exists as an integer:

]]
components.defineComponent("manaCount")
sync.autoSyncComponent("manaCount", {
    type = "number",
    lerp = false
})



components.defineComponent("manaCost")
--[[
the "mana cost" to activate an item / slot.

If `manaCost` is on an item:
The item will use mana from the slot that it's on.

If `manaCost` is on a slot:
The slot will use it's own mana, (if it has any)

]]
