local Deadlock = require("utils/deadlock")

local Items = {
    ["concrete"] = {tier = "concrete", sub_group = "tile"},
    ["explosives"] = {tier = "explosives", sub_group = "weapon"},
    ["rocket-control-unit"] = {tier = "rocket-control-unit", sub_group = "rocket"},
    ["low-density-structure"] = {tier = "low-density-structure", sub_group = "rocket"},
    ["rocket-fuel"] = {tier = "rocket-fuel", sub_group = "rocket"},
    ["automation-science-pack"] = {tier = 1, sub_group = "science", type = "tool"},
    ["logistic-science-pack"] = {tier = "logistic-science-pack", sub_group = "science", type = "tool"},
    ["military-science-pack"] = {tier = "military-science-pack", sub_group = "science", type = "tool"},
    ["chemical-science-pack"] = {tier = "chemical-science-pack", sub_group = "science", type = "tool"},
    ["production-science-pack"] = {tier = "production-science-pack", sub_group = "science", type = "tool"},
    ["utility-science-pack"] = {tier = "utility-science-pack", sub_group = "science", type = "tool"},
    ["space-science-pack"] = {tier = "space-science-pack", sub_group = "science", type = "tool"}
}

Deadlock.MakeDeadlockItems(Items)
