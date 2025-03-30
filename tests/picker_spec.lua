local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Picker
local picker = require('utils.picker')

describe('utils.picker', function()
    describe('open_dir', function()
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
