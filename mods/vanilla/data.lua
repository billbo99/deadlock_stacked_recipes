local Deadlock = require("utils/deadlock")

local Items = {
    ["concrete"] = { tier=1, sub_group='tile' },
    ["explosives"] = { tier=1, sub_group='weapon'  },
    ["rocket-control-unit"] = { tier=3, sub_group='rocket' },
    ["low-density-structure"] = { tier=3, sub_group='rocket' },
    ["rocket-fuel"] = { tier=3, sub_group='rocket' },
}

Deadlock.MakeDeadlockItems(Items)
Deadlock.FixResearchTree(Items)
