return {
    setup = function(opts)
        require('utils.config').setup(opts)
        require('utils.commands').setup()
    end,
}
