vim.api.nvim_create_user_command('UtilsClearCache', function(opts)
    require('utils').clear_cache(opts.args)
end, { nargs = 1 })
