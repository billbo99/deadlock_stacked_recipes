local Logger = {}

Logger.tracking = {}

function Logger.logger(flag, message)
    local setting = tonumber(settings.startup["debug_logging_level"].value) or settings.startup["debug_logging_level"].value
    local level = tonumber(flag) or flag

    if type(setting) == "number" and setting >= 9 then
        local info = debug.getinfo(2, "Sl")
        if info then
            log(string.format("[%s]:%d", info.short_src, info.currentline))
        end
    end

    if type(setting) == "number" and setting >= level then
        log("FLAG" .. flag .. " " .. message)
    end

    if type(setting) == "number" and setting >= 9 and message == "RAW" then
        log(serpent.block(data.raw))
    end
end

return Logger
