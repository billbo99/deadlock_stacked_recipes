local logger = require("utils/logging").logger

if settings.startup["deadlock-enable-beltboxes"].value then
    local Deadlock = require("utils/deadlock")

    Deadlock.DensityOverride()
    Deadlock.MakeStackedRecipes()
    Deadlock.DensityOverride()
    Deadlock.FixLocalisedNames()
    Deadlock.SubGroups()
    Deadlock.FixResearchTree()
    Deadlock.ChangeIcons()
end

logger("9", serpent.block(data.raw))

-- logger("7", serpent.block(data.raw.recipe["StackedRecipe-automation-science-pack"].icons))
