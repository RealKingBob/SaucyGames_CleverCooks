--[[
	Name: Knit Initialization [V1]
	Creator: Real_KingBob
	Made in: 9/19/21 (Updated: 4/18/22)
	Description: ProfileTemplate table is what empty profiles will default to.
    Updating the template will not include missing template values in existing player profiles!
]]

----- Services -----
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local PhysicsService = game:GetService("PhysicsService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService");
local ChatService = require(game.ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit);
local Component = require(Knit.Util.Component);
local Promise = require(Knit.Util.Promise);

----- Knit -----
Knit.Shared = ReplicatedStorage.Common;
Knit.GameLibrary = ReplicatedStorage.Common;
Knit.Services = ServerScriptService.Services;
Knit.Modules = ServerScriptService.Modules;
Knit.Settings = ServerScriptService.Settings;
Knit.Config = require(Knit.Shared.Modules.Config);

Knit.Components = ServerScriptService.Components;

----- Loaded Services -----
Knit.AvatarService = require(Knit.Services.AvatarService);
Knit.ProximityService = require(Knit.Services.ProximityService);
Knit.CookingService = require(Knit.Services.CookingService);
Knit.DataService = require(Knit.Services.DataService);

Knit.ComponentsLoaded = false;
----- Initialize -----

local RemoteFunctions = Knit.GameLibrary:FindFirstChild("RemoteFunctions");

local Whitelist = true; -- if true then only whitelisted players can play
local Profiles = {}; -- [player] = profile
local WhitelistedPlayers = {52624453, 21831137, 1464956079, 51714312, 131997771, 47330208, 1154275938, 2283059942, 475945078, 418172096, 259288924, 933996022, 121998890, 76172952};


--// Ensures that all components are loaded
function Knit.OnComponentsLoaded()
	if Knit.ComponentsLoaded then
		return Promise.Resolve();
	end

	return Promise.new(function(resolve, reject, onCancel)
		local heartbeat;

		heartbeat = RunService.Heartbeat:Connect(function()
			if Knit.ComponentsLoaded then
				heartbeat:Disconnect();
				heartbeat = nil;
			end
		end)

		onCancel(function()
			if heartbeat then
				heartbeat:Disconnect();
				heartbeat = nil;
			end
		end)
	end)
end

Knit.Start():andThen(function()
    Component.Auto(Knit.Components);
	Knit.ComponentsLoaded = true;
	print("Server Initialized");
end):catch(function(err)
    warn(err);
end)

----- Variables -----
local playerCollisionGroupName = "Players";
PhysicsService:CreateCollisionGroup(playerCollisionGroupName);
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false);

local previousCollisionGroups = {};
local playerProfiles = {}; -- [player] = profile
local deathCooldown = {};

local ChatTags = {
	[21831137] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Real_KingBob
	[1464956079] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Sencives
	[131997771] = {TagText = "MANAGER", TagColor = Color3.fromRGB(6, 207, 16)}, -- Emerald
}

local PurchasedChatTags = {
	[26228902] = {TagText = "VIP", TagColor = Color3.fromRGB(255, 204, 0)}, -- VIP
}

local VIP_GAMEPASS = 26228902;

----- Private Functions -----

----- Connections -----

local function onCharacterAdded(character)

	local E = Instance.new("ObjectValue")
	E.Name = "Ingredient"
	E.Parent = character

	local player = Players:GetPlayerFromCharacter(character);

	if player then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid");
        if CollectionService:HasTag(player, Knit.Config.CHEF_TAG) then
            --// NOTE: This is if player bought chef gamepass
			--Knit.AvatarService:SetHunterSkin(player);
        else
			local userId = 53347204;

			local AvatarService = Knit.AvatarService

			local playerAccessories = AvatarService:GetAvatarAccessories(userId);
			local playerColor = AvatarService:GetAvatarColor(userId);
			local playerFace = AvatarService:GetAvatarFace(userId);
			local hasHeadless = AvatarService:CheckForHeadless(userId);
			
			for _, assetId in pairs(playerAccessories) do
				AvatarService:SetAvatarAccessory(userId,character.Humanoid,assetId);
			end;
			
			AvatarService:SetAvatarColor(userId,character, playerColor);
			AvatarService:SetAvatarFace(userId,character,playerFace, false);
			
			if hasHeadless == true then
				AvatarService:SetHeadless(userId,character);
			end;

			CollectionService:AddTag(character, "TrackInstance")
		end
    end
end

local function onPlayerRemoving(player)
	for _, tag in ipairs(CollectionService:GetTags(player)) do
		CollectionService:RemoveTag(player, tag)
	end
end

local function onPlayerAdded(player)
	if game.PlaceId == 0000000 then
		if Knit.Config.WHITELIST == true then
			if not player:IsInGroup(13585944) then
				if player.UserId > 0 then
					player:Kick("Not Whitelisted")
				end
			end
		end
	end
	local DataHasLoaded = Knit.DataService:CheckIfDataLoaded(player);
	while DataHasLoaded == false do
		DataHasLoaded = Knit.DataService:CheckIfDataLoaded(player);
		if DataHasLoaded then
			print(player.UserId,"| DataLoaded:", DataHasLoaded);
		end
		task.wait(.125);
	end

    local profile = Knit.DataService:GetProfile(player);

    if profile ~= nil then
        if player:IsDescendantOf(Players) == true then
			playerProfiles[player] = profile;

			task.spawn(function()
                --// @todo: Add Missions
				--MissionService:Initialize(player,profile)
				--Knit.StatTrackService:StartTracking(player);
			end)

			local leaderstats = Instance.new("Folder")
			leaderstats.Name = "leaderstats"
			leaderstats.Parent = player
		
			local wins = Instance.new("IntValue")
			wins.Name = "Wins"
			wins.Value = playerProfiles[player].Data.PlayerInfo.TotalWins;
			wins.Parent = leaderstats

				--// Main Data folder
			local DataFolder = Instance.new("Folder")
			DataFolder.Name = "Data"
			DataFolder.Parent = player
			
			--// Checkpoint | 1
			local GameValues = Instance.new("Folder")
			GameValues.Name = "GameValues"
			GameValues.Parent = DataFolder
	
			local IngredientLocation = Instance.new("ObjectValue")
			IngredientLocation.Name = "Ingredient"
			IngredientLocation.Parent = GameValues
			local FoodLocation = Instance.new("ObjectValue")
			FoodLocation.Name = "Food"
			FoodLocation.Parent = GameValues
		
			--// Stars | 2
			local CookingFolder = Instance.new("Folder")
			CookingFolder.Name = "Cooking"
			CookingFolder.Parent = DataFolder
			
			local FoodMade = Instance.new("IntValue")
			FoodMade.Name = "FoodMade"
			FoodMade.Parent = CookingFolder
			FoodMade.Value = 0
		
			--// Quests | 3
			local QuestFolder = Instance.new("Folder")
			QuestFolder.Name = "Quests"
			QuestFolder.Parent = DataFolder
			
			local JohnQuest = Instance.new("BoolValue")
			JohnQuest.Name = "John"
			JohnQuest.Parent = QuestFolder
			JohnQuest.Value = false
		
			--// Bosses | 4
			local Bosses = Instance.new("Folder")
			Bosses.Name = "Bosses"
			Bosses.Parent = DataFolder
			
			local ChefBoss = Instance.new("BoolValue")
			ChefBoss.Name = "Rdite"
			ChefBoss.Parent = Bosses
			ChefBoss.Value = false

			local char = player.Character or player.CharacterAdded:Wait()
            player.CharacterAdded:Connect(onCharacterAdded);
			onCharacterAdded(char);
        else
            --// Player left before the profile loaded:
            playerProfiles[player] = nil;
        end
    else
        --// The profile couldn't be loaded possibly due to other
        --//  Roblox servers trying to load this profile at the same time:
        player:Kick();
    end
end

--// In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
    coroutine.wrap(onPlayerAdded)(player);
end

Players.PlayerAdded:Connect(onPlayerAdded);
Players.PlayerRemoving:Connect(onPlayerRemoving);

local DropUtil = require(Knit.Shared.Modules.DropUtil);

task.spawn(function()
	for _, value in ipairs(CollectionService:GetTagged(Knit.Config.CHEESE_SPAWN)) do
		while true do
			task.wait(math.random(4,6))
			workspace.Spawnables.Cheese:ClearAllChildren()
			DropUtil.DropCheese(value.CFrame, game.ReplicatedStorage.Spawnables.Cheese, math.random(10,15), math.random(5,10))
		end
	end
end)

----------------------------------------------------------------------------------------------