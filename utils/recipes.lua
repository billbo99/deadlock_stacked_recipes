local Recipes = {}

function Recipes.result_to_results(recipe_section)
    if not recipe_section.result then
        return
    end
    local result_count = recipe_section.result_count or 1
    if type(recipe_section.result) == "string" then
        recipe_section.results = {{type = "item", name = recipe_section.result, amount = result_count}}
    elseif recipe_section.result.name then
        recipe_section.results = {recipe_section.result}
    elseif recipe_section.result[1] then
        result_count = recipe_section.result[2] or result_count
        recipe_section.results = {{type = "item", name = recipe_section.result[1], amount = result_count}}
    end
    recipe_section.result = nil
end

function Recipes.standardize_recipe(prototype)
    if not prototype.normal then
        prototype.normal = {
            enabled = prototype.enabled,
            energy_required = prototype.energy_required,
            requester_paste_multiplier = prototype.requester_paste_multiplier,
            hidden = prototype.hidden,
            ingredients = prototype.ingredients,
            results = prototype.results,
            result = prototype.result,
            result_count = prototype.result_count,
            main_product = prototype.main_product
        }
        prototype.enabled = nil
        prototype.energy_required = nil
        prototype.requester_paste_multiplier = nil
        prototype.hidden = nil
        prototype.ingredients = nil
        prototype.results = nil
        prototype.result = nil
        prototype.result_count = nil
        prototype.main_product = nil
    else
        prototype.normal = util.table.deepcopy(prototype.normal)
    end

    if not prototype.expensive then
        prototype.expensive = util.table.deepcopy(prototype.normal)
    else
        prototype.expensive = util.table.deepcopy(prototype.expensive)
    end

    if not prototype.normal.results and prototype.normal.result then
        Recipes.result_to_results(prototype.normal)
    end

    if not prototype.expensive.results and prototype.expensive.result then
        Recipes.result_to_results(prototype.expensive)
    end

    -- for key, property in pairs(prototype) do
    --     if key == "ingredients" then
    --         raw.normal.ingredients = table.deepcopy(property)
    --         raw.expensive.ingredients = table.deepcopy(property)
    --     elseif key == "results" then
    --         raw.normal.results = table.deepcopy(property)
    --         raw.expensive.results = table.deepcopy(property)
    --     elseif key ~= "normal" and key ~= "expensive" then
    --         raw[key] = property
    --     end
    -- end

    -- if prototype.normal then
    --     for key, property in pairs(prototype.normal) do
    --         raw.normal[key] = property
    --     end
    -- end

    -- if prototype.expensive then
    --     for key, property in pairs(prototype.expensive) do
    --         raw.expensive[key] = property
    --     end
    -- end
end

return Recipes
