--[[
	Name: Knit Initialization [V2]
	Made By: Real_KingBob
	Created: 9/2/2023
	Description: ProfileTemplate table is what empty profiles will default to.
    Updating the template will not include missing template values in existing player profiles!
]]

----- Services -----
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

----- Knit -----
Knit.Shared = ReplicatedStorage.Common
Knit.Modules = ServerScriptService.Modules
Knit.Components = ServerScriptService.Components

-- Constants
local StartingTime = workspace:GetServerTimeNow()

--// Ensures that all components are loaded
function Knit.OnComponentsLoaded()
	if Knit.ComponentsLoaded then
		return Promise.Resolve()
	end

	return Promise.new(function(resolve, reject, onCancel)
		local heartbeat

		heartbeat = RunService.Heartbeat:Connect(function()
			if Knit.ComponentsLoaded then
				heartbeat:Disconnect()
				heartbeat = nil
			end
		end)

		onCancel(function()
			if heartbeat then
				heartbeat:Disconnect()
				heartbeat = nil
			end
		end)
	end)
end

-- Load all services within 'Services':
Knit.AddServices(script.Parent.Services)
Knit.ComponentsLoaded = false
Knit.Start({ServicePromises = false}):andThen(function()

	-- Setting up services
	for _, component in pairs(Knit.Components:GetChildren()) do
		if not component:IsA("ModuleScript") then continue end
		require(component)
	end

	Knit.ComponentsLoaded = true
end):catch(warn):finally(function()
    local msTimeDifference: number = math.round((workspace:GetServerTimeNow() - StartingTime) * 1000)
	
	print(`✅ Server Initialized: Took {msTimeDifference}ms`)
end)