

local os = require('os')

local json = require('utils.json')
local noti = require('utils.notification')
local shell = require('utils.shell')

---@class Utils.Cache
local M = {}

---@return string
local function get_cache_dir()
    local cache_dir = vim.fn.stdpath('cache')
    local result = cache_dir .. '/utils-nvim-cache'
    if vim.fs and vim.fs.normalize then
        return vim.fs.normalize(result)
    else
        return result:gsub('\\', '/'):gsub('//+', '/')
    end
end

---@param cache_key string
---@return string
local function get_cache_file_path(cache_key)
    local cache_dir = get_cache_dir()
    vim.fn.mkdir(cache_dir, 'p')
    return cache_dir .. '/' .. cache_key .. '.json'
end

---@param cache_file string
---@return {time: number, data: any}|nil
local function read_cache_file(cache_file)
    if vim.fn.filereadable(cache_file) ~= 0 then
        local f = io.open(cache_file, 'r')
        if f then
            local content = f:read('*a')
            f:close()
            local cache_data = json.safe_json_decode(content)
            if cache_data and cache_data.time and cache_data.data then
                return cache_data
            end
        end
    end
    return nil
end

---@param cache_file string
---@param data any
local function write_cache_file(cache_file, data)
    local cache_data = {
        time = os.time(),
        data = data,
    }
    local f = io.open(cache_file, 'w')
    if f then
        f:write(vim.json.encode(cache_data))
        f:close()
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
    shell.async_shell_execute(command, function(result)
        local data = json.safe_json_decode(result)
        if data then
            write_cache_file(cache_file, data)
            callback(data)
        end
    end)
end

---@param prefix string
M.clear_cache = function(prefix)
    local cache_dir = get_cache_dir()
    if vim.fn.isdirectory(cache_dir) == 0 then
        return
    end

    local matching_files = vim.fn.globpath(cache_dir, prefix .. '*', false, true)

    if #matching_files == 0 then
        noti.queue_notification('No cache items found matching: ' .. prefix, nil, 'Utils')
        return
    end

    for _, file in ipairs(matching_files) do
        vim.fn.delete(file, 'rf')
    end

    noti.queue_notification('Cleared cache items matching: ' .. prefix .. '*', nil, 'Utils')
end

return M
