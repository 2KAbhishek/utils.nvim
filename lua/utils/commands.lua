---@class Utils.Commands
local M = {}
local cache = require('utils.cache')

M.setup = function()
    vim.api.nvim_create_user_command('UtilsClearCache', function(opts)
        cache.clear_cache(opts.args)
    end, { nargs = '?' })
end

return M
