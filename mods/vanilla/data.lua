local Deadlock = require("utils/deadlock")

local Items = {
    ["concrete"] = {tier = 1, sub_group = "tile"},
    ["explosives"] = {tier = 1, sub_group = "weapon"},
    ["rocket-control-unit"] = {tier = 3, sub_group = "rocket"},
    ["low-density-structure"] = {tier = 3, sub_group = "rocket"},
    ["rocket-fuel"] = {tier = 3, sub_group = "rocket"},
    ["automation-science-pack"] = {tier = 3, sub_group = "science", type = "tool"},
    ["logistic-science-pack"] = {tier = 3, sub_group = "science", type = "tool"},
    ["military-science-pack"] = {tier = 3, sub_group = "science", type = "tool"},
    ["chemical-science-pack"] = {tier = 3, sub_group = "science", type = "tool"},
    ["production-science-pack"] = {tier = 3, sub_group = "science", type = "tool"},
    ["utility-science-pack"] = {tier = 3, sub_group = "science", type = "tool"},
    ["space-science-pack"] = {tier = 3, sub_group = "science", type = "tool"}
}

Deadlock.MakeDeadlockItems(Items)
Deadlock.FixResearchTree(Items)
