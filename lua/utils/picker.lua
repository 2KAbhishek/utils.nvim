local config = require('utils.config')
local picker_provider = config.config.picker_provider

---@class Utils.Picker
local M = {}

local fzf_lua_prompt_suffix = ' '

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
                opts.prompt = opts.title .. fzf_lua_prompt_suffix
                require('fzf-lua').git_files(opts)
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
                opts.prompt = opts.title .. fzf_lua_prompt_suffix
                require('fzf-lua').files(opts)
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
                opts.prompt = opts.title .. fzf_lua_prompt_suffix
                require('fzf-lua').live_grep(opts)
            end,
        },
        select_file = {
            snacks = function()
                require('snacks.picker').pick({
                    items = vim.tbl_map(function(item)
                        return { file = item }
                    end, opts.items),
                    title = opts.title,
                    format = Snacks.picker.format.file,
                    actions = {
                        confirm = Snacks.picker.actions.jump,
                    },
                })
            end,
            telescope = function()
                opts.prompt_title = opts.title
                require('telescope.pickers')
                    .new({}, {
                        prompt_title = opts.prompt_title,
                        finder = require('telescope.finders').new_table({
                            results = opts.items,
                            entry_maker = require('telescope.make_entry').gen_from_file(),
                        }),
                        sorter = require('telescope.sorters').get_fzy_sorter(),
                        previewer = require('telescope.previewers').vim_buffer_cat.new({}),
                    })
                    :find()
            end,
            fzf_lua = function()
                require('fzf-lua').fzf_exec(opts.items, {
                    prompt = opts.title .. fzf_lua_prompt_suffix,
                    file_icons = true,
                    previewer = 'builtin',
                    file_skip_empty_lines = true,
                    actions = {
                        ['default'] = function(selected)
                            if selected and #selected > 0 then
                                vim.cmd('edit ' .. vim.fn.fnameescape(selected[1]))
                            end
                        end,
                    },
                })
            end,
        },
        custom = {
            snacks = function()
                require('snacks.picker').pick({
                    items = vim.tbl_map(function(item)
                        return {
                            text = opts.entry_maker(item).display,
                            value = item,
                            preview = {
                                text = opts.preview_generator(item),
                                ft = opts.preview_ft or 'markdown',
                            },
                        }
                    end, opts.items),
                    title = opts.title,
                    format = Snacks.picker.format.text,
                    preview = 'preview',
                    actions = {
                        confirm = function(_, selected)
                            if selected and selected.value then
                                opts.selection_handler(nil, { value = selected.value })
                            end
                        end,
                    },
                })
            end,
            telescope = function()
                require('telescope.pickers')
                    .new({}, {
                        prompt_title = opts.title,
                        finder = require('telescope.finders').new_table({
                            results = opts.items,
                            entry_maker = opts.entry_maker,
                        }),
                        sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
                        previewer = require('telescope.previewers').new_buffer_previewer({
                            define_preview = function(self, entry, _)
                                local repo_info = opts.preview_generator(entry.value)
                                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(repo_info, '\n'))
                            end,
                        }),
                        attach_mappings = function(prompt_bufnr, _)
                            require('telescope.actions').select_default:replace(function()
                                local selection = require('telescope.actions.state').get_selected_entry()
                                require('telescope.actions').close(prompt_bufnr)
                                opts.selection_handler(prompt_bufnr, selection)
                            end)
                            return true
                        end,
                    })
                    :find()
            end,
            fzf_lua = function()
                local formatted_items = {}
                local item_map = {}
                for _, item in ipairs(opts.items) do
                    local entry = opts.entry_maker(item)
                    table.insert(formatted_items, entry.display)
                    item_map[entry.display] = item
                end

                local CustomPreviewer = require('fzf-lua.previewer.builtin').base:extend()
                function CustomPreviewer:new(o, preview_opts, fzf_win)
                    CustomPreviewer.super.new(self, o, preview_opts, fzf_win)
                    setmetatable(self, CustomPreviewer)
                    self.item_map = item_map
                    return self
                end

                function CustomPreviewer:populate_preview_buf(entry_str)
                    local bufnr = self:get_tmp_buffer()
                    local item = self.item_map[entry_str]
                    local preview_text = opts.preview_generator(item)
                    local lines = vim.split(preview_text, '\n')
                    vim.bo[bufnr].filetype = opts.preview_ft or 'markdown'
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

                    self:set_preview_buf(bufnr)
                    if self.win and type(self.win.update_scrollbar) == 'function' then
                        self.win:update_scrollbar()
                    end
                end

                require('fzf-lua').fzf_exec(formatted_items, {
                    prompt = opts.title .. fzf_lua_prompt_suffix,
                    previewer = CustomPreviewer,
                    actions = {
                        ['default'] = function(selected)
                            if selected and #selected > 0 then
                                local item = item_map[selected[1]]
                                if item then
                                    opts.selection_handler(nil, { value = item })
                                end
                            end
                        end,
                    },
                })
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

M.select_file = function(opts)
    vim.schedule(function()
        local picker_cmd = get_picker_command('select_file', opts)
        picker_cmd()
    end)
end

M.custom = function(opts)
    vim.schedule(function()
        local picker_cmd = get_picker_command('custom', opts)
        picker_cmd()
    end)
end

return M
