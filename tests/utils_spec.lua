local stub = require('luassert.stub')

---@type Utils
local utils = require('utils')

describe('utils', function()
    local notifications = {}
    local original_notify

    before_each(function()
        notifications = {}
        original_notify = vim.notify
        vim.notify = function(msg, level, opts)
            table.insert(notifications, {
                message = msg,
                level = level,
                opts = opts,
            })
        end
    end)

    after_each(function()
        vim.notify = original_notify
        notifications = {}
    end)

    describe('notifications', function()
        it('shows notification with default values', function()
            utils.show_notification('test message')
            assert.equal(1, #notifications)
            assert.equal('test message', notifications[1].message)
            assert.equal(vim.log.levels.INFO, notifications[1].level)
            assert.equal('Notification', notifications[1].opts.title)
            assert.equal(5000, notifications[1].opts.timeout)
        end)

        it('queues multiple notifications', function()
            utils.queue_notification('message 1')
            utils.queue_notification('message 2')
            -- Allow the schedule to run
            vim.wait(100)
            assert.equal(2, #notifications)
        end)
    end)

    describe('json operations', function()
        it('safely decodes valid json', function()
            local json_str = '{"key": "value"}'
            local result = utils.safe_json_decode(json_str)
            assert.is_table(result)
            assert.equal('value', result.key)
        end)

        it('handles invalid json gracefully', function()
            local invalid_json = '{invalid json}'
            local result = utils.safe_json_decode(invalid_json)
            assert.is_nil(result)
            -- Check that an error notification was queued
            vim.wait(100)
            assert.equal(1, #notifications)
            assert.equal(vim.log.levels.ERROR, notifications[1].level)
        end)
    end)

    describe('cache operations', function()
        local original_path
        local mock_cache_file
        local current_time

        before_each(function()
            -- Clear the utils module from package.loaded
            package.loaded['utils'] = nil

            -- Store original Path module and time
            original_path = require('plenary.path')
            current_time = os.time()

            -- Mock os.time
            _G.os.time = function()
                return current_time
            end

            -- Create mock cache file
            mock_cache_file = {
                exists = function()
                    return true
                end,
                read = function()
                    return vim.json.encode({
                        time = current_time - 1000,
                        data = 'cached',
                    })
                end,
                write = function() end,
                joinpath = function(self, _)
                    return self
                end,
                mkdir = function() end,
            }

            -- Create and install mock Path module
            local MockPath = {
                new = function(_, ...)
                    return mock_cache_file
                end,
            }
            package.loaded['plenary.path'] = MockPath

            -- Require utils after mock is in place
            utils = require('utils')
        end)

        after_each(function()
            -- Restore original modules
            package.loaded['plenary.path'] = original_path
            package.loaded['utils'] = nil
            _G.os.time = os.time
        end)

        it('retrieves data from cache when fresh', function()
            local callback_called = false

            utils.get_data_from_cache('test-key', 'command', function(data)
                callback_called = true
                assert.equal('cached', data)
            end, 3600)

            assert.is_true(callback_called)
        end)
    end)
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
            utils.open_command('test.txt')
            assert.stub(stub_execute).was_called_with('open test.txt')

            -- Cleanup
            vim.fn.has = original_has
            stub_execute:revert()
        end)

        it('handles tmux environment for open_dir', function()
            local original_execute = os.execute
            local execute_called = false
            os.execute = function(cmd)
                execute_called = true
                return 1 -- Simulate failure to fall back to Telescope
            end

            local original_schedule = vim.schedule
            local schedule_called = false
            vim.schedule = function(callback)
                schedule_called = true
                callback()
            end

            local original_cmd = vim.cmd
            local cmd_calls = {}
            vim.cmd = function(command)
                table.insert(cmd_calls, command)
            end

            utils.open_dir('test/dir')

            assert.is_true(execute_called)
            assert.is_true(schedule_called)
            assert.equal(2, #cmd_calls)
            assert.equal('cd test/dir', cmd_calls[1])
            assert.equal('Telescope git_files', cmd_calls[2])

            -- Cleanup
            os.execute = original_execute
            vim.schedule = original_schedule
            vim.cmd = original_cmd
        end)
    end)

    describe('async operations', function()
        it('executes shell commands asynchronously', function()
            local original_job = require('plenary.job')

            -- Create mock job module
            local mock_job = {
                new = function(config)
                    return {
                        start = function()
                            -- Schedule the on_exit callback to simulate async behavior
                            vim.schedule(function()
                                config.on_exit({
                                    result = function()
                                        return { 'success' }
                                    end,
                                }, 0)
                            end)
                        end,
                    }
                end,
            }

            -- Replace job module
            package.loaded['plenary.job'] = mock_job

            local callback_called = false
            utils.async_shell_execute('test command', function(result)
                callback_called = true
            end)

            -- Wait for the scheduled callback
            vim.wait(100)
            assert.is_true(callback_called)

            -- Restore original job module
            package.loaded['plenary.job'] = original_job
        end)

        it('handles shell command errors', function()
            local original_job = require('plenary.job')

            -- Create mock job module
            local mock_job = {
                new = function(config)
                    return {
                        start = function()
                            -- Schedule the on_exit callback to simulate async behavior
                            vim.schedule(function()
                                config.on_exit({
                                    result = function()
                                        return { 'error output' }
                                    end,
                                }, 1)
                            end)
                        end,
                    }
                end,
            }

            -- Replace job module
            package.loaded['plenary.job'] = mock_job

            local callback_called = false
            utils.async_shell_execute('failing command', function()
                callback_called = true
            end)

            -- Wait for the scheduled callback
            vim.wait(100)
            assert.is_false(callback_called)
            assert.equal(1, #notifications)
            assert.equal(vim.log.levels.ERROR, notifications[1].level)

            -- Restore original job module
            package.loaded['plenary.job'] = original_job
        end)
    end)
end)
