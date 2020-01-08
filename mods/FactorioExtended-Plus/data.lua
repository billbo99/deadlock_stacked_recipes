if mods["FactorioExtended-Plus-Core"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["titanium"] = {tier = 1, types = {"ore", "alloy"}}
    }

    Deadlock.MakeDeadlockItems(Items)
    Deadlock.FixResearchTree(Items)
end
