if settings.startup["deadlock-enable-beltboxes"].value then
    local Deadlock = require("utils/deadlock")

    Deadlock.DensityOverride()
    Deadlock.MakeStackedRecipes()
    Deadlock.DensityOverride()
    Deadlock.FixLocalisedNames()
    Deadlock.SubGroups()
end
