if mods["WaterWell"] and mods["CompressedFluids"] then
    local item = table.deepcopy(data.raw.item["water-well-pump"])
    item.name = "hp-water-well-pump"
    item.icon = "__deadlock_stacked_recipes__/graphics/WaterWell/water-well-pump-icon.png"
    item.order = "x[water-well-pump]"
    item.place_result = item.name

    local recipe1 = table.deepcopy(data.raw.recipe["water-well-pump"])
    recipe1.name = "hp-water-well-pump"
    recipe1.icon = "__deadlock_stacked_recipes__/graphics/WaterWell/water-well-pump-icon.png"
    recipe1.icon_size = 32
    recipe1.order = "x[water-well-pump]"
    recipe1.result = recipe1.name
    recipe1.ingredients = {
        { "advanced-circuit", 10 },
        { "steel-plate",      15 },
        { "water-well-pump",  1 },
        { "fluid-compressor", 1 },

    }
    result = "water-well-pump"

    local recipe2 = table.deepcopy(data.raw.recipe["water-well-flow"])
    recipe2.name = "hp-water-well-flow"
    recipe2.results = { { type = "fluid", name = "high-pressure-water", amount = 2000 / settings["startup"]["fluid-compression-rate"].value } }

    local entity = table.deepcopy(data.raw["assembling-machine"]["water-well-pump"])
    entity.name = "hp-water-well-pump"
    entity.icon = "__deadlock_stacked_recipes__/graphics/WaterWell/water-well-pump-icon.png"
    entity.fixed_recipe = "hp-water-well-flow"
    entity.minable = { hardness = 0.2, mining_time = 0.5, result = "hp-water-well-pump" }

    entity.animation.layers[1].filename = "__deadlock_stacked_recipes__/graphics/WaterWell/water-well-pump-anim.png"
    entity.animation.layers[1].hr_version.filename = "__deadlock_stacked_recipes__/graphics/WaterWell/hr-water-well-pump-anim.png"

    local tech = data.raw.technology["fluid-compressor"]
    table.insert(tech.effects, { type = "unlock-recipe", recipe = "hp-water-well-pump" })

    data:extend({ item, recipe1, recipe2, entity })
end
