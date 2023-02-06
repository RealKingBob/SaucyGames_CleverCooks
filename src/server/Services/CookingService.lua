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
    Name = "CookingService";
    Client = {
		PickUp = Knit.CreateSignal(),
        DropDown = Knit.CreateSignal(),
		Recipe = Knit.CreateSignal(),
		Cook = Knit.CreateSignal(),
		Deliver = Knit.CreateSignal(),
		ParticlesSpawn = Knit.CreateSignal(),
		SendIngredients = Knit.CreateSignal(),
		ProximitySignal = Knit.CreateSignal();

		UpdatePans = Knit.CreateSignal();

		ChangeClientBlender = Knit.CreateSignal();
	};
}

----- Services -----

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

----- Directories -----

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary");

local IngredientAvailable = workspace:WaitForChild("IngredientAvailable");
local FoodAvailable = workspace:WaitForChild("FoodAvailable");

local ReplicatedAssets = Knit.Shared.Assets;
local ReplicatedModules = Knit.Shared.Modules;
local ServerModules = Knit.Modules;
local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects");
local FoodObjects = GameLibrary:FindFirstChild("FoodObjects");

local ThemeData = "French"

----- Loaded Modules -----

local ZoneAPI = require(ReplicatedModules:FindFirstChild("Zone"));
local Phrases = require(ReplicatedModules:FindFirstChild("Phrases"));
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"));
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"));
local TableAPI = require(ServerModules:FindFirstChild("Table"));
local MathAPI = require(ServerModules:FindFirstChild("Math"));

--[[local RecipeModule = require(ReplicatedModules:WaitForChild("RecipeModule"));
local ZoneAPI = require(ReplicatedModules:FindFirstChild("Zone"));
local SpawnItemsAPI = require(ModuleAPIs:FindFirstChild("SpawnItemsAPI"));
local TableAPI = require(ModuleAPIs:FindFirstChild("TableAPI"));
local MathAPI = require(ModuleAPIs:FindFirstChild("MathAPI"));

local CookingService = require(ModuleServices:FindFirstChild("CookingService"));
local ProximityService = require(ModuleServices:FindFirstChild("ProximityService"));
local StatTrackService = require(ModuleServices:FindFirstChild("StatTrackService"));
local RewardService = require(ModuleServices:FindFirstChild("RewardService"));
local DataService = require(ModuleServices:FindFirstChild("DataService"));]]

local panZone = ZoneAPI.new(CollectionService:GetTagged("Pan"));
local deliverZone = ZoneAPI.new(CollectionService:GetTagged("DeliverStation"));

----- Variables -----

local EXPMultiplier = 10;
local MaxFoodSpawnRange = 25;

----- Tables -----

local FoodData = {};
local possibleRecipes = {};
local PlayersInServers = {};
local CurrentIngredientObjects = {};
local foodCookWarnings = {};

local blenderArray = {};
local playerDebounces = {};

local cookingTimers = {};

local playerIngredients = {};
local prevIngredients = {};

local cookingPansQueue = {};
local additionalPansInfo = {};

local blendingFoodQueue = {};
local deliverQueues = {};

local tempData = {};
local tCurrentIngredients = {};
local tCurrentIngredientObjects = {};
local partsArray = {};

local function PlayerAdded(player)
    CurrentIngredientObjects[player.Name] = {};
	additionalPansInfo[player.UserId] = {};
    possibleRecipes[player.Name] = {};
	playerDebounces[player] = false;

	player.CharacterAdded:Connect(function(Character)
		Character.Humanoid.Died:Connect(function()
			Knit.GetService("CookingService"):DropDown(player,Character)
		end)
   	end)
end;

local function deletePlayerObject(player, object)
	if not player or not object then return end;
	local owner = object:IsA("Model") and object.PrimaryPart and object.PrimaryPart:GetAttribute("Owner") or object:GetAttribute("Owner")

	if owner and owner == player.Name then
		object:Destroy()
	end
end

local function PlayerRemoving(player)
    CurrentIngredientObjects[player.Name] = nil;
	additionalPansInfo[player.UserId] = nil;
    possibleRecipes[player.Name] = nil;
	playerDebounces[player] = nil;
	cookingTimers[player] = nil;

	for _,v in pairs(FoodAvailable:GetChildren()) do
		deletePlayerObject(player, v)
	end;

	for _,v in pairs(IngredientAvailable:GetChildren()) do
		deletePlayerObject(player, v)
	end;
end;


local coldRangeVisuals = {min = 0, max = 34};
local cookedRangeVisuals = {min = 35, max = 66};
local burntRangeVisuals = {min = 67, max = 96};

local easyCookTalkPhrases = Phrases.easyCookTalkPhrases

local annoyedCookTalkPhrases = Phrases.annoyedCookTalkPhrases

local defeatedCookTalkPhases = Phrases.defeatedCookTalkPhases

local function debounceCooking(player, time)
	if not player or not time then return end;
	if (not cookingTimers[player]) then
		cookingTimers[player] = Instance.new("IntValue")
		cookingTimers[player].Value = time
		task.spawn(function()
			while (cookingTimers[player].Value > 0) do
				cookingTimers[player].Value -= 1
				task.wait(1)
			end
			cookingTimers[player] = nil
		end)
	else
		-- To RESET the timer.
		cookingTimers[player].Value = time

		-- To ADD to the timer.
		--stunned.Value = stunned.Value + Time
	end
end

local function warnAboutOvercookingFood(player, obj)
	if not foodCookWarnings[obj] then foodCookWarnings[obj] = 0 end
	
	foodCookWarnings[obj] += 1;

	local NotificationService = Knit.GetService("NotificationService")
	local talkPhrase;

	if foodCookWarnings[obj] < math.random(3,5) then
		talkPhrase = easyCookTalkPhrases[math.random(1, #easyCookTalkPhrases)]
		NotificationService:Message(false, player, talkPhrase, {Effect = true, Color = Color3.fromRGB(255,255,255)})
		return false;
	elseif foodCookWarnings[obj] < math.random(6,10)  then
		talkPhrase = annoyedCookTalkPhrases[math.random(1, #annoyedCookTalkPhrases)]
		NotificationService:Message(false, player, talkPhrase, {Effect = true, Color = Color3.fromRGB(255, 23, 23)})
		return false;
	else
		talkPhrase = defeatedCookTalkPhases[math.random(1, #defeatedCookTalkPhases)]
		NotificationService:Message(false, player, talkPhrase, {Effect = true, Color = Color3.fromRGB(255,255,255)})
		return true
	end
end

local function percentageInRange(currentNumber, startRange, endRange)
	if startRange > endRange then startRange, endRange = endRange, startRange; end

	local normalizedNum = (currentNumber - startRange) / (endRange - startRange);

	normalizedNum = math.max(0, normalizedNum);
	normalizedNum = math.min(1, normalizedNum);

	return (math.floor(normalizedNum * 100) / 100); -- rounds to .2 decimal places
end

local function visualizeFood(foodObject, percentage)
    if not foodObject or not percentage then return end

	print("visualizing:", foodObject, percentage)

    local function destroyTexture()
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("SurfaceAppearance") and item.Name == "Texture" then
                item:Destroy()
            end

            if item:IsA("Decal") and item.Name == "Texture" then
                item:Destroy()
            end
        end
    end

    local function setTransparency(transparency)
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("Decal") and item.Name == "Texture" then
                item.Transparency = transparency
            end
        end
    end

    local function setFillTransparency(transparency)
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("Decal") and item.Name == "Burnt" then --if item:IsA("Highlight") and item.Name == "Burnt" then
				item.Transparency = transparency --item.FillTransparency = transparency
            end
        end
    end

    if foodObject:GetAttribute("RawColor") ~= nil then
        foodObject.Color = foodObject:GetAttribute("RawColor")
    end

    if percentage <= coldRangeVisuals.min or (percentage > coldRangeVisuals.min and percentage <= coldRangeVisuals.max) then
        destroyTexture()
    elseif percentage > coldRangeVisuals.max and percentage <= cookedRangeVisuals.max then
        --destroyTexture()
        setTransparency(0)
    elseif percentage > cookedRangeVisuals.max and percentage <= burntRangeVisuals.max then
        setTransparency(0)
        setFillTransparency((1 - percentageInRange(percentage, cookedRangeVisuals.min, burntRangeVisuals.max)))
    else
        setTransparency(0)
        setFillTransparency(0)
    end
end

local function checkItemIsOwner(Player, Item)
	local PartyService = Knit.GetService("PartyService");
	local PartyMembers = {};
	local PartyOwner = Player;

	local PartyInfo = PartyService:FindPartyFromPlayer(Player);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
	for _, memberInParty in pairs(PartyInfo.Members) do
		local memberIdToPlayer = memberInParty.Player;
		table.insert(PartyMembers, memberIdToPlayer)
	end

	if Item:GetAttribute("Owner") == "Default" then
		return true, PartyMembers;
	end

	if Item:GetAttribute("Owner") == PartyOwner.Name then
		return true, PartyMembers;
	end

	return false, nil;
end

local function searchForItemInWorkspace(item)
	local workspaceDescendants = workspace:GetDescendants()
	for _, obj in ipairs(workspaceDescendants) do
		if obj == item then
			return true
		end
	end
	return nil;
end

-- Proximity Functions

function CookingService:GetAdditionalPansInfo(Player)
	if additionalPansInfo[Player.UserId] then
		return additionalPansInfo[Player.UserId];
	end
	return {};
end;

function CookingService:PickUp(Player, Character, Item)
	if not Player or not Character or not Item then return end
	if not searchForItemInWorkspace(Item) then return end
	if CollectionService:HasTag(Item, "OnCookingDelete") then return end
	if CollectionService:HasTag(Item, "InPickup") then return end
	local isOwner, partyMembers = checkItemIsOwner(Player, Item)
	if isOwner == false then return end

	local playerData = PlayersInServers[Player.UserId];
	if not playerData then 
		PlayersInServers[Player.UserId] = {nil, nil}; 
		playerData = PlayersInServers[Player.UserId];
	end

	if not playerData[1] and not Character:FindFirstChild("Ingredient").Value then
		--print('c',cookingTimers[Player])
		debounceCooking(Player, 1);
		--print('d',cookingTimers[Player])
		local ProximityService = Knit.GetService("ProximityService");
		CollectionService:AddTag(Item, "InPickup")

		local PartyService = Knit.GetService("PartyService");
		local PartyMembers = {};

		print("FindPartyFromPlayer", PartyService:FindPartyFromPlayer(Player))
		local PartyInfo = PartyService:FindPartyFromPlayer(Player);
		for _, memberInParty in pairs(PartyInfo.Members) do
			local memberIdToPlayer = memberInParty.Player;
			table.insert(PartyMembers, memberIdToPlayer)
		end

		local itemObject = (Item:IsA("Model") and Item.PrimaryPart ~= nil and Item.PrimaryPart) or Item;
		
		if not itemObject or not Character:FindFirstChild("HumanoidRootPart") then return end;
		local Magnitude = (itemObject.Position - Character:FindFirstChild("HumanoidRootPart").Position).magnitude;

		--print("MAGNITUDE:", Magnitude)
		
		if not Magnitude or Magnitude > 13 then return end

		local itemType = itemObject:GetAttribute("Type");

		PlayersInServers[Player.UserId] = {true, Item};

		local blendedItems = {};

		if itemType == "Ingredient" then

			local ClonedItem = IngredientObjects:FindFirstChild(Item.Name):Clone();
			
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
			
			ProximityService:PickUpIngredient(Character, ClonedItem);
			print("pickup members,",PartyMembers)
			for i, member in pairs(PartyMembers) do
				self.Client.PickUp:Fire(member, Item)
			end
			self.Client.ProximitySignal:Fire(Player,"DropDown",true);
			PlayersInServers[Player.UserId] = {nil, Item};
		elseif itemType == "Food" then
			local cookingPercentage = (Item:IsA("Model") and Item.PrimaryPart ~= nil and Item.PrimaryPart:GetAttribute("CookingPercentage")) or Item:GetAttribute("CookingPercentage")
				
			local ClonedItem = FoodObjects:FindFirstChild(Item.Name):Clone();

			local mainCloneItem = (ClonedItem:IsA("Model") and ClonedItem.PrimaryPart ~= nil and ClonedItem.PrimaryPart) or ClonedItem
			
			mainCloneItem:SetAttribute("CookingPercentage", cookingPercentage)
			
			visualizeFood(ClonedItem, cookingPercentage);
			
			ProximityService:PickUpFood(Character, ClonedItem);
			print("pickup members,",PartyMembers)
			for i, member in pairs(PartyMembers) do
				self.Client.PickUp:Fire(member, Item)
			end
			self.Client.ProximitySignal:Fire(Player,"DropDown",true);
			PlayersInServers[Player.UserId] = {nil, Item};
		end
	end
end;

function CookingService:DropDown(Player,Character)
	if not Player or not Character then return end
	local playerData = PlayersInServers[Player.UserId];
	if not playerData then 
		PlayersInServers[Player.UserId] = {nil, nil}; 
		playerData = PlayersInServers[Player.UserId];
	end

	if not playerData[1] and Character:FindFirstChild("Ingredient").Value then
		debounceCooking(Player, 1);
		PlayersInServers[Player.UserId][1] = true;
		local ProximityService = Knit.GetService("ProximityService");

		local PartyService = Knit.GetService("PartyService");
		local PartyMembers = {};
		local PartyOwner = Player;

		local PartyInfo = PartyService:FindPartyFromPlayer(Player);
		PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)

		for _,item in pairs(game.Workspace:FindFirstChild("FoodAvailable"):GetChildren()) do
			if item:IsA("Model") then
				--print("CHECKl", item.PrimaryPart:GetAttribute("Owner") , Player.Name, item , PlayersInServers[Player.UserId][2], item.PrimaryPart == PlayersInServers[Player.UserId][2])
				if not item then continue end
				if item and not item.PrimaryPart then item:Destroy() continue end
				if item.PrimaryPart:GetAttribute("Owner") == PartyOwner.Name and item.PrimaryPart == PlayersInServers[Player.UserId][2] then item:Destroy() end;
			elseif item:IsA("MeshPart") then
				if not item then continue end
				if item:GetAttribute("Owner") == PartyOwner.Name and item == PlayersInServers[Player.UserId][2] then item:Destroy() end;
			end;
		end;
		for _,item in pairs(game.Workspace:FindFirstChild("IngredientAvailable"):GetChildren()) do
			if item:IsA("Model") then
				if not item then continue end
				if item and not item.PrimaryPart then item:Destroy() continue end
				if item.PrimaryPart:GetAttribute("Owner") == PartyOwner.Name and item.PrimaryPart == PlayersInServers[Player.UserId][2] then item:Destroy() end;
			elseif item:IsA("MeshPart") then
				--print("CHECK2", item:GetAttribute("Owner") , Player.Name, item , PlayersInServers[Player.UserId][2], item == PlayersInServers[Player.UserId][2])
				if not item then continue end
				if item:GetAttribute("Owner") == PartyOwner.Name and item == PlayersInServers[Player.UserId][2] then item:Destroy() end;
			end;
		end;

		ProximityService:DropItem(Character, PlayersInServers[Player.UserId][2]);
		self.Client.ProximitySignal:Fire(Player,"DropDown",false);

		PlayersInServers[Player.UserId] = nil;
	end
end;

----- Cooking Functions -----

function CookingService:GetNumberOfFoodCooking(player)
	if not cookingPansQueue[player.UserId] then
		return 0;
	end
	return #cookingPansQueue[player.UserId]
end

function CookingService:GetPickUpData(player)
	if not PlayersInServers[player.UserId] then
		return {false, nil};
	end
	return PlayersInServers[player.UserId];
end

function CookingService:CanCookOnPan(player, pan)
	--print("CanCookOnPan:", cookingPansQueue[player.UserId])
	if not cookingPansQueue[player.UserId] then 
		cookingPansQueue[player.UserId] = {};
		additionalPansInfo[player.UserId] = {};
		return true;
	end
	local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end

	--print("cookingPansQueue", cookingPansQueue[player.UserId], tablefind(cookingPansQueue[player.UserId], pan) )
	--print("CanCookOnPan 2:", #cookingPansQueue[player.UserId])
	if #cookingPansQueue[player.UserId] == 0 then return true; end

	local function removeFood()
		if tablefind(cookingPansQueue[player.UserId], pan) then 
			local PartyService = Knit.GetService("PartyService");
			local PartyMembers = {};
			local PartyOwner = player;

			local PartyInfo = PartyService:FindPartyFromPlayer(player);
			PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
			for _, memberInParty in pairs(PartyInfo.Members) do
				local memberIdToPlayer = memberInParty.Player;
				table.insert(PartyMembers, memberIdToPlayer)
			end
			-- something is on the pan i will clear it for u
			print("Removing food from pan")
	
			table.remove( cookingPansQueue[PartyOwner.UserId], tablefind(cookingPansQueue[PartyOwner.UserId], pan) );

			for _, member in pairs(PartyMembers) do
				self.Client.UpdatePans:Fire(member, cookingPansQueue[PartyOwner.UserId])
			end

			--print("cookingPansQueue", cookingPansQueue[player.UserId])
			local SelectedRecipe = RecipeModule[tostring(additionalPansInfo[PartyOwner.UserId][pan].Recipe)];
			local RawCalculatedEXP = (EXPMultiplier * #SelectedRecipe["Ingredients"]);
			self.Client.ProximitySignal:Fire(player,"CookVisible",false);
			--RewardService:GiveReward(profile, {EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2);})
	
			local DistanceBetweenPlayerAndPan = player:DistanceFromCharacter(pan.Position);
			local food;
	
			--print("OUTPUT:", additionalPansInfo[player.UserId][pan])
	
			if DistanceBetweenPlayerAndPan > MaxFoodSpawnRange or DistanceBetweenPlayerAndPan == 0 then
				food = SpawnItemsAPI:Spawn(
					player.UserId, 
					player, 
					additionalPansInfo[PartyOwner.UserId][pan].Recipe, 
					FoodObjects, 
					FoodAvailable, 
					pan.Position + Vector3.new(0,5,0),
					additionalPansInfo[PartyOwner.UserId][pan].Percentage
				);
			else
				food = SpawnItemsAPI:Spawn(
					player.UserId, 
					player, 
					additionalPansInfo[PartyOwner.UserId][pan].Recipe, 
					FoodObjects, 
					FoodAvailable,
					player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.lookVector * 4,
					additionalPansInfo[PartyOwner.UserId][pan].Percentage
				);
			end
	
			--print("GENERATED FOOD:", food)

			for _, member in pairs(PartyMembers) do
				Knit.GetService("NotificationService"):Message(false, member, string.upper(tostring(food)).." WAS MADE!")
	
				self.Client.ParticlesSpawn:Fire(member, food, "CookedParticle")
				self.Client.Cook:Fire(member, "Destroy", tostring(additionalPansInfo[PartyOwner.UserId][pan].Recipe), pan)
			end

			additionalPansInfo[PartyOwner.UserId][pan] = nil;
			return true;
		end
		return false;
	end

	local hasRemovedItem = removeFood()
	--print("CanCookOnPan 3:",hasRemovedItem)

	if hasRemovedItem == true then return false; end;

	if #cookingPansQueue[player.UserId] >= 1 then
		print("needs gamepass to cook multiple foods")
		-- check if has gamepass
		local ProgressionService = Knit.GetService("ProgressionService");
		local playerCurrency, playerStorage, progressionStorage = ProgressionService:GetProgressionData(player, ThemeData)

		local Multitasking = progressionStorage["Multitasking"].Data[playerStorage["Multitasking"]].Value;
		if Multitasking == false then
			Knit.GetService("NotificationService"):Message(false, player, "Buy the multitasking skill in player upgrades to be able to cook multiple foods!")
		end
		return Multitasking;
	end
	return false;
end

function CookingService:CanBlendOnBlender(player, blender)
	local PartyService = Knit.GetService("PartyService");
	local PartyOwner = player;

	local PartyInfo = PartyService:FindPartyFromPlayer(player);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)

	if not blendingFoodQueue[PartyOwner.UserId] then 
		blendingFoodQueue[PartyOwner.UserId] = {};
		return true; 
	end
	if #blendingFoodQueue[PartyOwner.UserId] == 0 then return true; end

	if table.find(blendingFoodQueue[PartyOwner.UserId], blender) then return false; end

	if #blendingFoodQueue[PartyOwner.UserId] > 1 then
		print("needs gamepass to cook blend foods")
		-- check if has gamepass
		return true;
	end
	return false;
end

function CookingService:Recipe(player, recipe)
	print('[CookingService]: Finding recipe: '.. tostring(recipe));
	--[[if player and recipe then
		local FoodHolder = CookingService:FindFoodHolder(player);
		if RecipeModule[tostring(recipe)] then
			if FoodHolder then
				if not FoodHolder.ScrollingFrame:FindFirstChild(tostring(recipe)) then
					--if FoodHolder.Visible == false then FoodHolder.Visible = true end;
					--CookingService:AddRecipe(player.UserId, player, recipe);
				end;
			end;
		end;
	end;]]
end;

function CookingService:Blend(player, Character, recipe, blender)
	if not player or not Character or not recipe or not blender then return end;
	print('[CookingService]: Blending Food: '.. tostring(recipe));

	local PartyService = Knit.GetService("PartyService");
	local PartyMembers = {};
	local PartyOwner = player;

	local PartyInfo = PartyService:FindPartyFromPlayer(player);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
	for _, memberInParty in pairs(PartyInfo.Members) do
		local memberIdToPlayer = memberInParty.Player;
		table.insert(PartyMembers, memberIdToPlayer)
	end

	if self:CanBlendOnBlender(PartyOwner, blender) == false then return false; end

	local DataService = Knit.GetService("DataService")
	local profile = DataService.GetProfile(PartyOwner);
	if not profile then
		local getRadius = function(part)
			return (part.Size.Z<part.Size.Y and part.Size.Z or part.Size.Y)/2
			--[[In the above we are returning the smallest, first we check if Z is smaller
			than Y, if so then we return Z or else we return Y.]]
		end;

		for _,hitbox in pairs(CollectionService:GetTagged("Pan")) do
			local radiusOfPan = getRadius(hitbox)

			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
			overlapParams.FilterType = Enum.RaycastFilterType.Blacklist;

			local parts = workspace:GetPartBoundsInRadius(hitbox.Position, radiusOfPan, overlapParams)
			for _, part in pairs(parts) do
				table.insert(blenderArray, part)
			end
		end
	else
		warn("Could not find user["..tostring(PartyOwner.UserId).."] profile to cook the food, please retry")
	end;
end;

local function ingredientCheck(player, recipe)
	local IngredientsUsed = {};
	local SelectedRecipe = RecipeModule[tostring(recipe)];
	local previousPercentage = 0;
	--print(SelectedRecipe,SelectedRecipe["Ingredients"])
	for _,ingredientFromRecipe in pairs(SelectedRecipe["Ingredients"]) do
		--print("AB",ingredientFromRecipe,CurrentIngredientObjects[player.Name]);
		if not CurrentIngredientObjects[player.Name] then CurrentIngredientObjects[player.Name] = {} end
		if CurrentIngredientObjects[player.Name] then
			for _, ingredientFromTable in pairs(CurrentIngredientObjects[player.Name]) do
				if typeof(ingredientFromTable) == "table" then
					if tostring(ingredientFromTable.Ingredient) == tostring(ingredientFromRecipe) then
						CollectionService:AddTag(ingredientFromTable.Source, "OnDelete")
						CollectionService:AddTag(ingredientFromTable.Source, "OnCookingDelete")
						table.insert(IngredientsUsed,ingredientFromTable.Source);
						break;
					end;
				else
					if tostring(ingredientFromTable) == tostring(ingredientFromRecipe) then
						CollectionService:AddTag(ingredientFromTable, "OnCookingDelete")
						table.insert(IngredientsUsed,ingredientFromTable);
						break;
					end;
				end
			end;
		end
	end;

	return IngredientsUsed;
end

local function destroyIngredients(IngredientsUsed)
	local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");
	for i, ingredient in pairs(IngredientsUsed) do
		if ingredient then
			if CollectionService:HasTag(ingredient, "OnDelete") then
				ingredient:Destroy();
				table.remove(IngredientsUsed, i);
				continue;
			end
			if ingredient:IsA("Model") and ingredient.PrimaryPart then
				ingredient.PrimaryPart.ProximityPrompt.Enabled = false;
			else
				ingredient.ProximityPrompt.Enabled = false;
			end
		end
	end;
	for _, ingredient in pairs(IngredientsUsed) do
		task.spawn(function()
			if ingredient then
				local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)];
				if RandomFoodLocation then
					if ingredient:IsA("Model") then
						if ingredient.PrimaryPart then
							ingredient:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
						else
							ingredient = nil;
						end
					else
						ingredient.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5));
					end
				end

				task.wait(0.1)

				if ingredient ~= nil then
					CollectionService:RemoveTag(ingredient, "OnCookingDelete")
					if ingredient:IsA("Model") and ingredient.PrimaryPart then
						ingredient.PrimaryPart.ProximityPrompt.Enabled = true;
					else
						ingredient.ProximityPrompt.Enabled = true;
					end
				end;
			end
		end)
	end;
end

local function checkForFood(player)
	local foundFood = false;
	local currentRecipe, currentPercentage;
	local playerData = CurrentIngredientObjects[player.Name];
	if not playerData then 
		CurrentIngredientObjects[player.Name] = {}
		playerData = CurrentIngredientObjects[player.Name];
	end
	
	for _, ingredientFromTable in pairs(playerData) do
		local obj = (ingredientFromTable:IsA("Model") and ingredientFromTable.PrimaryPart ~= nil and ingredientFromTable.PrimaryPart) or ingredientFromTable

		if obj:GetAttribute("Type") == "Food" then
			currentRecipe = ingredientFromTable.Name;
			--print(obj:GetAttribute("CookingPercentage"))
			currentPercentage = obj:GetAttribute("CookingPercentage") or 0;

			if currentPercentage >= 100 then
				if warnAboutOvercookingFood(player, ingredientFromTable) == false then return nil end
			end		
			local objToDelete = (obj:GetAttribute("Type") ~= nil and obj.Parent:IsA("Model") and obj.Parent) or obj
			CollectionService:AddTag(objToDelete, "OnCookingDelete")
			print("checkforfood:", objToDelete:GetFullName(), ingredientFromTable:GetFullName())
			objToDelete:Destroy();
			foundFood = true;
			break;
		end;
	end;
	if foundFood == false then return nil end
	return currentRecipe, currentPercentage;
end

function CookingService:StartCookingProcess(player, pan, recipe, previousPercentage)
	print("player, pan, recipe, previousPercentage:", player, pan, recipe, previousPercentage)
	local PartyService = Knit.GetService("PartyService");
	local PartyMembers = {};
	local PartyOwner = player;

	local PartyInfo = PartyService:FindPartyFromPlayer(player);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
	for _, memberInParty in pairs(PartyInfo.Members) do
		local memberIdToPlayer = memberInParty.Player;
		table.insert(PartyMembers, memberIdToPlayer)
	end

	debounceCooking(PartyOwner, 1);
	if additionalPansInfo[PartyOwner.UserId][pan] == nil then
		additionalPansInfo[PartyOwner.UserId][pan] = {};
	end

	table.insert(cookingPansQueue[PartyOwner.UserId], pan)
	additionalPansInfo[PartyOwner.UserId][pan] = {
		Recipe = recipe,
		Percentage = previousPercentage,
	}

	local ProgressionService = Knit.GetService("ProgressionService");
	local playerCurrency, playerStorage, progressionStorage = ProgressionService:GetProgressionData(player, ThemeData)

	-- cookingTime = (Default_Time / Player_Cook_Speed) * 2
	local cookingTime = (RecipeModule:GetCookTime(tostring(recipe)) / progressionStorage["Cook Speed"].Data[playerStorage["Cook Speed"]].Value) * 2;

	--print("cookingPansQueue", cookingPansQueue[player.UserId])

	print(PartyMembers)

	for _, member in pairs(PartyMembers) do
		Knit.GetService("NotificationService"):Message(false, member, "COOKING STARTED!")

		self.Client.Cook:Fire(member, "Initialize", tostring(recipe), pan)
		self.Client.UpdatePans:Fire(member, cookingPansQueue[PartyOwner.UserId])
	end
	

	local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end

	-- Function to get a number within the range 0 to 100 from a range from 0 to [num]
	local function getNumberInRange(num, maxRange)
		-- Calculate the number in the range 0 to 100
		local numberInRange = (num / maxRange) * 100

		-- Return the calculated number
		return numberInRange
	end

	-- Function to get a number within the range 0 to [num] from a range from 0 to 100
	local function getNumberInRange2(num, maxRange)
		-- Calculate the number in the range 0 to 100
		local numberInRange = (num / 100) * maxRange

		-- Return the calculated number
		return numberInRange
	end

	local count = getNumberInRange2(previousPercentage,  cookingTime);
	local isOverLimit = false;

	local waitTime = 2;
	local numOfDrops = (cookingTime / 2) / waitTime;

	local CurrencySessionService = Knit.GetService("CurrencySessionService");

	task.spawn(function()
		repeat
			if count >= cookingTime then
				count = cookingTime
				isOverLimit = true;
			else
				count += 1;
			end

			print("count", count)
			if count == math.ceil((cookingTime / 2)) then
				local CookPerfection = progressionStorage["Cooking Perfection"].Data[playerStorage["Cooking Perfection"]].Value
				if CookPerfection == true then
					for _, member in pairs(PartyMembers) do
						Knit.GetService("NotificationService"):Message(false, member, "Perfect Cooking!", {Effect = false, Color = Color3.fromRGB(255, 200, 21)})
					end
					if additionalPansInfo[PartyOwner.UserId][pan] then
						additionalPansInfo[PartyOwner.UserId][pan] = {
							Recipe = recipe,
							Percentage = getNumberInRange(count + 1,  cookingTime),
						}
					end
					self:CanCookOnPan(PartyOwner, pan)
				end
			end

			if (count % waitTime == 0) and (count <= (cookingTime / 2)) then

				local cheeseDrop = RecipeModule:GetRecipeRewards(RecipeModule[tostring(recipe)].Difficulty);
				local rCheeseDropReward = math.random(
					(cheeseDrop[1] - (cheeseDrop[1] * .15)),
					(cheeseDrop[2] - (cheeseDrop[2] * .15)))

				local cheeseValuePerDrop = rCheeseDropReward / numOfDrops;
				local cheeseObjectPerDrop = 10;

				CurrencySessionService:DropCheese(
					pan.CFrame, 
					PartyOwner, 
					cheeseObjectPerDrop, 
					math.floor((cheeseValuePerDrop / cheeseObjectPerDrop))
				)
			end

			if additionalPansInfo[PartyOwner.UserId][pan] then
				additionalPansInfo[PartyOwner.UserId][pan] = {
					Recipe = recipe,
					Percentage = getNumberInRange(count,  cookingTime),
				}
				--print("ehm: ", additionalPansInfo[player.UserId][pan])
				local previousNumberInRange = getNumberInRange(count - 1, cookingTime)
				local currentNumberInRange = getNumberInRange(count,  cookingTime)

				--print("nums", count, count-1, previousNumberInRange, currentNumberInRange)

				for _, member in pairs(PartyMembers) do
					self.Client.Cook:Fire(member, "CookUpdate", tostring(recipe), pan, {previous = previousNumberInRange, current = currentNumberInRange, overCookingLimit = isOverLimit})
				end
				task.wait(1)
			end
		until not PartyOwner 
			or additionalPansInfo[PartyOwner.UserId][pan] == nil 
			or cookingPansQueue[PartyOwner.UserId] == nil 
			or tablefind(cookingPansQueue[PartyOwner.UserId], pan) == nil
	end)
end
local count = 0;
function CookingService:Cook(player, Character, recipe, pan)
	count += 1;

	print("\n\n\n\n\n\n\n\n\n\n\n\n\n")
	print('[CookingService]: Cooking Food: '.. tostring(recipe), player,"COUNT:",count);
	print('[CookingService]: Additional info:', player, Character, recipe, pan);

	local PartyService = Knit.GetService("PartyService");
	local PartyMembers = {};
	local PartyOwner = player;

	local PartyInfo = PartyService:FindPartyFromPlayer(player);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
	for _, memberInParty in pairs(PartyInfo.Members) do
		local memberIdToPlayer = memberInParty.Player;
		table.insert(PartyMembers, memberIdToPlayer)
	end

	if not PartyOwner or not pan then return false; end
	if cookingTimers[PartyOwner] then
		warn('CANT COOK BECAUSE COOLDOWN:', cookingTimers[PartyOwner].Value)
		return 
	end;
	local CanCook = self:CanCookOnPan(PartyOwner, pan)
	print('Check if can cook:', CanCook)
	if CanCook == false then return false; end

	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(PartyOwner);

	if profile then
		if recipe and RecipeModule[tostring(recipe)] then -- if not food and all ingredients
			print("Cooking new food")
			local SelectedRecipe = RecipeModule[tostring(recipe)];
			local previousPercentage = 0;
			local IngredientsUsed = ingredientCheck(PartyOwner, recipe);

			if #SelectedRecipe["Ingredients"] == #IngredientsUsed then
				print('[CookingService]: Found all ingredients',IngredientsUsed);
				destroyIngredients(IngredientsUsed);
				IngredientsUsed = {};
			else
				recipe, previousPercentage = checkForFood(PartyOwner);

				if not recipe then 
					warn("couldnt find food")
					return 
				end
				IngredientsUsed = {};
			end;

			--print("COOKING TIME")

			self:StartCookingProcess(PartyOwner, pan, recipe, previousPercentage)
		else -- if food
			print("Cooking existing food")
			if not CurrentIngredientObjects[PartyOwner.Name] then CurrentIngredientObjects[PartyOwner.Name] = {} end
			local previousPercentage = 0;

			recipe, previousPercentage = checkForFood(PartyOwner);
			if not recipe then 
				warn("couldnt find food")
				return 
			end

			self:StartCookingProcess(PartyOwner, pan, recipe, previousPercentage)
		end;
	else
		warn("Could not find user["..tostring(PartyOwner.UserId).."] profile to cook the food, please retry")
	end;
end;

function CookingService:DeliverFood(player, food)
    print('[CookingService]: Submitting Food: '.. tostring(food));

	local DataService = Knit.GetService("DataService")
	local PartyService = Knit.GetService("PartyService");
	local profile = DataService:GetProfile(player);

	local PartyMembers = {};
	local PartyOwner = player;

	local PartyInfo = PartyService:FindPartyFromPlayer(player);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
	for _, memberInParty in pairs(PartyInfo.Members) do
		local memberIdToPlayer = memberInParty.Player;
		table.insert(PartyMembers, memberIdToPlayer)
	end

	if profile then

		if RecipeModule[tostring(food)] then
			--print(SelectedRecipe,SelectedRecipe["Ingredients"])
			debounceCooking(PartyOwner, 1);
			for k, v in ipairs(food:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Weld") then
					continue;
				else
					v:Destroy();
				end
			end

			CollectionService:AddTag(food, "Delivering")

			if food:IsA("Model") then
				if food.PrimaryPart then
					for _, v in ipairs(food:GetChildren()) do
						v.Transparency = 1;
						v.CanCollide = false;
						v.Anchored = true;
					end
				end
			else
				food.Transparency = 1;
				food.CanCollide = false;
				food.Anchored = true;
			end

			print("DELIVER TIME")

			if not deliverQueues[PartyOwner.UserId] then 
				deliverQueues[PartyOwner.UserId] = {};
			end

			table.insert(deliverQueues[PartyOwner.UserId], food)

			local deliverTime = RecipeModule:GetCookTime(tostring(food));

			local cookingPercentage = (food:IsA("Model") and food.PrimaryPart ~= nil and food.PrimaryPart:GetAttribute("CookingPercentage")) or food:GetAttribute("CookingPercentage")

			--print("cookingPansQueue", cookingPansQueue[player.UserId])

			for _, member in pairs(PartyMembers) do
				self.Client.Deliver:Fire(member, tostring(food), food, deliverTime)
			end
			
			local cheeserew;

			task.spawn(function()
				local waitTime = 2;
				local numOfDrops = deliverTime / waitTime;
				local cheeseDrop = RecipeModule:GetRecipeRewards(RecipeModule[tostring(food)].Difficulty);
				local rCheeseDropReward = math.random(
					(cheeseDrop[1] - (cheeseDrop[1] * .15)),
					(cheeseDrop[2] - (cheeseDrop[2] * .15)))

				cheeserew = rCheeseDropReward;

				local cheeseValuePerDrop = rCheeseDropReward / numOfDrops;
				local cheeseObjectPerDrop = 10;
				-- oCFrame, obj, amount, value

				--print("cooking drop", numOfDrops, cheeseDrop, rCheeseDropReward, cheeseValuePerDrop)

				local foodObj;

				if food:IsA("Model") then
					foodObj = food.PrimaryPart;
				else
					foodObj = food;
				end

				local CurrencySessionService = Knit.GetService("CurrencySessionService");
				
				for i = 1, numOfDrops do
					CurrencySessionService:DropCheese(
						foodObj.CFrame, 
						PartyOwner, 
						cheeseObjectPerDrop, 
						math.floor((cheeseValuePerDrop / cheeseObjectPerDrop))
					)
					task.wait(waitTime);
				end

				food:Destroy();
			end)

			Knit.GetService("OrderService"):completeRecipe(PartyOwner, tostring(food), cheeserew, cookingPercentage)
			--RewardService:GiveReward(profile, {EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2);})

			print("food delivered:", food)
			
			for _, member in pairs(PartyMembers) do
				Knit.GetService("NotificationService"):Message(false, member, string.upper(tostring(food)).." WAS DELIVERED!")
			end

			task.wait(deliverTime);

			local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end
			table.remove( deliverQueues[PartyOwner.UserId], tablefind(deliverQueues[PartyOwner.UserId], food) );

			--print("cookingPansQueue", cookingPansQueue[player.UserId])

			--local RawCalculatedEXP = (EXPMultiplier * #SelectedRecipe["Ingredients"]);
			for _, member in pairs(PartyMembers) do
				self.Client.ProximitySignal:Fire(member,"CookVisible",false);
			end
			
			--StatTrackService:SetRecentCookedFood(player, tostring(recipe));
		end;
	else
		warn("Could not find user["..tostring(player.UserId).."] profile to deliver the food, please retry")
	end;
end

function CookingService:KnitStart()
	--local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");
	--local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)]

	--SpawnItemsAPI:Spawn(nil, nil, "Raw Steak", IngredientObjects, IngredientsAvailable, RandomFoodLocation.Position + Vector3.new(0,5,0));
    --SpawnItemsAPI:SpawnAllIngredients(5);
	--SpawnItemsAPI:SpawnAll(IngredientObjects,IngredientsAvailable);
    --SpawnItemsAPI:SpawnAtRandomSpawns(IngredientObjects,IngredientsAvailable, workspace.FoodSpawnPoints);
    --SpawnItemsAPI:SpawnAll(FoodObjects,IngredientsAvailable);
end


function CookingService:KnitInit()
    print('[CookingService]: Activated! [V2]')

	-- Tables
	local playerCheckDebounce = {}
	local oldFoodData = {};

	-- Private functions
	local getRadius = function(part)
		return (part.Size.Z<part.Size.Y and part.Size.Z or part.Size.Y)/2
		--[[In the above we are returning the smallest, first we check if Z is smaller
		than Y, if so then we return Z or else we return Y.]]
	end;

	local function deliverFood(OwnerPlayer, touchedObject)
		if CollectionService:HasTag(touchedObject, "Delivering") == false then
			print(touchedObject, "in deliverzone")
			self:DeliverFood(OwnerPlayer, touchedObject)
		end
	end

	local ori = false

	local function checkIngredients(player) -- checks if the ingredients changed from last frame, if so send to client
		--print("check ingred")
		if playerCheckDebounce[player.UserId] == nil then playerCheckDebounce[player.UserId] = false; end
		if playerCheckDebounce[player.UserId] == true then return; end
		playerCheckDebounce[player.UserId] = true;

		if prevIngredients[player.UserId] == nil then prevIngredients[player.UserId] = {} end;
		playerIngredients[player.UserId] = {}

		if CurrentIngredientObjects[player.Name] then
			for _, ingredient in pairs(CurrentIngredientObjects[player.Name]) do
				if typeof(ingredient) == "table" then
					table.insert(playerIngredients[player.UserId], tostring(ingredient.Ingredient))
				else
					table.insert(playerIngredients[player.UserId], tostring(ingredient))
				end
			end
		end

		if TableAPI.CheckArrayEquality(prevIngredients[player.UserId],playerIngredients[player.UserId]) == false then
			--print("SENT DATA")
			--print("data comparison", prevIngredients[player.UserId], playerIngredients[player.UserId], TableAPI.CheckArrayEquality(prevIngredients[player.UserId],playerIngredients[player.UserId]))
			
			local PartyMembers = {};
			local PartyOwner = player;
			local PartyService = Knit.GetService("PartyService");
			local PartyInfo = PartyService:FindPartyFromPlayer(player);
			PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
			for _, memberInParty in pairs(PartyInfo.Members) do
				local memberIdToPlayer = memberInParty.Player;
				table.insert(PartyMembers, memberIdToPlayer)
			end
			for _, member in pairs(PartyMembers) do
				self.Client.SendIngredients:Fire(member, playerIngredients[PartyOwner.UserId])
			end
		end

		prevIngredients[player.UserId] = playerIngredients[player.UserId];
		playerCheckDebounce[player.UserId] = false;
	end

	local function checkDeliverStations(deliverHitbox) -- checks if any food needs to be delivered
		local radiusOfDeliverZone = getRadius(deliverHitbox)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
		overlapParams.FilterType = Enum.RaycastFilterType.Blacklist;

		local objectsInDeliverZone = workspace:GetPartBoundsInRadius(deliverHitbox.Position, radiusOfDeliverZone, overlapParams)
		for _, object in pairs(objectsInDeliverZone) do
			local touchedType, touchedOwner, touchedObject;

			local tObject = nil;
			if object then
				if object.Parent then
					if object.Parent:IsA("Model") then
						if object.Parent.PrimaryPart then
							tObject = object.Parent.PrimaryPart;
							touchedObject = tObject.Parent;
						end
					else
						tObject = object;
						touchedObject = object;
					end
				end
			end

			if tObject == nil then continue end;

			touchedType = tObject:GetAttribute("Type");
			touchedOwner = tObject:GetAttribute("Owner");

			if touchedType == "Food" and touchedOwner ~= "None" then
				local OwnerPlayer = Players:FindFirstChild(touchedOwner)
				if OwnerPlayer then
					deliverFood(OwnerPlayer, touchedObject)
				end
			end
		end
	end

	local function checkPans(panHitbox) -- checks if any object is on the pans
		local panArray = {};
		local radiusOfPanZone = getRadius(panHitbox)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
		overlapParams.FilterType = Enum.RaycastFilterType.Blacklist;

		local objectsInPanZone = workspace:GetPartBoundsInRadius(panHitbox.Position, radiusOfPanZone, overlapParams)
		for _, object in pairs(objectsInPanZone) do
			local touchedType, touchedOwner, touchedObject;

			local tObject = nil;
			if object then
				if object.Parent then
					if object.Parent:IsA("Model") then
						if object.Parent.PrimaryPart then
							tObject = object.Parent.PrimaryPart;
							touchedObject = tObject.Parent;
						end
					else
						tObject = object;
						touchedObject = object;
					end
				end
			end
			
			if tObject == nil then continue end;

			touchedType = tObject:GetAttribute("Type");
			touchedOwner = tObject:GetAttribute("Owner");

			if touchedObject and touchedType and touchedOwner then
				table.insert(panArray, object)
			end
		end

		return panArray;
	end

	task.spawn(function()
		while task.wait(0) do
			for _, player in pairs(Players:GetPlayers()) do
				checkIngredients(player)
			end
		end
	end)
	
	task.spawn(function()
		while task.wait(0.1) do
			tempData = {};
			tCurrentIngredients = {};
			tCurrentIngredientObjects = {};
			partsArray = {};

			local function checkForBlendedItems(object, PlayerName)
				if CollectionService:HasTag(object, "IngredientsTable") then
					for i = 1, 5 do
						local blendedIngredient
						if object.Parent:IsA("Model") then
							blendedIngredient = object.Parent.PrimaryPart:GetAttribute("i"..tostring(i));
							table.insert(tempData,{PlayerName,{Ingredient = blendedIngredient.."-[Blended]", Source = object.Parent}})
							table.insert(tCurrentIngredientObjects[PlayerName], {Ingredient = blendedIngredient.."-[Blended]", Source = object.Parent})
						else
							blendedIngredient = object:GetAttribute("i"..tostring(i));
							table.insert(tempData,{PlayerName,{Ingredient = blendedIngredient.."-[Blended]", Source = object}})
							table.insert(tCurrentIngredientObjects[PlayerName], {Ingredient = blendedIngredient.."-[Blended]", Source = object})
						end
						if blendedIngredient ~= "" and blendedIngredient ~= nil then
							table.insert(tCurrentIngredients[PlayerName],blendedIngredient.."-[Blended]")
						end
					end
				end
			end

			local function checkForRecipes(PlayerName)
				for key,currentRecipe in pairs(RecipeModule) do
					if type(currentRecipe) == "table" then
						local valid = TableAPI.Equals(tCurrentIngredients[PlayerName],currentRecipe["Ingredients"]);

						if valid == true then
							if possibleRecipes[PlayerName] then
								if table.find(possibleRecipes[PlayerName],key) == nil then
									table.insert(possibleRecipes[PlayerName],key);
									self:Recipe(game.Players:FindFirstChild(PlayerName), key);
								else
									--print(possibleRecipes[touchedOwner]);
								end;
							end;
						end;
					end;
				end;
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
					local tTouchedPart;

					if touchedPart.Parent:IsA("Model") and touchedPart.Parent.PrimaryPart then
						tTouchedPart = touchedPart.Parent.PrimaryPart;
					else
						tTouchedPart = touchedPart
					end

					local touchedType = tTouchedPart:GetAttribute("Type");
					local touchedOwner = tTouchedPart:GetAttribute("Owner");

					if touchedType and touchedOwner ~= "Default" and touchedOwner ~= "None" and panZone:findPart(touchedPart) == true then
						table.insert(tempData,{touchedOwner,touchedPart});

						if tCurrentIngredients[touchedOwner] == nil then
							tCurrentIngredients[touchedOwner] = {};
							tCurrentIngredientObjects[touchedOwner] = {};
						end;

						if table.find(tCurrentIngredientObjects[touchedOwner],touchedPart) == nil then
							table.insert(tCurrentIngredientObjects[touchedOwner],touchedPart);
							table.insert(tCurrentIngredients[touchedOwner],touchedPart.Name);

							checkForBlendedItems(touchedPart, touchedOwner)
							--checkForRecipes(touchedOwner)
						end;
					end;
				end

				FoodData = tempData; --Table.Sync(FoodData,tempData)
				CurrentIngredientObjects = tCurrentIngredientObjects; --Table.Sync(CurrentIngredientObjects,tCurrentIngredientObjects)

				if TableAPI.CheckTableEquality(oldFoodData, FoodData) ~= true then
					--print("FOOD DATA:", FoodData)
					--print("Ingredient DATA:", CurrentIngredientObjects)
					oldFoodData = FoodData;
				else
					if #FoodData ~= 0 then
						print("INEQUALITY", FoodData)
					end
				end;
			else
				FoodData = {};
				for _, player in Players:GetPlayers() do
					CurrentIngredientObjects[player.Name] = {};
				end
			end;
		end;
	end);

    ----- Connections -----
	self.Client.PickUp:Connect(function(player, food)
		return self:PickUp(player, player.Character, food);
    end)

	self.Client.DropDown:Connect(function(player)
		return self:DropDown(player, player.Character);
    end)

	self.Client.Recipe:Connect(function(player, recipe)
		return self:Recipe(player, recipe);
    end)

	self.Client.Cook:Connect(function(player, recipe, pan)
		local cookReturn = nil;
		if not playerDebounces[player] then playerDebounces[player] = false; end
		if playerDebounces[player] == false then
			playerDebounces[player] = true;
			cookReturn = self:Cook(player, player.Character, recipe, pan);
			task.wait(1)
			playerDebounces[player] = false;
		end
		--print(player, recipe, pan)
		return cookReturn;
    end)

    Players.PlayerAdded:Connect(PlayerAdded);
    Players.PlayerRemoving:Connect(PlayerRemoving);
end


return CookingService
