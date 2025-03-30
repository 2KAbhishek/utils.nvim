local os = require('os')
local config = require('utils.config')
local picker_provider = config.config.picker_provider

---@class Utils.Picker
local M = {}

---@type boolean
local inside_tmux = vim.env.TMUX ~= nil
local is_git_repo = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match('true')

---@return function
local function get_open_dir_command(dir)
    local commands = {
        git = {
            telescope = function()
                vim.cmd('Telescope git_files cwd=' .. (dir or ''))
            end,
            fzf_lua = function()
                vim.cmd('FzfLua git_files cwd=' .. (dir or ''))
            end,
            snacks = function()
                Snacks.picker.git_files({ cwd = dir })
            end,
        },
        no_git = {
            telescope = function()
                vim.cmd('Telescope find_files')
            end,
            fzf_lua = function()
                vim.cmd('FzfLua files')
            end,
            snacks = function()
                Snacks.picker.files()
            end,
        },
    }

    if is_git_repo then
        return commands.git[picker_provider]
    else
        return commands.no_git[picker_provider]
    end
end

---@param dir string
M.open_dir = function(dir)
    if picker_provider ~= 'snacks' and picker_provider ~= 'fzf_lua' and picker_provider ~= 'telescope' then
        error(
            'Invalid `fuzzy_provider`: ' .. picker_provider .. "\nPlease use either 'telescope', 'fzf_lua' or 'snacks'."
        )
    end

    if inside_tmux then
        local open_cmd = string.format('tea %s', dir)
        local open_result = os.execute(open_cmd)
        if open_result == 0 then
            return
        end
    end
    vim.schedule(function()
        vim.cmd('cd ' .. dir)

        local open_cmd = get_open_dir_command(dir)
        open_cmd()
    end)
end

return M
