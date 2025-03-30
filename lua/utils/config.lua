---@class Utils.Config
local M = {}

---@class Utils.Config.config
---@field picker_provider string
local config = {
    picker_provider = 'snacks',
}

---@type Utils.Config.config
M.config = config

---@param args Utils.Config.config
M.setup = function(args)
    M.config = vim.tbl_deep_extend('force', M.config, args or {})
end

return M
