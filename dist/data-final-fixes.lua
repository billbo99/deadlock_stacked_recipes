local logger = require("utils/logging").logger
local Deadlock = require("utils/deadlock")

require "mods.Krastorio2.data-final-fixes"
require "mods.FactorioExtended-Plus-Module.data-final-fixes"
require "mods.Deadlock-SE-bridge.data-final-fixes"

if settings.startup["deadlock-enable-beltboxes"].value then
    log("DSR___START,DensityOverride")
    Deadlock.DensityOverride()
    log("DSR___END,DensityOverride")

    log("DSR___START,MakeStackedRecipes")
    Deadlock.MakeStackedRecipes()
    log("DSR___END,MakeStackedRecipes")

    log("DSR___START,DensityOverride2")
    Deadlock.DensityOverride()
    log("DSR___END,DensityOverride2")

    log("DSR___START,FixLocalisedNames")
    Deadlock.FixLocalisedNames()
    log("DSR___END,FixLocalisedNames")

    log("DSR___START,FixResearchTree")
    Deadlock.FixResearchTree()
    log("DSR___END,FixResearchTree")

    log("DSR___START,FixFuel")
    Deadlock.FixFuel()
    log("DSR___END,FixFuel")
end

log("DSR___START,mods.Kythbloods_Stacked_Mining.data-final-fixes")
require "mods.Kythbloods_Stacked_Mining.data-final-fixes"
log("DSR___END,mods.Kythbloods_Stacked_Mining.data-final-fixes")
log("DSR___START,mods.CompressedFluids.data-final-fixes")
require "mods.CompressedFluids.data-final-fixes"
log("DSR___END,mods.CompressedFluids.data-final-fixes")

log("DSR___START,ReOrderTechnologyBehindBeacons")
if settings.startup["DSR_recipes_after_beacons"].value then
    Deadlock.ReOrderTechnologyBehindBeacons()
end
log("DSR___END,ReOrderTechnologyBehindBeacons")

logger("9", "RAW")

log("DSR___FINSHED")
