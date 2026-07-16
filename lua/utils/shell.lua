local os = require('os')
local noti = require('utils.notification')
local utils = require('utils')

---@class Utils.Shell
local M = {}

M.inside_tmux = vim.env.TMUX ~= nil

---@param command string
---@param callback fun(result: string)
M.async_shell_execute = function(command, callback)
    local cmd = vim.fn.has('win32') == 1 and { 'cmd', '/c', command } or { 'sh', '-c', command }
    local stdout = {}
    local stderr = {}

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    table.insert(stdout, line)
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    table.insert(stderr, line)
                end
            end
        end,
        on_exit = function(_, exit_code)
            while #stdout > 0 and stdout[#stdout] == '' do
                table.remove(stdout)
            end
            while #stderr > 0 and stderr[#stderr] == '' do
                table.remove(stderr)
            end

            local output = table.concat(stdout, '\n')

            if exit_code ~= 0 then
                local error_output = table.concat(stderr, '\n')
                local error_message =
                    string.format('Error executing:\n%s\n\nDetails:\n%s\n%s', command, output, error_output)
                noti.queue_notification(error_message, vim.log.levels.ERROR)
                return
            end
            callback(output)
        end,
    })
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
    else
        vim.schedule(function()
            vim.cmd('cd ' .. dir)
            if utils.is_available('pickme') then
                require('pickme').pick('files', { cwd = dir })
            else
                vim.cmd('edit ' .. dir)
            end
        end)
    end
end

return M
