local rusty_locale = require("__rusty-locale__.locale")
local rusty_icons = require("__rusty-locale__.icons")
local rusty_recipes = require("__rusty-locale__.recipes")
local rusty_prototypes = require("__rusty-locale__.prototypes")

local _Data = require("__stdlib__/stdlib/data/data")
local _Recipe = require("__stdlib__/stdlib/data/recipe")

local logger = require("utils/logging").logger

local Func = require("utils.func")
local Deadlock = {}

local function FixRecipeLocalisedNames()
    for recipe_name, recipe_table in pairs(data.raw.recipe) do
        if Func.starts_with(recipe_name, "StackedRecipe") then
            logger("1", "FixRecipeLocalisedNames " .. recipe_name)
            local parent_name = string.sub(recipe_name, 15)

            local locale = rusty_locale.of(data.raw.recipe[parent_name])
            -- recipe_table.localised_name = {"recipe-name.deadlock-stacking-stack", locale.name}
            recipe_table.localised_name = {"recipe-name.DSR_Recipe", locale.name}
            logger("2", string.format("FixRecipeLocalisedNames .. %s .. %s", recipe_name, serpent.block(locale.name)))
        end
    end
end

local function FixItemLocalisedNames()
    for item_name, item_table in pairs(data.raw.item) do
        if string.match(item_name, "deadlock%-stack%-") then
            local parent_item = string.sub(item_name, 16)
            if data.raw.item[parent_item] then
                local locale = rusty_locale.of_item(data.raw.item[parent_item])
                item_table.localised_name[2] = locale.name
                logger("2", string.format("FixItemLocalisedNames .. %s .. %s", item_name, serpent.block(locale.name)))
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

                if tech.effects then
                    local effects = {}
                    for _, effect in pairs(tech.effects) do
                        if effect.type == "unlock-recipe" and (Func.starts_with(effect.recipe, "StackedRecipe-") or Func.starts_with(effect.recipe, "DSR_HighPressure-")) then
                            table.insert(data.raw.technology[dsr_tech].effects, {type = "unlock-recipe", recipe = effect.recipe})
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
            table.insert(data.raw.technology["dsr-technology-automation-science-pack"].effects, {type = "unlock-recipe", recipe = recipe.name})
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

                if data.raw.recipe[k].results then
                    local items = data.raw.recipe[k].results[1].amount / RecipeMultiplier
                    if items < deadlock_stack_size then
                        data.raw.recipe[k].results[1].amount = deadlock_stack_size * RecipeMultiplier
                    end
                end
            end
            if Func.starts_with(k, "deadlock-stacks-stack-") then
                if data.raw.recipe[k].ingredients then
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

        local types = {"item", "tool", "rail-planner", "ammo", "module", "capsule"}
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
                    --     stack_size = parent_stack_size
                    -- end
                    -- if child_stack_size < deadlock_stack_size then
                    --     -- stack_size = deadlock_stack_size
                    --     stack_size = parent_stack_size
                    -- end

                    data.raw.item[k].stack_size = stack_size
                    data.raw.item[k].localised_name[3] = deadlock_stack_size

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
                        for _, recipe in pairs({"StackedRecipe-" .. effect.recipe, "deadlock-stacks-stack-" .. effect.recipe, "deadlock-stacks-unstack-" .. effect.recipe}) do
                            if data.raw.recipe[recipe] and not recipes_to_unlock[recipe] then
                                table.insert(tech_table.effects, {recipe = recipe, type = "unlock-recipe"})
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

    if settings.startup["dsr_new_subgroup_placement"].value then
        new_subgroup = name .. "Stacked"
        if not data.raw["item-subgroup"][new_subgroup] then
            subgroup = {type = "item-subgroup", name = new_subgroup, group = current_group, order = current_order .. "Stacked"}
        end
    else
        new_subgroup = "Stacked-" .. name
        if not data.raw["item-subgroup"][new_subgroup] then
            subgroup = {type = "item-subgroup", name = new_subgroup, group = "Stacked_Recipes", order = new_subgroup}
        end
    end
    if subgroup then
        data:extend({subgroup})
    end
    return new_subgroup
end

-- local function MakeDeadlockItem(name, deadlock_tier, sub_group, type)
--     if type == nil then
--         type = "item"
--     end
--     logger("1", string.format("name (%s), deadlock_tier (%s), sub_group (%s), type (%s)", name, deadlock_tier, sub_group, type))
--     MakeSubGroup(sub_group)
--     local Item = data.raw[type][name]
--     if Item then
--         if Item.icon then
--             if Item.icon_size then
--                 -- all good
--             else
--                 logger("2", string.format("base icon_size missing for %s", name))
--             end
--         else
--             for _, v2 in pairs(Item.icons) do
--                 if v2.icon_size then
--                     -- all good
--                 else
--                     v2.icon_size = Item.icon_size
--                 end
--             end
--         end

--         if tonumber(deadlock_tier) then
--             deadlock_tier = "deadlock-stacking-" .. deadlock_tier
--         end

--         if Icons[name] then
--             logger("2", string.format("add_stack-a .. %s .. %s .. %s .. %s", name, "__deadlock_stacked_recipes__/graphics/icons/" .. Icons[name], deadlock_tier, type))
--             deadlock.add_stack(name, "__deadlock_stacked_recipes__/graphics/icons/" .. Icons[name], deadlock_tier, 64, type, 4)
--         else
--             logger("2", string.format("add_stack-b .. %s .. %s .. %s", name, deadlock_tier, type))
--             deadlock.add_stack(name, nil, deadlock_tier, 32, type)
--         end
--         local DeadlockItem = data.raw[type][string.format("deadlock-stack-%s", name)]
--         if DeadlockItem then
--             -- stack size
--             if settings.startup["override_stacking_size"].value then
--                 local parent_stack_size = data.raw[type][name].stack_size
--                 local deadlock_stack_size = settings.startup["deadlock-stack-size"].value
--                 if deadlock_stack_size > parent_stack_size then
--                     DeadlockItem.stack_size = deadlock_stack_size
--                 else
--                     DeadlockItem.stack_size = parent_stack_size
--                 end
--             end
--             -- stack recipe
--             local stack_recipe = string.format("deadlock-stacks-stack-%s", name)
--             local DeadlockStackRecipe = data.raw.recipe[stack_recipe]
--             local locale = rusty_locale.of(Item)
--             if locale.name then
--                 DeadlockStackRecipe.localised_name[2] = locale.name
--             end
--             DeadlockStackRecipe.subgroup = "Stacked-" .. sub_group

--             -- unstack recipe
--             local unstack_recipe = string.format("deadlock-stacks-unstack-%s", name)
--             local DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
--             if locale.name then
--                 DeadlockUnStackRecipe.localised_name[2] = locale.name
--             end
--             DeadlockUnStackRecipe.subgroup = "Stacked-" .. sub_group

--             -- item
--             DeadlockItem.subgroup = "Stacked-" .. sub_group
--             if Item.order then
--                 DeadlockItem.order = Item.subgroup .. "-" .. Item.order
--             end
--             if locale.name then
--                 DeadlockItem.localised_name[2] = locale.name
--             end
--         else
--             logger("2", "DeadlockItem missing " .. string.format("deadlock-stack-%s", name))
--         end
--     else
--         logger("2", "missing item  " .. name)
--     end
-- end

-- function Deadlock.MakeDeadlockItems(dataset)
--     for name, name_table in pairs(dataset) do
--         local type
--         if name_table.type then
--             type = name_table.type
--         else
--             type = "item"
--         end
--         if name_table.variations then
--             for _, variation in pairs(name_table.variations) do
--                 local Name = name .. "-" .. variation
--                 if data.raw[type][Name] then
--                     MakeDeadlockItem(Name, name_table.tier, variation, type)
--                 end
--             end
--         else
--             local sub_group
--             if name_table.sub_group then
--                 sub_group = name_table.sub_group
--             else
--                 sub_group = data.raw[type][name].subgroup
--             end
--             MakeDeadlockItem(name, name_table.tier, sub_group, type)
--         end
--     end
-- end

local function ConvertToStackedItems(ingredients)
    for _, ingredient in pairs(ingredients) do
        if ingredient.name then
            ingredient.name = string.format("deadlock-stack-%s", ingredient.name)
        else
            ingredient[1] = string.format("deadlock-stack-%s", ingredient[1])
        end
    end

    return ingredients
end

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

local function ScaleUpFluid(recipe, fluid_to_find, multiplier)
    local normal_ingredients = recipe.ingredients or recipe.normal.ingredients
    local expensive_ingredients
    if recipe.expensive then
        expensive_ingredients = recipe.expensive.ingredients
    else
        expensive_ingredients = {}
    end

    --update normal ingredients
    for _, ingredient in pairs(normal_ingredients) do
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

    --update expensive ingredients
    for _, ingredient in pairs(expensive_ingredients) do
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

local function MakeStackedRecipe(recipe, ingredients, results)
    local StackedRecipeName = string.format("StackedRecipe-%s", recipe)
    local OrigRecipe = _Recipe(recipe):convert_results()
    local NewRecipe = _Recipe(recipe):copy(StackedRecipeName):convert_results()
    local Multiplier = settings.startup["deadlock-stack-size"].value

    -- Grab all the ingredients of the orignal recipe and replace with stacked versions
    logger("4", "Processing ingredients")
    ingredients = OrigRecipe.ingredients or OrigRecipe.normal.ingredients
    for _, ingredient in pairs(ingredients) do
        local name
        if ingredient.name then
            name = ingredient.name
        else
            name = ingredient[1]
        end
        local StackedIngredient = string.format("deadlock-stack-%s", name)
        if data.raw.item[StackedIngredient] then
            logger("5", string.format("Adding %s to new recipe", StackedIngredient))
            NewRecipe:replace_ingredient(name, StackedIngredient, StackedIngredient)
        end
        if ingredient.type and ingredient.type == "fluid" then
            logger("5", string.format("Adding %s to new recipe", name))
            ScaleUpFluid(NewRecipe, name, Multiplier)
        end
    end

    -- Grab all the results of the orignal recipe and replace with stacked versions
    logger("4", "Processing new recipe results")
    local NewRecipeResultsFlag = false
    local rv
    if NewRecipe.results and #NewRecipe.results > 0 then
        NewRecipeResultsFlag = true
        rv, NewRecipe.results = ReplaceResult(NewRecipe.results)
        if rv then
            if NewRecipe.energy_required then
                NewRecipe.energy_required = NewRecipe.energy_required * Multiplier
            else
                NewRecipe.energy_required = 0.5 * Multiplier
            end
        else
            NewRecipeResultsFlag = false
        end
    else
        if NewRecipe.normal and NewRecipe.normal.results and #NewRecipe.normal.results > 0 then
            NewRecipeResultsFlag = true
            rv, NewRecipe.normal.results = ReplaceResult(NewRecipe.normal.results)
            if rv then
                if NewRecipe.normal.energy_required then
                    NewRecipe.normal.energy_required = NewRecipe.normal.energy_required * Multiplier
                else
                    NewRecipe.normal.energy_required = 0.5 * Multiplier
                end
            else
                NewRecipeResultsFlag = false
            end
        end
        if NewRecipe.expensive and NewRecipe.expensive.results and #NewRecipe.expensive.results > 0 then
            NewRecipeResultsFlag = true
            rv, NewRecipe.expensive.results = ReplaceResult(NewRecipe.expensive.results)
            if rv then
                if NewRecipe.expensive.energy_required then
                    NewRecipe.expensive.energy_required = NewRecipe.expensive.energy_required * Multiplier
                else
                    NewRecipe.expensive.energy_required = 0.5 * Multiplier
                end
            else
                NewRecipeResultsFlag = false
            end
        end
    end
    logger("5", string.format("NewRecipeResultsFlag = %s", NewRecipeResultsFlag))

    -- Main Product
    logger("4", "Processing new recipe main_product")
    local StackedProduct = nil
    if NewRecipe.main_product then
        logger("6", "main_product .. " .. NewRecipe.main_product)
        StackedProduct = string.format("deadlock-stack-%s", NewRecipe.main_product)
        if data.raw.item[StackedProduct] then
            NewRecipe.main_product = StackedProduct
            logger("5", string.format("main_product .. %s .. set on recipe", StackedProduct))
        else
            logger("5", string.format("no stacked version of main_product found  .. %s", StackedProduct))
        end
    end

    if NewRecipe.normal and NewRecipe.normal.main_product and data.raw.item[string.format("deadlock-stack-%s", NewRecipe.normal.main_product)] then
        StackedProduct = string.format("deadlock-stack-%s", NewRecipe.normal.main_product)
        if data.raw.item[StackedProduct] then
            NewRecipe.normal.main_product = StackedProduct
        end
    end
    if NewRecipe.expensive and NewRecipe.expensive.main_product and data.raw.item[string.format("deadlock-stack-%s", NewRecipe.expensive.main_product)] then
        StackedProduct = string.format("deadlock-stack-%s", NewRecipe.expensive.main_product)
        if data.raw.item[StackedProduct] then
            NewRecipe.expensive.main_product = StackedProduct
        end
    end
    logger("5", string.format("StackedProduct = %s", StackedProduct))

    -- Results
    logger("4", "Processing new recipe results")
    local OrigMainProduct
    if OrigRecipe.results or OrigRecipe.normal.results then
        if OrigRecipe.results and #OrigRecipe.results > 0 then
            OrigMainProduct = OrigRecipe.results[1].name
        end
        if OrigRecipe.normal and #OrigRecipe.normal.results > 0 and OrigRecipe.normal.results[1].name then
            OrigMainProduct = OrigRecipe.normal.results[1].name
        end
    end
    logger("5", string.format("OrigMainProduct = %s", OrigMainProduct))

    -- Unstack stuff
    local unstack_recipe = string.format("deadlock-stacks-unstack-%s", OrigMainProduct)
    local DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
    if DeadlockUnStackRecipe and DeadlockUnStackRecipe.subgroup then
        NewRecipe.subgroup = DeadlockUnStackRecipe.subgroup
    end

    -- -- Stacked Icon for Stacked Recipe
    -- logger("4", "Processing new recipe icon")
    local icon = nil
    local icon_size = nil
    local icons = nil
    local base_icon = "__deadlock_stacked_recipes__/graphics/blank_64.png"
    local dsr_icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png"
    local recipe_icons = rusty_icons.of_recipe(data.raw.recipe[OrigRecipe.name])

    -- First look to see if recipe has an icon defined
    NewRecipe.icons = {}
    table.insert(NewRecipe.icons, {icon = base_icon, icon_size = 64})
    if data.raw.recipe[OrigRecipe.name] and data.raw.recipe[OrigRecipe.name].icons then
        for _, layer in pairs(data.raw.recipe[OrigRecipe.name].icons) do
            table.insert(NewRecipe.icons, layer)
        end
    elseif data.raw.recipe[OrigRecipe.name] and data.raw.recipe[OrigRecipe.name].icon then
        table.insert(NewRecipe.icons, {icon = data.raw.recipe[OrigRecipe.name].icon, icon_size = data.raw.recipe[OrigRecipe.name].icon_size, icon_scale = 64 / data.raw.recipe[OrigRecipe.name].icon_size})
    elseif #recipe_icons > 0 then
        for _, layer in pairs(recipe_icons) do
            table.insert(NewRecipe.icons, layer)
        end
    end
    table.insert(NewRecipe.icons, {icon = dsr_icon, icon_size = 64})
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
        log("hmm")
    end

    NewRecipe.order = order
    if subgroup then
        NewRecipe.subgroup = MakeSubGroup(subgroup, order)
    end

    if NewRecipeResultsFlag then
        logger("1", "adding recipe .. " .. NewRecipe.name)
        NewRecipe:extend()
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
        if Func.starts_with(recipe_name, "StackedRecipe") or Func.starts_with(recipe_name, "kr-vc-") or Func.starts_with(recipe_name, "deadlock-stacks-stack") or Func.starts_with(recipe_name, "deadlock-stacks-unstack") or Func.starts_with(recipe_name, "spidertron-remote") then
            logger("1", string.format("Skipping recipe .. %s", recipe_name.name))
        else
            local SomethingStacked = false
            local StackedIngredientsFound = true
            local StackedResultsFound = true
            local ingredients
            local expensive_ingredients
            local results = {}

            if data.raw.recipe[recipe_name].normal and not data.raw.recipe[recipe_name].expensive then
                data.raw.recipe[recipe_name].expensive = data.raw.recipe[recipe_name].normal
            end
            local FixedRecipe = _Recipe(recipe_name):convert_results() -- standardize recipe format

            if recipe_table.ingredients then
                logger("2", string.format("recipe_table.ingredients matched for %s", recipe_name))
                ingredients = recipe_table.ingredients
            elseif recipe_table.normal then
                logger("2", string.format("recipe_table.normal matched for %s", recipe_name))
                ingredients = recipe_table.normal.ingredients
                if recipe_table.expensive and recipe_table.expensive.ingredients then
                    expensive_ingredients = recipe_table.expensive.ingredients
                else
                    expensive_ingredients = recipe_table.normal.ingredients
                end
            else
                logger("1", string.format("nothing matched for %s", recipe_name))
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
                MakeStackedRecipe(recipe_name, ingredients, results)
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

-- function Deadlock.ChangeIcons()
--     local name
--     for k, v in pairs(Icons) do
--         logger("1", string.format("ChangeIcons .. k (%s) .. v (%s)", k, v))
--         name = string.format("StackedRecipe-%s", k)
--         if data.raw.recipe[name] then
--             data.raw.recipe[name].icons = nil
--             data.raw.recipe[name].icon = string.format("__deadlock_stacked_recipes__/graphics/icons/%s", v)
--             data.raw.recipe[name].icon_size = 64
--             data.raw.recipe[name].icon_mipmaps = 4
--         end

--         name = string.format("deadlock-stack-%s", k)
--         if data.raw.item[name] then
--             data.raw.item[name].icons = nil
--             data.raw.item[name].icon = string.format("__deadlock_stacked_recipes__/graphics/icons/%s", v)
--             data.raw.item[name].icon_size = 64
--             data.raw.item[name].icon_mipmaps = 4
--         end

--         name = string.format("deadlock-stacks-unstack-%s", k)
--         if data.raw.recipe[name] then
--             data.raw.recipe[name].icons = {
--                 {icon = string.format("__deadlock_stacked_recipes__/graphics/icons/%s", v), icon_mipmaps = 4, icon_size = 64},
--                 {icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/arrow-u-64.png", icon_size = 64, scale = 0.25}
--             }
--         end

--         name = string.format("deadlock-stacks-stack-%s", k)
--         if data.raw.recipe[name] then
--             data.raw.recipe[name].icons = {
--                 {icon = string.format("__deadlock_stacked_recipes__/graphics/icons/%s", v), icon_mipmaps = 4, icon_size = 64},
--                 {icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/arrow-d-64.png", icon_size = 64, scale = 0.25}
--             }
--         end
--     end
-- end

return Deadlock
