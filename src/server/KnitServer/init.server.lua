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
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService");
--local ChatService = require(game.ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit);
local Component = require(Knit.Util.Component);
local Promise = require(Knit.Util.Promise);

----- Knit -----
Knit.Shared = ReplicatedStorage.Common;
Knit.ReplicatedModules = Knit.Shared.Modules;
Knit.ReplicatedAssets = Knit.Shared.Assets;
Knit.ReplicatedRarities = require(Knit.ReplicatedAssets.Rarities)
Knit.GameLibrary = ReplicatedStorage.GameLibrary;
Knit.Services = ServerScriptService.Services;
Knit.Modules = ServerScriptService.Modules;
Knit.Settings = ServerScriptService.Settings;
Knit.Config = require(Knit.Shared.Modules.Config);

Knit.Components = ServerScriptService.Components;

Knit.ReplicatedHatSkins = Knit.Shared.Assets.HatSkins;
Knit.ReplicatedBoosterEffects = Knit.Shared.Assets.BoosterEffects;

----- Loaded Services -----
Knit.DataService = require(Knit.Services.DataService);
Knit.ProgressionService = require(Knit.Services.ProgressionService);
Knit.PartyService = require(Knit.Services.PartyService);
Knit.AvatarService = require(Knit.Services.AvatarService);
Knit.MusicService = require(Knit.Services.MusicService);
Knit.NotificationService = require(Knit.Services.NotificationService);
Knit.ProximityService = require(Knit.Services.ProximityService);
Knit.CurrencySessionService = require(Knit.Services.CurrencySessionService)
Knit.InventoryService = require(Knit.Services.InventoryService);
Knit.CookingService = require(Knit.Services.CookingService);
Knit.OrderService = require(Knit.Services.OrderService);
Knit.CrateService = require(Knit.Services.CrateService);
Knit.NpcService = require(Knit.Services.NpcService);
Knit.GameService = require(Knit.Services.GameService);

Knit.ComponentsLoaded = false;
----- Initialize -----

local RemoteFunctions = Knit.GameLibrary:FindFirstChild("RemoteFunctions");

local Whitelist = true; -- if true then only whitelisted players can play
local Profiles = {}; -- [player] = profile
local WhitelistedPlayers = {52624453, 21831137, 1464956079, 51714312, 131997771, 47330208, 1154275938, 2283059942, 475945078, 418172096, 259288924, 933996022, 121998890, 76172952};

local ThemeData = workspace:GetAttribute("Theme")

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
--PhysicsService:CreateCollisionGroup(playerCollisionGroupName);
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false);

local previousCollisionGroups = {};
local playerProfiles = {}; -- [player] = profile
local deathCooldown = {};

local isFalling = {}
local fallingDebounce = {}

local playerDoubleJumped = {}
local playerTripleJumped = {}

local canJump = {};
local canDoubleJump = {};
local canTripleJump = {};
local currentJump = {};

local CHECK_DELAY_IN_SECONDS = 0.2;

local function setCollisionGroup(object)
	if CollectionService:HasTag(object, "CC_Food") then
		return
	end
    if object then
        if object:IsA("BasePart") then
            previousCollisionGroups[object] = object.CollisionGroupId;
            --PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName);
            object.CollisionGroup = playerCollisionGroupName;
        end
    end
end

local function setCollisionGroupRecursive(object)
	if object:GetAttribute("Owner") then
		return
	end
	if CollectionService:HasTag(object, "CC_Food") then
		return
	end
    if object then
        setCollisionGroup(object);

        for _, child in ipairs(object:GetChildren()) do
            setCollisionGroupRecursive(child);
        end
    end
end

local function resetCollisionGroup(object)
	if object:GetAttribute("Owner") then
		return
	end

	if CollectionService:HasTag(object, "CC_Food") then
		return
	end
    if object then
        local previousCollisionGroupId = previousCollisionGroups[object];
        if not previousCollisionGroupId then return end 

        local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId);
        if not previousCollisionGroupName then return end

        --PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName);
        object.CollisionGroup = previousCollisionGroupName;
        previousCollisionGroups[object] = nil;
    end
end

local ChatTags = {
	[21831137] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Real_KingBob
	[1464956079] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Sencives
	[131997771] = {TagText = "MANAGER", TagColor = Color3.fromRGB(6, 207, 16)}, -- Emerald
}

local PurchasedChatTags = {
	[26228902] = {TagText = "VIP", TagColor = Color3.fromRGB(255, 204, 0)}, -- VIP
}

local VIP_GAMEPASS = 26228902;

--[[ [OLD] Chat System
local inDevelopment = false
local configuration = require(Knit.Settings.ChatConfigs)
local toRequire = inDevelopment and  game:GetService("ServerScriptService"):WaitForChild("MainModule") or 9375790695
local addons = script:WaitForChild("Addons")

require(toRequire)(configuration,addons)]]

local client, server, shared = require(script:FindFirstChild("LoaderUtils", true)).toWallyFormat(script.src, false)

server.Name = "_SoftShutdownServerPackages"
server.Parent = script

client.Name = "_SoftShutdownClientPackages"
client.Parent = ReplicatedFirst

shared.Name = "_SoftShutdownSharedPackages"
shared.Parent = ReplicatedFirst

local clientScript = script.ClientScript
clientScript.Name = "QuentySoftShutdownClientScript"
clientScript:Clone().Parent = ReplicatedFirst

require(server.SoftShutdownService):Init()

----- Private Functions -----

----- Connections -----

local function onCharacterAdded(character)

	local E = Instance.new("ObjectValue")
	E.Name = "Ingredient"
	E.Parent = character

	local player = Players:GetPlayerFromCharacter(character);

	if player then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid");

		currentJump[player] = 0;
		canJump[player] = true

		local debounceJump = false

		local ProgressionService = Knit.GetService("ProgressionService");
		local playerCurrency, playerStorage, progressionStorage = ProgressionService:GetProgressionData(player, ThemeData)

		humanoid.MaxHealth = progressionStorage["Extra Health"].Data[playerStorage["Extra Health"]].Value;
		humanoid.Health = progressionStorage["Extra Health"].Data[playerStorage["Extra Health"]].Value;

		local function manageConsecutiveJumps(_, newState)
			if newState == Enum.HumanoidStateType.Freefall then
				canDoubleJump[player] = true
				canTripleJump[player] = true
				currentJump[player] = 0
			elseif newState == Enum.HumanoidStateType.Jumping then
				warn("OKOK")
				canJump[player] = false;
				task.wait(CHECK_DELAY_IN_SECONDS);
				currentJump[player] = currentJump[player] + 1;
				canJump[player] = currentJump[player] < 3;
				warn(character, currentJump)
				if currentJump[player] == 2 then
					canDoubleJump[player] = false
					playerDoubleJumped[player] = true
				elseif currentJump[player] == 3 then
					canTripleJump[player] = false
					playerTripleJumped[player] = true
				end
			elseif newState == Enum.HumanoidStateType.Landed then
				currentJump[player] = 0;
				canJump[player] = true;
				canDoubleJump[player] = nil
				canTripleJump[player] = nil
				playerDoubleJumped[player] = nil
				playerTripleJumped[player] = nil
			end
		end

		local function onJumpRequest()
			if not character or not humanoid or not character:IsDescendantOf(workspace) or
			humanoid:GetState() == Enum.HumanoidStateType.Dead then
				return
			end
			
			if canDoubleJump[player] and not playerDoubleJumped[player] then
				playerDoubleJumped[player] = true
			elseif canTripleJump[player] and playerDoubleJumped[player] and not playerTripleJumped[player] then
				playerTripleJumped[player] = true
			end
		end	

		humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
			if humanoid.Jump == true then
				if debounceJump == true then return end
				warn("JUMP REQUEST")
				onJumpRequest()
				task.spawn(function()
					if debounceJump == true then return end
					debounceJump = true
					task.wait(1)
					debounceJump = false
				end)
			end
		end)
		
		humanoid.StateChanged:Connect(manageConsecutiveJumps);

		humanoid.FreeFalling:Connect(function(falling)
			isFalling[player] = falling
			if isFalling[player] and not fallingDebounce[player] then
				fallingDebounce[player] = true
				local maxHeight = 0
				local humRoot = character:FindFirstChild("HumanoidRootPart")
				while isFalling[player] do
					local height = math.abs(humRoot.Position.y)
					if height > maxHeight then
						maxHeight = height
					end
					if canDoubleJump[player] and playerDoubleJumped[player] then -- Check if the player double jumped
						warn('DOUBLE')
						maxHeight = height -- Update the max height to the new height
						canDoubleJump[player] = false
					end
					if canTripleJump[player] and playerTripleJumped[player] then -- Check if the player double jumped
						warn("TRIPLE")
						maxHeight = height -- Update the max height to the new height
						canTripleJump[player] = false
					end
					task.wait()
				end
		
				local fallHeight = maxHeight - humRoot.Position.y
				if fallHeight >= Knit.Config.LOWEST_FALL_HEIGHT then
					humanoid:TakeDamage(fallHeight)
				end
				fallingDebounce[player] = nil
			end
		end)		

        if CollectionService:HasTag(player, Knit.Config.CHEF_TAG) then
            --// NOTE: This is if player bought chef gamepass
			--Knit.AvatarService:SetHunterSkin(player);
        else
			local userId = player.UserId;

			setCollisionGroupRecursive(character);
			character.DescendantAdded:Connect(setCollisionGroup);
			character.DescendantRemoving:Connect(resetCollisionGroup);

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

			--AvatarService:SetAvatarHat(player, AvatarService:GetAvatarHat(player))
			AvatarService:SetBoosterEffect(player, AvatarService:GetBoosterEffect(player))

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

	for i,v in pairs(CollectionService:GetTagged("NPC")) do
        task.spawn(function()
            task.wait(i/2)
            Knit.NpcService.Client.SetupNPC:FireAll(v)
        end)
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

----------------------------------------------------------------------------------------------