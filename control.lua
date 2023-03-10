local Func = require("utils.func")

script.on_configuration_changed(
    function(e)
        -- e.mod_changes
        -- e.mod_startup_settings_changed
        -- e.migration_applied
        log("on_configuration_changed")
        if e.mod_startup_settings_changed or e.mod_changes["deadlock_stacked_recipes"] then
            for index, force in pairs(game.forces) do
                local recipes = force.recipes
                for _, tech in pairs(force.technologies) do
                    if tech.researched then
                        for _, effect in pairs(tech.effects) do
                            if effect.type == "unlock-recipe" and (Func.starts_with(effect.recipe, "StackedRecipe") or Func.starts_with(effect.recipe, "DSR_HighPressure-")) then
                                recipes[effect.recipe].enabled = true
                                recipes[effect.recipe].reload()
                            end
                        end
                    end
                end
            end
        end
    end
)
