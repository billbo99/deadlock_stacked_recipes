local _Data = require("__stdlib__/stdlib/data/data")
local _Recipe = require("__stdlib__/stdlib/data/recipe")

local Locale = require("utils/locale")

local Func = require("utils.func")
local Deadlock = {}

local function get_item_localised_name(item_name)
    if data.raw.item[item_name] and data.raw.item[item_name].localised_name then
        return data.raw.item[item_name].localised_name
    else
        return {"item-name." .. item_name}
    end
end

local function get_recipe_localised_name(recipe_name)
    if data.raw.recipe[recipe_name] and data.raw.recipe[recipe_name].localised_name then
        return data.raw.recipe[recipe_name].localised_name
    else
        return {"recipe-name." .. recipe_name}
    end
end

local function FixRecipeLocalisedNames()
    for recipe_name, recipe_table in pairs(data.raw.recipe) do
        if Func.starts_with(recipe_name, "StackedRecipe") then
            local parent_name = string.sub(recipe_name, 15)
            local main_product, main_type = Locale.get_main_product(recipe_table.normal or recipe_table.expensive or recipe_table)
            if main_product then
                local localised_name = data.raw[main_type][main_product].localised_name
                if localised_name then
                    recipe_table.localised_name = {"recipe-name.deadlock-stacking-stack", localised_name}
                end
            else
                recipe_table.localised_name = {"recipe-name.deadlock-stacking-stack", {"recipe-name." .. parent_name}}
            end
        end
    end
end

local function FixItemLocalisedNames()
    for item_name, item_table in pairs(data.raw.item) do
        if string.match(item_name, "deadlock%-stack%-") then
            local parent_item = string.sub(item_name, 16)
            if data.raw.item[parent_item] then
                item_table.localised_name[2] = get_item_localised_name(parent_item)
            end
        end
    end
end

function Deadlock.FixLocalisedNames()
    FixItemLocalisedNames()
    FixRecipeLocalisedNames()
end

function Deadlock.DensityOverride()
    if settings.startup["override_stacking_size"].value then
        local deadlock_stack_size = settings.startup["deadlock-stack-size"].value
        for k, v in pairs(data.raw.recipe) do
            if string.match(k, "deadlock%-stacks%-unstack%-") then
                if data.raw.recipe[k].result_count and data.raw.recipe[k].result_count < deadlock_stack_size then
                    data.raw.recipe[k].result_count = deadlock_stack_size
                end

                if data.raw.recipe[k].results and data.raw.recipe[k].results[1].amount < deadlock_stack_size then
                    data.raw.recipe[k].results[1].amount = deadlock_stack_size
                end
            end
            if string.match(k, "deadlock%-stack%-stack%-") then
                if data.raw.recipe[k].ingredients and data.raw.recipe[k].ingredients[1][2] < deadlock_stack_size then
                    data.raw.recipe[k].ingredients[1][2] = deadlock_stack_size
                end
            end
        end
        for k, _ in pairs(data.raw.item) do
            if string.match(k, "deadlock%-stack%-") then
                local parent_item = string.sub(k, 16)
                if data.raw.item[parent_item] then
                    local stack_size
                    local parent_stack_size = data.raw.item[parent_item].stack_size
                    local child_stack_size = data.raw.item[k].stack_size

                    stack_size = deadlock_stack_size
                    if parent_stack_size > deadlock_stack_size then
                        stack_size = parent_stack_size
                    end
                    if child_stack_size < deadlock_stack_size then
                        stack_size = deadlock_stack_size
                    end

                    data.raw.item[k].stack_size = stack_size
                    data.raw.item[k].localised_name[3] = deadlock_stack_size

                    log(string.format("DensityOverride .. %s", data.raw.item[k].stack_size))
                end
            end
        end
    end
end

local function MapItemUnlockedByTech(item)
    local item_unlocked_by_tech = {}
    for tech, tech_table in pairs(data.raw["technology"]) do
        local enabled = true
        if tech_table.enabled ~= nil then
            enabled = tech_table.enabled
        end
        if enabled and tech_table.effects then
            for _, effect in pairs(tech_table.effects) do
                if effect.type and effect.type == "unlock-recipe" then
                    local recipe = effect.recipe
                    if data.raw.recipe[recipe] then
                        local Recipe = data.raw.recipe[recipe]
                        local results = {}
                        if Recipe.results then
                            results = Recipe.results
                        elseif Recipe.result then
                            results = {{name = Recipe.result}}
                        elseif Recipe.normal.results then
                            results = Recipe.normal.results
                        elseif Recipe.normal.result then
                            results = {{name = Recipe.normal.result}}
                        else
                            log("how did I get no recipe result for .. " .. recipe)
                        end
                        for _, result in pairs(results) do
                            if result.name then
                                if not item_unlocked_by_tech[result.name] then
                                    item_unlocked_by_tech[result.name] = {}
                                end
                                if not Func.contains(item_unlocked_by_tech[result.name], tech) then
                                    if not Func.starts_with(tech, "deadlock") then
                                        table.insert(item_unlocked_by_tech[result.name], tech)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if item then
        return item_unlocked_by_tech[item]
    else
        return item_unlocked_by_tech
    end
end

function Deadlock.FixResearchTree(dataset)
    -- find what recipe is unlocked by each research
    local item_unlocked_by_tech = MapItemUnlockedByTech()

    -- for each item we care about add the deadlock stack/unstack recipe to the research tree
    -- and remove from the default stacker
    local function FixResearchTreeForNamedItem(name, tier)
        if item_unlocked_by_tech[name] then
            for _, tech in pairs(item_unlocked_by_tech[name]) do
                local Technology = data.raw.technology[tech]
                -- add stack
                local stack_recipe = string.format("deadlock-stacks-stack-%s", name)
                table.insert(Technology.effects, {recipe = stack_recipe, type = "unlock-recipe"})
                -- add unstack
                local unstack_recipe = string.format("deadlock-stacks-unstack-%s", name)
                table.insert(Technology.effects, {recipe = unstack_recipe, type = "unlock-recipe"})

                local deadlock_tech = "deadlock-stacking-" .. tier
                local DeadlockTechnology = data.raw.technology[deadlock_tech]
                for idx, effect in pairs(DeadlockTechnology.effects) do
                    if effect.recipe == stack_recipe then
                        DeadlockTechnology.effects[idx] = nil
                    end
                    if effect.recipe == unstack_recipe then
                        DeadlockTechnology.effects[idx] = nil
                    end
                end
            end
        end
    end

    for name, name_table in pairs(dataset) do
        if name_table.types then
            for _, type in pairs(name_table.types) do
                FixResearchTreeForNamedItem(name .. "-" .. type, name_table.tier)
            end
        else
            FixResearchTreeForNamedItem(name, name_table.tier)
        end
    end
end

local function MakeSubGroup(sub_group)
    if not data.raw["item-subgroup"]["Stacked-" .. sub_group] then
        data:extend({{type = "item-subgroup", name = "Stacked-" .. sub_group, group = "Stacked_Recipes", order = "Stacked-" .. sub_group}})
    end
end

local function MakeDeadlockItem(name, deadlock_tier, sub_group)
    log(string.format("name (%s), deadlock_tier (%s), sub_group (%s)", name, deadlock_tier, sub_group))
    MakeSubGroup(sub_group)
    local Item = data.raw["item"][name]
    if Item then
        if Item.icon then
            if Item.icon_size then
                -- all good
            else
                log(string.format("base icon_size missing for %s", name))
            end
        else
            for _, v2 in pairs(Item.icons) do
                if v2.icon_size then
                    -- all good
                else
                    v2.icon_size = Item.icon_size
                end
            end
        end

        deadlock.add_stack(name, nil, "deadlock-stacking-" .. deadlock_tier, 32, "item")
        local DeadlockItem = data.raw["item"][string.format("deadlock-stack-%s", name)]
        if DeadlockItem then
            -- stack size
            if settings.startup["override_stacking_size"].value then
                local parent_stack_size = data.raw.item[name].stack_size
                local deadlock_stack_size = settings.startup["deadlock-stack-size"].value
                if deadlock_stack_size > parent_stack_size then
                    DeadlockItem.stack_size = deadlock_stack_size
                else
                    DeadlockItem.stack_size = parent_stack_size
                end
            end
            -- stack recipe
            local stack_recipe = string.format("deadlock-stacks-stack-%s", name)
            local DeadlockStackRecipe = data.raw.recipe[stack_recipe]
            if Item.localised_name then
                DeadlockStackRecipe.localised_name[2] = Item.localised_name
            end
            DeadlockStackRecipe.subgroup = "Stacked-" .. sub_group

            -- unstack recipe
            local unstack_recipe = string.format("deadlock-stacks-unstack-%s", name)
            local DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
            if Item.localised_name then
                DeadlockUnStackRecipe.localised_name[2] = Item.localised_name
            end
            DeadlockUnStackRecipe.subgroup = "Stacked-" .. sub_group

            -- item
            DeadlockItem.subgroup = "Stacked-" .. sub_group
            if Item.order then
                DeadlockItem.order = Item.subgroup .. "-" .. Item.order
            end
            if Item.localised_name then
                DeadlockItem.localised_name[2] = Item.localised_name
            end
        else
            log("DeadlockItem missing " .. string.format("deadlock-stack-%s", name))
        end
    else
        log("missing  " .. name .. "-" .. type)
    end
end

function Deadlock.MakeDeadlockItems(dataset)
    for name, name_table in pairs(dataset) do
        if name_table.types then
            for _, type in pairs(name_table.types) do
                local Name = name .. "-" .. type
                if data.raw.item[Name] then
                    MakeDeadlockItem(Name, name_table.tier, type)
                end
            end
        else
            local sub_group
            if name_table.sub_group then
                sub_group = name_table.sub_group
            else
                sub_group = data.raw.item[name].subgroup
            end
            MakeDeadlockItem(name, name_table.tier, sub_group)
        end
    end
end

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
    for _, result in pairs(results) do
        local name
        if result.name then
            name = result.name
        else
            name = result[1]
        end
        local StackedIngredient = string.format("deadlock-stack-%s", name)
        if data.raw.item[StackedIngredient] then
            if result.name then
                result.name = StackedIngredient
            else
                result[1] = StackedIngredient
            end
        end
    end
    return results
end

local function CheckStackedProductivity(orig)
    for _, module_table in pairs(data.raw.module) do
        if module_table.limitation then
            if Func.contains(module_table.limitation, orig) then
                local StackedRecipe = string.format("StackedRecipe-%s", orig)
                if data.raw.recipe[StackedRecipe] then
                    table.insert(module_table.limitation, StackedRecipe)
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
            NewRecipe:replace_ingredient(name, StackedIngredient, StackedIngredient)
        end
        if ingredient.type and ingredient.type == "fluid" then
            ScaleUpFluid(NewRecipe, name, Multiplier)
        end
    end

    local NewRecipeResultsFlag = false
    if NewRecipe.results and #NewRecipe.results > 0 then
        NewRecipeResultsFlag = true
        NewRecipe.results = ReplaceResult(NewRecipe.results)
        if NewRecipe.energy_required then
            NewRecipe.energy_required = NewRecipe.energy_required * Multiplier
        else
            NewRecipe.energy_required = 0.5 * Multiplier
        end
    else
        if NewRecipe.normal and NewRecipe.normal.results and #NewRecipe.normal.results > 0 then
            NewRecipeResultsFlag = true
            NewRecipe.normal.results = ReplaceResult(NewRecipe.normal.results)
            if NewRecipe.normal.energy_required then
                NewRecipe.normal.energy_required = NewRecipe.normal.energy_required * Multiplier
            else
                NewRecipe.normal.energy_required = 0.5 * Multiplier
            end
        end
        if NewRecipe.expensive and NewRecipe.expensive.results and #NewRecipe.expensive.results > 0 then
            NewRecipeResultsFlag = true
            NewRecipe.expensive.results = ReplaceResult(NewRecipe.expensive.results)
            if NewRecipe.expensive.energy_required then
                NewRecipe.expensive.energy_required = NewRecipe.expensive.energy_required * Multiplier
            else
                NewRecipe.expensive.energy_required = 0.5 * Multiplier
            end
        end
    end

    if NewRecipe.main_product and data.raw.item[NewRecipe.main_product] then
        local StackedIngredient = string.format("deadlock-stack-%s", NewRecipe.main_product)
        if data.raw.item[StackedIngredient] then
            NewRecipe.main_product = StackedIngredient
        end
    end
    if NewRecipe.normal and NewRecipe.normal.main_product and data.raw.item[NewRecipe.normal.main_product] then
        local StackedIngredient = string.format("deadlock-stack-%s", NewRecipe.normal.main_product)
        if data.raw.item[StackedIngredient] then
            NewRecipe.normal.main_product = StackedIngredient
        end
    end
    if NewRecipe.expensive and NewRecipe.expensive.main_product and data.raw.item[NewRecipe.expensive.main_product] then
        local StackedIngredient = string.format("deadlock-stack-%s", NewRecipe.expensive.main_product)
        if data.raw.item[StackedIngredient] then
            NewRecipe.expensive.main_product = StackedIngredient
        end
    end

    if OrigRecipe.results or OrigRecipe.normal.results then
        local OrigMainProduct
        if OrigRecipe.results and #OrigRecipe.results > 0 then
            OrigMainProduct = OrigRecipe.results[1].name
        end
        if OrigRecipe.normal and #OrigRecipe.normal.results > 0 and OrigRecipe.normal.results[1].name then
            OrigMainProduct = OrigRecipe.normal.results[1].name
        end
        if OrigMainProduct then
            local TechMap = MapItemUnlockedByTech(OrigMainProduct)
            if TechMap then
                for _, tech in pairs(TechMap) do
                    NewRecipe:add_unlock(tech)
                end
            end
            CheckStackedProductivity(OrigRecipe.name)
        end
    end

    local unstack_recipe = string.format("deadlock-stacks-unstack-%s", OrigMainProduct)
    local DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
    if DeadlockUnStackRecipe and DeadlockUnStackRecipe.subgroup then
        NewRecipe.subgroup = DeadlockUnStackRecipe.subgroup
    end

    if NewRecipeResultsFlag then
        log("adding recipe .. " .. NewRecipe.name)
        NewRecipe:extend()
    end
end

-- Go though each recipe to see if all ingredients / products are stacked,  if so then make a stacked recipe version of it
function Deadlock.MakeStackedRecipes()
    for recipe, recipe_table in pairs(data.raw.recipe) do
        local StackedItemsFound = true
        local ingredients
        local expensive_ingredients
        local results = {}

        local StackedRecipeName = string.format("stacked-recipe-%s", recipe)
        local FixedRecipe = _Recipe(recipe):convert_results() -- standardize recipe format

        if recipe_table.ingredients then
            log(string.format("recipe_table.ingredients matched for %s", recipe))
            ingredients = recipe_table.ingredients
        elseif recipe_table.normal then
            log(string.format("recipe_table.normal matched for %s", recipe))
            ingredients = recipe_table.normal.ingredients
            expensive_ingredients = recipe_table.expensive.ingredients
        else
            log(string.format("nothing matched for %s", recipe))
            ingredients = nil
        end

        -- examine main_product if defined
        if recipe_table.main_product and data.raw.item[recipe_table.main_product] then
            local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", recipe_table.main_product)]
            if not DeadlockItem then
                log("main_product can not be found as a stacked item .. " .. recipe_table.main_product)
                StackedItemsFound = false
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
                log(string.format("recipe (%s) has ingredient (%s)", recipe, name))
                local DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", name)]
                if not DeadlockItem then
                    if ingredient.type and ingredient.type == "fluid" then
                        -- do nothing
                    else
                        StackedItemsFound = false
                    end
                end
            end
        end

        -- look though results for stacked version
        if FixedRecipe.results then
            results = FixedRecipe.results
            for _, product in pairs(FixedRecipe.results) do
                if product.name then
                    if not data.raw["item"][string.format("deadlock-stack-%s", product.name)] then
                        StackedItemsFound = false
                    end
                end
            end
        elseif FixedRecipe.normal then
            if FixedRecipe.normal.results then
                results = FixedRecipe.normal.results
                for _, product in pairs(FixedRecipe.normal.results) do
                    if product.name then
                        if not data.raw["item"][string.format("deadlock-stack-%s", product.name)] then
                            StackedItemsFound = false
                        end
                    end
                end
            end
        end

        if StackedItemsFound then
            MakeStackedRecipe(recipe, ingredients, results)
        end
    end
end

function Deadlock.SubGroups()
    for recipe_name, _ in pairs(data.raw.recipe) do
        if Func.starts_with(recipe_name, "StackedRecipe") then
            local parent_name = string.sub(recipe_name, 15)
            if data.raw.recipe[parent_name] then
                local parent = data.raw.recipe[parent_name]
                local sub_group = parent.subgroup or "misc"
                MakeSubGroup(sub_group)
                data.raw.recipe[recipe_name].subgroup = "Stacked-" .. sub_group
            end
        end
    end
end

return Deadlock
