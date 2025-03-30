local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local before_each = require('plenary.busted').before_each
local after_each = require('plenary.busted').after_each

---@type Utils.Notification
local noti = require('utils.notification')

describe('utils.notification', function()
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
            noti.show_notification('test message')
            assert.equal(1, #notifications)
            assert.equal('test message', notifications[1].message)
            assert.equal(vim.log.levels.INFO, notifications[1].level)
            assert.equal('Notification', notifications[1].opts.title)
            assert.equal(5000, notifications[1].opts.timeout)
        end)

        it('queues multiple notifications', function()
            noti.queue_notification('message 1')
            noti.queue_notification('message 2')
            -- Allow the schedule to run
            vim.wait(100)
            assert.equal(2, #notifications)
        end)
    end)
end)
