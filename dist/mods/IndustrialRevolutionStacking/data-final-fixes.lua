if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["IndustrialRevolutionStacking"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["coal"] = {tier = "deadlock-stacking-1"},
        ["copper-ore"] = {tier = "deadlock-stacking-1"},
        ["tin-ore"] = {tier = "deadlock-stacking-2"},
        ["iron-ore"] = {tier = "deadlock-stacking-1"},
        ["gold-ore"] = {tier = "deadlock-stacking-2"},
        ["sulfur"] = {tier = "deadlock-stacking-2"},
        ["solid-fuel"] = {tier = "deadlock-stacking-2"},
        ["uranium-ore"] = {tier = "deadlock-stacking-3"},
        ["uranium-235"] = {tier = "deadlock-stacking-3"},
        ["uranium-238"] = {tier = "deadlock-stacking-3"}
    }

    for k, v in pairs(Items) do
        data.raw["item"][k].stack_size = tonumber(data.raw["item"][k].stack_size)
        deadlock.add_stack(k, nil, v.tier, nil, nil)
    end
end
