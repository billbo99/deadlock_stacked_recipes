local Func = require("utils.func")

if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if not mods["Kythbloods_Stacked_Mining"] then
    return
end

if not mods["Mining_Drones"] then
    return
end

for recipe, recipe_table in pairs(data.raw.recipe) do
    if Func.starts_with(recipe, "mine-deadlock-stack") then
        local item_stack_size
        if recipe_table.results then
            item_stack_size = data.raw.item[recipe_table.results[1].name].stack_size
            recipe_table.results[1].amount = math.min(item_stack_size * 100, (2 ^ 16) - 1)
        end
        if recipe_table.normal and recipe_table.normal.results then
            item_stack_size = data.raw.item[recipe_table.normal.results[1].name].stack_size
            recipe_table.normal.results[1].amount = math.min(item_stack_size * 100, (2 ^ 16) - 1)
        end
        if recipe_table.expensive and recipe_table.expensive.results then
            item_stack_size = data.raw.item[recipe_table.expensive.results[1].name].stack_size
            recipe_table.expensive.results[1].amount = math.min(item_stack_size * 100, (2 ^ 16) - 1)
        end
    end
end
