local M = {}

M.setup = function(opts)
    require('utils.config').setup(opts)
    require('utils.commands').setup()
end

M.is_available = function(module)
    if not module then
        return false
    end

    local ok = pcall(require, module)
    return ok
end

return M
