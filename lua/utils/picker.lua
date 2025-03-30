local os = require('os')
local config = require('utils.config')
local picker_provider = config.config.picker_provider

---@class Utils.Picker
local M = {}

---@return function
local function get_picker_command(command, opts)
    local picker_commands = {
        git_files = {
            snacks = function()
                require('snacks.picker').git_files(opts)
            end,
            telescope = function()
                opts.prompt_title = opts.title
                require('telescope.builtin').git_files(opts)
            end,
            fzf_lua = function()
                require('fzf-lua').git_files(opts)
            end,
            mini = function()
                require('mini.pick').builtin.files(opts)
            end,
        },
        files = {
            snacks = function()
                require('snacks.picker').files(opts)
            end,
            telescope = function()
                opts.prompt_title = opts.title
                require('telescope.builtin').find_files(opts)
            end,
            fzf_lua = function()
                require('fzf-lua').files(opts)
            end,
            mini = function()
                require('mini.pick').builtin.files(opts)
            end,
        },
        live_grep = {
            snacks = function()
                require('snacks.picker').grep(opts)
            end,
            telescope = function()
                opts.prompt_title = opts.title
                require('telescope.builtin').live_grep(opts)
            end,
            fzf_lua = function()
                require('fzf-lua').live_grep(opts)
            end,
            mini = function()
                require('mini.pick').builtin.grep(opts)
            end,
        },
    }

    return picker_commands[command][picker_provider]
end

M.files = function(opts)
    local is_git_repo =
        vim.fn.system('cd ' .. opts.cwd .. ' && git rev-parse --is-inside-work-tree 2>/dev/null'):match('true')
    local command = is_git_repo and 'git_files' or 'files'
    vim.schedule(function()
        local picker_cmd = get_picker_command(command, opts)
        picker_cmd()
    end)
end

M.live_grep = function(opts)
    vim.schedule(function()
        local picker_cmd = get_picker_command('live_grep', opts)
        picker_cmd()
    end)
end

return M
