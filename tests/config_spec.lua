local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Config
local config = require('utils.config')

describe('utils.config', function()
    describe('setup', function()
        it('checks if setup function exists', function()
            assert.is_not_nil(config.setup)
            assert.are.equals(type(config.setup), 'function')
        end)
    end)

    describe('config', function()
        it('checks if config table exists', function()
            assert.is_not_nil(config.config)
            assert.are.equals(type(config.config), 'table')
        end)

        it('checks if config table has default values', function()
            assert.are.equals(config.config.picker_provider, 'snacks')
        end)
    end)
end)
