local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Picker
local picker = require('utils.picker')

describe('utils.picker', function()
    describe('files', function()
        it('checks if function exists', function()
            assert.is_not_nil(picker.files)
            assert.are.equals(type(picker.files), 'function')
        end)
    end)

    describe('live_grep', function()
        it('checks if function exists', function()
            assert.is_not_nil(picker.live_grep)
            assert.are.equals(type(picker.live_grep), 'function')
        end)
    end)

    describe('select_file', function()
        it('checks if function exists', function()
            assert.is_not_nil(picker.select_file)
            assert.are.equals(type(picker.select_file), 'function')
        end)
    end)

    describe('custom', function()
        it('checks if function exists', function()
            assert.is_not_nil(picker.custom)
            assert.are.equals(type(picker.custom), 'function')
        end)
    end)
end)
