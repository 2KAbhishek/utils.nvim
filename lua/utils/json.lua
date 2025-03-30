local noti = require('utils.notification')

---@class Utils.Json
local M = {}

---@param str string
---@return table|nil
M.safe_json_decode = function(str)
    local success, result = pcall(vim.json.decode, str)
    if success then
        return result
    else
        noti.queue_notification('Failed to parse JSON: ' .. result, vim.log.levels.ERROR)
        return nil
    end
end

return M
