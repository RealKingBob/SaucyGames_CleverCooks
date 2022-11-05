----- Services -----
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Intermission = require(Knit.ServerModules.Intermission);
local TableUtil = require(Knit.Util.TableUtil);
local RewardService = require(Knit.Services.RewardService);

----- Settings -----
local GAMESTATE = Knit.Config.GAME_STATES;
local GAMEPLAY_TIME = Knit.Config.DEFAULT_SANDBOX_TIME;
local INTERMISSION_TIME = Knit.Config.DEFAULT_INTERMISSION_TIME;
local MAPS = Knit.Config.MAPS;

----- Team Based Modes -----
local TeamModes = Knit.ServerModules.ModeAssets.TeamModes;
local T_DominationRound = require(TeamModes.DominationRound);


----- Final Modes -----
local FinalModes = Knit.ServerModules.ModeAssets.FinalModes;
local F_TileFallingRound = require(FinalModes.TileFallingRound);


-- Tables
local Cooldown = {};
local PartTouchCooldown = {};
local PartTouchConnections = {};

local AlreadyUsedModes = {};

-- MAP SELECTING & GAMEMODES
local sortedMaps = {}
local copiedMaps = TableUtil.Copy(MAPS);

local currentMap = nil;
local nextMap = nil;
local boostedMap = false;

local customMap = nil;
local customMode = nil;

customMap = Knit.Config.CUSTOM_MAP;
customMode = Knit.Config.CUSTOM_MODE;

local NormalMode = Knit.CreateService {
    Name = "NormalMode",
    Client = {},
}

----- Normal Mode -----
NormalMode.numOfDays = 0;

NormalMode.Intermission = nil;
NormalMode.PreviousMap = nil;
NormalMode.PreviousMode = nil;
NormalMode.GameMode = nil;

-- Initialize the maps and modes in sorted Tables

for _, mapData in pairs(copiedMaps) do
    sortedMaps[#sortedMaps + 1] = { name = mapData.MapName, chance = math.random(1, 10) / 10 } -- 0.1 - 1
end

table.sort(sortedMaps, function(itemA, itemB) return itemA.chance > itemB.chance end)

-- Private Functions
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

local function adjustCooldown(min, max, alpha)
    return min + (max - min) * alpha
end

if customMap ~= nil then
    nextMap = customMap;
else
    nextMap = getRandomMap();
end

function NormalMode:StartMode()
    print("SANDBOX MODE STARTED")

    local GameService = Knit.GetService("GameService");

    print("[GameService]: Intermission Started")

    while true do
        GameService:SetState(GAMESTATE.INTERMISSION)

        GameService.Client.UpdateMapQueue:FireAll({
            CurrentMap = currentMap,
            NextMap = nextMap,
            Boosted = boostedMap,
        });

        GameService:ClearCooldowns()
        GameService:ClearTracked()

        task.wait(5)

        --// Intermission Started
        self.Intermission = Intermission.new(INTERMISSION_TIME, self.numOfDays);
        self.numOfDays += 1;

        --// Intermission Ended
        print("[GameService]: Intermission Ended")

        task.wait(5)

        GameService:SetState(GAMESTATE.GAMEPLAY)
        print("[GameService]: Gameplay Starting soon, getting map mode")

        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            GameService:AddTracker(player)
        end

        currentMap = getRandomMap();

        print("MAP;", currentMap, nextMap)

        GameService.Client.UpdateMapQueue:FireAll({
            CurrentMap = currentMap,
            NextMap = nextMap,
            Boosted = boostedMap,
        });

        boostedMap = false
        
        print("[GameService]: Gameplay Started")

        -- change map and spawn players 

        --// Game Round Ended
        print("[GameService]: Gameplay Ended")
        GameService:SetState(GAMESTATE.ENDED)

        GameService:SetLighting("Lobby")

        -- Fire results UI
        print("[GameService]: Firing results UI")
        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            if GameService:GetPlayerTracked(player) then
                print("Track:", GameService:GetPlayerTracked(player):GetPlayerStats(player), GameService:GetPlayerTracked(player):GetSecondsPlayed(player))
                GameService:GetPlayerTracked(player):UpdateResults(player)
                GameService.Client.ResultSignal:Fire(player, GameService:GetPlayerTracked(player):GetPlayerStats(player))
                local profile = Knit.DataService:GetProfile(player)
                if profile then
                    RewardService:GiveReward(profile, {
                        Coins = GameService:GetPlayerTracked(player):GetPlayerStats(player).CoinsEarned;
                    })
                end
                GameService:GetPlayerTracked(player):Destroy();
                GameService:ClearTracked(player)
            end
        end

        GameService:ClearTracked()

        -- Award Winners
        print("[GameService]: Awarding winners a win")
        for _, player in pairs(game.Players:GetPlayers()) do
            if  CollectionService:HasTag(player, Knit.Config.GHOST_TAG) == true then
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
        end
    end
end

function NormalMode:KnitStart()
    
end


function NormalMode:KnitInit()
    
end


return NormalMode
