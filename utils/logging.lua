local Logger = {}

function Logger.logger(flag, message)
    local setting = tonumber(settings.startup["debug_logging_level"].value) or settings.startup["debug_logging_level"].value
    local level = tonumber(flag) or flag

    if type(setting) == "number" and setting >= level then
        log(message)
    end
end

return Logger
