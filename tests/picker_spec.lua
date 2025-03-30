local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Picker
local picker = require('utils.picker')

describe('utils.picker', function()
    describe('system operations', function()
        it('determines correct open command', function()
            local original_has = vim.fn.has
            vim.fn.has = function(what)
                if what == 'mac' then
                    return 1
                else
                    return 0
                end
            end

            local stub_execute = stub(os, 'execute')
            picker.open_command('test.txt')
            assert.stub(stub_execute).was_called_with('open test.txt')

            -- Cleanup
            vim.fn.has = original_has
            stub_execute:revert()
        end)

        it('handles tmux environment for open_dir', function()
            local original_execute = os.execute
            os.execute = function(cmd)
                return 1 -- Simulate failure to fall back to Telescope
            end

            local original_schedule = vim.schedule
            vim.schedule = function(callback)
                callback()
            end

            local original_cmd = vim.cmd
            local cmd_calls = {}
            vim.cmd = function(command)
                table.insert(cmd_calls, command)
            end

            local test_dir = 'test/dir'
            picker.open_dir(test_dir)

            assert.equal(2, #cmd_calls)
            assert.equal('cd ' .. test_dir, cmd_calls[1])
            assert.equal('Telescope git_files cwd=' .. test_dir, cmd_calls[2])

            -- Cleanup
            os.execute = original_execute
            vim.schedule = original_schedule
            vim.cmd = original_cmd
        end)
    end)
end)
