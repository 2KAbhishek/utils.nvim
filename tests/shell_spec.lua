local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local before_each = require('plenary.busted').before_each
local after_each = require('plenary.busted').after_each

---@type Utils.Shell
local shell = require('utils.shell')

describe('utils.shell', function()
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
            shell.async_shell_execute('test command', function(result)
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
            shell.async_shell_execute('failing command', function()
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
