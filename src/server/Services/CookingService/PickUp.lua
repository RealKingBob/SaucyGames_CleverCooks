

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")

local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects")
local FoodObjects = GameLibrary:FindFirstChild("FoodObjects")

local WalkSpeedWithItem = 13
local NewWalkSpeedWithItem = 26

return function (Player, Character, Item)
	if not Player or not Character or not Item then return end
	if not Item:IsDescendantOf(workspace) then return end
	if CollectionService:HasTag(Item, "OnCookingDelete") then return end
	if CollectionService:HasTag(Item, "InPickup") then return end

    local CookingService = Knit.GetService("CookingService")

	local playerData = CookingService.PlayersInServers[Player.UserId]
	if not playerData then 
		CookingService.PlayersInServers[Player.UserId] = {nil, nil} 
		playerData = CookingService.PlayersInServers[Player.UserId]
	end

	if not playerData[1] and not Character:FindFirstChild("Ingredient").Value then
		--print('c',cookingTimers[Player])
		CookingService:DebounceCooking(Player, 1)
		--print('d',cookingTimers[Player])
		local ProximityService = Knit.GetService("ProximityService")
		CollectionService:AddTag(Item, "InPickup")

		local itemObject = (Item:IsA("Model") and Item.PrimaryPart ~= nil and Item.PrimaryPart) or Item
		
		if not itemObject or not Character:FindFirstChild("HumanoidRootPart") then return end
		local Magnitude = (itemObject.Position - Character:FindFirstChild("HumanoidRootPart").Position).magnitude

		print("MAGNITUDE:", Magnitude)
		
		if not Magnitude or Magnitude > 13 then return end

		local itemType = itemObject:GetAttribute("Type")

		CookingService.PlayersInServers[Player.UserId] = {true, Item}

		local blendedItems = {}

		if itemType == "Ingredient" then

			local ClonedItem = IngredientObjects:FindFirstChild(Item.Name):Clone()
			
			if CollectionService:HasTag(itemObject, "IngredientsTable")  then
				for i = 1, 5 do
					if Item:IsA("Model") then
						table.insert(blendedItems, i, Item.PrimaryPart:GetAttribute("i"..tostring(i)))
					else
						table.insert(blendedItems, i, Item:GetAttribute("i"..tostring(i)))
					end
				end

				if ClonedItem:IsA("Model") then
					ClonedItem.PrimaryPart.Color = (Item:IsA("Model") and Item.PrimaryPart ~= nil and Item.PrimaryPart.Color) or Item.Color
				else
					ClonedItem.Color = (Item:IsA("Model") and Item.PrimaryPart ~= nil and Item.PrimaryPart.Color) or Item.Color
				end

				for i = 1, 5 do
					if ClonedItem:IsA("Model") then
						ClonedItem.PrimaryPart:SetAttribute("i"..tostring(i), blendedItems[i])
					else
						ClonedItem:SetAttribute("i"..tostring(i), blendedItems[i])
					end
				end
			end
			
			ProximityService:PickUpIngredient(Character, ClonedItem)
			for _, player : Player in Players:GetPlayers() do
				CookingService.Client.PickUp:Fire(player, {Type = "DestroyFood", Data = Item})
			end
			print("pickup members,")
			CookingService.Client.ProximitySignal:Fire(Player,"DropDown",true) 
			CookingService.Client.PickUp:Fire(Player, {Type = "ChangeStamina", Data = {WalkSpeedWithItem, NewWalkSpeedWithItem}})
			CookingService.PlayersInServers[Player.UserId] = {nil, Item}
		elseif itemType == "Food" then
			local cookingPercentage = (Item:IsA("Model") and Item.PrimaryPart ~= nil and Item.PrimaryPart:GetAttribute("CookingPercentage")) or Item:GetAttribute("CookingPercentage")
				
			local ClonedItem = FoodObjects:FindFirstChild(Item.Name):Clone()

			local mainCloneItem = (ClonedItem:IsA("Model") and ClonedItem.PrimaryPart ~= nil and ClonedItem.PrimaryPart) or ClonedItem
			
			mainCloneItem:SetAttribute("CookingPercentage", cookingPercentage)
			
			require(script.Parent.VisualizeFood)(ClonedItem, cookingPercentage)
			
			ProximityService:PickUpFood(Character, ClonedItem)
			print("pickup members,")
			for _, player : Player in Players:GetPlayers() do
				CookingService.Client.PickUp:Fire(player, {Type = "DestroyFood", Data = Item})
			end
			CookingService.Client.ProximitySignal:Fire(Player,"DropDown",true)
			CookingService.Client.PickUp:Fire(Player, {Type = "ChangeStamina", Data = {WalkSpeedWithItem, NewWalkSpeedWithItem}})
			CookingService.PlayersInServers[Player.UserId] = {nil, Item}
		end
	end
end