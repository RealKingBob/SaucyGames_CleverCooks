

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")

local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects")
local FoodObjects = GameLibrary:FindFirstChild("FoodObjects")

local NormalWalkSpeed = 16
local NewWalkSpeed = 30

return function (Player,Character)
	if not Player or not Character then return end

    local CookingService = Knit.GetService("CookingService")

	local playerData = CookingService.PlayersInServers[Player.UserId]
	if not playerData then 
		CookingService.PlayersInServers[Player.UserId] = {nil, nil} 
		playerData = CookingService.PlayersInServers[Player.UserId]
	end

	if not playerData[1] and Character:FindFirstChild("Ingredient").Value then
		CookingService:DebounceCooking(Player, 1)
		CookingService.PlayersInServers[Player.UserId][1] = true
		local ProximityService = Knit.GetService("ProximityService")

		for _,item in pairs(game.Workspace:FindFirstChild("FoodAvailable"):GetChildren()) do
			if item:IsA("Model") then
				--print("CHECKl", item.PrimaryPart:GetAttribute("Owner") , Player.Name, item , PlayersInServers[Player.UserId][2], item.PrimaryPart == PlayersInServers[Player.UserId][2])
				if not item then continue end
				if item and not item.PrimaryPart then item:Destroy() continue end
				if item.PrimaryPart == CookingService.PlayersInServers[Player.UserId][2] then item:Destroy() end
			elseif item:IsA("MeshPart") then
				if not item then continue end
				if  item == CookingService.PlayersInServers[Player.UserId][2] then item:Destroy() end
			end
		end
		for _,item in pairs(game.Workspace:FindFirstChild("IngredientAvailable"):GetChildren()) do
			if item:IsA("Model") then
				if not item then continue end
				if item and not item.PrimaryPart then item:Destroy() continue end
				if item.PrimaryPart == CookingService.PlayersInServers[Player.UserId][2] then item:Destroy() end
			elseif item:IsA("MeshPart") then
				--print("CHECK2", item:GetAttribute("Owner") , Player.Name, item , PlayersInServers[Player.UserId][2], item == PlayersInServers[Player.UserId][2])
				if not item then continue end
				if item == CookingService.PlayersInServers[Player.UserId][2] then item:Destroy() end
			end
		end

		ProximityService:DropItem(Character, CookingService.PlayersInServers[Player.UserId][2])
		CookingService.Client.ProximitySignal:Fire(Player,"DropDown",false)
		CookingService.Client.PickUp:Fire(Player, {Type = "ChangeStamina", Data = {NormalWalkSpeed, NewWalkSpeed}})

		CookingService.PlayersInServers[Player.UserId] = nil
	end
end