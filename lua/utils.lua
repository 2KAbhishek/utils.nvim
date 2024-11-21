---@class job
---@field new fun(self: job, config: table): job
---@field start fun(self: job): job
---@field result fun(self: job): string[]

---@class path
---@field new fun(self: path, ...): path
---@field exists fun(self: path): boolean
---@field read fun(self: path): string
---@field write fun(self: path, content: string, mode: string): nil
---@field mkdir fun(self: path, opts: table): nil
---@field joinpath fun(self: path, path: string): path
---@field rm fun(self: path, opts: table): nil

local job = require('plenary.job')
local path = require('plenary.path')
local os = require('os')

---@class Utils
local M = {}

---@type table<number, {message: string, level: number, title: string, timeout: number}>
local notification_queue = {}

---@return path
local function get_cache_dir()
    local cache_dir = vim.fn.stdpath('cache')
    return path:new(cache_dir, 'utils-nvim-cache')
end

---@param cache_key string
---@return path
local function get_cache_file_path(cache_key)
    local cache_dir = get_cache_dir()
    cache_dir:mkdir({ parents = true, exists_ok = true })
    return cache_dir:joinpath(cache_key .. '.json')
end

---@param cache_file path
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

---@param cache_file path
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
    local inside_tmux = vim.env.TMUX ~= nil
    if inside_tmux then
        local open_cmd = string.format('tea %s', dir)
        local open_result = os.execute(open_cmd)
        if open_result == 0 then
            return
        end
    end
    vim.schedule(function()
        vim.cmd('cd ' .. dir)

        local is_git_repo = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match('true')

        if is_git_repo then
            vim.cmd('Telescope git_files cwd=' .. dir)
        else
            vim.cmd('Telescope find_files')
        end
    end)
end

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
                M.queue_notification(error_message, vim.log.levels.ERROR)
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

---@param prefix string
M.clear_cache = function(prefix)
    local cache_dir = get_cache_dir()
    if not cache_dir:exists() then
        return
    end

    if not prefix then
        cache_dir:rm({ recursive = true })
        M.queue_notification('Cache cleared successfully', nil, 'Utils')
        return
    end

    local matching_files = vim.fn.globpath(cache_dir:absolute(), prefix .. '*', false, true)

    if #matching_files == 0 then
        M.queue_notification('No cache items found matching: ' .. prefix, nil, 'Utils')
        return
    end

    for _, file in ipairs(matching_files) do
        vim.fn.delete(file, 'rf')
    end

    M.queue_notification('Cleared cache items matching: ' .. prefix, nil, 'Utils')
end

return M
