---
-- @module ContentProviderUtils

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local Promise = require(ReplicatedStorage.Packages.Promise)

local ContentProviderUtils = {}

-- Note: If strings are passed in, it only preloads textures, and will preload meshes, but only to http client.
function ContentProviderUtils.promisePreload(contentIdList)
	assert(type(contentIdList) == "table")

	return Promise.defer(function(resolve, reject)
		local ok, err = pcall(function()
			ContentProvider:PreloadAsync(contentIdList)
		end)

		if not ok then
			return reject(err)
		end

		resolve()
	end)
end

return ContentProviderUtils