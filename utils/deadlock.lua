local rusty_locale = require("__rusty-locale__.locale")
local rusty_icons = require("__rusty-locale__.icons")
local rusty_recipes = require("__rusty-locale__.recipes")
local rusty_prototypes = require("__rusty-locale__.prototypes")

local logger = require("utils/logging").logger

local Func = require("utils.func")
local Deadlock = {}

local item_cache = {}
local item_types = {
    "item",
    "fluid",
    "ammo",
    "tool",
    "module",
    "capsule",
    "gun",
    "repair-tool",
    "armor",
    "rail-planner",
    "item-with-entity-data"
}

---Find an item in cache
---@param name string
---@return table
local function find_item(name)
    if not item_cache[name] then
        for _, item_type in ipairs(item_types) do
            if data.raw[item_type] and data.raw[item_type][name] then
                item_cache[name] = data.raw[item_type][name]
            end
        end
    end
    return item_cache[name]
end

---Reformat string ingredient into table using key/value pairs
---@param ingredient string|table
---@param result_count integer
---@return table
local function format(ingredient, result_count)
    local object
    if type(ingredient) == "table" then
        if ingredient.valid and ingredient:is_valid() then
            return ingredient
        elseif ingredient.name then
            if data.raw[ingredient.type] and data.raw[ingredient.type][ingredient.name] then
                object = table.deepcopy(ingredient)
                if not object.amount and not (object.amount_min and object.amount_max and object.probability) then
                    error("Result table requires amount or probabilities")
                end
            end
        elseif #ingredient > 0 then
            -- Can only be item types not fluid
            local item = find_item(ingredient[1])
            if item then
                object = {
                    type = item.type,
                    name = ingredient[1],
                    amount = ingredient[2] or 1
                }
            end
        end
    elseif type(ingredient) == "string" then
        -- Our shortcut so we need to check it
        local item = find_item(ingredient)
        if item then
            object = {
                type = item.type == "fluid" and "fluid" or "item",
                name = ingredient,
                amount = result_count or 1
            }
        end
    end
    return object
end

---Replace ingredient old for new
---@param ingredients table
---@param orig_item string
---@param new_item string
local function replace_ingredient(ingredients, orig_item, new_item)
    for _, ingredient in pairs(ingredients) do
        if ingredient then
            if ingredient.name == orig_item then
                ingredient.name = new_item
            end
            if ingredient[1] == orig_item then
                ingredient[1] = new_item
            end
        end
    end
end

---Convert recipe results into a table of key/values
---@param recipe LuaRecipePrototype
local function convert_results(recipe)
    if recipe.normal and recipe.normal.result then
        recipe.normal.results = { format(recipe.normal.result, recipe.normal.result_count or 1) }
        recipe.normal.result = nil
        recipe.normal.result_count = nil
    end

    if recipe.expensive and recipe.expensive.result then
        recipe.expensive.results = { format(recipe.expensive.result, recipe.expensive.result_count or 1) }
        recipe.expensive.result = nil
        recipe.expensive.result_count = nil
    end

    if recipe.result then
        recipe.results = { format(recipe.result, recipe.result_count or 1) }
        recipe.result = nil
        recipe.result_count = nil
    end
end

local function FixRecipeLocalisedNames()
    for recipe_name, recipe_table in pairs(data.raw.recipe) do
        if Func.starts_with(recipe_name, "StackedRecipe") then
            logger("1", "FixRecipeLocalisedNames " .. recipe_name)
            local parent_name = string.sub(recipe_name, 15)

            local locale = rusty_locale.of(data.raw.recipe[parent_name])
            -- recipe_table.localised_name = {"recipe-name.deadlock-stacking-stack", locale.name}
            recipe_table.localised_name = { "recipe-name.DSR_Recipe", locale.name }
            logger("2", string.format("FixRecipeLocalisedNames .. %s .. %s", recipe_name, serpent.block(locale.name)))
        end
    end
end

local function FixItemLocalisedNames()
    for item_name, item_table in pairs(data.raw.item) do
        if string.match(item_name, "deadlock%-stack%-") then
            local parent_item = string.sub(item_name, 16)
            local parent = data.raw.item[parent_item]
            if parent then
                logger("1", parent.name)
                local locale = rusty_locale.of_item(parent)
                if Func.has_key(item_table, "localised_name") then
                    item_table.localised_name[2] = locale.name
                end
                if data.raw.recipe["deadlock-stacks-stack-" .. parent.name] then
                    logger("1", data.raw.recipe["deadlock-stacks-stack-" .. parent.name].name)
                    data.raw.recipe["deadlock-stacks-stack-" .. parent.name].localised_name[2] = locale.name
                end
                if data.raw.recipe["deadlock-stacks-unstack-" .. parent.name] then
                    logger("1", data.raw.recipe["deadlock-stacks-unstack-" .. parent.name].name)
                    data.raw.recipe["deadlock-stacks-unstack-" .. parent.name].localised_name[2] = locale.name
                end
                logger("2", string.format("FixItemLocalisedNames .. %s .. %s", item_name, serpent.block(locale.name)))
            end
        end
    end
end

function Deadlock.FixFuel()
    local deadlock_stack_size = settings.startup["deadlock-stack-size"].value ---@cast deadlock_stack_size integer

    for item_name, item_table in pairs(data.raw.item) do
        if string.match(item_name, "deadlock%-stack%-") then
            local parent_item = string.sub(item_name, 16)
            if data.raw.item[parent_item] and data.raw.item[parent_item].fuel_value then
                local parent = data.raw.item[parent_item]
                item_table.fuel_category = parent.fuel_category
                item_table.fuel_acceleration_multiplier = parent.fuel_acceleration_multiplier
                item_table.fuel_top_speed_multiplier = parent.fuel_top_speed_multiplier
                item_table.fuel_emissions_multiplier = parent.fuel_emissions_multiplier
                item_table.fuel_value = Func.multiply_number_unit(parent.fuel_value, deadlock_stack_size)
            end
            if data.raw.item[parent_item] and data.raw.item[parent_item].burnt_result then
                if item_table.burnt_result == nil then
                    local burnt_result = "deadlock-stack-" .. data.raw.item[parent_item].burnt_result
                    if data.raw.item[burnt_result] then
                        item_table.burnt_result = "deadlock-stack-" .. data.raw.item[parent_item].burnt_result
                    end
                end
            end
        end
    end
end

function Deadlock.FixLocalisedNames()
    FixItemLocalisedNames()
    FixRecipeLocalisedNames()
end

function Deadlock.ReOrderTechnologyBehindBeacons()
    local rank = {
        -- Vanilla
        ["automation-science-pack"] = 10,
        ["logistic-science-pack"] = 20,
        ["military-science-pack"] = 30,
        ["chemical-science-pack"] = 40,
        ["production-science-pack"] = 50,
        ["utility-science-pack"] = 9999,
        ["space-science-pack"] = 9999,
        --K2
        ["basic-tech-card"] = 5,
        ["matter-tech-card"] = 9999,
        ["advanced-tech-card"] = 9999,
        ["singularity-tech-card"] = 9999,
        -- SE
        ["se-rocket-science-pack"] = 9999,
        ["se-astronomic-science-pack-1"] = 9999,
        ["se-astronomic-science-pack-2"] = 9999,
        ["se-astronomic-science-pack-3"] = 9999,
        ["se-astronomic-science-pack-4"] = 9999,
        ["se-biological-science-pack-1"] = 9999,
        ["se-biological-science-pack-2"] = 9999,
        ["se-biological-science-pack-3"] = 9999,
        ["se-biological-science-pack-4"] = 9999,
        ["se-deep-space-science-pack-1"] = 9999,
        ["se-deep-space-science-pack-2"] = 9999,
        ["se-deep-space-science-pack-3"] = 9999,
        ["se-deep-space-science-pack-4"] = 9999,
        ["se-energy-science-pack-1"] = 9999,
        ["se-energy-science-pack-2"] = 9999,
        ["se-energy-science-pack-3"] = 9999,
        ["se-energy-science-pack-4"] = 9999,
        ["se-material-science-pack-1"] = 9999,
        ["se-material-science-pack-2"] = 9999,
        ["se-material-science-pack-3"] = 9999,
        ["se-material-science-pack-4"] = 9999,
        -- Bobs
        ["advanced-logistic-science-pack"] = 9999,
        ["science-pack-gold"] = 9999,
        ["alien-science-pack"] = 9999,
        ["alien-science-pack-blue"] = 9999,
        ["alien-science-pack-green"] = 9999,
        ["alien-science-pack-orange"] = 9999,
        ["alien-science-pack-purple"] = 9999,
        ["alien-science-pack-red"] = 9999,
        ["alien-science-pack-yellow"] = 9999,
        ["effectivity-processor"] = 9999,
        ["module-case"] = 9999,
        ["module-circuit-board"] = 9999,
        ["pollution-clean-processor"] = 9999,
        ["pollution-create-processor"] = 9999,
        ["productivity-processor"] = 9999,
        ["speed-processor"] = 9999,
        ["token-bio"] = 9999
    }

    local track_touched = {}

    for _, tech in pairs(data.raw.technology) do
        if Func.starts_with(tech.name, "dsr-technology") then
            -- skip
        else
            local max_pack = 0
            if tech.unit and tech.unit.ingredients then
                for _, row in pairs(tech.unit.ingredients) do
                    local pack = row[1] or row.name
                    if rank[pack] and rank[pack] > max_pack then
                        max_pack = rank[pack]
                    end
                end
            end

            if max_pack ~= 9999 then
                local dsr_tech
                for k, v in pairs(rank) do
                    if v == max_pack then
                        dsr_tech = "dsr-technology-" .. k
                    end
                end

                if tech.effects and data.raw.technology[dsr_tech] then
                    local effects = {}
                    for _, effect in pairs(tech.effects) do
                        if effect.type == "unlock-recipe" and (Func.starts_with(effect.recipe, "StackedRecipe-") or Func.starts_with(effect.recipe, "DSR_HighPressure-")) then
                            table.insert(data.raw.technology[dsr_tech].effects, { type = "unlock-recipe", recipe = effect.recipe })
                            track_touched[effect.recipe] = true
                        else
                            table.insert(effects, effect)
                        end
                    end
                    tech.effects = effects
                end
            else
                if tech.effects then
                    for _, effect in pairs(tech.effects) do
                        if effect.type == "unlock-recipe" and (Func.starts_with(effect.recipe, "StackedRecipe-") or Func.starts_with(effect.recipe, "DSR_HighPressure-")) then
                            track_touched[effect.recipe] = true
                        end
                    end
                end
            end
        end
    end

    for _, recipe in pairs(data.raw.recipe) do
        if (Func.starts_with(recipe.name, "StackedRecipe-") or Func.starts_with(recipe.name, "DSR_HighPressure-")) and not track_touched[recipe.name] then
            table.insert(data.raw.technology["dsr-technology-automation-science-pack"].effects, { type = "unlock-recipe", recipe = recipe.name })
            if recipe.normal then
                recipe.normal.enabled = false
            end
            if recipe.expensive then
                recipe.expensive.enabled = false
            end
            recipe.enabled = false
        end
    end
end

function Deadlock.HideRecipes()
    if settings.startup["Hide_DSR_recipes"].value then
        for recipe, recipe_table in pairs(data.raw.recipe) do
            if Func.starts_with(recipe, "StackedRecipe") or Func.starts_with(recipe, "DSR_HighPressure") then
                logger("1", "hide_from_player_crafting .. " .. tostring(settings.startup["Hide_DSR_recipes"].value))
                recipe_table.hide_from_player_crafting = true
                if recipe_table.normal then
                    recipe_table.normal.hide_from_player_crafting = true
                end
                if recipe_table.expensive then
                    recipe_table.expensive.hide_from_player_crafting = true
                end
            end
        end
    end
end

function Deadlock.DensityOverride()
    if settings.startup["override_stacking_size"].value then
        local deadlock_stack_size = settings.startup["deadlock-stack-size"].value
        local RecipeMultiplier = 1
        if settings.startup["deadlock-stacking-batch-stacking"].value then
            RecipeMultiplier = 4
        end

        for k, _ in pairs(data.raw.recipe) do
            if Func.starts_with(k, "deadlock-stacks-unstack-") then
                if data.raw.recipe[k].result_count then
                    local items = data.raw.recipe[k].result_count / RecipeMultiplier
                    if items < deadlock_stack_size then
                        data.raw.recipe[k].result_count = deadlock_stack_size * RecipeMultiplier
                    end
                end

                if data.raw.recipe[k].results and #data.raw.recipe[k].results > 0 then
                    local items = data.raw.recipe[k].results[1].amount / RecipeMultiplier
                    if items < deadlock_stack_size then
                        data.raw.recipe[k].results[1].amount = deadlock_stack_size * RecipeMultiplier
                    end
                end
            end
            if Func.starts_with(k, "deadlock-stacks-stack-") then
                if data.raw.recipe[k].ingredients and #data.raw.recipe[k].ingredients > 0 then
                    if data.raw.recipe[k].ingredients[1].amount then
                        local items = data.raw.recipe[k].ingredients[1].amount / RecipeMultiplier
                        if items < deadlock_stack_size then
                            data.raw.recipe[k].ingredients[1].amount = deadlock_stack_size * RecipeMultiplier
                        end
                    elseif #data.raw.recipe[k].ingredients[1] >= 2 then
                        local items = data.raw.recipe[k].ingredients[1][2] / RecipeMultiplier
                        if items < deadlock_stack_size then
                            data.raw.recipe[k].ingredients[1][2] = deadlock_stack_size * RecipeMultiplier
                        end
                    end
                end
            end
        end

        local types = { "item", "tool", "rail-planner", "ammo", "module", "capsule" }
        for k, _ in pairs(data.raw.item) do
            if string.match(k, "deadlock%-stack%-") then
                local parent_item
                local parent_name = string.sub(k, 16)
                for _, type in pairs(types) do
                    if data.raw[type][parent_name] then
                        parent_item = data.raw[type][parent_name]
                    end
                end

                if parent_item then
                    local stack_size
                    local parent_stack_size = parent_item.stack_size
                    local child_stack_size = data.raw.item[k].stack_size

                    stack_size = parent_stack_size
                    -- stack_size = deadlock_stack_size
                    -- if parent_stack_size > deadlock_stack_size then
                    --     stack_size = parent_stack_sizead
                    -- end
                    -- if child_stack_size < deadlock_stack_size then
                    --     -- stack_size = deadlock_stack_size
                    --     stack_size = parent_stack_size
                    -- end

                    data.raw.item[k].stack_size = stack_size
                    if Func.has_key(data.raw.item[k], "localised_name") then
                        data.raw.item[k].localised_name[3] = deadlock_stack_size
                    end

                    logger("1", string.format("DensityOverride .. %s .. %s .. %s", type, k, data.raw.item[k].stack_size))
                end
            end
        end
    end
end

function Deadlock.FixResearchTree()
    local recipes = {}
    for recipe, _ in pairs(data.raw.recipe) do
        local StackedRecipe = "StackedRecipe-" .. recipe
        if data.raw.recipe[StackedRecipe] then
            recipes[recipe] = StackedRecipe
        end
    end

    for tech, tech_table in pairs(data.raw.technology) do
        local enabled = true
        if tech_table.enabled ~= nil then
            enabled = tech_table.enabled
        end
        if enabled and tech_table.effects then
            local recipes_to_unlock = {}
            for _, effect in pairs(tech_table.effects) do
                if effect.type and effect.type == "unlock-recipe" then
                    recipes_to_unlock[effect.recipe] = true
                end
            end

            for _, effect in pairs(tech_table.effects) do
                if effect.type and effect.type == "unlock-recipe" then
                    if recipes[effect.recipe] then
                        for _, recipe in pairs({ "StackedRecipe-" .. effect.recipe, "deadlock-stacks-stack-" .. effect.recipe, "deadlock-stacks-unstack-" .. effect.recipe }) do
                            if data.raw.recipe[recipe] and not recipes_to_unlock[recipe] then
                                table.insert(tech_table.effects, { recipe = recipe, type = "unlock-recipe" })
                            end
                        end
                    end
                end
            end
        end
    end
end

local function MakeSubGroup(name, order)
    local current_group = data.raw["item-subgroup"][name].group
    local current_order = data.raw["item-subgroup"][name].order or order
    local new_subgroup
    local subgroup

    new_subgroup = name .. "-Stacked"
    if settings.startup["dsr_new_subgroup_placement"].value then
        if not data.raw["item-subgroup"][new_subgroup] then
            subgroup = { type = "item-subgroup", name = new_subgroup, group = current_group, order = current_order .. "Stacked" }
        end
    else
        if not data.raw["item-subgroup"][new_subgroup] then
            subgroup = { type = "item-subgroup", name = new_subgroup, group = "Stacked_Recipes", order = new_subgroup }
        end
    end
    if subgroup then
        data:extend({ subgroup })
    end
    return new_subgroup
end

-- local function ConvertToStackedItems(ingredients)
--     for _, ingredient in pairs(ingredients) do
--         if ingredient.name then
--             ingredient.name = string.format("deadlock-stack-%s", ingredient.name)
--         else
--             ingredient[1] = string.format("deadlock-stack-%s", ingredient[1])
--         end
--     end

--     return ingredients
-- end

---Replace results
---@param results table
---@return boolean
---@return table
local function ReplaceResult(results)
    local bAllGood = true
    for _, result in pairs(results) do
        local name
        if result.name then
            name = result.name
        else
            name = result[1]
        end
        if Func.starts_with(name, "deadlock-stack-") then
            logger("3", string.format("Result .. %s .. is already a stacked item", name))
        else
            local StackedIngredient = string.format("deadlock-stack-%s", name)
            if data.raw.item[StackedIngredient] then
                if result.name then
                    result.name = StackedIngredient
                else
                    result[1] = StackedIngredient
                end
            else
                if result.type == "fluid" then
                    local multiplier = settings.startup["deadlock-stack-size"].value
                    if result.amount then
                        result.amount = result.amount * multiplier
                    end
                    if result.amount_min then
                        result.amount_min = result.amount_min * multiplier
                    end
                    if result.amount_max then
                        result.amount_max = result.amount_max * multiplier
                    end
                    if result.catalyst_amount then
                        result.catalyst_amount = result.catalyst_amount * multiplier
                    end
                else
                    bAllGood = false
                end
            end
        end
    end
    return bAllGood, results
end

local function CheckStackedProductivity(orig)
    logger("1", string.format("CheckStackedProductivity .. %s", orig))
    for module_name, module_table in pairs(data.raw.module) do
        if module_table.limitation then
            if Func.contains(module_table.limitation, orig) then
                local StackedRecipe = string.format("StackedRecipe-%s", orig)
                if data.raw.recipe[StackedRecipe] then
                    table.insert(module_table.limitation, StackedRecipe)
                    logger("2", string.format("CheckStackedProductivity .. add .. %s .. to %s", StackedRecipe, module_name))
                end
            end
        end
    end
end

---Scale up Fluid values to match stacking multiplier
---@param ingredients table
---@param fluid_to_find string
---@param multiplier number
local function ScaleUpFluidIngredients(ingredients, fluid_to_find, multiplier)
    for _, ingredient in pairs(ingredients) do
        local name
        if ingredient.name then
            name = ingredient.name
        else
            name = ingredient[1]
        end
        if name == fluid_to_find then
            ingredient.amount = ingredient.amount * multiplier
        end
    end
end

---Process ingredients from recipe
---@param src_ingredients Ingredient[]
---@param dst_ingredients Ingredient[]
local function Processingredients(src_ingredients, dst_ingredients)
    local Multiplier = settings.startup["deadlock-stack-size"].value ---@cast Multiplier integer
    for _, ingredient in pairs(src_ingredients) do
        if ingredient then
            local name
            if ingredient.name then
                name = ingredient.name
            else
                name = ingredient[1]
            end
            local StackedIngredient = string.format("deadlock-stack-%s", name)
            if data.raw.item[StackedIngredient] then
                logger("5", string.format("Adding %s to new recipe", StackedIngredient))
                replace_ingredient(dst_ingredients, name, StackedIngredient)
            end
            if ingredient.type and ingredient.type == "fluid" then
                logger("5", string.format("Adding %s to new recipe", name))
                ScaleUpFluidIngredients(dst_ingredients, name, Multiplier)
            end
        end
    end
end

---Fix results and set energy_required correctly
---@param recipe LuaRecipePrototype
---@param Multiplier integer
---@return boolean
local function FixResults(recipe, Multiplier)
    local NewRecipeResultsFlag = true
    rv, recipe.results = ReplaceResult(recipe.results)
    if rv then
        if recipe.energy_required then
            recipe.energy_required = recipe.energy_required * Multiplier
        else
            recipe.energy_required = 0.5 * Multiplier
        end
    else
        NewRecipeResultsFlag = false
    end
    return NewRecipeResultsFlag
end

---If used update main_product to stacked version
---@param recipe LuaRecipePrototype
local function FixMainProduct(recipe)
    logger("6", "main_product .. " .. recipe.main_product)
    StackedProduct = string.format("deadlock-stack-%s", recipe.main_product)
    if data.raw.item[StackedProduct] then
        recipe.main_product = StackedProduct
        logger("5", string.format("main_product .. %s .. set on recipe", StackedProduct))
    else
        logger("5", string.format("no stacked version of main_product found  .. %s", StackedProduct))
    end
end

---If used update main_product to stacked version
---@param recipe LuaRecipePrototype
local function FindFirstResult(recipe)
    if recipe.results and #recipe.results > 0 then
        for _, result in pairs(recipe.results) do
            if result then return result.name or result[1] end
        end
    end
    return nil
end

---Make stacked reipe from base recipe
---@param recipe LuaRecipePrototype:LuaObject
local function MakeStackedRecipe(recipe)
    local StackedRecipeName = string.format("StackedRecipe-%s", recipe)
    local OrigRecipe = Func.deepcopy(data.raw.recipe[recipe])
    local NewRecipe = Func.deepcopy(data.raw.recipe[recipe])

    -- Clean up results so they are a standard format
    NewRecipe.name = StackedRecipeName
    convert_results(OrigRecipe)
    convert_results(NewRecipe)
    local Multiplier = settings.startup["deadlock-stack-size"].value ---@cast Multiplier integer

    -- Grab all the ingredients of the orignal recipe and replace with stacked versions
    logger("4", "Processing ingredients")
    if OrigRecipe.ingredients then Processingredients(OrigRecipe.ingredients, NewRecipe.ingredients) end
    if OrigRecipe.normal and OrigRecipe.normal.ingredients then Processingredients(OrigRecipe.normal.ingredients, NewRecipe.normal.ingredients) end
    if OrigRecipe.expensive and OrigRecipe.expensive.ingredients then Processingredients(OrigRecipe.expensive.ingredients, NewRecipe.expensive.ingredients) end

    -- Grab all the results of the orignal recipe and replace with stacked versions
    logger("4", "Processing new recipe results")
    local NewRecipeResultsFlag = false

    if NewRecipe.results and #NewRecipe.results > 0 then NewRecipeResultsFlag = FixResults(NewRecipe, Multiplier) end
    if NewRecipe.normal and NewRecipe.normal.results and #NewRecipe.normal.results > 0 then NewRecipeResultsFlag = FixResults(NewRecipe.normal, Multiplier) end
    if NewRecipe.expensive and NewRecipe.expensive.results and #NewRecipe.expensive.results > 0 then NewRecipeResultsFlag = FixResults(NewRecipe.expensive, Multiplier) end
    logger("5", string.format("NewRecipeResultsFlag = %s", NewRecipeResultsFlag))

    -- Main Product1
    logger("4", "Processing new recipe main_product")
    local StackedProduct = nil
    if NewRecipe.main_product then FixMainProduct(NewRecipe) end
    if NewRecipe.normal and NewRecipe.normal.main_product then FixMainProduct(NewRecipe.normal) end
    if NewRecipe.expensive and NewRecipe.expensive.main_product then FixMainProduct(NewRecipe.expensive) end
    logger("5", string.format("StackedProduct = %s", StackedProduct))

    -- Results
    logger("4", "Processing new recipe results")
    local OrigMainProduct
    if OrigRecipe.results then OrigMainProduct = FindFirstResult(OrigRecipe) end
    if OrigRecipe.normal and OrigRecipe.normal.results then OrigMainProduct = FindFirstResult(OrigRecipe.normal) end
    logger("5", string.format("OrigMainProduct = %s", OrigMainProduct))

    -- Unstack stuff
    local unstack_recipe = string.format("deadlock-stacks-unstack-%s", OrigMainProduct)
    local DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
    if DeadlockUnStackRecipe and DeadlockUnStackRecipe.subgroup then
        NewRecipe.subgroup = DeadlockUnStackRecipe.subgroup
    end

    -- -- Stacked Icon for Stacked Recipe
    -- logger("4", "Processing new recipe icon")
    local base_icon = "__deadlock_stacked_recipes__/graphics/blank_64.png"
    local dsr_icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png"
    local recipe_icons = rusty_icons.of_recipe(data.raw.recipe[OrigRecipe.name])

    -- First look to see if recipe has an icon defined
    NewRecipe.icons = {}
    table.insert(NewRecipe.icons, { icon = base_icon, icon_size = 64 })
    if data.raw.recipe[OrigRecipe.name] and data.raw.recipe[OrigRecipe.name].icons then
        for _, layer in pairs(data.raw.recipe[OrigRecipe.name].icons) do
            table.insert(NewRecipe.icons, layer)
        end
    elseif data.raw.recipe[OrigRecipe.name] and data.raw.recipe[OrigRecipe.name].icon then
        table.insert(NewRecipe.icons, { icon = data.raw.recipe[OrigRecipe.name].icon, icon_size = data.raw.recipe[OrigRecipe.name].icon_size, icon_scale = 64 / data.raw.recipe[OrigRecipe.name].icon_size })
    elseif #recipe_icons > 0 then
        for _, layer in pairs(recipe_icons) do
            table.insert(NewRecipe.icons, layer)
        end
    end
    table.insert(NewRecipe.icons, { icon = dsr_icon, icon_size = 64 })
    NewRecipe.icon = nil

    local subgroup
    local order
    local main_product = rusty_recipes.get_main_product(data.raw.recipe[OrigRecipe.name])

    if main_product then
        if not data.raw[main_product.type][main_product.name] then
            local prototypes = rusty_prototypes.find_by_name(main_product.name)
            for k, v in pairs(prototypes) do
                if data.raw[k][v.name].subgroup then
                    subgroup = data.raw[k][v.name].subgroup
                    order = order or data.raw[k][v.name].order
                end
            end
        else
            subgroup = data.raw[main_product.type][main_product.name].subgroup
            order = order or data.raw[main_product.type][main_product.name].order
            if not subgroup and main_product.type == "fluid" then
                subgroup = "fluid"
            end
        end
    end

    if data.raw.recipe[OrigRecipe.name].subgroup then
        subgroup = data.raw.recipe[OrigRecipe.name].subgroup
        order = data.raw.recipe[OrigRecipe.name].order or order
    elseif not subgroup then
        logger("1", "hmm")
    end

    NewRecipe.order = order
    if subgroup then
        NewRecipe.subgroup = MakeSubGroup(subgroup, order)
    end

    if NewRecipeResultsFlag then
        logger("1", "adding recipe .. " .. NewRecipe.name)
        data:extend({ NewRecipe })
        CheckStackedProductivity(recipe)
        logger("8", serpent.block(data.raw.recipe[NewRecipe.name]))
    else
        logger("1", "failed to add recipe .. " .. NewRecipe.name)
    end
end

-- Go though each recipe to see if all ingredients / products are stacked,  if so then make a stacked recipe version of it
function Deadlock.MakeStackedRecipes()
    for recipe_name, recipe_table in pairs(data.raw.recipe) do
        logger("1", string.format("000 MakeStackedRecipes %s", recipe_name))
        if Func.starts_with(recipe_name, "StackedRecipe") or Func.starts_with(recipe_name, "kr-vc-") or Func.starts_with(recipe_name, "deadlock-stacks-stack") or Func.starts_with(recipe_name, "deadlock-stacks-unstack") or Func.starts_with(recipe_name, "spidertron-remote") or Func.starts_with(recipe_name, "sp-spidertron-patrol-remote") then
            logger("1", string.format("Skipping recipe .. %s", recipe_name.name))
        else
            local SomethingStacked = false
            local StackedIngredientsFound = true
            local StackedResultsFound = true
            local ingredients = nil
            local expensive_ingredients
            local results = {}

            if data.raw.recipe[recipe_name].normal and not data.raw.recipe[recipe_name].expensive then
                data.raw.recipe[recipe_name].expensive = data.raw.recipe[recipe_name].normal
            end
            local FixedRecipe = table.deepcopy(data.raw.recipe[recipe_name])
            convert_results(FixedRecipe)

            if recipe_table.ingredients then
                logger("2", string.format("recipe_table.ingredients matched for %s", recipe_name))
                ingredients = recipe_table.ingredients
            end
            if recipe_table.normal then
                logger("2", string.format("recipe_table.normal matched for %s", recipe_name))
                ingredients = recipe_table.normal.ingredients
                if recipe_table.expensive and recipe_table.expensive.ingredients then
                    expensive_ingredients = recipe_table.expensive.ingredients
                else
                    expensive_ingredients = recipe_table.normal.ingredients
                end
            end

            if ingredients == nil then
                ingredients = nil
            end

            -- examine main_product if defined
            if recipe_table.main_product and data.raw.item[recipe_table.main_product] then
                local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", recipe_table.main_product)]
                if not DeadlockItem then
                    logger("1", "main_product can not be found as a stacked item .. " .. recipe_table.main_product)
                    StackedResultsFound = false
                else
                    logger("2", "main_product found .. " .. DeadlockItem.name)
                end
            end
            -- look though expensive_ingredients for stacked version
            if expensive_ingredients then
                for _, ingredient in pairs(expensive_ingredients) do
                    local name
                    if ingredient.name then
                        name = ingredient.name
                    else
                        name = ingredient[1]
                    end
                    logger("2", string.format("recipe (%s) has expensive_ingredients (%s)", recipe_name, name))
                    local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", name)]
                    if not DeadlockItem then
                        if ingredient.type and ingredient.type == "fluid" then
                            -- do nothing
                        else
                            logger("2", string.format("recipe (%s) missing stacked expensive_ingredients (%s)", recipe_name, string.format("deadlock-stack-%s", name)))
                            StackedIngredientsFound = false
                        end
                    else
                        SomethingStacked = true
                        logger("1", "Stacked expensive_ingredients found .. " .. DeadlockItem.name)
                    end
                end
            end
            -- look though ingredients for stacked version
            if ingredients then
                for _, ingredient in pairs(ingredients) do
                    local name
                    if ingredient.name then
                        name = ingredient.name
                    else
                        name = ingredient[1]
                    end
                    logger("2", string.format("recipe (%s) has ingredient (%s)", recipe_name, name))
                    local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", name)]
                    if not DeadlockItem then
                        if ingredient.type and ingredient.type == "fluid" then
                            -- do nothing
                        else
                            logger("2", string.format("recipe (%s) missing stacked ingredient (%s)", recipe_name, string.format("deadlock-stack-%s", name)))
                            StackedIngredientsFound = false
                        end
                    else
                        SomethingStacked = true
                        logger("1", "Stacked ingredient found .. " .. DeadlockItem.name)
                    end
                end
            end

            -- look though results for stacked version
            if FixedRecipe.results then
                if #FixedRecipe.results > 0 then
                    results = FixedRecipe.results
                    for _, product in pairs(results) do
                        local product_name = product.name or product[1] or nil
                        if product_name then
                            local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", product_name)] or data.raw.tool[string.format("deadlock-stack-%s", product_name)]
                            if not DeadlockItem then
                                if product.type == "fluid" then
                                    -- do nothing
                                    logger("2", "fluid .. " .. product_name)
                                else
                                    logger("1", string.format("recipe (%s) missing stacked result (%s)", recipe_table, string.format("deadlock-stack-%s", product_name)))
                                    StackedResultsFound = false
                                end
                            else
                                SomethingStacked = true
                                logger("1", "Stacked result found " .. DeadlockItem.name)
                            end
                        end
                    end
                else
                    StackedResultsFound = false
                end
            elseif FixedRecipe.normal then
                if FixedRecipe.normal.results then
                    if #FixedRecipe.normal.results > 0 then
                        results = FixedRecipe.normal.results
                        for _, product in pairs(FixedRecipe.normal.results) do
                            local product_name = product.name or product[1] or nil
                            if product_name then
                                local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", product_name)]
                                if not DeadlockItem then
                                    if product.type == "fluid" then
                                        -- do nothing
                                        logger("2", "fluid .. " .. product_name)
                                    else
                                        logger("1", string.format("recipe (%s) missing stacked result (%s)", recipe_table, string.format("deadlock-stack-%s", product_name)))
                                        StackedResultsFound = false
                                    end
                                else
                                    SomethingStacked = true
                                    logger("1", "Stacked result found " .. DeadlockItem.name)
                                end
                            end
                        end
                    else
                        StackedResultsFound = false
                    end
                end
            end

            logger("2", string.format("MakeStackedRecipe %s .. StackedIngredientsFound %s .. StackedResultsFound %s", recipe_table, StackedIngredientsFound, StackedResultsFound))
            if SomethingStacked and StackedResultsFound and StackedIngredientsFound then
                MakeStackedRecipe(recipe_name)
            end
        end
    end
end

function Deadlock.SubGroups()
    for recipe_name, _ in pairs(data.raw.recipe) do
        if Func.starts_with(recipe_name, "StackedRecipe") then
            local parent_name = string.sub(recipe_name, 15)
            if data.raw.recipe[parent_name] then
                local sub_group = "misc"
                if data.raw.recipe[parent_name] and data.raw.recipe[parent_name].subgroup then
                    sub_group = data.raw.recipe[parent_name].subgroup
                end
                if data.raw.item[parent_name] and data.raw.item[parent_name].subgroup then
                    sub_group = data.raw.item[parent_name].subgroup
                end
                if sub_group == "misc" then
                    for _, data in pairs(rusty_prototypes.find_by_name(parent_name)) do
                        if data.subgroup then
                            sub_group = data.subgroup
                        end
                    end
                end

                MakeSubGroup(sub_group)
                data.raw.recipe[recipe_name].subgroup = "Stacked-" .. sub_group
            end
        end
    end
end

return Deadlock
