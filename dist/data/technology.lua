if not settings.startup["DSR_recipes_after_beacons"].value then
    return
end

local rank = {
    -- Vanilla
    ["automation-science-pack"] = 10,
    ["logistic-science-pack"] = 20,
    ["military-science-pack"] = 30,
    ["chemical-science-pack"] = 40,
    ["production-science-pack"] = 50,
    ["utility-science-pack"] = 9999,
    ["space-science-pack"] = 9999,
    --K2
    ["basic-tech-card"] = 5,
    ["matter-tech-card"] = 9999,
    ["advanced-tech-card"] = 9999,
    ["singularity-tech-card"] = 9999,
    -- SE
    ["se-rocket-science-pack"] = 9999,
    ["se-astronomic-science-pack-1"] = 9999,
    ["se-astronomic-science-pack-2"] = 9999,
    ["se-astronomic-science-pack-3"] = 9999,
    ["se-astronomic-science-pack-4"] = 9999,
    ["se-biological-science-pack-1"] = 9999,
    ["se-biological-science-pack-2"] = 9999,
    ["se-biological-science-pack-3"] = 9999,
    ["se-biological-science-pack-4"] = 9999,
    ["se-deep-space-science-pack-1"] = 9999,
    ["se-deep-space-science-pack-2"] = 9999,
    ["se-deep-space-science-pack-3"] = 9999,
    ["se-deep-space-science-pack-4"] = 9999,
    ["se-energy-science-pack-1"] = 9999,
    ["se-energy-science-pack-2"] = 9999,
    ["se-energy-science-pack-3"] = 9999,
    ["se-energy-science-pack-4"] = 9999,
    ["se-material-science-pack-1"] = 9999,
    ["se-material-science-pack-2"] = 9999,
    ["se-material-science-pack-3"] = 9999,
    ["se-material-science-pack-4"] = 9999,
    -- Bobs
    ["advanced-logistic-science-pack"] = 9999,
    ["science-pack-gold"] = 9999,
    ["alien-science-pack"] = 9999,
    ["alien-science-pack-blue"] = 9999,
    ["alien-science-pack-green"] = 9999,
    ["alien-science-pack-orange"] = 9999,
    ["alien-science-pack-purple"] = 9999,
    ["alien-science-pack-red"] = 9999,
    ["alien-science-pack-yellow"] = 9999,
    ["effectivity-processor"] = 9999,
    ["module-case"] = 9999,
    ["module-circuit-board"] = 9999,
    ["pollution-clean-processor"] = 9999,
    ["pollution-create-processor"] = 9999,
    ["productivity-processor"] = 9999,
    ["speed-processor"] = 9999,
    ["token-bio"] = 9999
}

for name, tool_table in pairs(data.raw.tool) do
    log(name)
    if rank[name] ~= nil and rank[name] ~= 9999 then
        data:extend(
            {
                {
                    effects = {},
                    icons = {
                        {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                        {icon = tool_table.icon, icon_mipmaps = tool_table.icon_mipmaps, icon_size = tool_table.icon_size},
                        {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
                    },
                    name = "dsr-technology-" .. name,
                    order = "dsr-technology-" .. name,
                    localised_name = {"technology-name.dsr-technology"},
                    localised_description = {"technology-description.dsr-technology"},
                    prerequisites = {"effect-transmission"},
                    type = "technology",
                    unit = {
                        count = 1,
                        ingredients = {
                            {name, 1}
                        },
                        time = 60
                    }
                }
            }
        )
    end
end

log("end")
