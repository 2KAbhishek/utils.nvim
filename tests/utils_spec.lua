local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils
local utils = require('utils')

describe('utils', function()
    describe('setup', function()
        it('checks if setup function exists', function()
            assert.is_not_nil(utils.setup)
            assert.are.equals(type(utils.setup), 'function')
        end)
    end)
end)
