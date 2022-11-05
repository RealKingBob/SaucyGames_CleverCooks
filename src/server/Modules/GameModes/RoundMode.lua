----- Services -----
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Intermission = require(Knit.ServerModules.Intermission);
local Signal = require(Knit.Util.Signal);
local TableUtil = require(Knit.Util.TableUtil);
local PlayerTrack = require(Knit.ServerModules.PlayerTrack);
local RewardService = require(Knit.Services.RewardService);

----- Settings -----
local GAMESTATE = Knit.Config.GAME_STATES;
local GAMEPLAY_TIME = Knit.Config.DEFAULT_GAMEPLAY_TIME;
local HILL_TIME = Knit.Config.DEFAULT_HILL_TIME;
local INTERMISSION_TIME = Knit.Config.DEFAULT_INTERMISSION_TIME;
local GAMEMODES = Knit.Config.GAMEMODES;
local MAPS = Knit.Config.MAPS;

local TEAM_BASE_MODES = Knit.Config.TEAM_BASE_MODES;
local INDIVIDUAL_MODES = Knit.Config.INDIVIDUAL_MODES;
local FINAL_MODES = Knit.Config.FINAL_MODES;

----- Individual Game Modes -----
local IndividualModes = Knit.ServerModules.ModeAssets.IndividualModes;
local I_ClassicRound = require(IndividualModes.ClassicRound);
local I_DeformedRound = require(IndividualModes.DeformedRound);
local I_HotPotatoRound = require(IndividualModes.HotPotatoRound);
local I_InfectionRound = require(IndividualModes.InfectionRound);
local I_KOTHRound = require(IndividualModes.KOTHRound);
local I_RaceRound = require(IndividualModes.RaceRound);
--local I_RightLightGreenLightRound = require(IndividualModes.RightLightGreenLightRound);


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

local sortedTeamModes = {}
local copiedTeamModes = TableUtil.Copy(TEAM_BASE_MODES);

local sortedIndividualModes = {}
local copiedIndividualModes = TableUtil.Copy(INDIVIDUAL_MODES);

local sortedFinalModes = {}
local copiedFinalModes = TableUtil.Copy(FINAL_MODES);

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

local NormalMode = Knit.CreateService {
    Name = "NormalMode",
    Client = {},
}

----- Normal Mode -----
NormalMode.numOfIntermissions = 0;

NormalMode.Intermission = nil;
NormalMode.PreviousMap = nil;
NormalMode.PreviousMode = nil;
NormalMode.GameMode = nil;

-- Initialize the maps and modes in sorted Tables

for _, mapData in pairs(copiedMaps) do
    sortedMaps[#sortedMaps + 1] = { name = mapData.MapName, chance = math.random(1, 10) / 10 } -- 0.1 - 1
end
for _, modeData in pairs(copiedTeamModes) do
    sortedTeamModes[#sortedTeamModes + 1] = { name = modeData.Mode, chance = math.random(1, 10) / 10 } -- 0.1 - 1
end
for _, modeData in pairs(copiedIndividualModes) do
    sortedIndividualModes[#sortedIndividualModes + 1] = { name = modeData.Mode, chance = math.random(1, 10) / 10 } -- 0.1 - 1
end
for _, modeData in pairs(copiedFinalModes) do
    sortedFinalModes[#sortedFinalModes + 1] = { name = modeData.Mode, chance = math.random(1, 10) / 10 } -- 0.1 - 1
end

table.sort(sortedMaps, function(itemA, itemB) return itemA.chance > itemB.chance end)
table.sort(sortedTeamModes, function(itemA, itemB) return itemA.chance > itemB.chance end)
table.sort(sortedIndividualModes, function(itemA, itemB) return itemA.chance > itemB.chance end)
table.sort(sortedFinalModes, function(itemA, itemB) return itemA.chance > itemB.chance end)

-- Private Functions

local function setupFinalMode(mode, gameRound)
    if mode == "TILE FALLING" then
        return F_TileFallingRound.new(GAMEPLAY_TIME, "TILE FALLING", currentMap, "FINAL ROUND")
    elseif mode == "RACE MODE" then

    end
    return F_TileFallingRound.new(GAMEPLAY_TIME, "TILE FALLING", currentMap, "FINAL ROUND")
end

local function setupTeamBasedMode(mode, gameRound)
    if mode == "DOMINATION" then
        return T_DominationRound.new(HILL_TIME, "DOMINATION", currentMap, "ROUND "..tostring(gameRound))
    elseif mode == "DODGEBALL" then
        
    elseif mode == "[TEAM] HOLE IN THE WALL" then

    elseif mode == "[TEAM] RACE MODE" then

    elseif mode == "PROTECT THE DUCK" then

    end
    return T_DominationRound.new(HILL_TIME, "DOMINATION", currentMap, "ROUND "..tostring(gameRound))
end

local function setupIndividualMode(mode, gameRound)
    if mode == "RACE MODE" then
        return I_RaceRound.new(GAMEPLAY_TIME, "RACE MODE", currentMap, "ROUND "..tostring(gameRound))
    elseif mode == "DUCK OF THE HILL" then
        return I_KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap, "ROUND "..tostring(gameRound))
    elseif mode == "HOT POTATO" then
        return I_HotPotatoRound.new(HILL_TIME, "HOT POTATO", currentMap, "ROUND "..tostring(gameRound))
    elseif mode == "CLASSIC MODE" then
        return I_ClassicRound.new(GAMEPLAY_TIME, "CLASSIC MODE", currentMap, "ROUND "..tostring(gameRound))
    elseif mode == "INFECTION MODE" then
        return I_InfectionRound.new(GAMEPLAY_TIME, "INFECTION MODE", currentMap, "ROUND "..tostring(gameRound))
    elseif mode == "DEFORMED MODE" then
        return I_DeformedRound.new(GAMEPLAY_TIME, "DEFORMED MODE", currentMap, "ROUND "..tostring(gameRound))
    end
    return I_KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap, "ROUND "..tostring(gameRound))
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

local function getRandomFinalMode()
    local random = math.random();
    local selectedMode = nil;

    for _, map in pairs(sortedFinalModes) do
        if random <= map.chance and selectedMode == nil then
            selectedMode = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMode == nil then
        table.sort(sortedFinalModes, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMode = sortedFinalModes[1].name;
        sortedFinalModes[1].chance = 0;
    end
    return selectedMode;
end

local function getRandomTeamMode()
    local random = math.random();
    local selectedMode = nil;

    for _, map in pairs(sortedTeamModes) do
        if random <= map.chance and selectedMode == nil then
            selectedMode = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMode == nil then
        table.sort(sortedTeamModes, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMode = sortedTeamModes[1].name;
        sortedTeamModes[1].chance = 0;
    end
    return selectedMode;
end

local function getRandomMode()
    local random = math.random();
    local selectedMode = nil;

    for _, map in pairs(sortedIndividualModes) do
        if random <= map.chance and selectedMode == nil then
            selectedMode = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMode == nil then
        table.sort(sortedIndividualModes, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMode = sortedIndividualModes[1].name;
        sortedIndividualModes[1].chance = 0;
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


function NormalMode:StartMode()
    print("NORMAL MODE STARTED")

    local GameService = Knit.GetService("GameService");
    local TournamentService = Knit.GetService("TournamentService");

    print("[GameService]: Intermission Started")
    Players.RespawnTime = 1.3;
    GameService:SetState(GAMESTATE.INTERMISSION)

    GameService.Client.UpdateMapQueue:FireAll({
        CurrentMap = currentMap,
        NextMap = nextMap,
        Boosted = boostedMap,
    });


    GameService:ClearCooldowns()
    GameService:ClearTracked()

    --[[task.spawn(function()
        task.wait(2);
        for index, value in ipairs(game.Players:GetPlayers()) do
            self:CreateBreadTool(value);
        end
    end)]]

    task.wait(5)

    --// Intermission Started
    self.Intermission = Intermission.new(INTERMISSION_TIME, true);
    self.numOfIntermissions += 1;

    --// Intermission Ended
    print("[GameService]: Intermission Ended, Checking if enough players")

    local TournamentWinner = false;

    local other1, other2;
    for gameRound = 1, 4 do
        task.wait(5)

        GameService:SetState(GAMESTATE.GAMEPLAY)
        print("[GameService]: Gameplay Starting soon, getting map mode")

        for _, player : Player in pairs(game.Players:GetPlayers()) do
            if CollectionService:HasTag(player, Knit.Config.GHOST_TAG) == false then
                CollectionService:AddTag(player, Knit.Config.ALIVE_TAG);
            end
        end

        if TournamentWinner == false then
            print("[GameService]: Getting all players that are not AFK")
            --// New Game Round
            for _, player : Player in pairs(game.Players:GetPlayers()) do
                CollectionService:RemoveTag(player, Knit.Config.LOBBY_TAG);
                CollectionService:RemoveTag(player, Knit.Config.BREAD_TAG);
            end

            if #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) == 0 then
                warn("GAME OVER, NO PLAYERS")
                break;
            end

            if #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) <= 2 then
                warn("MOVING TO FINAL ROUND")
                break;
            end

            for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
                GameService:AddTracker(player)
            end

            print("[GameService]: Adjusting all cooldown based off player amount")
            GameService.Client.AdjustDashCooldown:FireAll(adjustCooldown(1, 2, #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers));
            GameService.Client.AdjustClickCooldown:FireAll(adjustCooldown(0.35, 1, #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers));
            GameService:AdjustWeapons();
            --self.GameRound = ClassicRound.new(GAMEPLAY_TIME, "CLASSIC MODE");

            --[[if customMap ~= nil then
                currentMap = customMap
                nextMap = customMap
            else
                currentMap = nextMap;
                nextMap = getRandomMap();
            end ]]

            currentMap = getRandomMap();

            print("MAP;", currentMap, nextMap)

            GameService.Client.UpdateMapQueue:FireAll({
                CurrentMap = currentMap,
                NextMap = nextMap,
                Boosted = boostedMap,
            });

            boostedMap = false
            
            print("[GameService]: Gameplay Started")
            
            
            if gameRound == 1 then -- TEAM, 50%
                currentMode = getRandomTeamMode();
                self.GameRound = setupTeamBasedMode(currentMode, gameRound);

            elseif gameRound == 2 then -- TEAM, 50%
                currentMode = getRandomTeamMode();
                self.GameRound = setupTeamBasedMode(currentMode, gameRound);

            elseif gameRound == 3 then -- Individual, 60%
                currentMode = getRandomMode();
                self.GameRound = setupIndividualMode(currentMode, gameRound);

            elseif gameRound == 4 then -- Individual, 70%
                currentMode = getRandomMode();
                self.GameRound = setupIndividualMode(currentMode, gameRound);

            else
                self.GameRound = I_KOTHRound.new(HILL_TIME, "DUCK OF THE HILL", currentMap, "ROUND "..tostring(gameRound));
            end
            
            --// Game Round Ended
            print("[GameService]: Gameplay Ended")
            GameService:SetState(GAMESTATE.ENDED)

            GameService:SetLighting("Lobby")

            Players.RespawnTime = 1.3;
            --// @todo: Display Winner goes here after map cutscene ends
            --Knit.Services.WinService:DisplayWinner();

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

            if GameService.IsTournament == true then
                if #Players:GetPlayers() - #CollectionService:GetTagged(Knit.Config.GHOST_TAG) == 1 then
                    TournamentWinner = true;
                end
            end
            
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

                -- check if thats a winner
                if TournamentWinner == true then
                    if CollectionService:HasTag(player, Knit.Config.GHOST_TAG) == false then
                        if #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) == 1 then
                            TournamentService:WinnerSelected(player);

                            if profile then
                                if profile.Data.PlayerInfo.TournamentWins == nil then
                                    profile.Data.PlayerInfo.TournamentWins = 1
                                else
                                    profile.Data.PlayerInfo.TournamentWins += 1
                                end
                            end
                        end
                        
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
                GameService.GetCurrentHunters[player] = nil;
                GameService.GetCurrentHunters = nil;
                GameService.GetCurrentHunters = {};
            end
            GameService.Client.AdjustDashCooldown:FireAll(adjustCooldown(1,2.5, (Players.MaxPlayers / 2) / Players.MaxPlayers));
            GameService.Client.AdjustClickCooldown:FireAll(adjustCooldown(0.35, 1, (Players.MaxPlayers / 2) / Players.MaxPlayers));
            
            if TournamentWinner == true then
                warn("end the tournament")
                break; -- End the tournament
            end
            
            task.wait(3)
        else
            warn("[GameService]: There no more game modes");
            self.Finished:Fire();
        end
    end

    print("tournament check if complete:", TournamentWinner)

    if TournamentWinner == false then

        for _, player : Player in pairs(game.Players:GetPlayers()) do
            CollectionService:RemoveTag(player, Knit.Config.LOBBY_TAG);
            CollectionService:RemoveTag(player, Knit.Config.BREAD_TAG);
        end

        currentMap = getRandomMap();

        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            GameService:AddTracker(player)
        end

        print("[GameService]: Adjusting all cooldown based off player amount")
        GameService.Client.AdjustDashCooldown:FireAll(adjustCooldown(1, 2, #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers));
        GameService.Client.AdjustClickCooldown:FireAll(adjustCooldown(0.35, 1, #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) / Players.MaxPlayers));
        GameService:AdjustWeapons();

        currentMode = getRandomFinalMode();
        self.GameRound = setupFinalMode(currentMode, "FINAL ROUND");

        --// Game Round Ended
        print("[GameService]: Gameplay Ended")
        GameService:SetState(GAMESTATE.ENDED)

        GameService:SetLighting("Lobby")

        Players.RespawnTime = 1.3;
        --// @todo: Display Winner goes here after map cutscene ends
        --Knit.Services.WinService:DisplayWinner();

        print("IF ", #CollectionService:GetTagged(Knit.Config.WINNER_TAG))

        if #CollectionService:GetTagged(Knit.Config.WINNER_TAG) == 1 then
            TournamentWinner = true;
            local player = CollectionService:GetTagged(Knit.Config.WINNER_TAG)[1]

            TournamentService:WinnerSelected(player);
            local profile = Knit.DataService:GetProfile(player)

            if profile then
                if profile.Data.PlayerInfo.TournamentWins == nil then
                    profile.Data.PlayerInfo.TournamentWins = 1
                else
                    profile.Data.PlayerInfo.TournamentWins += 1
                end
            end
        end

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

        if self.GameRound ~= nil then
            self.GameRound:Destroy();
        end

        for _, player in pairs(game.Players:GetPlayers()) do
            player.Backpack:ClearAllChildren()
            CollectionService:RemoveTag(player, Knit.Config.ALIVE_TAG)
            CollectionService:RemoveTag(player, Knit.Config.WINNER_TAG)
            CollectionService:RemoveTag(player, Knit.Config.HUNTER_TAG)
            CollectionService:RemoveTag(player, Knit.Config.DUCK_TAG)
            --CollectionService:RemoveTag(player, Knit.Config.BREAD_TAG);
            GameService.GetCurrentHunters[player] = nil;
            GameService.GetCurrentHunters = nil;
            GameService.GetCurrentHunters = {};
        end

        
    end

    if self.SetGameplay == true then

        warn("[GameService]: TOURNAMENT ENDED");
    end
end

function NormalMode:KnitStart()
    
end


function NormalMode:KnitInit()
    
end


return NormalMode
