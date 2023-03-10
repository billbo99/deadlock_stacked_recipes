local logger = require("utils/logging").logger
local Deadlock = require("utils/deadlock")

require("mods.IndustrialRevolutionStacking.data-final-fixes")
require "mods.Krastorio2.data-final-fixes"
require "mods.FactorioExtended-Plus-Module.data-final-fixes"
require "mods.Deadlock-SE-bridge.data-final-fixes"

if settings.startup["deadlock-enable-beltboxes"].value then
    logger("1", "DSR___START,DensityOverride")
    Deadlock.DensityOverride()
    logger("1", "DSR___END,DensityOverride")

    logger("1", "DSR___START,MakeStackedRecipes")
    Deadlock.MakeStackedRecipes()
    logger("1", "DSR___END,MakeStackedRecipes")

    logger("1", "DSR___START,DensityOverride2")
    Deadlock.DensityOverride()
    logger("1", "DSR___END,DensityOverride2")

    logger("1", "DSR___START,FixLocalisedNames")
    Deadlock.FixLocalisedNames()
    logger("1", "DSR___END,FixLocalisedNames")

    logger("1", "DSR___START,FixResearchTree")
    Deadlock.FixResearchTree()
    logger("1", "DSR___END,FixResearchTree")

    logger("1", "DSR___START,FixFuel")
    Deadlock.FixFuel()
    logger("1", "DSR___END,FixFuel")
end

logger("1", "DSR___START,mods.Kythbloods_Stacked_Mining.data-final-fixes")
require "mods.Kythbloods_Stacked_Mining.data-final-fixes"
logger("1", "DSR___END,mods.Kythbloods_Stacked_Mining.data-final-fixes")
logger("1", "DSR___START,mods.CompressedFluids.data-final-fixes")
require "mods.CompressedFluids.data-final-fixes"
logger("1", "DSR___END,mods.CompressedFluids.data-final-fixes")

logger("1", "DSR___START,ReOrderTechnologyBehindBeacons")
if settings.startup["DSR_recipes_after_beacons"].value then
    Deadlock.ReOrderTechnologyBehindBeacons()
end
logger("1", "DSR___END,ReOrderTechnologyBehindBeacons")

logger("1", "DSR___START,HideRecipes")
Deadlock.HideRecipes()
logger("1", "DSR___END,HideRecipes")

logger("9", "RAW")

logger("1", "DSR___FINSHED")
