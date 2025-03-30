local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Picker
local picker = require('utils.picker')

describe('utils.picker', function()
    describe('open_dir', function()
        it('checks if open_dir function exists', function()
            assert.is_not_nil(picker.open_dir)
            assert.are.equals(type(picker.open_dir), 'function')
        end)
    end)
end)
