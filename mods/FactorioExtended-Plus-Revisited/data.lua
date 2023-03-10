if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["FactorioExtended-Plus-Revisited"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["titanium"] = {tier = 1, variations = {"ore", "gear", "rod", "girder", "alloy"}}
    }

    Deadlock.MakeDeadlockItems(Items)
end
