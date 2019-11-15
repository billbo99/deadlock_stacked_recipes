data:extend(
    {
        {
            type = "item-group",
            name = 'Stacked_Recipes',
            icon = '__deadlock_stacked_recipes__/graphics/thumbnail64.png',
            icon_size = 64,
            order = "z-Stacked_Recipes",
        },
        {type = "item-subgroup", name = 'Stacked-misc', group = 'Stacked_Recipes', order = 'Stacked-misc'},
        {type = "item-subgroup", name = 'Stacked-ore', group = 'Stacked_Recipes', order = 'Stacked-ore'},
        {type = "item-subgroup", name = 'Stacked-plate', group = 'Stacked_Recipes', order = 'Stacked-plate'},
    }   
)

log(serpent.block(data.raw["item-group"]["Stacked_Recipes"]))
log(serpent.block(data.raw["item-subgroup"]["Stacked-ore"]))

