local Locale = {}

local non_entity_types = {
    achievement = true,
    ["active-defense-equipment"] = true,
    ["ambient-sound"] = true,
    ammo = true,
    ["ammo-category"] = true,
    armor = true,
    ["autoplace-control"] = true,
    ["battery-equipment"] = true,
    ["belt-immunity-equipment"] = true,
    blueprint = true,
    ["blueprint-book"] = true,
    ["build-entity-achievement"] = true,
    capsule = true,
    ["combat-robot-count"] = true,
    ["construct-with-robots-achievement"] = true,
    ["copy-paste-tool"] = true,
    ["custom-input"] = true,
    ["damage-type"] = true,
    ["deconstruct-with-robots-achievement"] = true,
    ["deconstruction-item"] = true,
    decorative = true,
    ["deliver-by-robots-achievement"] = true,
    ["dont-build-entity-achievement"] = true,
    ["dont-craft-manually-achievement"] = true,
    ["dont-use-entity-in-energy-production-achievement"] = true,
    ["editor-controller"] = true,
    ["energy-shield-equipment"] = true,
    ["equipment-category"] = true,
    ["equipment-grid"] = true,
    ["finish-the-game-achievement"] = true,
    fluid = true,
    font = true,
    ["fuel-category"] = true,
    ["generator-equipment"] = true,
    ["god-controller"] = true,
    ["group-attack-achievement"] = true,
    ["gui-style"] = true,
    gun = true,
    item = true,
    ["item-group"] = true,
    ["item-subgroup"] = true,
    ["item-with-entity-data"] = true,
    ["item-with-inventory"] = true,
    ["item-with-label"] = true,
    ["item-with-tags"] = true,
    ["kill-achievement"] = true,
    ["map-gen-presets"] = true,
    ["map-settings"] = true,
    ["mining-tool"] = true,
    module = true,
    ["module-category"] = true,
    ["mouse-cursor"] = true,
    ["movement-bonus-equipment"] = true,
    ["night-vision-equipment"] = true,
    ["noise-expression"] = true,
    ["noise-layer"] = true,
    ["optimized-decorative"] = true,
    ["player-damaged-achievement"] = true,
    ["produce-achievement"] = true,
    ["produce-per-hour-achievement"] = true,
    recipe = true,
    ["recipe-category"] = true,
    ["repair-tool"] = true,
    ["research-achievement"] = true,
    ["resource-category"] = true,
    ["roboport-equipment"] = true,
    ["selection-tool"] = true,
    shortcut = true,
    ["solar-panel-equipment"] = true,
    sound = true,
    ["spectator-controller"] = true,
    sprite = true,
    technology = true,
    tile = true,
    tool = true,
    ["train-path-achievement"] = true,
    ["trigger-target-type"] = true,
    ["trivial-smoke"] = true,
    tutorial = true,
    ["upgrade-item"] = true,
    ["utility-constants"] = true,
    ["utility-sounds"] = true,
    ["utility-sprites"] = true,
    ["virtual-signal"] = true,
    ["wind-sound"] = true
}

function Locale.find_item_prototype(name)
    --- Find the prototype for an item with the given name.
    --- This assumes that items and only items have `stack_size` defined.
    for type, prototypes in pairs(data.raw) do
        local prototype = prototypes[name]
        if prototype ~= nil and prototype.stack_size ~= nil then
            return prototype
        end
    end
    return nil
end

function Locale.find_entity_prototype(name)
    --- Find the prototype for an entity with the given name.
    for type, prototypes in pairs(data.raw) do
        if not non_entity_types[type] and prototypes[name] then
            return prototypes[name]
        end
    end
    return nil
end

function Locale.find_equipment_prototype(name)
    --- Find the prototype for an equipment with the given name.
    for type, prototypes in pairs(data.raw) do
        if type:match("-equipment") and prototypes[name] then
            return prototypes[name]
        end
    end
    return nil
end

function Locale.get_equipment_locale(name)
    --- Get the localised name of the equipment with the given name.
    local equipment = Locale.find_equipment_prototype(name)
    if equipment.localised_name then
        return equipment.localised_name
    else
        return {"equipment-name." .. name}
    end
end

function Locale.get_entity_locale(name)
    --- Get the localised name of the entity with the given name.
    local entity = Locale.find_entity_prototype(name)
    if entity.localised_name then
        return entity.localised_name
    else
        return {"entity-name." .. name}
    end
end

function Locale.get_item_locale(name)
    --- Get the localised name of the item with the given name.
    local item = Locale.find_item_prototype(name)

    if item.localised_name then
        return item.localised_name
    elseif item.place_result then
        return Locale.get_entity_locale(item.place_result)
    elseif item.placed_as_equipment_result then
        return Locale.get_equipment_locale(item.placed_as_equipment_result)
    else
        return {"item-name." .. name}
    end
end

function Locale.get_fluid_locale(name)
    --- Get the localised name of the fluid with the given name.
    local fluid = data.raw["fluid"][name]
    if fluid.localised_name then
        return fluid.localised_name
    else
        return {"fluid-name." .. name}
    end
end

function Locale.parse_product(product)
    local types = {"item", "tool"}
    --- Get a pair of `name, type` from the given product.
    if type(product) == "string" then
        for _, type in pairs(types) do
            if data.raw[type] and data.raw[type][product] then
                return product, type
            end
        end
        return product, "item"
    elseif type(product) == "table" then
        local prd = product.name or product[1]
        for _, type in pairs(types) do
            if data.raw[type] and data.raw[type][prd] then
                return prd, type
            end
        end

        local type = product.type or "item"
        return product.name, type
    else
        return product[1], "item"
    end
end

function Locale.find_product(recipe, product_name)
    --- Get a pair of `name, type` for the given product name in the given recipe.
    if recipe.results then
        for _, product in pairs(recipe.results) do
            local name, type = Locale.parse_product(product)
            if name == product_name then
                return name, type
            end
        end
    elseif recipe.result == product_name then
        return product_name, "item"
    else
        return nil, nil
    end
end

function Locale.get_main_product(recipe)
    --- Get a pair of `name, type` for the main product of the recipe.
    if recipe.main_product == "" then
        return nil, nil
    elseif recipe.main_product ~= nil then
        return Locale.find_product(recipe, recipe.main_product)
    elseif recipe.results then
        if table_size(recipe.results) == 1 then
            return Locale.parse_product(recipe.results[1])
        else
            return nil, nil
        end
    elseif recipe.normal.results then
        if table_size(recipe.normal.results) == 1 then
            return Locale.parse_product(recipe.normal.results[1])
        else
            return nil, nil
        end
    else
        return Locale.parse_product(recipe.result)
    end
end

function Locale.get_recipe_locale(recipe)
    --- Get the localised name for the given recipe.
    if recipe.localised_name then
        return recipe.localised_name
    end

    if recipe.normal ~= nil and recipe.expensive ~= nil then
        local normal_product, normal_type = Locale.get_main_product(recipe.normal)
        local expensive_product, expensive_type = Locale.get_main_product(recipe.expensive)
        if normal_product ~= nil and normal_product == expensive_product and normal_type == expensive_type then
            if normal_type == "item" then
                return Locale.get_item_locale(normal_product)
            else
                return Locale.get_fluid_locale(normal_product)
            end
        else
            return {"recipe-name." .. recipe.name}
        end
    end

    local main_product, main_type = Locale.get_main_product(recipe.normal or recipe.expensive or recipe)
    if main_product ~= nil then
        if main_type == "item" then
            return Locale.get_item_locale(main_product)
        else
            return Locale.get_fluid_locale(main_product)
        end
    else
        return {"recipe-name." .. recipe.name}
    end
end

return Locale
