----- Services -----
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Intermission = require(Knit.Modules.Intermission);
local TableUtil = require(Knit.Util.TableUtil);
--local RewardService = require(Knit.Services.RewardService);

----- Settings -----
local GAMESTATE = Knit.Config.GAME_STATES;
local GAMEPLAY_TIME = Knit.Config.DEFAULT_SANDBOX_TIME;
local NIGHT_TIME = Knit.Config.DEFAULT_NIGHT_TIME;
local INTERMISSION_TIME = Knit.Config.DEFAULT_INTERMISSION_TIME;
local MAPS = Knit.Config.MAPS;

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

local SandboxMode = Knit.CreateService {
    Name = "SandboxMode",
    Client = {},
}

----- Sandbox Mode -----
SandboxMode.numOfDays = 0;

SandboxMode.Intermission = nil;
SandboxMode.PreviousMap = nil;
SandboxMode.PreviousMode = nil;
SandboxMode.GameMode = nil;

SandboxMode.percentageTillNight = 90; --// 10%


-- Initialize the maps and modes in sorted Tables

for _, mapData in pairs(copiedMaps) do
    sortedMaps[#sortedMaps + 1] = { name = mapData.MapName, chance = math.random(1, 10) / 10 } -- 0.1 - 1
end

table.sort(sortedMaps, function(itemA, itemB) return itemA.chance > itemB.chance end)

-- Private Functions
local startPercent, endPercent, dayStartShift, dayEndShift = 0, 1, Knit.Config.DAY_START_SHIFT, Knit.Config.DAY_END_SHIFT; -- 9 am to 5 pm
local nightStartShift, nightEndShift = Knit.Config.NIGHT_START_SHIFT, Knit.Config.NIGHT_END_SHIFT; -- 12 am to 6 am
-- f(x)=b(x−min)+a(max−x) / max−min
-- m+t/10(M−m)

local function formatTime(timeVal)
    local split = tostring(timeVal):split('.')
    local hour = (tonumber(split[1]) ~= nil and tonumber(split[1])) or timeVal;
    local min = (tonumber(split[2]) ~= nil and tonumber(split[2])) or 0;

    min = (min / 100) * 60;

    local period = "AM"

    if hour >= 12 then
        period = "PM"
        hour = hour ~= 12 and hour - 12 or hour
    end

    if hour == 0 then
        hour = 12
    end

    return string.format("%d:%02d %s", hour, min, period)
    --return string.format("%.2d:%.2d %s", hour, min, period)
end

local function dayShiftHours(timeVal)
    --print(timeVal, startPercent, endPercent, dayStartShift, dayEndShift)
    return (dayStartShift + (timeVal / endPercent) * (dayEndShift - dayStartShift));
    --return (((endPercent * (timeVal - dayStartShift)) + (startPercent * (dayEndShift - timeVal))) / (dayEndShift - dayStartShift));
end

local function nightShiftHours(timeVal)
    return (nightStartShift + (timeVal / endPercent) * (nightEndShift - nightStartShift));
end

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

function SandboxMode:StartMode()
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
        --self.Intermission = Intermission.new(INTERMISSION_TIME, self.numOfDays);

        --// Intermission Ended
        print("[GameService]: Intermission Ended")

        task.wait(5)

        GameService:SetState(GAMESTATE.GAMEPLAY)
        print("[GameService]: Gameplay Starting soon, getting map mode")

        --[[for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            GameService:AddTracker(player)
        end]]

        --currentMap = getRandomMap();

        print("MAP;", currentMap, nextMap)

        GameService.Client.UpdateMapQueue:FireAll({
            CurrentMap = currentMap,
            NextMap = nextMap,
            Boosted = boostedMap,
        });

        boostedMap = false
        
        print("[GameService]: Gameplay Started")

        -- change map and spawn players 

        --[[local RiseTween = TweenInfo.new(GAMEPLAY_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut);
        local TweenModule = require(Knit.ReplicatedModules.TweenUtil);

        local TimeTween = TweenModule.new(RiseTween, function(Alpha)
            print(Alpha)
            local currentTime = dayShiftHours((Alpha))
            print("currentTime", formatTime(string.format("%.2f", currentTime)))
        end)]]

        for i = 0, GAMEPLAY_TIME do
            local currentTime = dayShiftHours((i / GAMEPLAY_TIME))
            GameService.Client.AdjustTimeSignal:FireAll({
                Day = self.numOfDays,
                Time = formatTime(string.format("%.2f", currentTime)),
                IsNight = false,
            });
            print("Day:", self.numOfDays ,"| Time:", formatTime(string.format("%.2f", currentTime)))
            task.wait(1)
        end

        local Synced = require(Knit.ReplicatedModules.Synced);
        local DailyShopOffset = (60 * 60 * Knit.Config.DAILY_SHOP_OFFSET); 
        local Day = math.floor((Synced.time() + DailyShopOffset) / (60 * 60 * 24))
        local seed = Random.new(Day);

        local weightNumber = seed:NextNumber(0, 100);

        if weightNumber <= self.percentageTillNight then
            warn("OOO SPOOKY NIGHT")
            self.percentageTillNight = 2;
            for i = 0, NIGHT_TIME do
                local currentTime = nightShiftHours((i / NIGHT_TIME))
                GameService.Client.AdjustTimeSignal:FireAll({
                    Day = self.numOfDays,
                    Time = formatTime(string.format("%.2f", currentTime)),
                    IsNight = true,
                });
                print("Night:", self.numOfDays ,"| Time:", formatTime(string.format("%.2f", currentTime)))
                task.wait(1)
            end
        else
            self.percentageTillNight += 10;
        end
        
        --TimeTween:Play();
        --TimeTween.Completed:Wait();

        --// Game Round Ended
        print("[GameService]: Gameplay Ended")
        GameService:SetState(GAMESTATE.ENDED)

        self.numOfDays += 1;

        --[[GameService:SetLighting("Lobby")

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
        end]]
    end
end

function SandboxMode:KnitStart()
    
end


function SandboxMode:KnitInit()
    
end


return SandboxMode
