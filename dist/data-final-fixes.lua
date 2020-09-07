local logger = require("utils/logging").logger
local Deadlock = require("utils/deadlock")

require "mods.Krastorio2.data-final-fixes"
require "mods.FactorioExtended-Plus-Module.data-final-fixes"
require "mods.Deadlock-SE-bridge.data-final-fixes"

if settings.startup["deadlock-enable-beltboxes"].value then
    Deadlock.DensityOverride()
    Deadlock.MakeStackedRecipes()
    Deadlock.DensityOverride()
    Deadlock.FixLocalisedNames()
    Deadlock.FixResearchTree()
end

require "mods.Kythbloods_Stacked_Mining.data-final-fixes"
require "mods.CompressedFluids.data-final-fixes"

if settings.startup["DSR_recipes_after_beacons"].value then
    Deadlock.ReOrderTechnologyBehindBeacons()
end

logger("9", serpent.block(data.raw))
