local Func = require("utils.func")
local Recipes = require("utils.recipes")
local rusty_locale = require("rusty-locale.locale")
local rusty_icons = require("rusty-locale.icons")
local rusty_recipes = require("rusty-locale.recipes")

if mods["CompressedFluids"] then
    local hp_icon = {icon = "__CompressedFluids__/graphics/icons/overlay-HP-group.png", icon_size = 64, tint = {r = 0, g = 1, b = 0}}

    local scale_up_factor
    if settings.startup["override_fluid_only_recipes"] then
        if settings.startup["override_fluid_only_recipes"].value > 0 then
            scale_up_factor = settings.startup["override_fluid_only_recipes"].value
        else
            scale_up_factor = settings.startup["fluid-compression-rate"].value
        end
    end

    local function scale_up_fluid_only_recipe(items)
        for _, item in pairs(items) do
            if item.amount then
                item.amount = item.amount * scale_up_factor
            end
            if item.amount_min then
                item.amount_min = item.amount_min * scale_up_factor
            end
            if item.amount_max then
                item.amount_max = item.amount_max * scale_up_factor
            end
        end
    end

    local function add_recipes_to_technologies(recipes)
        for technology, technology_table in pairs(data.raw.technology) do
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
        local hp_fluid_only = true
        local flag = false
        if items then
            for _, item in pairs(items) do
                if item.type and item.type == "fluid" then
                    local hp_name = string.format("high-pressure-%s", item.name)
                    if data.raw.fluid[hp_name] then
                        -- Some of the compressed fluids do not have matching temperature ranges as the base fluid
                        if item.temperature then
                            if data.raw.fluid[hp_name].max_temperature and data.raw.fluid[hp_name].default_temperature then
                                if item.temperature > data.raw.fluid[hp_name].max_temperature or item.temperature < data.raw.fluid[hp_name].default_temperature then
                                    flag = "abort"
                                end
                            end
                        end
                    end
                end
            end

            if flag == false then
                for _, item in pairs(items) do
                    if item.type and item.type == "fluid" then
                        local hp_name = string.format("high-pressure-%s", item.name)
                        if data.raw.fluid[hp_name] then
                            item.name = hp_name
                            if item.amount then
                                item.amount = item.amount / settings.startup["fluid-compression-rate"].value
                                flag = true
                            end
                            if item.amount_min then
                                item.amount_min = item.amount_min / settings.startup["fluid-compression-rate"].value
                                flag = true
                            end
                            if item.amount_max then
                                item.amount_max = item.amount_max / settings.startup["fluid-compression-rate"].value
                                flag = true
                            end
                        elseif Func.starts_with(item.name, "high-pressure") then
                            -- do nothing
                        else
                            hp_fluid_only = false
                        end
                    else
                        hp_fluid_only = false
                    end
                end
            end
        end
        return flag, hp_fluid_only, items
    end

    local function parse_recipes()
        log(serpent.block(data.raw.recipe["advanced-oil-processing"]))
        local parsed_recipes = {}
        local raw_recipes = util.table.deepcopy(data.raw.recipe)
        for _, recipe_table in pairs(raw_recipes) do
            local rv1a, rv2a, rv3a, rv4a
            local rv1b, rv2b, rv3b, rv4b
            local ingredients, results, expensive_ingredients, expensive_results

            if recipe_table.category == "fluid-decompressing" or recipe_table.category == "fluid-compressing" or recipe_table.subgroup == "empty-barrel" or recipe_table.subgroup == "fill-barrel" then
                -- do nothing
            else
                Recipes.standardize_recipe(recipe_table)

                local recipe_icons = rusty_icons.of(recipe_table)
                local recipe_locale = rusty_locale.of(recipe_table)
                local recipe_main_product = rusty_recipes.get_main_product(recipe_table)

                rv1a, rv1b, ingredients = process_items(recipe_table.normal.ingredients)
                rv2a, rv2b, results = process_items(recipe_table.normal.results)
                rv3a, rv3b, expensive_ingredients = process_items(recipe_table.expensive.ingredients)
                rv4a, rv4b, expensive_results = process_items(recipe_table.expensive.results)

                if rv1b and rv2b and rv3b and rv4b then
                    -- if all the items to the recipes are valid high-pressure fluids
                    scale_up_fluid_only_recipe(ingredients)
                    scale_up_fluid_only_recipe(results)
                    scale_up_fluid_only_recipe(expensive_ingredients)
                    scale_up_fluid_only_recipe(expensive_results)
                    local energy_required = recipe_table.energy_required or recipe_table.normal.energy_required or 0.5
                    recipe_table.normal.energy_required = energy_required * scale_up_factor
                    recipe_table.expensive.energy_required = energy_required * scale_up_factor
                end

                if rv1a == "abort" or rv2a == "abort" or rv3a == "abort" or rv4a == "abort" then
                    -- bail out of recipe creation
                elseif (rv1a or rv2a or rv3a or rv4a) and recipe_icons then
                    -- fluidHP.localised_name = {"fluid-name.compressed-fluid", fluid.localised_name or {"fluid-name."..fluid.name}}
                    recipe_table.localised_name = {"recipe-name.DSR_HighPressure", recipe_locale.name}

                    -- Have to do some coding when main_product has been declared
                    if recipe_table.normal.main_product and recipe_table.normal.main_product ~= "" then
                        local suggested_main_product
                        if recipe_main_product and recipe_main_product.type == "fluid" then
                            if Func.starts_with(recipe_main_product.name, "high-pressure") then
                                suggested_main_product = recipe_main_product.name
                            else
                                suggested_main_product = string.format("high-pressure-%s", recipe_main_product.name)
                            end
                        elseif data.raw.fluid[recipe_table.normal.main_product] then
                            if Func.starts_with(recipe_table.normal.main_product, "high-pressure") then
                                suggested_main_product = recipe_table.normal.main_product
                            else
                                suggested_main_product = string.format("high-pressure-%s", recipe_table.normal.main_product)
                            end
                        end

                        -- make sure the suggested_main_product is in the list of results
                        if suggested_main_product then
                            local flag1, flag2 = false, false
                            for _, item in pairs(results) do
                                if item.type and item.type == "fluid" then
                                    if item.name == suggested_main_product then
                                        flag1 = true
                                    end
                                end
                            end
                            if Func.is_empty(expensive_results) then
                                flag2 = true
                            else
                                for _, item in pairs(expensive_results) do
                                    if item.type and item.type == "fluid" then
                                        if item.name == suggested_main_product then
                                            flag2 = true
                                        end
                                    end
                                end
                            end
                            if flag1 and flag2 then
                                recipe_table.main_product = suggested_main_product
                                recipe_table.normal.main_product = suggested_main_product
                                recipe_table.expensive.main_product = suggested_main_product
                            end
                        end
                    end

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
