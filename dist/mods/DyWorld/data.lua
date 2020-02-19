if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["DyWorld"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["stone"] = {tier = 1, variations = {"plate"}},
        ["nickel"] = {tier = 1, variations = {"ore", "plate", "slag", "gear-wheel", "stick", "cable"}},
        ["silver"] = {tier = 1, variations = {"ore", "plate", "slag", "stick"}},
        ["bronze"] = {tier = 1, variations = {"plate", "slag"}},
        ["tin"] = {tier = 1, variations = {"ore", "plate", "slag", "gear-wheel", "cable"}},
        ["gold"] = {tier = 2, variations = {"ore", "plate", "slag", "stick", "cable"}},
        ["lead"] = {tier = 2, variations = {"ore", "plate", "slag", "gear-wheel", "stick"}},
        ["cobalt"] = {tier = 2, variations = {"ore", "plate", "slag", "gear-wheel", "stick", "cable"}},
        ["invar"] = {tier = 2, variations = {"plate", "slag", "gear-wheel", "stick", "cable"}},
        ["electrum"] = {tier = 2, variations = {"plate", "slag", "stick", "cable"}},
        ["stainless-steel"] = {tier = 2, variations = {"plate", "slag", "gear-wheel", "stick"}},
        ["arditium"] = {tier = 2, variations = {"ore", "plate", "slag", "gear-wheel"}},
        ["titanium"] = {tier = 2, variations = {"ore", "plate", "slag", "gear-wheel", "stick", "cable"}},
        ["tungsten"] = {tier = 2, variations = {"ore", "plate", "slag", "gear-wheel", "stick"}},
        ["neutronium"] = {tier = 2, variations = {"ore", "plate", "slag", "stick"}},
        ["electranium"] = {tier = 2, variations = {"plate", "slag", "stick", "cable"}},
        ["arditium-tungstenate"] = {tier = 2, variations = {"plate", "slag", "gear-wheel", "stick"}},
        ["tungstvar"] = {tier = 2, variations = {"plate", "slag", "stick"}},
        ["neutrobaltium"] = {tier = 2, variations = {"plate", "slag", "gear-wheel", "stick", "cable"}}
    }

    Deadlock.MakeDeadlockItems(Items)
end
