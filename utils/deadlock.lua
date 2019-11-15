local _Data = require('__stdlib__/stdlib/data/data')
local _Recipe = require('__stdlib__/stdlib/data/recipe')

local Func = require("utils.func")
local Deadlock = {}

local function get_localised_name(item_name)
    if data.raw.item[item_name] and data.raw.item[item_name].localised_name then
        return data.raw.item[item_name].localised_name
    else
        return {"item-name."..item_name}
	end
end

function Deadlock.FixLocalisedNames()
    for item_name, item_table in pairs(data.raw.item) do
        if string.match(item_name, "deadlock%-stack%-") then
            local parent_item = string.sub(item_name, 16)
            if data.raw.item[parent_item] then
                item_table.localised_name[2] = get_localised_name(parent_item)
            end
        end
    end
end

function Deadlock.DensityOverride()
    if settings.startup["override_stacking_size"].value then
        local item_types = {"item"}
        for k, v in pairs(data.raw.item) do
            if string.match(k, "deadlock%-stack%-") then
                local parent_item = string.sub(k, 16)
                for _, item_type in ipairs(item_types) do
                    if data.raw[item_type][parent_item] then
                        data.raw.item[k].stack_size = data.raw[item_type][parent_item].stack_size
                        log(string.format("%s .. %s .. %s", item_type, parent_item, data.raw.item[k].stack_size))
                    end
                end
            end
        end
    end
end

local function MapItemUnlockedByTech(item)
    local item_unlocked_by_tech = {}
    for tech, tech_table in pairs(data.raw["technology"]) do
        local enabled = true
        if tech_table.enabled ~= nil then enabled = tech_table.enabled end
        if enabled and tech_table.effects then
            for _, effect in pairs(tech_table.effects) do
                if effect.type and effect.type == "unlock-recipe" then
                    recipe = effect.recipe
                    if data.raw.recipe[recipe] then
                        Recipe = data.raw.recipe[recipe]
                        if Recipe.results then
                            results = Recipe.results
                        elseif Recipe.result then
                            results = {{name=Recipe.result}}
                        elseif Recipe.normal.results then
                            results = Recipe.normal.results
                        elseif Recipe.normal.result then
                            results = {{name=Recipe.normal.result}}
                        else
                            log('how did I get no recipe result for .. '..recipe)
                        end
                        for _, result in pairs(results) do
                            if result.name then
                                if not item_unlocked_by_tech[result.name] then item_unlocked_by_tech[result.name] = {} end
                                if not Func.contains(item_unlocked_by_tech[result.name], tech) then
                                    if not Func.starts_with(tech, 'deadlock') then 
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
                Technology = data.raw.technology[tech]
                -- add stack
                stack_recipe = string.format("deadlock-stacks-stack-%s", name)
                table.insert(Technology.effects, {recipe = stack_recipe, type = "unlock-recipe"})
                -- add unstack
                unstack_recipe = string.format("deadlock-stacks-unstack-%s", name)
                table.insert(Technology.effects, {recipe = unstack_recipe, type = "unlock-recipe"})

                deadlock_tech = "deadlock-stacking-"..tier
                DeadlockTechnology = data.raw.technology[deadlock_tech]
                for idx, effect in pairs(DeadlockTechnology.effects) do
                    if effect.recipe == stack_recipe then DeadlockTechnology.effects[idx] = nil end
                    if effect.recipe == unstack_recipe then DeadlockTechnology.effects[idx] = nil end
                end
            end
        end
    end

    for name, name_table in pairs(dataset) do
        if name_table.types then
            for _, type in pairs(name_table.types) do
                FixResearchTreeForNamedItem(name..'-'..type, name_table.tier)
            end
        else
            FixResearchTreeForNamedItem(name, name_table.tier)
        end
    end
end

local function MakeSubGroup(sub_group)
    if not data.raw["item-subgroup"]['Stacked-'..sub_group] then
        data:extend({{type = "item-subgroup", name = 'Stacked-'..sub_group, group = 'Stacked_Recipes', order = 'Stacked-'..sub_group}})
    end
end

local function MakeDeadlockItem(name, deadlock_tier, sub_group)
    MakeSubGroup(sub_group)
    Item = data.raw["item"][name]
    if Item then
        if Item.icon then
            if Item.icon_size then
                -- all good
            else
                log(string.format("base icon_size missing for %s", name))
            end
        else
            for k2, v2 in pairs(Item.icons) do
                if v2.icon_size then
                    -- all good
                else
                    v2.icon_size = Item.icon_size
                end
            end
        end

        deadlock.add_stack(name, nil, "deadlock-stacking-".. deadlock_tier, 32, "item")
        DeadlockItem = data.raw["item"][string.format("deadlock-stack-%s", name)]
        if DeadlockItem then
            -- stack recipe
            stack_recipe = string.format("deadlock-stacks-stack-%s", name)
            DeadlockStackRecipe = data.raw.recipe[stack_recipe]
            if Item.localised_name then DeadlockStackRecipe.localised_name[2] = Item.localised_name end
            DeadlockStackRecipe.subgroup = 'Stacked-'..sub_group

            -- unstack recipe
            unstack_recipe = string.format("deadlock-stacks-unstack-%s", name)
            DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
            if Item.localised_name then DeadlockUnStackRecipe.localised_name[2] = Item.localised_name end
            DeadlockUnStackRecipe.subgroup = 'Stacked-'..sub_group

            -- item
            DeadlockItem.subgroup = 'Stacked-'..sub_group
            if Item.order then DeadlockItem.order = Item.subgroup .. '-' .. Item.order end
            if Item.localised_name then DeadlockItem.localised_name[2] = Item.localised_name end
        else
            log('DeadlockItem missing '..string.format("deadlock-stack-%s", name))
        end
    else
        log('missing  '..name..'-'..type)
    end
end

function Deadlock.MakeDeadlockItems(dataset)
    for name, name_table in pairs(dataset) do
        if name_table.types then
            for _, type in pairs(name_table.types) do
                local Name = name..'-'..type
                if data.raw.item[Name] then 
                    MakeDeadlockItem(Name, name_table.tier, type)
                end
            end
        else
            MakeDeadlockItem(name, name_table.tier, name_table.sub_group)
        end
    end
end

local function ConvertToStackedItems(ingredients)
    for _, ingredient in pairs(ingredients) do
        if ingredient.name then 
            name = ingredient.name
            ingredient.name = string.format("deadlock-stack-%s", ingredient.name)
        else 
            ingredient[1] = string.format("deadlock-stack-%s", ingredient[1])
        end
    end

    return ingredients
end

local function ReplaceResult(results)
    for _, result in pairs(results) do
        if result.name then name = result.name else name=result[1] end
        StackedIngredient = string.format("deadlock-stack-%s", name)
        if data.raw.item[StackedIngredient] then 
            if result.name then result.name = StackedIngredient else result[1] = StackedIngredient end
        end
    end
    return results
end

local function CheckStackedProductivity(OrigProduct)
    for module, module_table in pairs(data.raw.module) do
        if module_table.limitation then
            if Func.contains(module_table.limitation, OrigProduct) then
                StackedRecipe = string.format("StackedRecipe-%s", OrigProduct)
                if data.raw.recipe[StackedRecipe] then 
                    table.insert(module_table.limitation, StackedRecipe)
                    log(module..' limitations expanded to include '..StackedRecipe)
                end
            end
        end
    end
end

local function ScaleUpFluid(recipe, fluid_to_find, multiplier)
    normal_ingredients = recipe.ingredients or recipe.normal.ingredients
    if recipe.expensive then expensive_ingredients = recipe.expensive.ingredients else expensive_ingredients = {} end
    
    --update normal ingredients
    for _, ingredient in pairs(normal_ingredients) do
        if ingredient.name then name = ingredient.name else name=ingredient[1] end
        if name == fluid_to_find then
            ingredient.amount = ingredient.amount * multiplier
        end
    end

    --update expensive ingredients
    for _, ingredient in pairs(expensive_ingredients) do
        if ingredient.name then name = ingredient.name else name=ingredient[1] end
        if name == fluid_to_find then
            ingredient.amount = ingredient.amount * multiplier
        end
    end
end

local function MakeStackedRecipe(recipe, ingredients, results)
    StackedRecipeName = string.format("StackedRecipe-%s", recipe)
    OrigRecipe = _Recipe(recipe):convert_results()
    NewRecipe = _Recipe(recipe):copy(StackedRecipeName):convert_results()
    Multiplier = settings.startup["deadlock-stack-size"].value 

    ingredients = OrigRecipe.ingredients or OrigRecipe.normal.ingredients
    for _, ingredient in pairs(ingredients) do 
        if ingredient.name then name = ingredient.name else name=ingredient[1] end
        StackedIngredient = string.format("deadlock-stack-%s", name)
        NewRecipe:replace_ingredient(name, StackedIngredient, StackedIngredient)
        if ingredient.type and ingredient.type == 'fluid' then ScaleUpFluid(NewRecipe, name, Multiplier) end
    end

    if NewRecipe.results then
        NewRecipe.results = ReplaceResult(NewRecipe.results)
        if NewRecipe.energy_required then 
            NewRecipe.energy_required = NewRecipe.energy_required * Multiplier 
        else 
            NewRecipe.energy_required = 0.5 * Multiplier
        end
    else
        if NewRecipe.normal and NewRecipe.normal.results then
            NewRecipe.normal.results = ReplaceResult(NewRecipe.normal.results)
            if NewRecipe.normal.energy_required then 
                NewRecipe.normal.energy_required = NewRecipe.normal.energy_required * Multiplier
            else
                NewRecipe.normal.energy_required = 0.5 * Multiplier
            end
        end
        if NewRecipe.expensive and NewRecipe.expensive.results then
            NewRecipe.expensive.results = ReplaceResult(NewRecipe.expensive.results)
            if NewRecipe.expensive.energy_required then 
                NewRecipe.expensive.energy_required = NewRecipe.expensive.energy_required * Multiplier
            else
                NewRecipe.expensive.energy_required = 0.5 * Multiplier
            end
        end
    end

    if OrigRecipe.results or OrigRecipe.normal.results then
        if OrigRecipe.results then OrigMainProduct = OrigRecipe.results[1].name end
        if OrigRecipe.normal and OrigRecipe.normal.results[1].name then OrigMainProduct = OrigRecipe.normal.results[1].name end
        if OrigMainProduct then 
            TechMap = MapItemUnlockedByTech(OrigMainProduct)
            if TechMap then
                for _, tech in pairs(TechMap) do
                    NewRecipe:add_unlock(tech)
                end
            end
            CheckStackedProductivity(OrigMainProduct)

        end
    
    end

    unstack_recipe = string.format("deadlock-stacks-unstack-%s", OrigMainProduct)
    DeadlockUnStackRecipe = data.raw.recipe[unstack_recipe]
    if DeadlockUnStackRecipe and DeadlockUnStackRecipe.subgroup then NewRecipe.subgroup = DeadlockUnStackRecipe.subgroup end

    NewRecipe:extend()
end

-- Go though each recipe to see if all ingredients / products are stacked,  if so then make a stacked recipe version of it
function Deadlock.MakeStackedRecipes()
    for recipe, recipe_table in pairs(data.raw.recipe) do 
        local StackedItemsFound = true
        local ingredients = {}
        local results = {}

        StackedRecipeName = string.format("stacked-recipe-%s", recipe)
        FixedRecipe = _Recipe(recipe):convert_results()  -- standardize recipe format

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

        -- look though ingredients for stacked version
        if ingredients then
            for _, ingredient in pairs(ingredients) do 
                if ingredient.name then name = ingredient.name else name=ingredient[1] end
                log(string.format("recipe (%s) has ingredient (%s)", recipe, name))
                DeadlockItem = data.raw.item[string.format("deadlock-stack-%s", name)]
                if not DeadlockItem then 
                    if ingredient.type and ingredient.type == 'fluid' then
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
                    if not data.raw["item"][string.format("deadlock-stack-%s", product.name)] then StackedItemsFound = false end
                end
            end
        elseif FixedRecipe.normal then
            if FixedRecipe.normal.results then 
                results = FixedRecipe.normal.results
                for _, product in pairs(FixedRecipe.normal.results) do 
                    if product.name then
                        if not data.raw["item"][string.format("deadlock-stack-%s", product.name)] then StackedItemsFound = false end
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
    for recipe_name, recipe_table in pairs(data.raw.recipe) do
        if Func.starts_with(recipe_name, "StackedRecipe") then
            local parent_name = string.sub(recipe_name, 15)
            if data.raw.recipe[parent_name] then
                local parent = data.raw.recipe[parent_name]
                sub_group = parent.subgroup or "misc"
                MakeSubGroup(sub_group)
                data.raw.recipe[recipe_name].subgroup = 'Stacked-'..sub_group
            end
        end
    end
end

return Deadlock