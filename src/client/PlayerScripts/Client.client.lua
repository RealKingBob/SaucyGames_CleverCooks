--[[
	Name: Knit Client [V2]
	Creator: Real_KingBob
	Made in: 9/2/2023
	Description: Handles all the knit client initialization
]]

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

----- Knit -----
Knit.PlayerScripts = Knit.Player:WaitForChild("PlayerScripts")

--Knit.Components = Knit.PlayerScripts:WaitForChild("Components")
Knit.Modules = Knit.PlayerScripts:WaitForChild("Modules")
Knit.Controllers = Knit.PlayerScripts:WaitForChild("Controllers")

Knit.Shared = ReplicatedStorage.Common

-- Constants
local StartingTime = workspace:GetServerTimeNow()

local KnitClient = Knit.CreateController { Name = "KnitClient" }

function KnitClient:KnitInit()

end

Knit.AddControllersDeep(Knit.Controllers)
Knit.Start({ServicePromises = false}):andThen(function()

	--[[for _, component in pairs(Knit.Components:GetDescendants()) do
		if not component:IsA("ModuleScript") then continue end
		require(component)
	end]]

	--[[local Animations = ReplicatedStorage.Assets:WaitForChild("Animations")
    print("Preloading Animations...")
    ContentProvider:PreloadAsync(Animations:GetDescendants())]]
    print("Animations Loaded!")

	Knit.ComponentsLoaded = true
	print("Client started | Version:", game.PlaceVersion)
end):catch(warn):finally(function()
    local msTimeDifference: number = math.round((workspace:GetServerTimeNow() - StartingTime) * 1000)

    print(`✅ Client | Took: {msTimeDifference}ms to initialize`)
end)