
local juice = {}


local shockwave = require("client.shockwaves")

function juice.shockwave()
    client.entities.empty()
end

juice.newParticleSystem = require("client.particles")


juice.popups = require("client.popups")

juice.title = require("client.title")


umg.expose("juice", juice)

