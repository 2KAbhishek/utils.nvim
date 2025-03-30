local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

---@type Utils.Time
local time = require('utils.time')

describe('utils.time', function()
    describe('human_time', function()
        it('converts timestamp to human readable format', function()
            local timestamp = '2024-10-05T15:46:41Z'
            local expected = '05 Oct 2024, 03:46 PM'
            local result = time.human_time(timestamp)
            assert.is_string(result)
            assert.equal(expected, result)
        end)

        it('returns invalid timestamps as is', function()
            local invalid_timestamp = 'invalid timestamp'
            local result = time.human_time(invalid_timestamp)
            assert.equal(invalid_timestamp, result)
        end)
    end)
end)
