
--[[

base mod API export 


]]


local base = {}

if client then
    base.client = {}

    base.client.groundTexture = require("client.ground_texture")
end


base.gravity = require("shared.gravity");

base.components = require("shared.components")

base.inspect = require("_libs.inspect");

base.weightedRandom = require("shared.weighted_random");


if server then
    base.server = {}
end


umg.expose("base", base)
