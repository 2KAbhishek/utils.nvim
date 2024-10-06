vim.api.nvim_create_user_command('UtilsClearCache', function()
    require('utils').clear_cache()
end, {})
