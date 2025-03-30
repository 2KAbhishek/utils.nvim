local assert = require('luassert.assert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local before_each = require('plenary.busted').before_each
local after_each = require('plenary.busted').after_each

---@type Utils.Cache
local cache = require('utils.cache')

describe('utils.cache', function()
    describe('cache operations', function()
        local original_path
        local mock_cache_file
        local current_time

        before_each(function()
            -- Clear the utils.cache module from package.loaded
            package.loaded['utils.cache'] = nil

            -- Store original Path module and time
            original_path = require('plenary.path')
            current_time = os.time()

            -- Mock os.time
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

            -- Require utils.cache after mock is in place
            cache = require('utils.cache')
        end)

        after_each(function()
            -- Restore original modules
            package.loaded['plenary.path'] = original_path
            package.loaded['utils.cache'] = nil
        end)

        it('retrieves data from cache when fresh', function()
            local callback_called = false

            cache.get_data_from_cache('test-key', 'command', function(data)
                callback_called = true
                assert.equal('cached', data)
            end, 3600)

            assert.is_true(callback_called)
        end)
    end)

    describe('clear_cache', function()
        it('checks if clear_cache function exists', function()
            assert.is_not_nil(cache.clear_cache)
            assert.are.equals(type(cache.clear_cache), 'function')
        end)
    end)
end)
