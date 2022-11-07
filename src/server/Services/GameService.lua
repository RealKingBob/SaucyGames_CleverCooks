----- Services -----
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CollectionService = game:GetService("CollectionService");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal);
local PlayerSettings = require(Knit.ReplicatedModules.SettingsUtil);
local SystemInfo = require(Knit.ReplicatedAssets.SystemInfo);

----- Tournament Modes -----
local SandboxMode = require(Knit.Modules.GameModes.SandboxMode);
--local RoundMode = require(Knit.Modules.GameModes.RoundMode);

----- Settings -----

----- GameService -----
local GameService = Knit.CreateService {
    Name = "GameService";
    TimeLeft = Signal.new();
    Client = {
        SetEnvironmentSignal = Knit.CreateSignal();
        AdjustTimeSignal = Knit.CreateSignal();
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

        UpdateWinner = Knit.CreateSignal();
    };
}

----- GameService -----
-- Tables
local Cooldown = {};
local PartTouchCooldown = {};
local PartTouchConnections = {};

GameService.Intermission = nil;
GameService.PreviousMap = nil;
GameService.PreviousMode = nil;
GameService.GameMode = nil;

GameService.PlayersTracked = {};
GameService.GetCurrentHunters = {};
GameService.GameState = nil;
GameService.SetGameplay = false;

GameService.IsTournament = false;
GameService.TournamentMode = nil;


local currentMap = nil;
local nextMap = nil;
local boostedMap = false;

local currentMode = nil;
local nextMode = nil;
local boostedMode = false;

local customMap = nil;
local customMode = nil;

customMap = Knit.Config.CUSTOM_MAP;
customMode = Knit.Config.CUSTOM_MODE;

function GameService:ClearCooldowns()
    Cooldown = {};
    PartTouchCooldown = {};
    PartTouchConnections = {};
    return
end

function GameService:GetGameRound()
    return self.GameRound;
end

function GameService:SetGameRound(gameMode)
    self.GameRound = gameMode;
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
        --MapData = sortedMaps,
        --ModeData = sortedModes,
    }
end

function GameService:ClearTracked(player)
    if player then
        if self.PlayersTracked[player.UserId] then
            self.PlayersTracked[player.UserId] = nil
            return
        end
    end
    self.PlayersTracked = {};
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
    print(CurrentMapName)
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
    if SettingName == "Music" then
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

if customMap ~= nil then
    nextMap = customMap;
else
    --nextMap = getRandomMap();
end

if customMode ~= nil then
    nextMode = customMode;
else
    --nextMode = getRandomMode();
end

function GameService:StartGame(gamemode : string)
    if gamemode == "Round" then
        --self.GameMode = RoundMode:StartMode();
    else
        self.GameMode = SandboxMode:StartMode();
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
    task.wait(5)
    self:StartGame();
end

return GameService