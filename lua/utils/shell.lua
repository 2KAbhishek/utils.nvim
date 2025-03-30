---@class job
---@field new fun(self: job, config: table): job
---@field start fun(self: job): job
---@field result fun(self: job): string[]
local job = require('plenary.job')

local os = require('os')
local noti = require('utils.notification')
local picker = require('utils.picker')

---@class Utils.Shell
local M = {}

M.inside_tmux = vim.env.TMUX ~= nil

---@param command string
---@param callback fun(result: string)
M.async_shell_execute = function(command, callback)
    job:new({
        command = vim.fn.has('win32') == 1 and 'cmd' or 'sh',
        args = vim.fn.has('win32') == 1 and { '/c', command } or { '-c', command },
        on_exit = function(j, return_val)
            local result = j:result()
            local output = type(result) == 'table' and table.concat(result, '\n') or tostring(result)

            if return_val ~= 0 then
                local error_output = j:stderr_result()
                error_output = type(error_output) == 'table' and table.concat(error_output, '\n')
                    or tostring(error_output)

                local error_message =
                    string.format('Error executing:\n%s\n\nDetails:\n%s\n%s', command, output, error_output)
                noti.queue_notification(error_message, vim.log.levels.ERROR)
                return
            end
            callback(output)
        end,
    }):start()
end

---@param command string
M.open_command = function(command)
    local open_command
    if vim.fn.has('mac') == 1 then
        open_command = 'open'
    elseif vim.fn.has('unix') == 1 then
        open_command = 'xdg-open'
    else
        open_command = 'start'
    end
    os.execute(open_command .. ' ' .. command)
end

---@param dir string
M.open_session_or_dir = function(dir)
    if M.inside_tmux then
        local open_cmd = string.format('tea %s', dir)
        local open_result = os.execute(open_cmd)
        if open_result == 0 then
            return
        end
    end
    vim.cmd('cd ' .. dir)
    picker.files(dir)
end

return M
