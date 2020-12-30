if not settings.startup["deadlock-enable-beltboxes"].value then
    return
end

if mods["IndustrialRevolutionStacking"] then
    local Deadlock = require("utils/deadlock")

    local Items = {
        ["carbon-powder"] = {tier = "deadlock-stacking-1"},
        ["gravel"] = {tier = "deadlock-stacking-1"},
        ["silica"] = {tier = "deadlock-stacking-1"},
        ["glass"] = {tier = "deadlock-stacking-1"},
        ["glass-scrap"] = {tier = "deadlock-stacking-1"},
        ["glass-mix"] = {tier = "deadlock-stacking-1"},
        ["wood-beam"] = {tier = "deadlock-stacking-1"},
        ["wood-chips"] = {tier = "deadlock-stacking-1"},
        ["rubber"] = {tier = "deadlock-stacking-1"},
        ["charcoal"] = {tier = "deadlock-stacking-1"},
        ["paper"] = {tier = "deadlock-stacking-1"},
        ["coal"] = {tier = "deadlock-stacking-1"},
        ["sensor"] = {tier = "deadlock-stacking-1"},
        ["copper-motor"] = {tier = "deadlock-stacking-1"},
        ["iron-motor"] = {tier = "deadlock-stacking-1"},
        ["copper-coil"] = {tier = "deadlock-stacking-1"},
        ["electric-engine-unit"] = {tier = "deadlock-stacking-2"},
        ["gyroscope"] = {tier = "deadlock-stacking-2"},
        ["plastiglass"] = {tier = "deadlock-stacking-3"},
        ["graphite"] = {tier = "deadlock-stacking-3"},
        --
        ["copper-ore"] = {tier = "deadlock-stacking-1"},
        ["copper-rivet"] = {tier = "deadlock-stacking-1"},
        ["copper-piston"] = {tier = "deadlock-stacking-1"},
        ["copper-foil"] = {tier = "deadlock-stacking-1"},
        ["copper-beam"] = {tier = "deadlock-stacking-1"},
        ["copper-scrap"] = {tier = "deadlock-stacking-1"},
        ["copper-gate"] = {tier = "deadlock-stacking-1"},
        ["copper-board"] = {tier = "deadlock-stacking-1"},
        ["copper-frame-small"] = {tier = "deadlock-stacking-1"},
        ["copper-frame-large"] = {tier = "deadlock-stacking-1"},
        ["copper-cable-heavy"] = {tier = "deadlock-stacking-1"},
        ["copper-crushed"] = {tier = "deadlock-stacking-2"},
        ["copper-pure"] = {tier = "deadlock-stacking-3"},
        ["nickel-pure"] = {tier = "deadlock-stacking-3"},
        --
        ["tin-ore"] = {tier = "deadlock-stacking-2"},
        ["tin-scrap"] = {tier = "deadlock-stacking-2"},
        ["tin-crushed"] = {tier = "deadlock-stacking-2"},
        ["tin-pure"] = {tier = "deadlock-stacking-3"},
        ["lead-pure"] = {tier = "deadlock-stacking-3"},
        --
        ["bronze-rivet"] = {tier = "deadlock-stacking-1"},
        ["bronze-piston"] = {tier = "deadlock-stacking-1"},
        ["bronze-scrap"] = {tier = "deadlock-stacking-1"},
        ["bronze-mix"] = {tier = "deadlock-stacking-1"},
        ["bronze-plate-heavy"] = {tier = "deadlock-stacking-1"},
        ["bronze-plate-special"] = {tier = "deadlock-stacking-1"},
        --
        ["iron-ore"] = {tier = "deadlock-stacking-1"},
        ["iron-rivet"] = {tier = "deadlock-stacking-1"},
        ["iron-piston"] = {tier = "deadlock-stacking-1"},
        ["iron-beam"] = {tier = "deadlock-stacking-1"},
        ["iron-scrap"] = {tier = "deadlock-stacking-1"},
        ["iron-plate-heavy"] = {tier = "deadlock-stacking-1"},
        ["iron-frame-small"] = {tier = "deadlock-stacking-1"},
        ["iron-frame-large"] = {tier = "deadlock-stacking-1"},
        ["iron-crushed"] = {tier = "deadlock-stacking-2"},
        ["iron-pure"] = {tier = "deadlock-stacking-3"},
        ["chromium-pure"] = {tier = "deadlock-stacking-3"},
        ["iron-powder"] = {tier = "deadlock-stacking-3"},
        --
        ["gold-ore"] = {tier = "deadlock-stacking-2"},
        ["gold-crushed"] = {tier = "deadlock-stacking-2"},
        ["gold-scrap"] = {tier = "deadlock-stacking-2"},
        ["gold-foil"] = {tier = "deadlock-stacking-2"},
        ["gold-board"] = {tier = "deadlock-stacking-2"},
        ["gold-gate"] = {tier = "deadlock-stacking-2"},
        ["gold-pure"] = {tier = "deadlock-stacking-3"},
        ["tellurium-pure"] = {tier = "deadlock-stacking-3"},
        --
        ["silicon-mix"] = {tier = "deadlock-stacking-2"},
        ["silicon"] = {tier = "deadlock-stacking-2"},
        --
        ["steel-plate-heavy"] = {tier = "deadlock-stacking-2"},
        ["steel-beam"] = {tier = "deadlock-stacking-2"},
        ["steel-piston"] = {tier = "deadlock-stacking-2"},
        ["steel-rivet"] = {tier = "deadlock-stacking-2"},
        ["steel-mix"] = {tier = "deadlock-stacking-2"},
        ["steel-scrap"] = {tier = "deadlock-stacking-2"},
        ["steel-frame-small"] = {tier = "deadlock-stacking-2"},
        ["steel-frame-large"] = {tier = "deadlock-stacking-2"},
        --
        ["tellurium-foil"] = {tier = "deadlock-stacking-3"},
        ["tellurium-board"] = {tier = "deadlock-stacking-3"},
        ["tellurium-gate"] = {tier = "deadlock-stacking-3"},
        ["data-storage"] = {tier = "deadlock-stacking-3"},
        --
        ["junction-box"] = {tier = "deadlock-stacking-3"},
        ["stainless-beam"] = {tier = "deadlock-stacking-3"},
        ["stainless-frame-small"] = {tier = "deadlock-stacking-3"},
        ["stainless-frame-large"] = {tier = "deadlock-stacking-3"},
        ["stainless-scrap"] = {tier = "deadlock-stacking-3"},
        ["stainless-mix"] = {tier = "deadlock-stacking-3"},
        ["stainless-rivet"] = {tier = "deadlock-stacking-3"},
        ["stainless-heavy-plate"] = {tier = "deadlock-stacking-3"},
        --
        ["invar-mix"] = {tier = "deadlock-stacking-3"},
        ["cupronickel-mix"] = {tier = "deadlock-stacking-3"},
        ["chromium-mix"] = {tier = "deadlock-stacking-3"},
        ["chromium-rivet"] = {tier = "deadlock-stacking-3"},
        ["chromium-piston"] = {tier = "deadlock-stacking-3"},
        --
        ["low-density-structure"] = {tier = "low-density-structure"},
        ["rocket-fuel"] = {tier = "rocket-fuel"},
        ["rocket-control-unit"] = {tier = "rocket-control-unit"},
        ["uranium-ore"] = {tier = "deadlock-stacking-3"},
        --
        ["computer-mk1"] = {tier = "deadlock-stacking-1"},
        ["computer-mk2"] = {tier = "deadlock-stacking-2"},
        ["computer-mk3"] = {tier = "deadlock-stacking-3"}
        --
    }

    for k, v in pairs(Items) do
        deadlock.add_stack(k, nil, v.tier, nil, nil)
    end
end

if mods["IndustrialRevolutionStacking"] and mods["CompressedFluids"] then
    compressedFluids.remote.forceCompressingFluid("sulphur-gas")
    compressedFluids.remote.forceCompressingFluid("copper-molten")
    compressedFluids.remote.forceCompressingFluid("tin-molten")
    compressedFluids.remote.forceCompressingFluid("bronze-molten")
    compressedFluids.remote.forceCompressingFluid("glass-molten")
    compressedFluids.remote.forceCompressingFluid("iron-molten")
    compressedFluids.remote.forceCompressingFluid("gold-molten")
    compressedFluids.remote.forceCompressingFluid("nickel-molten")
    compressedFluids.remote.forceCompressingFluid("lead-molten")
    compressedFluids.remote.forceCompressingFluid("steel-molten")
    compressedFluids.remote.forceCompressingFluid("invar-molten")
    compressedFluids.remote.forceCompressingFluid("cupronickel-molten")
    compressedFluids.remote.forceCompressingFluid("stainless-molten")
    compressedFluids.remote.forceCompressingFluid("chromium-molten")
    compressedFluids.remote.forceCompressingFluid("tellurium-molten")
end
