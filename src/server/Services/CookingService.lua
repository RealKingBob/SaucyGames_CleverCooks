--[[
	Name: Cooking Service [V2]
	Creator: Real_KingBob
	Made in: 9/19/21
    Updated: 9/30/22
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
		ParticlesSpawn = Knit.CreateSignal(),
		SendIngredients = Knit.CreateSignal(),
		ProximitySignal = Knit.CreateSignal();
	};
}

----- Services -----

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");

----- Directories -----

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary");

local workspacePans = workspace:WaitForChild("Pans");
local IngredientsAvailable = workspace:WaitForChild("IngredientAvailable");
local FoodAvailable = workspace:WaitForChild("FoodAvailable");

local ReplicatedAssets = Knit.Shared.Assets;
local ReplicatedModules = Knit.Shared.Modules;
local ServerModules = Knit.Modules;
local RemoteEvents = GameLibrary:FindFirstChild("RemoteEvents");
local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects");
local FoodObjects = GameLibrary:FindFirstChild("FoodObjects");

----- Loaded Modules -----

local ZoneAPI = require(ReplicatedModules:FindFirstChild("Zone"));
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"));
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"));
local TableAPI = require(ServerModules:FindFirstChild("Table"));
local MathAPI = require(ServerModules:FindFirstChild("Math"));
local DropUtil = require(ReplicatedModules.DropUtil)

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

local panZone = ZoneAPI.new(workspacePans:WaitForChild("PanHitboxes"));

----- Variables -----

local EXPMultiplier = 10;
local MaxFoodSpawnRange = 25;

----- Tables -----

local FoodData = {};
local ProxFunctions = {};
local CookFunctions = {};
local possibleRecipes = {};
local PlayersInServers = {};
local CurrentIngredients = {};
local CurrentIngredientObjects = {};

local playerIngredients = {};
local prevIngredients = {};
local cookingPansQueue = {};

local function PlayerAdded(player)
    CurrentIngredientObjects[player.Name] = {};
    CurrentIngredients[player.Name] = {};
    possibleRecipes[player.Name] = {};
end;

local function PlayerRemoving(player)
    CurrentIngredientObjects[player.Name] = nil;
    CurrentIngredients[player.Name] = nil;
    possibleRecipes[player.Name] = nil;
end;

-- Proximity Functions

function CookingService:PickUp(Player, Character, Item)
	print(Player, Character, Item)
	if Player and Character and Item then
		if (PlayersInServers[Player.UserId] == nil or PlayersInServers[Player.UserId][1] == nil) and Character:FindFirstChild("Ingredient").Value == nil then
			PlayersInServers[Player.UserId] = {true, Item};
			local ProximityService = Knit.GetService("ProximityService");
			if Item:GetAttribute("Type") == "Ingredient"
			or (Item:IsA("Model") and Item.PrimaryPart:GetAttribute("Type") == "Ingredient") then

				local ClonedItem = IngredientObjects:FindFirstChild(Item.Name):Clone();

				ProximityService:PickUpIngredient(Character, ClonedItem);
				--StatTrackService:AddIngredient(Player, 1);
				--StatTrackService:SetRecentIngredientPickUp(Player,tostring(Item));
				self.Client.ProximitySignal:Fire(Player,"DropDown",true);
				--ProximityService:PrintLogs(Player.UserId);

				PlayersInServers[Player.UserId] = {nil, Item};
			elseif Item:GetAttribute("Type") == "Food"
			or (Item:IsA("Model") and Item.PrimaryPart:GetAttribute("Type") == "Food") then
				local ClonedItem = FoodObjects:FindFirstChild(Item.Name):Clone();

				ProximityService:PickUpFood(Character, ClonedItem);
				--StatTrackService:AddFood(Player, 1);
				--StatTrackService:SetRecentFoodPickUp(Player,tostring(Item));
				self.Client.ProximitySignal:Fire(Player,"DropDown",true);
				--ProximityService:PrintLogs(Player.UserId);

				PlayersInServers[Player.UserId] = {nil, Item};
			end;
		end;
	end;
end;

function CookingService:DropDown(Player,Character)
	if Player and Character then
		if (PlayersInServers[Player.UserId] == nil or PlayersInServers[Player.UserId][1] == nil) and Character:FindFirstChild("Ingredient").Value ~= nil then
			PlayersInServers[Player.UserId][1] = true;
			local ProximityService = Knit.GetService("ProximityService");
			for _,item in pairs(game.Workspace:FindFirstChild("FoodAvailable"):GetChildren()) do
				if item:IsA("Model") then
					--print("CHECKl", item.PrimaryPart:GetAttribute("Owner") , Player.Name, item , PlayersInServers[Player.UserId][2], item.PrimaryPart == PlayersInServers[Player.UserId][2])
					if item.PrimaryPart:GetAttribute("Owner") == Player.Name and item.PrimaryPart == PlayersInServers[Player.UserId][2] then item:Destroy() end;
				elseif item:IsA("MeshPart") then
					if item:GetAttribute("Owner") == Player.Name and item == PlayersInServers[Player.UserId][2] then item:Destroy() end;
				end;
			end;
			for _,item in pairs(game.Workspace:FindFirstChild("IngredientAvailable"):GetChildren()) do
				if item:IsA("Model") then
					if item.PrimaryPart:GetAttribute("Owner") == Player.Name and item.PrimaryPart == PlayersInServers[Player.UserId][2] then item:Destroy() end;
				elseif item:IsA("MeshPart") then
					--print("CHECK2", item:GetAttribute("Owner") , Player.Name, item , PlayersInServers[Player.UserId][2], item == PlayersInServers[Player.UserId][2])
					if item:GetAttribute("Owner") == Player.Name and item == PlayersInServers[Player.UserId][2] then item:Destroy() end;
				end;
			end;
	
			ProximityService:DropItem(Character, PlayersInServers[Player.UserId][2]);
			self.Client.ProximitySignal:Fire(Player,"DropDown",false);
	
			PlayersInServers[Player.UserId] = nil;
		end;
	end;
end;

----- Cooking Functions -----

function CookingService:CanCookOnPan(player, pan)
	if not cookingPansQueue[player.UserId] then 
		cookingPansQueue[player.UserId] = {};
		return true; 
	end
	if #cookingPansQueue[player.UserId] == 0 then return true; end

	if table.find(cookingPansQueue[player.UserId], pan) then return false; end

	if #cookingPansQueue[player.UserId] > 1 then
		print("needs gamepass to cook multiple foods")
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

function CookingService:Cook(player,Character,recipe, pan)
	print('[CookingService]: Cooking Food: '.. tostring(recipe));

	if self:CanCookOnPan(player, pan) == false then return false; end

	local DataService = Knit.GetService("DataService")
	local profile = DataService.GetProfile(player);
	if not profile then
		if RecipeModule[tostring(recipe)] then
			local IngredientsUsed = {};
			local SelectedRecipe = RecipeModule[tostring(recipe)];
			--print(SelectedRecipe,SelectedRecipe["Ingredients"])
			for _,ingredientFromRecipe in pairs(SelectedRecipe["Ingredients"]) do
				--print("AB",ingredientFromRecipe,CurrentIngredientObjects[player.Name]);
				for _, ingredientFromTable in pairs(CurrentIngredientObjects[player.Name]) do
					if tostring(ingredientFromTable) == tostring(ingredientFromRecipe) then
						table.insert(IngredientsUsed,ingredientFromTable);
						break;
					end;
				end;
			end;
			if #SelectedRecipe["Ingredients"] == #IngredientsUsed then
				print('[CookingService]: Found all ingredients',IngredientsUsed);
				for _,deleteIngredient in pairs(IngredientsUsed) do
					deleteIngredient:Destroy();
					if deleteIngredient then
						deleteIngredient = nil;
					end
				end;
				IngredientsUsed = {};
			else return end;

			print("COOKING TIME")

			table.insert(cookingPansQueue[player.UserId], pan)

			local cookingTime = RecipeModule:GetCookTime(tostring(recipe));

			--print("cookingPansQueue", cookingPansQueue[player.UserId])

			self.Client.Cook:Fire(player, tostring(recipe), pan, cookingTime)

			task.spawn(function()
				local waitTime = 2;
				local numOfDrops = cookingTime / waitTime;
				local cheeseDrop = RecipeModule:GetRecipeRewards(RecipeModule[tostring(recipe)].Difficulty);
				local rCheeseDropReward = math.random(cheeseDrop[1],cheeseDrop[2])

				local cheeseValuePerDrop = rCheeseDropReward / numOfDrops;
				local cheeseObjectPerDrop = 10;
				-- oCFrame, obj, amount, value

				--print("cooking drop", numOfDrops, cheeseDrop, rCheeseDropReward, cheeseValuePerDrop)
				
				for i = 1, numOfDrops do
					DropUtil.DropCheese(pan.CFrame, game.ReplicatedStorage.Spawnables.Cheese, player, cheeseObjectPerDrop, math.floor((cheeseValuePerDrop / cheeseObjectPerDrop)))
					task.wait(waitTime);
				end
			end)
			task.wait(cookingTime);

			local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end
			table.remove( cookingPansQueue[player.UserId], tablefind(cookingPansQueue[player.UserId], pan) );

			--print("cookingPansQueue", cookingPansQueue[player.UserId])

			local RawCalculatedEXP = (EXPMultiplier * #SelectedRecipe["Ingredients"]);
			self.Client.ProximitySignal:Fire(player,"CookVisible",false);
			--RewardService:GiveReward(profile, {EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2);})

			local DistanceBetweenPlayerAndPan = player:DistanceFromCharacter(pan.Position);
			local food;

			if DistanceBetweenPlayerAndPan > MaxFoodSpawnRange or DistanceBetweenPlayerAndPan == 0 then
				food = SpawnItemsAPI:Spawn(player.UserId, player, recipe, FoodObjects, FoodAvailable, pan.Position + Vector3.new(0,5,0));
			else
				food = SpawnItemsAPI:Spawn(player.UserId, player, recipe, FoodObjects, FoodAvailable, Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4);
			end

			print("food created:", food)
			
			self.Client.ParticlesSpawn:Fire(player, food, "CookedParticle")
			--StatTrackService:SetRecentCookedFood(player, tostring(recipe));
		end;
	else
		warn("Could not find user["..tostring(player.UserId).."] profile to cook the food, please retry")
	end;
end;

function CookingService:KnitStart()
	SpawnItemsAPI:SpawnAllIngredients(2);
    --SpawnItemsAPI:SpawnAll(IngredientObjects,IngredientsAvailable);
    --SpawnItemsAPI:SpawnAtRandomSpawns(IngredientObjects,IngredientsAvailable, workspace.FoodSpawnPoints);
    --SpawnItemsAPI:SpawnAll(FoodObjects,IngredientsAvailable);
end


function CookingService:KnitInit()
    print('[CookingService]: Activated! [V2]')

	task.spawn(function()
		local playerCheckDebounce = {}

		while task.wait(0) do
			for _, plr in pairs(Players:GetPlayers()) do
				if playerCheckDebounce[plr.UserId] == nil then playerCheckDebounce[plr.UserId] = false; end
				if playerCheckDebounce[plr.UserId] == true then continue; end
				playerCheckDebounce[plr.UserId] = true;
				if prevIngredients[plr] == nil then prevIngredients[plr] = {} end;
				playerIngredients[plr.UserId] = {}
				--print("CurrentIngredientObjects", CurrentIngredientObjects)
				for k, v in pairs(CurrentIngredientObjects) do
					if tostring(k) == plr.Name then
						for _, b in pairs(v) do
							table.insert(playerIngredients[plr.UserId], tostring(b))
						end
					end
				end
				if TableAPI.CheckArrayEquality(prevIngredients[plr],playerIngredients[plr.UserId]) == false then
					print("SENT DATA")
					print("data comparison", prevIngredients[plr], playerIngredients[plr.UserId], TableAPI.CheckArrayEquality(prevIngredients[plr],playerIngredients[plr.UserId]))
					self.Client.SendIngredients:Fire(plr, playerIngredients[plr.UserId])
				end
				prevIngredients[plr] = playerIngredients[plr.UserId];
				playerCheckDebounce[plr.UserId] = false;
			end
		end
	end)
	
	task.spawn(function()
		local oldArray = {};
		local oldFoodData = {};

		local getRadius = function(part)
			return (part.Size.Z<part.Size.Y and part.Size.Z or part.Size.Y)/2
			--[[In the above we are returning the smallest, first we check if Z is smaller
			than Y, if so then we return Z or else we return Y.]]
		end;
	
		while task.wait(0.1) do
			local tempData = {};
			local tCurrentIngredients = {};
			local tCurrentIngredientObjects = {};
			local partsArray = {};
	
			for _,hitbox in pairs(workspacePans.PanHitboxes:GetChildren()) do
				local radiusOfPan = getRadius(hitbox)

				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
				overlapParams.FilterType = Enum.RaycastFilterType.Blacklist;

				local parts = workspace:GetPartBoundsInRadius(hitbox.Position, radiusOfPan, overlapParams)
				for _, part in pairs(parts) do
					table.insert(partsArray, part)
				end
			end
	
			if #partsArray > 0 then
				for _, touchedPart in ipairs(partsArray) do
					if TableAPI.CheckTableEquality(oldArray, partsArray) ~= true then
						oldArray = partsArray;
					end;

					local touchedType, touchedOwner;
					if touchedPart.Parent:IsA("Model") then
						if touchedPart.Parent.PrimaryPart then
							local touchedPrimary = touchedPart.Parent.PrimaryPart;
							touchedType = touchedPrimary:GetAttribute("Type");
							touchedOwner = touchedPrimary:GetAttribute("Owner");
						end
					else
						touchedType = touchedPart:GetAttribute("Type");
						touchedOwner = touchedPart:GetAttribute("Owner");
					end

					if touchedType and touchedOwner ~= "Default" and touchedOwner ~= "None" and panZone:findPart(touchedPart) == true then
						table.insert(tempData,{touchedOwner,touchedPart});

						if tCurrentIngredients[touchedOwner] == nil then
							tCurrentIngredients[touchedOwner] = {};
							tCurrentIngredientObjects[touchedOwner] = {};
						end;

						if table.find(tCurrentIngredients[touchedOwner],touchedPart.Name) == nil then
							table.insert(tCurrentIngredientObjects[touchedOwner],touchedPart);
							table.insert(tCurrentIngredients[touchedOwner],touchedPart.Name);
							for key,currentRecipe in pairs(RecipeModule) do
								if type(currentRecipe) == "table" then
									local valid = TableAPI.Equals(tCurrentIngredients[touchedOwner],currentRecipe["Ingredients"]);

									if valid == true then
										if possibleRecipes[touchedOwner] then
											if table.find(possibleRecipes[touchedOwner],key) == nil then
												table.insert(possibleRecipes[touchedOwner],key);
												self:Recipe(game.Players:FindFirstChild(touchedOwner), key);
											else
												--print(possibleRecipes[touchedOwner]);
											end;
										end;
									end;
								end;
							end;
						end;
					end;
				end

				FoodData = tempData; --Table.Sync(FoodData,tempData)
				CurrentIngredientObjects = tCurrentIngredientObjects; --Table.Sync(CurrentIngredientObjects,tCurrentIngredientObjects)
				CurrentIngredients = tCurrentIngredients; --Table.Sync(CurrentIngredients,tCurrentIngredients)
				
				--[[if #FoodData ~= 0 then
					print('[CookingHandler]: Food - ',FoodData,CurrentIngredientObjects,CurrentIngredients); --print(CurrentIngredients,tCurrentIngredients)
				end;]]

				if TableAPI.CheckTableEquality(oldFoodData, FoodData) ~= true then
					--print("FOOD DATA:", FoodData)
					oldFoodData = FoodData;
				else
					if #FoodData ~= 0 then
						print("INEQUALITY", FoodData)
					end
				end;
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
		return self:Cook(player, player.Character, recipe, pan);
    end)

    Players.PlayerAdded:Connect(PlayerAdded);
    Players.PlayerRemoving:Connect(PlayerRemoving);
end


return CookingService
