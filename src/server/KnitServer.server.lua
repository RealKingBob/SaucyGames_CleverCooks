--[[
	Name: Knit Initialization [V1]
	Creator: Real_KingBob
	Made in: 12/16/21
	Description: Handles all the knit server initialization
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
Knit.ReplicatedModules = Knit.Shared.Modules;
Knit.ReplicatedAssets = Knit.Shared.Assets;
Knit.ReplicatedMaps = Knit.Shared.Maps;

Knit.ReplicatedDuckSkins = require(Knit.ReplicatedAssets.DuckSkins)
Knit.ReplicatedDuckEmotes = require(Knit.ReplicatedAssets.DuckEmotes)
Knit.ReplicatedDuckEffects = require(Knit.ReplicatedAssets.DeathEffects)
Knit.ReplicatedRarities = require(Knit.ReplicatedAssets.Rarities)


Knit.ServerComponents = ServerScriptService.Components;
Knit.ServerModules = ServerScriptService.Modules;
Knit.APIs = ServerScriptService.APIs;
Knit.Services = ServerScriptService.Services;
Knit.Config = require(Knit.ReplicatedModules.Config);

----- Loaded Services -----
Knit.AudioService = require(Knit.Services.AudioService);
Knit.LeaderboardService = require(Knit.Services.LeaderboardService)
Knit.DataService = require(Knit.Services.DataService);
Knit.PartyService = require(Knit.Services.PartyService);
Knit.MatchmakingService = require(Knit.Services.MatchmakingService).GetSingleton();
Knit.TournamentService = require(Knit.Services.TournamentService);
Knit.BadgeService = require(Knit.Services.BadgeService);
Knit.TeleportService = require(Knit.Services.TeleportService);
Knit.AntiExploitService = require(Knit.Services.AntiExploitService);
Knit.StatTrackService = require(Knit.Services.StatTrackService);
Knit.GameService = require(Knit.Services.GameService);
Knit.AvatarService = require(Knit.Services.AvatarService);
Knit.HunterService = require(Knit.Services.HunterService);
Knit.LikeCounterService = require(Knit.Services.LikeCounterService);
Knit.InventoryService = require(Knit.Services.InventoryService);
Knit.DeathEffectService = require(Knit.Services.DeathEffectService);
Knit.CutsceneService = require(Knit.Services.CutsceneService);
Knit.MapService = require(Knit.Services.MapService);
Knit.CrateService = require(Knit.Services.CrateService);
Knit.ComponentsLoaded = false;
----- Initialize -----

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
    Component.Auto(Knit.ServerComponents);
	Knit.ComponentsLoaded = true;
	Knit.AntiExploitService:Start()
	print("Server Initialized");
end):catch(function(err)
    warn(err);
end)

----- Variables -----
local playerCollisionGroupName = "Players";
PhysicsService:CreateCollisionGroup(playerCollisionGroupName);
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false);

local weaponsSystemFolder = Knit.Shared:FindFirstChild("WeaponsSystem");
local weaponsSystemInitialized = false;

local previousCollisionGroups = {};
local playerProfiles = {}; -- [player] = profile
local deathCooldown = {};

local ChatTags = {
	[2510232695] = {TagText = "KARL", TagColor = Color3.fromRGB(160, 58, 255)}, -- Karl
	[21831137] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Real_KingBob
	[1464956079] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Sencives
	[52624453] = {TagText = "DEV", TagColor = Color3.fromRGB(255, 0, 0)}, -- Longnose
	[131997771] = {TagText = "MANAGER", TagColor = Color3.fromRGB(6, 207, 16)}, -- Emerald
}

local PurchasedChatTags = {
	[26228902] = {TagText = "VIP", TagColor = Color3.fromRGB(255, 204, 0)}, -- Longnose
}


local TEST_VOICE_CHAT_PLACE_ID = 8792750286;
local TEST_BIG_SERVER_PLACE_ID = 8793381822;
local TEST_SERVER_PLACE_ID = 8303278706;

local VIP_GAMEPASS = 26228902;

----- Private Functions -----

local function setCollisionGroup(object)
	if object then
		if object:IsA("BasePart") then
			previousCollisionGroups[object] = object.CollisionGroupId;
			PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName);
		end
	end
end

local function setCollisionGroupRecursive(object)
	if object then
		setCollisionGroup(object);

		for _, child in ipairs(object:GetChildren()) do
			setCollisionGroupRecursive(child);
		end
	end
end

local function resetCollisionGroup(object)
	if object then
		local previousCollisionGroupId = previousCollisionGroups[object];
		if not previousCollisionGroupId then return end 

		local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId);
		if not previousCollisionGroupName then return end

		PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName);
		previousCollisionGroups[object] = nil;
	end
end

local function initializeWeaponsSystemAssets()
	if not weaponsSystemInitialized then
		-- Enable/make visible all necessary assets
		local effectsFolder = weaponsSystemFolder.Assets.Effects;
		local partNonZeroTransparencyValues = {
			["BulletHole"] = 1, ["Explosion"] = 1, ["Pellet"] = 1, ["Scorch"] = 1,
			["Bullet"] = 1, ["Plasma"] = 1, ["Railgun"] = 1,
		};
		local decalNonZeroTransparencyValues = { ["ScorchMark"] = 0.25 };
		local particleEmittersToDisable = { ["Smoke"] = true };
		local imageLabelNonZeroTransparencyValues = { ["Impact"] = 0.25 };
		for _, descendant in pairs(effectsFolder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if partNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.Transparency = partNonZeroTransparencyValues[descendant.Name];
				else
					descendant.Transparency = 0;
				end
			elseif descendant:IsA("Decal") then
				descendant.Transparency = 0
				if decalNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.Transparency = decalNonZeroTransparencyValues[descendant.Name];
				else
					descendant.Transparency = 0;
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true;
				if particleEmittersToDisable[descendant.Name] ~= nil then
					descendant.Enabled = false;
				else
					descendant.Enabled = true;
				end
			elseif descendant:IsA("ImageLabel") then
				if imageLabelNonZeroTransparencyValues[descendant.Name] ~= nil then
					descendant.ImageTransparency = imageLabelNonZeroTransparencyValues[descendant.Name];
				else
					descendant.ImageTransparency = 0;
				end
			end
		end
		
		weaponsSystemInitialized = true;
	end
end

initializeWeaponsSystemAssets();
local WeaponsSystem = require(weaponsSystemFolder.WeaponsSystem);
if not WeaponsSystem.doingSetup and not WeaponsSystem.didSetup then
	WeaponsSystem.setup();
end

local function setupClientWeaponsScript(player)
	local clientWeaponsScript = player.PlayerGui:FindFirstChild("ClientWeaponsScript");
	if clientWeaponsScript == nil then
		weaponsSystemFolder.ClientWeaponsScript:Clone().Parent = player.PlayerGui;
	end
end

----- Connections -----

local function onCharacterAdded(character)
    setCollisionGroupRecursive(character);
    character.DescendantAdded:Connect(setCollisionGroup);
    character.DescendantRemoving:Connect(resetCollisionGroup);

	local player = Players:GetPlayerFromCharacter(character);

	if player then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid");
        if CollectionService:HasTag(player, Knit.Config.HUNTER_TAG) and tostring(player.RespawnLocation.Parent) ~= "Locations" then
            Knit.AvatarService:SetHunterSkin(player);
            --GameService:SetHunterCamera(true, player)
        else
			--print('Character added')
            Knit.GameService:SetHunterCamera(false, player);
			--Knit.AvatarService:SetRandomDeathEffect(player)
			--Knit.AvatarService:SetRandomAvatarSkin(player)
			Knit.AvatarService:SetDeathEffect(player, Knit.AvatarService:GetDeathEffect(player))
			Knit.AvatarService:SetAvatarSkin(player, Knit.AvatarService:GetAvatarSkin(player))
			
			if CollectionService:HasTag(player, Knit.Config.BREAD_TAG) then
				task.wait(0.3)
				Knit.AvatarService.Client.CreateB:FireAll(player)
			end
			--[[task.spawn(function()
			end)]]
		end
        
        humanoid.Died:Connect(function()
			if deathCooldown[player.UserId] == nil then
				deathCooldown[player.UserId] = true
				if CollectionService:HasTag(player, Knit.Config.HUNTER_TAG) == false or character:FindFirstChild("Sphere") ~= nil then
					--// Initiliaze Death Effect
					--print("death!")
					Knit.DeathEffectService:Init(player, character);
					task.wait(1)
					deathCooldown[player.UserId] = nil
				end
			end
		end)
    end
end

local function onPlayerRemoving(player)
	local PLAYER_UI = workspace.Lobby.NameTags:FindFirstChild(player.UserId)
	if PLAYER_UI then
		PLAYER_UI:Destroy()
	end

	for _, tag in ipairs(CollectionService:GetTags(player)) do
		CollectionService:RemoveTag(player, tag)
	end
end

local function onPlayerAdded(player)
	if game.PlaceId == TEST_VOICE_CHAT_PLACE_ID or 
	game.PlaceId == TEST_BIG_SERVER_PLACE_ID or 
	game.PlaceId == TEST_SERVER_PLACE_ID then
		if Knit.Config.WHITELIST == true then
			if not player:IsInGroup(13585944) then
				if player.UserId > 0 then
					player:Kick("Not Whitelisted")
				end
			end
		end
	end
	CollectionService:AddTag(player, Knit.Config.AFK_TAG)
	setupClientWeaponsScript(player);
	local DataHasLoaded = Knit.DataService:CheckIfDataLoaded(player);
	while DataHasLoaded == false do
		DataHasLoaded = Knit.DataService:CheckIfDataLoaded(player);
		if DataHasLoaded then
			--// print(player.UserId,"| DataLoaded:", DataHasLoaded);
		end
		task.wait(.125);
	end

    local profile = Knit.DataService:GetProfile(player);
    if Knit.GameService:GetGameState() == 0 then
        Knit.GameService.Client.NotEnoughPlayersSignal:Fire(player);
    end

	player.Idled:Connect(function(time)
		if CollectionService:HasTag(player, Knit.Config.ALIVE_TAG) == true and CollectionService:HasTag(player, Knit.Config.IDLE_TAG) == false then
			CollectionService:AddTag(player, Knit.Config.IDLE_TAG)
		end
   	end)

    if profile ~= nil then
        if player:IsDescendantOf(Players) == true then
			playerProfiles[player] = profile;
		   	task.spawn(function()
				player.RespawnLocation = workspace.Lobby.Spawns.Locations.Spawn
		   	end)
			task.spawn(function()
                --// @todo: Add Missions
				--MissionService:Initialize(player,profile)
				Knit.StatTrackService:StartTracking(player);
			end)

			local leaderstats = Instance.new("Folder")
			leaderstats.Name = "leaderstats"
			leaderstats.Parent = player
		
			local wins = Instance.new("IntValue")
			wins.Name = "Wins"
			wins.Value = playerProfiles[player].Data.PlayerInfo.TotalWins;
			wins.Parent = leaderstats

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

ChatService.SpeakerAdded:Connect(function(playerName)
	local Speaker = ChatService:GetSpeaker(playerName)
	local Player = game.Players[playerName]
	
	if ChatTags[Player.UserId] then
		Speaker:SetExtraData("Tags",{ChatTags[Player.UserId]})
		Speaker:SetExtraData("ChatColor",Color3.fromRGB(255, 230, 7))
	elseif MarketplaceService:UserOwnsGamePassAsync(Player.UserId, VIP_GAMEPASS) then
		Speaker:SetExtraData("Tags",{PurchasedChatTags[VIP_GAMEPASS]})
	end
end)

Players.PlayerAdded:Connect(onPlayerAdded);
Players.PlayerRemoving:Connect(onPlayerRemoving);

----------------------------------------------------------------------------------------------