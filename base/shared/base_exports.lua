
--[[

base mod API export 


]]

local defineExports = require("shared.define_exports")


local function loadClient(base)
    base.client = {}

    base.client.groundTexture = require("client.ground_texture")
end


local function loadShared(base)
    base.gravity = require("shared.gravity");

    base.components = require("shared.components")

    base.inspect = require("_libs.inspect");

    base.weightedRandom = require("shared.weighted_random");
end



local function loadServer(base)
    base.server = {}
end



defineExports({
    name = "base",
    loadServer = loadServer,
    loadClient = loadClient,
    loadShared = loadShared
})


