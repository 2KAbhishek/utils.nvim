---@class Utils.Notification
local M = {}

---@type table<number, {message: string, level: number, title: string, timeout: number}>
local notification_queue = {}

local function process_notification_queue()
    vim.schedule(function()
        while #notification_queue > 0 do
            local noti = table.remove(notification_queue, 1)
            M.show_notification(noti.message, noti.level, noti.title, noti.timeout)
        end
    end)
end

---@param message string
---@param level? number
---@param title? string
---@param timeout? number
M.queue_notification = function(message, level, title, timeout)
    level = level or vim.log.levels.INFO
    title = title or 'Notification'
    timeout = timeout or 5000
    table.insert(notification_queue, { message = message, level = level, title = title, timeout = timeout })
    process_notification_queue()
end

---@param message string
---@param level? number
---@param title? string
---@param timeout? number
M.show_notification = function(message, level, title, timeout)
    level = level or vim.log.levels.INFO
    title = title or 'Notification'
    timeout = timeout or 5000
    vim.notify(message, level, {
        title = title,
        timeout = timeout,
    })
end

return M
