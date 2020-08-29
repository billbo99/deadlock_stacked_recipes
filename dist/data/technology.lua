if not settings.startup["DSR_recipes_after_beacons"].value then
    return
end

data:extend(
    {
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/automation-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-1",
            order = "dsr-technology-1",
            prerequisites = {"effect-transmission"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1}
                },
                time = 60
            }
        },
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/logistic-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-2",
            order = "dsr-technology-2",
            prerequisites = {"dsr-technology-1"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1}
                },
                time = 60
            }
        },
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/military-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-3",
            order = "dsr-technology-3",
            prerequisites = {"dsr-technology-2"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1}
                },
                time = 60
            }
        },
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/chemical-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-4",
            order = "dsr-technology-4",
            prerequisites = {"dsr-technology-3"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1}
                },
                time = 60
            }
        },
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/production-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-5",
            order = "dsr-technology-5",
            prerequisites = {"dsr-technology-4"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1}
                },
                time = 60
            }
        },
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/utility-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-6",
            order = "dsr-technology-6",
            prerequisites = {"dsr-technology-5"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1}
                },
                time = 60
            }
        },
        {
            effects = {},
            icons = {
                {icon = "__deadlock_stacked_recipes__/graphics/blank_64.png", icon_size = 64},
                {icon = "__base__/graphics/icons/space-science-pack.png", icon_mipmaps = 4, icon_size = 64},
                {icon = "__deadlock_stacked_recipes__/graphics/DSR_64_v5.png", icon_size = 64}
            },
            name = "dsr-technology-7",
            order = "dsr-technology-7",
            prerequisites = {"dsr-technology-6"},
            type = "technology",
            unit = {
                count = 100,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"military-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"space-science-pack", 1}
                },
                time = 60
            }
        }
    }
)
