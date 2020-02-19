if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

local Deadlock = require("utils/deadlock")

local Items = {
    -- inserters
    ["burner-inserter"] = {tier = "1", sub_group = "inserter"},
    ["inserter"] = {tier = "1", sub_group = "inserter"},
    ["long-handed-inserter"] = {tier = "1", sub_group = "inserter"},
    ["fast-inserter"] = {tier = "fast-inserter", sub_group = "inserter"},
    ["filter-inserter"] = {tier = "fast-inserter", sub_group = "inserter"},
    ["stack-inserter"] = {tier = "stack-inserter", sub_group = "inserter"},
    ["stack-filter-inserter"] = {tier = "stack-inserter", sub_group = "inserter"},
    -- pipe
    ["pipe"] = {tier = "1", sub_group = "pipe"},
    ["pipe-to-ground"] = {tier = "1", sub_group = "pipe"},
    -- ammo
    ["firearm-magazine"] = {tier = "1", sub_group = "ammo", type = "ammo"},
    ["piercing-rounds-magazine"] = {tier = "military-2", sub_group = "ammo", type = "ammo"},
    ["uranium-rounds-magazine"] = {tier = "uranium-ammo", sub_group = "ammo", type = "ammo"},
    -- belt
    ["transport-belt"] = {tier = "1", sub_group = "belt"},
    ["underground-belt"] = {tier = "logistics", sub_group = "belt"},
    ["splitter"] = {tier = "logistics", sub_group = "belt"},
    ["fast-underground-belt"] = {tier = "logistics-2", sub_group = "belt"},
    ["fast-transport-belt"] = {tier = "logistics-2", sub_group = "belt"},
    ["fast-splitter"] = {tier = "logistics-2", sub_group = "belt"},
    ["express-transport-belt"] = {tier = "logistics-3", sub_group = "belt"},
    ["express-underground-belt"] = {tier = "logistics-3", sub_group = "belt"},
    ["express-splitter"] = {tier = "logistics-3", sub_group = "belt"},
    -- rail
    ["rail"] = {tier = "railway", sub_group = "trasnport", type = "rail-planner"},
    -- tile
    ["landfill"] = {tier = "landfill", sub_group = "tile"},
    ["concrete"] = {tier = "concrete", sub_group = "tile"},
    ["hazard-concrete"] = {tier = "concrete", sub_group = "tile"}, -- cant be done as it requires a left / right version
    ["refined-concrete"] = {tier = "concrete", sub_group = "tile"},
    ["refined-hazard-concrete"] = {tier = "concrete", sub_group = "tile"}, -- cant be done as it requires a left / right version
    -- misc
    ["explosives"] = {tier = "explosives", sub_group = "weapon"},
    ["rocket-control-unit"] = {tier = "rocket-control-unit", sub_group = "rocket"},
    ["low-density-structure"] = {tier = "low-density-structure", sub_group = "rocket"},
    ["rocket-fuel"] = {tier = "rocket-fuel", sub_group = "rocket"},
    -- science
    ["automation-science-pack"] = {tier = 1, sub_group = "science", type = "tool"},
    ["logistic-science-pack"] = {tier = "logistic-science-pack", sub_group = "science", type = "tool"},
    ["military-science-pack"] = {tier = "military-science-pack", sub_group = "science", type = "tool"},
    ["chemical-science-pack"] = {tier = "chemical-science-pack", sub_group = "science", type = "tool"},
    ["production-science-pack"] = {tier = "production-science-pack", sub_group = "science", type = "tool"},
    ["utility-science-pack"] = {tier = "utility-science-pack", sub_group = "science", type = "tool"},
    ["space-science-pack"] = {tier = "space-science-pack", sub_group = "science", type = "tool"}
}

Deadlock.MakeDeadlockItems(Items)
