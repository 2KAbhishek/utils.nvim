---@class Utils.Time
local M = {}

---@param timestamp string
---@return string
M.human_time = function(timestamp)
    local pattern = '(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)'
    local year, month, day, hour, min, sec = timestamp:match(pattern)

    if year and month and day and hour and min and sec then
        local timestamp_int = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
        return tostring(os.date('%d %b %Y, %I:%M %p', timestamp_int))
    else
        return timestamp
    end
end

return M
