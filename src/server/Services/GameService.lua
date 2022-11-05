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
local SandboxMode = require(Knit.ServerModules.Modes.ClassicRound);
local RoundMode = require(Knit.ServerModules.Modes.RaceRound);

----- Settings -----
local GAMESTATE = Knit.Config.GAME_STATES;
local SANDBOX_TIME = Knit.Config.DEFAULT_SANDBOX_TIME;
local ROUND_TIME = Knit.Config.DEFAULT_ROUND_TIME;
local INTERMISSION_TIME = Knit.Config.DEFAULT_INTERMISSION_TIME;
local MAPS = Knit.Config.MAPS;

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

-- MAP SELECTING
local sortedMaps = {}
local CopiedMaps = TableUtil.Copy(MAPS);

GameService.Intermission = nil;
GameService.GameRound = nil;

GameService.PlayersTracked = {};
GameService.GameState = nil;
GameService.SetGameplay = false;

local currentMap = nil;
local nextMap = nil;

local currentMode = "Sandbox";

local customMap = nil;

local numOfIntermissions = 0;

customMap = Knit.Config.CUSTOM_MAP;

function GameService:GetGameRound()
    return self.GameRound;
end

function GameService:SetGameRound(gameMode)
    self.GameRound = gameMode;
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
        --ModeData = sortedModes,
    }
end

function GameService:GetPlayerTracked(player)
    if player and self.PlayersTracked[player.UserId] then
        return self.PlayersTracked[player.UserId];
    else
        return nil;
    end
end

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

if customMap ~= nil then
    nextMap = customMap;
else
    nextMap = getRandomMap();
end

function GameService:StartGame(DeveloperEnabled : boolean)

    task.wait(15);

    while true do
        --// Intermission Started
        print("[GameService]: Intermission Started")
        self:SetState(GAMESTATE.INTERMISSION)
        self.Client.UpdateMapQueue:FireAll({
            CurrentMap = currentMap,
            NextMap = nextMap,
            --Boosted = boostedMap,
        });

        Cooldown = {};
        PartTouchCooldown = {};
        PartTouchConnections = {};
        self.PlayersTracked = {};

        self.Intermission = Intermission.new(INTERMISSION_TIME, numOfIntermissions);
        numOfIntermissions += 1;
        
        --// Intermission Ended
        print("[GameService]: Intermission Ended")

        task.wait(3)

        self:SetState(GAMESTATE.GAMEPLAY)
        print("[GameService]: Gameplay Starting soon")

        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            self.PlayersTracked[player.UserId] = PlayerTrack.new(player);
        end

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

        if tostring(currentMode) == "Round" then
            self.GameRound = RoundMode.new(ROUND_TIME, numOfIntermissions, currentMap);
        else
            self.GameRound = SandboxMode.new(SANDBOX_TIME, numOfIntermissions, currentMap);
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

        -- Award Winners
        print("[GameService]: Awarding winners a win")
        
        task.wait(3)
    end
end


function GameService:KnitInit()
    print("[SERVICE]: GameService initialized")

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

    self.Client.ChangeSetting:Connect(function(player, SettingName, Option)
        --print(player, SettingName, Option)
        self:ChangeSetting(player, SettingName, Option);
    end)

end


function GameService:KnitStart()
    self:StartGame(false);
end

return GameService