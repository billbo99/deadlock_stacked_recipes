if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["warptorio2_expansion"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["msi-ore-uvaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi-ore-solaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi-ore-bludaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi_pure_bludaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi_pure_solaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi_pure_uvaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi-clean-bludaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi-clean-solaz"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi-graphite"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"},
        ["msi-graphite-rad"] = {tier = "wpe_rare_orez", sub_group = "raw-resource"}
    }

    for k, v in pairs(Items) do
        deadlock.add_stack(k, nil, v.tier, nil, nil)
    end
end
