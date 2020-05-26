if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["Deadlock-SE-bridge"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["se-vulcanite-crushed"] = {tier = "deadlock-stacking-space"},
        ["se-vulcanite-washed"] = {tier = "deadlock-stacking-space"},
        ["se-vulcanite-ion-exchange-beads"] = {tier = "deadlock-stacking-space"},
        ["se-cryonite-crushed"] = {tier = "deadlock-stacking-space"},
        ["se-cryonite-washed"] = {tier = "deadlock-stacking-space"},
        ["se-cryonite-ion-exchange-beads"] = {tier = "deadlock-stacking-space"},
        ["se-beryllium-ore-crushed"] = {tier = "deadlock-stacking-space-astronomic"},
        ["se-beryllium-sulfate"] = {tier = "deadlock-stacking-space-astronomic"},
        ["se-beryllium-powder"] = {tier = "deadlock-stacking-space-astronomic"},
        ["se-beryllium-ingot"] = {tier = "deadlock-stacking-space-astronomic"},
        ["se-vitamelange-nugget"] = {tier = "deadlock-stacking-space-biological"},
        ["se-vitamelange-roast"] = {tier = "deadlock-stacking-space-biological"},
        ["se-vitamelange-spice"] = {tier = "deadlock-stacking-space-biological"},
        ["se-holmium-ore-crushed"] = {tier = "deadlock-stacking-space-energy"},
        ["se-holmium-ore-washed"] = {tier = "deadlock-stacking-space-energy"},
        ["se-holmium-powder"] = {tier = "deadlock-stacking-space-energy"},
        ["se-holmium-ingot"] = {tier = "deadlock-stacking-space-energy"},
        ["se-iridium-ore-crushed"] = {tier = "deadlock-stacking-space-material"},
        ["se-iridium-ore-washed"] = {tier = "deadlock-stacking-space-material"},
        ["se-iridium-powder"] = {tier = "deadlock-stacking-space-material"},
        ["se-iridium-ingot"] = {tier = "deadlock-stacking-space-material"},
        ["se-naquium-ore-crushed"] = {tier = "deadlock-stacking-space-deep"},
        ["se-naquium-ore-washed"] = {tier = "deadlock-stacking-space-deep"},
        ["se-naquium-powder"] = {tier = "deadlock-stacking-space-deep"},
        ["se-naquium-ingot"] = {tier = "deadlock-stacking-space-deep"},
        ["se-enriched-naquium"] = {tier = "deadlock-stacking-space-deep"},
        ["se-heavy-girder"] = {tier = "se-heavy-girder"},
        ["se-space-platform-scaffold"] = {
            tier = "se-space-platform-scaffold",
            type = "item",
            icon_path = "__space-exploration-graphics__/graphics/icons/space-platform-scaffold.png",
            icon_size = 32
        },
        ["se-space-platform-plating"] = {
            tier = "se-space-platform-plating",
            type = "item",
            icon_path = "__space-exploration-graphics__/graphics/icons/space-platform-plating.png",
            icon_size = 32
        }
    }

    for k, v in pairs(Items) do
        -- add_stack(item_name, graphic_path, target_tech, icon_size, item_type, mipmap_levels)
        if data.raw.item[k] then
            if not data.raw.item["deadlock-stack-" .. k] then
                local item_type = v.type or nil
                local icon_path = v.icon_path or nil
                local icon_size = v.icon_size or nil
                deadlock.add_stack(k, icon_path, v.tier, icon_size, item_type)
            end
        end
    end
end
