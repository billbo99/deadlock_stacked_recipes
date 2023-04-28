local logger = require("utils/logging").logger

logger("1", "data-start")

require("data/group.lua")
require("data/technology.lua")
require("mods/IndustrialRevolutionStacking/data.lua")
require("mods/WaterWell/data.lua")

logger("1", "data-end")
