if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["FactorioExtended-Plus-Module"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["speed-module-4"] = {tier = "speed-module-4"},
        ["speed-module-5"] = {tier = "speed-module-5"},
        ["speed-module-6"] = {tier = "speed-module-6"},
        ["effectivity-module-4"] = {tier = "effectivity-module-4"},
        ["effectivity-module-5"] = {tier = "effectivity-module-5"},
        ["effectivity-module-6"] = {tier = "effectivity-module-6"},
        ["productivity-module-4"] = {tier = "productivity-module-4"},
        ["productivity-module-5"] = {tier = "productivity-module-5"},
        ["productivity-module-6"] = {tier = "productivity-module-6"}
    }

    for k, v in pairs(Items) do
        -- add_stack(item_name, graphic_path, target_tech, icon_size, item_type, mipmap_levels)
        deadlock.add_stack(k, nil, v.tier, nil, "module")
    end
end
