log("data-start")

if settings.startup["deadlock-enable-beltboxes"].value then
    require("data/group.lua")
    require("mods/vanilla/data.lua")
    require("mods/DyWorld/data.lua")
    require("mods/Krastorio/data.lua")
    require("mods/Omnimatter/data.lua")
    require("mods/FactorioExtended-Plus-Core/data.lua")
    require("mods/FactorioExtended-Plus-Revisited/data.lua")
else
    log("!! DeadLock BeltBoxes not enabled, this mod has nothing to do without them.")
end

log("data-end")
