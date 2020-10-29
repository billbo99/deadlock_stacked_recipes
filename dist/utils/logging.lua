local Logger = {}

Logger.tracking = {}

function Logger.logger(flag, message)
    local setting = tonumber(settings.startup["debug_logging_level"].value) or settings.startup["debug_logging_level"].value
    local level = tonumber(flag) or flag

    if type(setting) == "number" and setting >= 9 then
        log("A")
        local info = debug.getinfo(2, "Sl")
        if info then
            log(string.format("[%s]:%d", info.short_src, info.currentline))
        end
        log("B")
    end

    if type(setting) == "number" and setting >= level then
        log("C")
        log("FLAG" .. flag .. " " .. message)
        log("D")
    end

    if type(setting) == "number" and setting >= 9 and message == "RAW" then
        log(serpent.block(data.raw))
    end
end

return Logger
