---@class Job
---@field new fun(self: Job, config: table): Job
---@field start fun(self: Job): Job
---@field result fun(self: Job): string[]

---@class Path
---@field new fun(self: Path, ...): Path
---@field exists fun(self: Path): boolean
---@field read fun(self: Path): string
---@field write fun(self: Path, content: string, mode: string): nil
---@field mkdir fun(self: Path, opts: table): nil
---@field joinpath fun(self: Path, path: string): Path

local Job = require('plenary.job')
local Path = require('plenary.path')
local os = require('os')

---@class Utils
local M = {}

---@type table<number, {message: string, level: number, title: string, timeout: number}>
local notification_queue = {}

---@type boolean
local inside_tmux = vim.env.TMUX ~= nil

---@return Path
local function get_cache_dir()
    local cache_dir = vim.fn.stdpath('cache')
    return Path:new(cache_dir, 'utils-nvim-cache')
end

---@param cache_key string
---@return Path
local function get_cache_file_path(cache_key)
    local cache_dir = get_cache_dir()
    return cache_dir:joinpath(cache_key .. '.json')
end

local cache_dir = get_cache_dir()
cache_dir:mkdir({ parents = true, exists_ok = true })

---@param cache_file Path
---@return {time: number, data: any}|nil
local function read_cache_file(cache_file)
    if cache_file:exists() then
        local content = cache_file:read()
        local cache_data = M.safe_json_decode(content)
        if cache_data and cache_data.time and cache_data.data then
            return cache_data
        end
    end
    return nil
end

---@param cache_file Path
---@param data any
local function write_cache_file(cache_file, data)
    local cache_data = {
        time = os.time(),
        data = data,
    }
    cache_file:write(vim.json.encode(cache_data), 'w')
end

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
M.open_dir = function(dir)
    if inside_tmux then
        local open_cmd = string.format('tea %s', dir)
        local open_result = os.execute(open_cmd)
        if open_result == 0 then
            return
        end
    end
    vim.schedule(function()
        vim.cmd('cd ' .. dir)
        vim.cmd('Telescope git_files')
    end)
end

---@param command string
---@param callback fun(result: string)
M.async_shell_execute = function(command, callback)
    Job:new({
        command = vim.fn.has('win32') == 1 and 'cmd' or 'sh',
        args = vim.fn.has('win32') == 1 and { '/c', command } or { '-c', command },
        on_exit = function(j, return_val)
            local result = table.concat(j:result(), '\n')
            if return_val ~= 0 then
                M.queue_notification('Error executing command: ' .. command, vim.log.levels.ERROR)
                return
            end
            callback(result)
        end,
    }):start()
end

---@param str string
---@return table|nil
M.safe_json_decode = function(str)
    local success, result = pcall(vim.json.decode, str)
    if success then
        return result
    else
        M.queue_notification('Failed to parse JSON: ' .. result, vim.log.levels.ERROR)
        return nil
    end
end

---@param cache_key string
---@param command string
---@param callback fun(data: any)
---@param cache_timeout number
M.get_data_from_cache = function(cache_key, command, callback, cache_timeout)
    local cache_file = get_cache_file_path(cache_key)
    local cache_data = read_cache_file(cache_file)
    local current_time = os.time()
    if cache_data and (current_time - cache_data.time) < cache_timeout then
        callback(cache_data.data)
        return
    end
    M.async_shell_execute(command, function(result)
        local data = M.safe_json_decode(result)
        if data then
            write_cache_file(cache_file, data)
            callback(data)
        end
    end)
end

return M
