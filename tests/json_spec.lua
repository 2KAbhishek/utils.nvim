local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local before_each = require('plenary.busted').before_each
local after_each = require('plenary.busted').after_each

---@type Utils.Json
local json = require('utils.json')

describe('utils.json', function()
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

    describe('json operations', function()
        it('safely decodes valid json', function()
            local json_str = '{"key": "value"}'
            local result = json.safe_json_decode(json_str)
            assert.is_table(result)
            assert.equal('value', result.key)
        end)

        it('handles invalid json gracefully', function()
            local invalid_json = '{invalid json}'
            local result = json.safe_json_decode(invalid_json)
            assert.is_nil(result)
            -- Check that an error notification was queued
            vim.wait(100)
            assert.equal(1, #notifications)
            assert.equal(vim.log.levels.ERROR, notifications[1].level)
        end)
    end)
end)
