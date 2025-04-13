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
    describe('is_available', function()
        it('returns true for available modules', function()
            local result = utils.is_available('plenary')
            assert.is_true(result)
        end)

        it('returns false for non-existent modules', function()
            local result = utils.is_available('this_module_does_not_exist_12345')
            assert.is_false(result)
        end)

        it('returns false when nil is passed', function()
            local result = utils.is_available(nil)
            assert.is_false(result)
        end)
    end)
end)
