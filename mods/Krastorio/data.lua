if mods["DyWorld"] then
    local Deadlock = require("utils/deadlock")

    local Items = {}

    Deadlock.MakeDeadlockItems(Items)
    Deadlock.FixResearchTree(Items)
end
