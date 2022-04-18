----- Services -----
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal);
local TableUtil = require(Knit.Util.TableUtil);
local Intermission = require(Knit.ServerModules.Intermission);
local RewardService = require(Knit.Services.RewardService);
local PlayerTrack = require(Knit.ServerModules.PlayerTrack);
local PlayerSettings = require(Knit.ReplicatedModules.SettingsUtil);
local SystemInfo = require(Knit.ReplicatedAssets.SystemInfo);

----- Game Modes -----
local ClassicRound = require(Knit.ServerModules.Modes.ClassicRound);
local RaceRound = require(Knit.ServerModules.Modes.RaceRound);
local InfectionRound = require(Knit.ServerModules.Modes.InfectionRound);
local DominationRound = require(Knit.ServerModules.Modes.DominationRound);
local HotPotatoRound = require(Knit.ServerModules.Modes.HotPotatoRound);
local KOTHRound = require(Knit.ServerModules.Modes.KOTHRound);
local TileFallingRound = require(Knit.ServerModules.Modes.TileFallingRound);

----- Tournament Game Modes -----
local T_RaceRound = require(Knit.ServerModules.TournamentModes.RaceRound);
local T_DominationRound = require(Knit.ServerModules.TournamentModes.DominationRound);
local T_HotPotatoRound = require(Knit.ServerModules.TournamentModes.HotPotatoRound);
local T_KOTHRound = require(Knit.ServerModules.TournamentModes.KOTHRound);
local T_TileFallingRound = require(Knit.ServerModules.TournamentModes.TileFallingRound);

----- Settings -----
local GAMESTATE = Knit.Config.GAME_STATES;
local GAMEPLAY_TIME = Knit.Config.DEFAULT_GAMEPLAY_TIME;
local HILL_TIME = Knit.Config.DEFAULT_HILL_TIME;
local INTERMISSION_TIME = Knit.Config.DEFAULT_INTERMISSION_TIME;
local GAMEMODES = Knit.Config.GAMEMODES;
local MAPS = Knit.Config.MAPS;

local TOURNAMENT_GAMEMODES = Knit.Config.T_GAMEMODES;
local TOURNAMENT_MAPS = Knit.Config.T_MAPS;

----- GameService -----
local GameService = Knit.CreateService {
    Name = "GameService";
    TimeLeft = Signal.new();
    Client = {
        SetEnvironmentSignal = Knit.CreateSignal();
        TimeLeftSignal = Knit.CreateSignal();
        NotEnoughPlayersSignal = Knit.CreateSignal();
        DisplayLobbyUI = Knit.CreateSignal();
        UpdatePotatoText = Knit.CreateSignal();
        ResultSignal = Knit.CreateSignal();
        UpdateMapQueue = Knit.CreateSignal();

        UpdateGameStateSignal = Knit.CreateSignal();
        HunterCameraSignal = Knit.CreateSignal();
        KillCam = Knit.CreateSignal();

        SetLighting = Knit.CreateSignal();
        TrapControl = Knit.CreateSignal();

        BoostCheck = Knit.CreateSignal();  
        ChangeSetting = Knit.CreateSignal();  
        SetIdle = Knit.CreateSignal();
        DisplayNametags = Knit.CreateSignal();

        AdjustDashCooldown = Knit.CreateSignal();
        AdjustClickCooldown = Knit.CreateSignal();
        ToolAttack = Knit.CreateSignal();
        MapData = Knit.CreateSignal();

        HEffect = Knit.CreateSignal();
        GameC = Knit.CreateSignal();
    };
}

----- GameService -----
-- Tables
local Cooldown = {};
local PartTouchCooldown = {};
local PartTouchConnections = {};

-- MAP SELECTING & GAMEMODES
local sortedModes = {}
local CopiedModes = TableUtil.Copy(GAMEMODES);

local sortedMaps = {}
local CopiedMaps = TableUtil.Copy(MAPS);

local CopiedTournamentModes = TableUtil.Copy(TOURNAMENT_GAMEMODES);
local CopiedTournamentMaps = TableUtil.Copy(TOURNAMENT_MAPS);

GameService.Intermission = nil;
GameService.PreviousMap = nil;
GameService.PreviousMode = nil;
GameService.GameRound = nil;

GameService.PlayersTracked = {};
GameService.GetCurrentHunters = {};
GameService.GameState = nil;
GameService.SetGameplay = false;

GameService.IsTournament = false;

local currentMap = nil;
local nextMap = nil;
local boostedMap = false;

local currentMode = nil;
local nextMode = nil;
local boostedMode = false;

local customMap = nil;
local customMode = nil;

local numOfIntermissions = 0;

customMap = Knit.Config.CUSTOM_MAP;
customMode = Knit.Config.CUSTOM_MODE;


function GameService:AdjustWeapons()
    local MaxShotCooldown = 2.8;
    local MinShotCooldown = 1.5;
    if #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) > 0 then
        local function adjustCooldown(min, max, alpha)
            return min + (max - min) * alpha;
        end

        local newCooldown = adjustCooldown(
            MaxShotCooldown, 
            MinShotCooldown, 
            #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers
        )
        for _, weaponTool in pairs(ServerStorage:WaitForChild("Weapons"):GetChildren()) do
            if weaponTool:IsA("Tool") then
                local ConfigFolder = weaponTool:FindFirstChild("Configuration")
                if ConfigFolder then
                    local ShotCooldown = ConfigFolder:FindFirstChild("ShotCooldown")
                    if ShotCooldown then
                        ShotCooldown.Value = newCooldown;
                    end
                end
            end
        end
    end
end

function GameService:GetGameRound()
    return self.GameRound;
end

function GameService:SetGameRound(gameMode)
    self.GameRound = gameMode;
end

function GameService:GetCurrentHunter(player)
    if self.GetCurrentHunters[player] == true then
        return player;
    else
        return nil;
    end
end

function GameService:ForceMode(modeName)
    if modeName then
        nextMode = modeName
    end
end

function GameService:ForceMap(mapName)
    if mapName then
        nextMap = mapName
        boostedMap = true;
    end

    self.Client.UpdateMapQueue:FireAll({
        CurrentMap = currentMap,
        NextMap = nextMap,
        Boosted = boostedMap,
    });
end

function GameService:SetCurrentHunter(player)
    self.GetCurrentHunters[player] = true;
end

function GameService:TrapControl(Map, Trap, Command, targetObject)
    self.Client.TrapControl:FireAll(Map, Trap, Command, targetObject)
end

--// NOTE: This makes the shoulder camera for the sniper get turned on/off
function GameService:SetHunterCamera(bool, player)
    if player then
        self.Client.HunterCameraSignal:Fire(player,bool)
    else
        self.Client.HunterCameraSignal:FireAll(bool)
    end
end

function GameService:GetGameState()
    return self.GameState;
end

function GameService:GetPreviousMap()
    if self.PreviousMap then
        return self.PreviousMap;
    end
    return nil;
end

function GameService:SetPreviousMap(mapName)
    self.PreviousMap = mapName;
end

function GameService:KillCam(player, killerPlayer)
    self.Client.KillCam:Fire(player, killerPlayer)
end

function GameService:GetPreviousMode()
    return self.PreviousMode;
end

function GameService:SetPreviousMode(modeName)
    self.PreviousMode = modeName;
end

function GameService:SetState(state)
    self.GameState = state;
    self.Client.UpdateGameStateSignal:FireAll(state)
end

function GameService.Client:GetPreviousMode()
    return self.Server:GetPreviousMode();
end

function GameService.Client:GetGameState()
    return self.Server:GetGameState();
end

function GameService.Client:GetMapQueue()
    --print("[GameService]: Requested for map queue")
    return {
        --LevelData = levelData, 
        CurrentMap = currentMap,
        NextMap = nextMap,
    }
end

function GameService.Client:GetMapData()
    --print("[GameService]: Requested for map data")
    return {
        --LevelData = levelData, 
        MapData = sortedMaps,
        ModeData = sortedModes,
    }
end

function GameService:GetPlayerTracked(player)
    if player and self.PlayersTracked[player.UserId] then
        return self.PlayersTracked[player.UserId];
    else
        return nil;
    end
end

local PAdmins = {
	["Player1"] = true;
	["Spagogy"] = true;
	["Real_KingBob"] = true;
	["LordLongNose"] = true;
	["Sencives"] = true;
	["Emeraldgamer98765"] = true;
};

function GameService:SetLighting(MapName, Player)
    local MapSettings = require(Knit.ServerModules.Settings.MapSettings)
    local CurrentMapName = "Lobby"
    local PreviousMap = MapName
    if PreviousMap ~= nil then
        CurrentMapName = PreviousMap
    end
    print("[GameService]: MAP LIGHTING:", MapName, MapSettings[CurrentMapName].Lighting)
    local LightingInfo = MapSettings[CurrentMapName].Lighting;
    if Player then
        self.Client.SetLighting:Fire(Player, LightingInfo)
    else
        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            self.Client.SetLighting:Fire(player, LightingInfo)
        end

        for _, player : Player in pairs(game.Players:GetPlayers()) do
            if PAdmins[player.Name] == true then
                self.Client.SetLighting:Fire(player, LightingInfo)
            end
        end
    end
end

function GameService.Client:GetLighting()
    local MapSettings = require(Knit.ServerModules.Settings.MapSettings)
    local CurrentMapName = "Lobby"
    local PreviousMap = self.Server:GetPreviousMap()
   -- print(PreviousMap)
    if PreviousMap ~= nil then
        CurrentMapName = PreviousMap
    end
    --print(MapSettings[CurrentMapName], CurrentMapName)

    return MapSettings[CurrentMapName].Lighting;
end

function GameService:ChangeSetting(player, SettingName, Option)
    --print("CHANGE SETTING:",player, SettingName, Option, PlayerSettings[SettingName].Options[Option][2])
    if SettingName == "AFK" then
        if PlayerSettings[SettingName].Options[Option][2] == true then
            --print("Added AFK TAG")
            CollectionService:AddTag(player, Knit.Config.AFK_TAG)
        else
            --print("Removed AFK TAG")
            CollectionService:RemoveTag(player, Knit.Config.AFK_TAG)
        end
    elseif SettingName == "Music" then
        local AudioService = Knit.GetService("AudioService")
        if PlayerSettings[SettingName].Options[Option][2] == false then
            --print("MUTED")
            AudioService:MuteMusic(true, player)
        else
            --print("UNMUTED")
            AudioService:MuteMusic(false, player)
        end
    elseif SettingName == "Nametags" then
        if PlayerSettings[SettingName].Options[Option] then
            --print(player,Option)
            self.Client.DisplayNametags:Fire(player, Option)
        end
    end
    self.Client.ChangeSetting:Fire(player, SettingName, Option)
end

function GameService:CreateBreadTool(player)
    local AvatarService = Knit.GetService("AvatarService")
    AvatarService.Client.CreateB:FireAll(player)
    --[[if player.Character:FindFirstChild("ParticleHolder") then
        local BreadToolClone = game.ReplicatedStorage.Tools.BreadTool:Clone()
        BreadToolClone.FaceJoint.Attachment1 = player.Character.ParticleHolder.Forward
        BreadToolClone.HandJoint.Attachment1 = player.Character.ParticleHolder.MouthAttachment
        BreadToolClone.Position = player.Character.ParticleHolder.Position
        BreadToolClone.Parent = player.Character
    end]]
end

function GameService.Client:GetGameResults(player)
    return self:GetGameResults(player);
end

local Select = false

for _, mapData in pairs(CopiedMaps) do
    sortedMaps[#sortedMaps + 1] = {
        name = mapData.MapName,
        chance = math.random(1, 10) / 10 -- 0.1 - 1
    }
end

for _, modeData in pairs(CopiedModes) do
    sortedModes[#sortedModes + 1] = {
        name = modeData.Mode,
        chance = math.random(1, 10) / 10 -- 0.1 - 1
    }
end

table.sort(sortedMaps, function(itemA, itemB)
    return itemA.chance > itemB.chance
end)

local function getRandomMap()
    local random = math.random();
    local selectedMap = nil;

    for _, map in pairs(sortedMaps) do
        if random <= map.chance and selectedMap == nil then
            selectedMap = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMap == nil then
        table.sort(sortedMaps, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMap = sortedMaps[1].name;
        sortedMaps[1].chance = 0;
    end
    return selectedMap;
end

local function getRandomMode()
    local random = math.random();
    local selectedMode = nil;

    for _, map in pairs(sortedModes) do
        if random <= map.chance and selectedMode == nil then
            selectedMode = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMode == nil then
        table.sort(sortedModes, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMode = sortedModes[1].name;
        sortedModes[1].chance = 0;
    end
    return selectedMode;
end

local function adjustCooldown(min, max, alpha)
    return min + (max - min) * alpha
end

if customMap ~= nil then
    nextMap = customMap;
else
    nextMap = getRandomMap();
end

if customMode ~= nil then
    nextMode = customMode;
else
    nextMode = getRandomMode();
end

function GameService:StartGame(TournamentEnabled : boolean)
    local TournamentService = Knit.GetService("TournamentService");
    print("GAMESERVICE [TournamentEnabled]:", TournamentEnabled)
    self.IsTournament = TournamentEnabled;
    if self.IsTournament == true then
        TournamentService:StartTournament();
    else
        task.wait(15);
    end
    while true do
        --// Intermission Started
        print("[GameService]: Intermission Started")
        Players.RespawnTime = 1.3;
        self:SetState(GAMESTATE.INTERMISSION)
        self.Client.UpdateMapQueue:FireAll({
            CurrentMap = currentMap,
            NextMap = nextMap,
            Boosted = boostedMap,
        });

        Cooldown = {};
        PartTouchCooldown = {};
        PartTouchConnections = {};
        self.PlayersTracked = {};

        --[[task.spawn(function()
            task.wait(2);
            for index, value in ipairs(game.Players:GetPlayers()) do
                self:CreateBreadTool(value);
            end
        end)]]

        if (self.IsTournament == true and numOfIntermissions <= 1) 
        or (self.IsTournament == false) then
            self.Intermission = Intermission.new(INTERMISSION_TIME, TournamentEnabled);
            numOfIntermissions += 1;
        end
        
        --// Intermission Ended
        print("[GameService]: Intermission Ended, Checking if enough players")

        task.wait(3)

        if ((#Players:GetPlayers() - #CollectionService:GetTagged(Knit.Config.AFK_TAG)) >= Knit.Config.MINIMUM_PLAYERS) then
            self.SetGameplay = true;
        else
            self.SetGameplay = false;
        end

        if self.SetGameplay == true then
            self:SetState(GAMESTATE.GAMEPLAY)
            print("[GameService]: Gameplay Starting soon, getting gamemode")
            CopiedModes = TableUtil.Copy(GAMEMODES); --// Prevents original table from being changed
            CopiedTournamentModes = TableUtil.Copy(TOURNAMENT_GAMEMODES); --// Prevents original table from being changed

            if self:GetPreviousMode() ~= nil then
                if table.find(CopiedModes,self:GetPreviousMode()) then
                    table.remove(CopiedModes,table.find(CopiedModes,self:GetPreviousMode()));
                end
            end

            if self:GetPreviousMode() ~= nil then
                if table.find(CopiedTournamentModes,self:GetPreviousMode()) then
                    table.remove(CopiedTournamentModes,table.find(CopiedTournamentModes,self:GetPreviousMode()));
                end
            end

            if #CopiedModes > 0 then
                if customMode ~= nil then
                    currentMode = customMode
                    nextMode = customMode
                else
                    currentMode = nextMode;
                    nextMode = self.IsTournament == false and getRandomMode() or TournamentService:getRandomTournamentMode();
                end 

                local SelectedMode = currentMode;
                --[[local Map = nil

                if Select == false then
                    Select = true
                    SelectedMode = "RACE MODE"
                    Map = "Tropical"
                end]]
                self:SetPreviousMode(tostring(SelectedMode));
                print("[GameService]: Getting all players that are not AFK")
                --// New Game Round
                for _, player : Player in pairs(game.Players:GetPlayers()) do
                    CollectionService:RemoveTag(player, Knit.Config.LOBBY_TAG);
                    CollectionService:RemoveTag(player, Knit.Config.BREAD_TAG);
                    if CollectionService:HasTag(player , Knit.Config.AFK_TAG) == false and CollectionService:HasTag(player , Knit.Config.GHOST_TAG) == false then
                        --print(player, "ALIVE_TAG");
                        CollectionService:AddTag(player, Knit.Config.ALIVE_TAG);
                    end
                end

                for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
                    self.PlayersTracked[player.UserId] = PlayerTrack.new(player);
                end

                print("[GameService]: Adjusting all cooldown based off player amount")
                self.Client.AdjustDashCooldown:FireAll(adjustCooldown(1, 2, #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers));
                self.Client.AdjustClickCooldown:FireAll(adjustCooldown(0.35, 1, #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers));
                self:AdjustWeapons();
                --self.GameRound = ClassicRound.new(GAMEPLAY_TIME, "CLASSIC MODE");

                if customMap ~= nil then
                    currentMap = customMap
                    nextMap = customMap
                else
                    currentMap = nextMap;
                    nextMap = getRandomMap();
                end 

                self.Client.UpdateMapQueue:FireAll({
                    CurrentMap = currentMap,
                    NextMap = nextMap,
                    Boosted = boostedMap,
                });

                boostedMap = false
                
                print("[GameService]: Gameplay Started")

                if self.IsTournament == true then
                    if tostring(SelectedMode) == "RACE MODE" then
                        self.GameRound = T_RaceRound.new(GAMEPLAY_TIME, "RACE MODE", currentMap);
                    elseif tostring(SelectedMode) == "DOMINATION" then
                        self.GameRound = T_DominationRound.new(HILL_TIME, "DOMINATION", currentMap);
                    elseif tostring(SelectedMode) == "HOT POTATO" then
                        self.GameRound = T_HotPotatoRound.new(GAMEPLAY_TIME, "HOT POTATO", currentMap);
                    elseif tostring(SelectedMode) == "DUCK OF THE HILL" then
                        self.GameRound = T_KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap);
                    elseif tostring(SelectedMode) == "TILE FALLING" then
                        self.GameRound = T_TileFallingRound.new.new(HILL_TIME, "TILE FALLING", currentMap);
                    else
                        self.GameRound = T_KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap);
                    end
                else
                    if tostring(SelectedMode) == "CLASSIC MODE" then
                        self.GameRound = ClassicRound.new(GAMEPLAY_TIME, "CLASSIC MODE", currentMap);
                    elseif tostring(SelectedMode) == "RACE MODE" then
                        self.GameRound = RaceRound.new(GAMEPLAY_TIME, "RACE MODE", currentMap);
                    elseif tostring(SelectedMode) == "DOMINATION" then
                        self.GameRound = DominationRound.new(HILL_TIME, "DOMINATION", currentMap);
                    elseif tostring(SelectedMode) == "INFECTION MODE" then
                        self.GameRound = InfectionRound.new(GAMEPLAY_TIME, "INFECTION MODE", currentMap);
                    elseif tostring(SelectedMode) == "HOT POTATO" then
                        self.GameRound = HotPotatoRound.new(GAMEPLAY_TIME, "HOT POTATO", currentMap);
                    elseif tostring(SelectedMode) == "DUCK OF THE HILL" then
                        self.GameRound = KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap);
                    elseif tostring(SelectedMode) == "TILE FALLING" then
                        self.GameRound = TileFallingRound.new(HILL_TIME, "TILE FALLING", currentMap);
                    else
                        self.GameRound = KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap);
                    end
                end
                
                --// Game Round Ended
                print("[GameService]: Gameplay Ended")
                self:SetState(GAMESTATE.ENDED)

                GameService:SetLighting("Lobby")

                Players.RespawnTime = 1.3;
                --// @todo: Display Winner goes here after map cutscene ends
                --Knit.Services.WinService:DisplayWinner();

                -- Fire results UI
                print("[GameService]: Firing results UI")
                for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
                    if self.PlayersTracked[player.UserId] then
                        self.PlayersTracked[player.UserId]:UpdateResults(player)
                        self.Client.ResultSignal:Fire(player, self.PlayersTracked[player.UserId]:GetPlayerStats(player))
                        local profile = Knit.DataService:GetProfile(player)
                        if profile then
                            RewardService:GiveReward(profile, {
                                Coins = self.PlayersTracked[player.UserId]:GetPlayerStats(player).CoinsEarned;
                            })
                        end
                        self.PlayersTracked[player.UserId]:Destroy();
                        self.PlayersTracked[player.UserId] = nil;
                    end
                end

                self.PlayersTracked = {};

                local TournamentWinner = false;

                if self.IsTournament == true then
                    if #Players:GetPlayers() - #CollectionService:GetTagged(Knit.Config.GHOST_TAG) == 1 then
                        TournamentWinner = true;
                    end
                end
                
                -- Award Winners
                print("[GameService]: Awarding winners a win")
                for _, player in pairs(game.Players:GetPlayers()) do
                    if CollectionService:HasTag(player, Knit.Config.AFK_TAG) == true or CollectionService:HasTag(player, Knit.Config.GHOST_TAG) == true then
                        continue;
                    end

                    local profile = Knit.DataService:GetProfile(player)
                    if CollectionService:HasTag(player , Knit.Config.WINNER_TAG) then
                        if profile then
                            if profile.Data.PlayerInfo.TotalWins == nil then
                                profile.Data.PlayerInfo.TotalWins = 1
                            else
                                profile.Data.PlayerInfo.TotalWins += 1
                            end
                        end
                        player:WaitForChild("leaderstats"):WaitForChild("Wins").Value = profile.Data.PlayerInfo.TotalWins;
                    else
                        if profile then
                            if profile.Data.PlayerInfo.TotalLosses == nil then
                                profile.Data.PlayerInfo.TotalLosses = 1
                            else
                                profile.Data.PlayerInfo.TotalLosses += 1
                            end
                        end
                    end

                    if TournamentWinner == true then
                        if CollectionService:HasTag(player, Knit.Config.AFK_TAG) == false and CollectionService:HasTag(player, Knit.Config.GHOST_TAG) == false then
                            TournamentService:WinnerSelected(player);
                        end
                    end
                end
                
                if self.GameRound ~= nil then
                    self.GameRound:Destroy();
                end

                for _, player in pairs(game.Players:GetPlayers()) do
                    player.Backpack:ClearAllChildren()
                    CollectionService:RemoveTag(player, Knit.Config.ALIVE_TAG)
                    CollectionService:RemoveTag(player, Knit.Config.WINNER_TAG)
                    CollectionService:RemoveTag(player, Knit.Config.HUNTER_TAG)
                    CollectionService:RemoveTag(player, Knit.Config.DUCK_TAG)
                    CollectionService:RemoveTag(player, Knit.Config.BREAD_TAG);
                    self.GetCurrentHunters[player] = nil;
                    self.GetCurrentHunters = nil;
                    self.GetCurrentHunters = {};
                end
                self.Client.AdjustDashCooldown:FireAll(adjustCooldown(1,2.5, (Players.MaxPlayers / 2) / Players.MaxPlayers));
                self.Client.AdjustClickCooldown:FireAll(adjustCooldown(0.35, 1, (Players.MaxPlayers / 2) / Players.MaxPlayers));
                
                if TournamentWinner == true then
                    break; -- End the tournament
                end
                
                task.wait(3)
            else
                warn("[GameService]: There no more game modes");
                self.Finished:Fire();
            end
        end
    end
end


function GameService:KnitInit()
    print("[SERVICE]: GameService initialized")

    local Zone = require(Knit.ReplicatedModules.Zone)
    local arenaContainer = workspace.Lobby.Arena
    local arenaZone = Zone.new(arenaContainer)

    arenaZone.playerEntered:Connect(function(player)
        CollectionService:AddTag(player, Knit.Config.ARENA_TAG);
		Knit.AvatarService.Client.CreateB:FireAll(player)
    end)
    
    arenaZone.playerExited:Connect(function(player)
        CollectionService:RemoveTag(player, Knit.Config.ARENA_TAG);
        Knit.AvatarService.Client.RemoveB:FireAll(player)
    end)

    self.Client.BoostCheck:Connect(function(player, mapName)
        print(player, mapName)
        if player and mapName then
            local mapTitle = SystemInfo.getMapTitleFromName(mapName)
            --print(mapTitle)
            if mapTitle then
                nextMap = mapTitle
                boostedMap = true;
            end
    
            self.Client.UpdateMapQueue:FireAll({
                CurrentMap = currentMap,
                NextMap = nextMap,
                Boosted = boostedMap,
            });
        end
    end)

    self.Client.ToolAttack:Connect(function(player)
        if Cooldown[player] == nil then
            Cooldown[player] = false;
        end
        
        if Cooldown[player] == false then
            task.spawn(function()
                Cooldown[player] = true;
                task.spawn(function()
                    local BreadTool = player.Character:FindFirstChild("BHitbox")
                    if BreadTool then
                        self.Client.ToolAttack:FireAll(player);
                        PartTouchConnections[player.UserId] = BreadTool.Touched:Connect(function(part)
                            local Player = game.Players:GetPlayerFromCharacter(part.Parent)
                            if Player and (Player ~= player) then
                                if CollectionService:HasTag(Player, Knit.Config.RED_TEAM) == true 
                                and CollectionService:HasTag(player, Knit.Config.RED_TEAM) == true then
                                    return;
                                end
                                if CollectionService:HasTag(Player, Knit.Config.BLUE_TEAM) == true 
                                and CollectionService:HasTag(player, Knit.Config.BLUE_TEAM) == true then
                                    return;
                                end
                                if CollectionService:HasTag(Player, Knit.Config.ARENA_TAG) == true or CollectionService:HasTag(Player, Knit.Config.BREAD_TAG) == true then
                                    if PartTouchCooldown[Player] == nil then
                                        PartTouchCooldown[Player] = false;
                                    end
                                    if PartTouchCooldown[Player] == false then
                                        PartTouchCooldown[Player] = true; 
                                        local TargetCharacter = Player.Character;
                                        if TargetCharacter then
                                            local Magnitude = (TargetCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude 
                                            if Magnitude < 7 then
                                                self.Client.HEffect:FireAll(player, Player);
                                                local velocity = Instance.new("BodyVelocity")
                                                if CollectionService:HasTag(player, Knit.Config.ALIVE_TAG) then
                                                    if TargetCharacter:FindFirstChild("KillerTag") then
                                                        TargetCharacter:FindFirstChild("KillerTag").Value = player;
                                                    else
                                                        local killerTag = Instance.new("ObjectValue")
                                                        killerTag.Name = "KillerTag";
                                                        killerTag.Value = player;
                                                        killerTag.Parent = TargetCharacter;
                                                        Debris:AddItem(killerTag, 5);
                                                    end
                                                end
                                                
                                                velocity.MaxForce = Vector3.new(100000,100000,100000)
                                                velocity.P = 1000
                                                local angle = ((TargetCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position) * Vector3.new(10,0,10)).Unit * 70 + Vector3.new(0,5,0)
                                                velocity.Velocity = angle
                                                velocity.Parent = TargetCharacter.HumanoidRootPart
                                                Debris:AddItem(velocity,.3)
                                            end
                                        end
                                        task.wait(0.5)
                                        PartTouchCooldown[Player] = false;
                                    end
                                end
                            end
                        end)
                    end
                    task.wait(.35);
                    if PartTouchConnections[player.UserId] then
                        PartTouchConnections[player.UserId]:Disconnect();
                        PartTouchConnections[player.UserId] = nil;
                    end
                end)
                task.wait(.35);
                Cooldown[player] = false;
            end)
        end
    end)

    self.Client.ChangeSetting:Connect(function(player, SettingName, Option)
        --print(player, SettingName, Option)
        self:ChangeSetting(player, SettingName, Option);
    end)

    self.Client.SetIdle:Connect(function(player)
        CollectionService:AddTag(player, Knit.Config.IDLE_TAG)
    end)
end


function GameService:KnitStart()
    local GetTournamentStatus = Knit.GetService("TournamentService"):GetIfTournament();
    self:StartGame(GetTournamentStatus);
end

return GameService