
--[[

Actions:

lootplot "actions" is something that is visibly buffered on-screen.
For example;
- activating an ent
- swapping items
- destroying an ent

actions are pushed to the pipeline via plot:buffer(f,...)

NOTE: Every action in this file should ALSO be able to be rewritten 
in other mods by calling plot:buffer(f,...)

]]

local actions = {}





return actions
