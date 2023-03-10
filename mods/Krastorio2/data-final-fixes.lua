if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["Krastorio2"] then
    local list_to_delete = {
        "kr-vc-deadlock-stack-raw-imersite",
        "kr-vc-deadlock-stack-stone"
    }

    for _, recpie in pairs(list_to_delete) do
        if data.raw.recipe[recpie] then
            data.raw.recipe[recpie].hidden = true
            data.raw.recipe[recpie].enabled = false
        end
    end
end
