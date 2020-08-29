data:extend(
    {
        -- startup
        {name = "override_stacking_size", type = "bool-setting", default_value = "true", setting_type = "startup", order = "0100"},
        {name = "dsr_new_subgroup_placement", type = "bool-setting", default_value = "true", setting_type = "startup", order = "0200"},
        {name = "override_fluid_only_recipes", type = "int-setting", default_value = -1, setting_type = "startup", order = "0300"},
        {name = "DSR_recipes_after_beacons", type = "bool-setting", default_value = false, setting_type = "startup", order = "0400"},
        {name = "debug_logging_level", type = "string-setting", default_value = "0", setting_type = "startup", order = "9999"}
    }
)
