log(serpent.block(data.raw.item["deadlock-stack-tin-ore"]))

local Deadlock = require("utils/deadlock")
Deadlock.MakeStackedRecipes()
Deadlock.DensityOverride()
Deadlock.FixLocalisedNames()
Deadlock.SubGroups()