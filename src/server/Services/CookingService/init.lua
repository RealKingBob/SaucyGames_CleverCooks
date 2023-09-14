--[[
	Name: Cooking Service [V3]
	Creator: Real_KingBob
	Made in: 9/19/21
    Updated: 12/31/22
	Description: Handles Cooking Mechanics / Proximity Mechanics for rat players
]]

local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CookingService = Knit.CreateService {
    Name = "CookingService",
	PlayersInServers = {},
    Client = {
		PickUp = Knit.CreateSignal(),
        DropDown = Knit.CreateSignal(),
		Recipe = Knit.CreateSignal(),
		Cook = Knit.CreateSignal(),
		Deliver = Knit.CreateSignal(),
		ParticlesSpawn = Knit.CreateSignal(),
		SendIngredients = Knit.CreateSignal(),
		ProximitySignal = Knit.CreateSignal(),

		UpdatePans = Knit.CreateSignal(),

		ChangeClientBlender = Knit.CreateSignal(),
	}
}

CookingService.PansInUse = {}
CookingService.DeliveryQueue = {}
CookingService.CookingDebounce = {}

----- Services -----

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Directories -----

local ReplicatedAssets = Knit.Shared.Assets
local ReplicatedModules = Knit.Shared.Modules
local ServerModules = Knit.Modules

----- Loaded Modules -----

local ZoneAPI = require(ReplicatedModules:FindFirstChild("Zone"))
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"))
local TableAPI = require(ServerModules:FindFirstChild("Table"))

local panZone = ZoneAPI.new(CollectionService:GetTagged("Pan"))
local deliverZone = ZoneAPI.new(CollectionService:GetTagged("DeliverStation"))

----- Variables -----

local EXPMultiplier = 10
local MaxFoodSpawnRange = 25

----- Tables -----

local FoodData = {}
local possibleRecipes = {}
local CurrentIngredientObjects = {}

local playerDebounces = {}

local Ingredients = {}
local prevIngredients = {}

local tempData = {}
local tCurrentIngredients = {}
local tCurrentIngredientObjects = {}
local partsArray = {}

local function PlayerAdded(player)
    possibleRecipes[player.Name] = {}
	playerDebounces[player] = false
end


local function PlayerRemoving(player)
    possibleRecipes[player.Name] = nil
	playerDebounces[player] = nil
end

function CookingService:DebounceCooking(player, time)
	if not player or not time then return end

	if not self.CookingDebounce then self.CookingDebounce = {} end
	
	if not self.CookingDebounce[player] then
		self.CookingDebounce[player] = Instance.new("IntValue")
		self.CookingDebounce[player].Value = time
		task.spawn(function()
			while (self.CookingDebounce[player].Value > 0) do
				self.CookingDebounce[player].Value -= 1
				task.wait(1)
			end
			self.CookingDebounce[player] = nil
		end)
	else
		-- To RESET the timer.
		self.CookingDebounce[player].Value = time

		-- To ADD to the timer.
		--stunned.Value = stunned.Value + Time
	end
end

-- Proximity Functions

function CookingService:PickUp(Player, Character, Item)
	return require(script.PickUp)(Player, Character, Item)
end

function CookingService:DropDown(Player,Character)
	return require(script.DropDown)(Player, Character)
end

----- Cooking Functions -----

function CookingService:CanCookOnPan(player, pan)
	return require(script.Cook.CanCookOnPan)(player, pan)
end

function CookingService:StartCookingProcess(player, pan, recipe, previousPercentage)
	return require(script.Cook.StartCookingProcess)(player, pan, recipe, previousPercentage)
end

function CookingService:Cook(player, Character, recipe, pan)
	return require(script.Cook)(player, Character, recipe, pan)
end

function CookingService:DeliverFood(player, food)
    return require(script.DeliverFood)(player, food)
end

function CookingService:KnitStart()
	--local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints")
	--local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)]

	--SpawnItemsAPI:Spawn(nil, nil, "Raw Steak", IngredientObjects, IngredientsAvailable, RandomFoodLocation.Position + Vector3.new(0,5,0))
    --SpawnItemsAPI:SpawnAllIngredients(5)
	--SpawnItemsAPI:SpawnAll(IngredientObjects,IngredientsAvailable)
    --SpawnItemsAPI:SpawnAtRandomSpawns(IngredientObjects,IngredientsAvailable, workspace.FoodSpawnPoints)
    --SpawnItemsAPI:SpawnAll(FoodObjects,IngredientsAvailable)
end


function CookingService:KnitInit()
    print('[CookingService]: Activated! [V2]')

	-- Tables
	local oldFoodData = {}

	-- Private functions
	local getRadius = function(part)
		return (part.Size.Z<part.Size.Y and part.Size.Z or part.Size.Y)/2
		--[[In the above we are returning the smallest, first we check if Z is smaller
		than Y, if so then we return Z or else we return Y.]]
	end

	local checkingDebounce = false

	local function checkIngredients() -- checks if the ingredients changed from last frame, if so send to client
		--print("check ingred")
		if checkingDebounce then return end

		checkingDebounce = true
		Ingredients = {}

		if self.CurrentIngredientObjects then
			for _, ingredient in pairs(self.CurrentIngredientObjects) do
				if typeof(ingredient) == "table" then
					table.insert(Ingredients, tostring(ingredient.Ingredient))
				else
					table.insert(Ingredients, tostring(ingredient))
				end
			end
		end

		if TableAPI.CheckArrayEquality(prevIngredients, Ingredients) == false then
			--print("SENT DATA")
			--print("data comparison", prevIngredients[player.UserId], playerIngredients[player.UserId], TableAPI.CheckArrayEquality(prevIngredients[player.UserId],playerIngredients[player.UserId]))
			
			for _, plr : Player in Players:GetPlayers() do
				self.Client.SendIngredients:Fire(plr, Ingredients)
			end
		end

		prevIngredients = Ingredients
		checkingDebounce = false
	end

	local function checkDeliverStations(deliverHitbox) -- checks if any food needs to be delivered
		--local radiusOfDeliverZone = getRadius(deliverHitbox)

		local overlapParams = OverlapParams.new()
		overlapParams.CollisionGroup = "Food"
		overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts")
		overlapParams.FilterType = Enum.RaycastFilterType.Blacklist

		local objectsInDeliverZone = workspace:GetPartBoundsInBox(deliverHitbox.CFrame, deliverHitbox.Size, overlapParams)
		for _, object in pairs(objectsInDeliverZone) do
			local touchedType, touchedOwner, touchedObject

			local tObject = nil
			if object then
				if object.Parent then
					if object.Parent:IsA("Model") then
						if object.Parent.PrimaryPart then
							tObject = object.Parent.PrimaryPart
							touchedObject = tObject.Parent
						end
					else
						tObject = object
						touchedObject = object
					end
				end
			end

			if tObject == nil then continue end

			touchedType = tObject:GetAttribute("Type")
			touchedOwner = tObject:GetAttribute("Owner")

			if touchedType == "Food" then
				if CollectionService:HasTag(touchedObject, "Delivering") == false then
					print(touchedObject, "in deliverzone")
					self:DeliverFood(touchedObject)
				end
			end
		end
	end

	local function checkPans(panHitbox) -- checks if any object is on the pans
		local panArray = {}
		local radiusOfPanZone = getRadius(panHitbox)

		local overlapParams = OverlapParams.new()
		overlapParams.CollisionGroup = "Food"
		overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts")
		overlapParams.FilterType = Enum.RaycastFilterType.Blacklist

		local objectsInPanZone = workspace:GetPartBoundsInRadius(panHitbox.Position, radiusOfPanZone, overlapParams)
		for _, object in pairs(objectsInPanZone) do
			local touchedType, touchedOwner, touchedObject

			local tObject = nil
			if object then
				if object.Parent then
					if object.Parent:IsA("Model") then
						if object.Parent.PrimaryPart then
							tObject = object.Parent.PrimaryPart
							touchedObject = tObject.Parent
						end
					else
						tObject = object
						touchedObject = object
					end
				end
			end
			
			if tObject == nil then continue end

			touchedType = tObject:GetAttribute("Type")
			touchedOwner = tObject:GetAttribute("Owner")

			if touchedObject and touchedType and touchedOwner then
				table.insert(panArray, object)
			end
		end

		return panArray
	end

	task.spawn(function()
		while task.wait(0) do
			checkIngredients()
		end
	end)
	
	task.spawn(function()
		while task.wait(0.1) do
			tempData = {}
			tCurrentIngredients = {}
			tCurrentIngredientObjects = {}
			partsArray = {}

			local function checkForBlendedItems(object, PlayerName)
				if CollectionService:HasTag(object, "IngredientsTable") then
					for i = 1, 5 do
						local blendedIngredient
						if object.Parent:IsA("Model") then
							blendedIngredient = object.Parent.PrimaryPart:GetAttribute("i"..tostring(i))
							table.insert(tempData,{PlayerName,{Ingredient = blendedIngredient.."-[Blended]", Source = object.Parent}})
							table.insert(tCurrentIngredientObjects, {Ingredient = blendedIngredient.."-[Blended]", Source = object.Parent})
						else
							blendedIngredient = object:GetAttribute("i"..tostring(i))
							table.insert(tempData,{PlayerName,{Ingredient = blendedIngredient.."-[Blended]", Source = object}})
							table.insert(tCurrentIngredientObjects, {Ingredient = blendedIngredient.."-[Blended]", Source = object})
						end
						if blendedIngredient ~= "" and blendedIngredient ~= nil then
							table.insert(tCurrentIngredients, blendedIngredient.."-[Blended]")
						end
					end
				end
			end

			for _, deliverHitbox in pairs(CollectionService:GetTagged("DeliverStation")) do
				checkDeliverStations(deliverHitbox)
			end
	
			for _, panHitbox in pairs(CollectionService:GetTagged("Pan")) do
				local specificPanArray = checkPans(panHitbox)

				for _, objectInPan in pairs(specificPanArray) do
					table.insert(partsArray, objectInPan)
				end
			end
	
			if #partsArray > 0 then -- checks if there are any parts
				--print("partsArray", partsArray)
				for _, touchedPart in ipairs(partsArray) do
					local tTouchedPart

					if touchedPart.Parent:IsA("Model") and touchedPart.Parent.PrimaryPart then
						tTouchedPart = touchedPart.Parent.PrimaryPart
					else
						tTouchedPart = touchedPart
					end

					local touchedType = tTouchedPart:GetAttribute("Type")
					local touchedOwner = tTouchedPart:GetAttribute("Owner")

					if touchedType and touchedOwner ~= "None" and panZone:findPart(touchedPart) == true then
						table.insert(tempData, touchedPart)

						if table.find(tCurrentIngredientObjects, touchedPart) == nil then
							table.insert(tCurrentIngredientObjects, touchedPart)
							table.insert(tCurrentIngredients, touchedPart.Name)

							checkForBlendedItems(touchedPart, touchedOwner)
						end
					end
				end

				FoodData = tempData --Table.Sync(FoodData,tempData)
				self.CurrentIngredientObjects = tCurrentIngredientObjects --Table.Sync(CurrentIngredientObjects,tCurrentIngredientObjects)

				if TableAPI.CheckTableEquality(oldFoodData, FoodData) ~= true then
					print("FOOD DATA:", FoodData)
					print("Ingredient DATA:", CurrentIngredientObjects)
					oldFoodData = FoodData
				else
					if #FoodData ~= 0 then
						print("INEQUALITY", FoodData)
					end
				end
			else
				FoodData = {}
				self.CurrentIngredientObjects = {}
			end
		end
	end)

    ----- Connections -----
	self.Client.PickUp:Connect(function(player, food)
		return self:PickUp(player, player.Character, food)
    end)

	self.Client.DropDown:Connect(function(player)
		return self:DropDown(player, player.Character)
    end)

	self.Client.Recipe:Connect(function(player, recipe)
		return self:Recipe(player, recipe)
    end)

	self.Client.Cook:Connect(function(player, recipe, pan)
		local cookReturn = nil
		if not playerDebounces[player] then playerDebounces[player] = false end
		if playerDebounces[player] == false then
			playerDebounces[player] = true
			cookReturn = self:Cook(player, player.Character, recipe, pan)
			task.wait(1)
			playerDebounces[player] = false
		end
		--print(player, recipe, pan)
		return cookReturn
    end)

    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(PlayerRemoving)
end


return CookingService
