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
Knit.AvatarService = require(Knit.Services.AvatarService);

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
	local DataHasLoaded = Knit.DataService:CheckIfDataLoaded(player);
	while DataHasLoaded == false do
		DataHasLoaded = Knit.DataService:CheckIfDataLoaded(player);
		if DataHasLoaded then
			--// print(player.UserId,"| DataLoaded:", DataHasLoaded);
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
				Knit.StatTrackService:StartTracking(player);
			end)

			--[[local leaderstats = Instance.new("Folder")
			leaderstats.Name = "leaderstats"
			leaderstats.Parent = player
		
			local wins = Instance.new("IntValue")
			wins.Name = "Wins"
			wins.Value = playerProfiles[player].Data.PlayerInfo.TotalWins;
			wins.Parent = leaderstats]]

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