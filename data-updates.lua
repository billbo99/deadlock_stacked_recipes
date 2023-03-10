local logger = require("utils/logging").logger

logger("1", "data-updates-start")

require("mods/warptorio2_expansion/data-updates.lua")

logger("1", "data-updates-end")
