


local grids = require("shared.grids")

grids.generateFloorTiling = require("shared.default_tilings.floor")
grids.generateFenceTiling = require("shared.default_tilings.fence")
grids.generatePathTiling = require("shared.default_tilings.path")


umg.expose("grids", grids)

