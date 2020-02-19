if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["FactorioExtended-Plus-Core"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["titanium"] = {tier = 1, variations = {"ore", "alloy"}}
    }

    Deadlock.MakeDeadlockItems(Items)
end
