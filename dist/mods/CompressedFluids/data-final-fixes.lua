local rusty_locale = require("rusty-locale.locale")
local rusty_icons = require("rusty-locale.icons")

if mods["CompressedFluids"] then
    local Func = require("utils.func")

    local hp_icon = {icon = "__CompressedFluids__/graphics/icons/overlay-HP-group.png", icon_size = 64, tint = {r = 0, g = 1, b = 0}}

    local function add_recipes_to_technologies(recipes)
        for technology, technology_table in pairs(data.raw.technology) do
            log(technology)
            if technology_table.effects then
                for effect, effect_table in pairs(technology_table.effects) do
                    if effect_table.type == "unlock-recipe" then
                        if effect_table.recipe and recipes[effect_table.recipe] then
                            table.insert(technology_table.effects, {type = "unlock-recipe", recipe = recipes[effect_table.recipe]})
                        end
                    end
                end
            end
        end
    end

    local function CheckProductivity(orig_recipe, new_recipe)
        for module_name, module_table in pairs(data.raw.module) do
            if module_table.limitation then
                if Func.contains(module_table.limitation, orig_recipe) then
                    if data.raw.recipe[new_recipe] then
                        table.insert(module_table.limitation, new_recipe)
                    end
                end
            end
        end
    end

    local function process_items(items)
        local flag = false
        for _, item in pairs(items) do
            if item.type and item.type == "fluid" then
                local hp_name = string.format("high-pressure-%s", item.name)
                if data.raw.fluid[hp_name] then
                    item.name = hp_name
                    item.amount = item.amount / settings.startup["fluid-compression-rate"].value
                    if item.amount_min then
                        item.amount_min = item.amount_min / settings.startup["fluid-compression-rate"].value
                    end
                    if item.amount_max then
                        item.amount_max = item.amount_max / settings.startup["fluid-compression-rate"].value
                    end

                    flag = true
                end
                log(item.name)
            end
        end
        return flag, items
    end

    local function parse_recipes()
        local parsed_recipes = {}
        local raw_recipes = table.deepcopy(data.raw.recipe)
        for recipe, recipe_table in pairs(raw_recipes) do
            local rv1, rv2, rv3, rv4
            local ingredients, results, expensive_ingredients, expensive_results

            if recipe_table.category == "fluid-decompressing" or recipe_table.category == "fluid-compressing" or recipe_table.subgroup == "empty-barrel" or recipe_table.subgroup == "fill-barrel" then
                -- do nothing
            else
                log(serpent.block(recipe_table))
                if recipe_table.normal then
                    ingredients = recipe_table.normal.ingredients
                    results = recipe_table.normal.results
                    if recipe_table.expensive then
                        expensive_ingredients = recipe_table.expensive.ingredients
                        expensive_results = recipe_table.expensive.results
                    else
                        expensive_ingredients = recipe_table.normal.ingredients
                        expensive_results = recipe_table.normal.results
                    end
                else
                    ingredients = recipe_table.ingredients
                    results = recipe_table.results
                    expensive_ingredients = ingredients
                    expensive_results = results
                end
                rv1, ingredients = process_items(ingredients)
                rv2, results = process_items(results)
                rv3, expensive_ingredients = process_items(expensive_ingredients)
                rv4, expensive_results = process_items(expensive_results)

                if rv1 or rv2 or rv3 or rv4 then
                    local recipe_icons = rusty_icons.of(recipe_table)
                    local recipe_locale = rusty_locale.of(recipe_table)

                    -- fluidHP.localised_name = {"fluid-name.compressed-fluid", fluid.localised_name or {"fluid-name."..fluid.name}}
                    recipe_table.localised_name = {"recipe-name.DSR_HighPressure", recipe_locale.name}

                    table.insert(recipe_icons, hp_icon)
                    recipe_table.icons = recipe_icons
                    local orig_name = recipe_table.name
                    recipe_table.name = string.format("DSR_HighPressure-%s", recipe_table.name)
                    data:extend({recipe_table})

                    CheckProductivity(orig_name, recipe_table.name)
                    parsed_recipes[orig_name] = recipe_table.name
                end
            end
        end

        return parsed_recipes
    end

    local parsed_recipes = parse_recipes()
    add_recipes_to_technologies(parsed_recipes)
end
