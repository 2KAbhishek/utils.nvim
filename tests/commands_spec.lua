local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Commands
local commands = require('utils.commands')

describe('utils.commands', function()
    describe('setup', function()
        it('checks if setup function exists', function()
            assert.is_not_nil(commands.setup)
            assert.are.equals(type(commands.setup), 'function')
        end)
    end)
end)
