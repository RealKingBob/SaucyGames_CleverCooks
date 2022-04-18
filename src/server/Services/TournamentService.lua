local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TableUtil = require(Knit.Util.TableUtil);

local TournamentService = Knit.CreateService {
    Name = "TournamentService";
    Client = {
        QueueStatus = Knit.CreateSignal();
        MatchFound = Knit.CreateSignal();
    };
}

local TOURNAMENT_GAMEMODES = Knit.Config.T_GAMEMODES;
local TOURNAMENT_MAPS = Knit.Config.T_MAPS;

TournamentService.IsGameServer = false;

TournamentService.gameData = nil;

TournamentService.sortedTournamentModes = {}
TournamentService.CopiedTournamentModes = TableUtil.Copy(TOURNAMENT_GAMEMODES);

TournamentService.sortedTournamentMaps = {}
TournamentService.CopiedTournamentMaps = TableUtil.Copy(TOURNAMENT_MAPS);

TournamentService.PlayersAddedToQueue = {}
TournamentService.PlayersPendingToQueue = {}

CollectionService:GetInstanceAddedSignal(Knit.Config.GHOST_TAG):Connect(function(Object)
    print(Object)
    if Object:IsA("Player") then
        if Object.Character then
            Object.Character:Destroy();
            print("u a ghost")
        end
    end
end)

function TournamentService:sortTournamentMapsAndModes()
    for _, mapData in pairs(self.CopiedTournamentMaps) do
        self.sortedTournamentMaps[#self.sortedTournamentMaps + 1] = {
            name = mapData.MapName,
            chance = math.random(1, 10) / 10 -- 0.1 - 1
        }
    end
    
    for _, modeData in pairs(self.CopiedTournamentModes) do
        self.sortedTournamentModes[#self.sortedTournamentModes + 1] = {
            name = modeData.Mode,
            chance = math.random(1, 10) / 10 -- 0.1 - 1
        }
    end
    
    table.sort(self.sortedTournamentMaps, function(itemA, itemB)
        return itemA.chance > itemB.chance
    end)
    
    table.sort(self.sortedTournamentModes, function(itemA, itemB)
        return itemA.chance > itemB.chance
    end)
end

function TournamentService:getRandomTournamentMap()
    local random = math.random();
    local selectedMap = nil;

    for _, map in pairs(self.sortedTournamentMaps) do
        if random <= map.chance and selectedMap == nil then
            selectedMap = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMap == nil then
        table.sort(self.sortedTournamentMaps, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMap = self.sortedTournamentMaps[1].name;
        self.sortedTournamentMaps[1].chance = 0;
    end
    return selectedMap;
end

function TournamentService:getRandomTournamentMode()
    local random = math.random();
    local selectedMode = nil;

    for _, map in pairs(self.sortedTournamentModes) do
        if random <= map.chance and selectedMode == nil then
            selectedMode = map.name;
            map.chance = -0.1;
        end
        map.chance += 0.1;
    end

    if selectedMode == nil then
        table.sort(self.sortedTournamentModes, function(itemA, itemB)
            return itemA.chance > itemB.chance
        end)
        selectedMode = self.sortedTournamentModes[1].name;
        self.sortedTournamentModes[1].chance = 0;
    end
    return selectedMode;
end

function TournamentService:GetIfTournament()
    return self.IsGameServer;
end

function TournamentService:WinnerSelected(Player : Player) 
    -- Do winner cutscene
    print(Player.Name .. " has won the tournament!")
end

function TournamentService:AddToVCQueue(Players : table)
    if self.PlayersAddedToQueue[Players[1].UserId] ~= nil then return false; end
    if self.PlayersPendingToQueue[Players[1].UserId] ~= nil then return false; end


    if self.PlayersPendingToQueue[Players[1].UserId] == nil then
        self.PlayersPendingToQueue[Players[1].UserId] = "Voicechat Tournament";
        for _, player in ipairs(Players) do
            self.Client.QueueStatus:Fire(player, "QueueStart", "Voicechat");
        end
    end

    task.wait(math.random(10,15))

    if self.PlayersPendingToQueue[Players[1].UserId] == "Voicechat Tournament" and self.PlayersAddedToQueue[Players[1].UserId] == nil then
        if #Players > 1 then
            local Success = Knit.MatchmakingService:QueueParty(Players, "tournament", "Voicechat Tournament")
            --if Success == true then
            --end
            return true;
        elseif #Players == 1 then
            local Success = Knit.MatchmakingService:QueuePlayer(Players[1], "tournament", "Voicechat Tournament")
            --if Success == true then
            --end
            return true;
        end
    end
    return false;
end

function TournamentService:AddToRegularQueue(Players : table)
    if self.PlayersAddedToQueue[Players[1].UserId] ~= nil then return false; end
    if self.PlayersPendingToQueue[Players[1].UserId] ~= nil then return false; end


    if self.PlayersPendingToQueue[Players[1].UserId] == nil then
        self.PlayersPendingToQueue[Players[1].UserId] = "Regular Tournament";
        for _, player in ipairs(Players) do
            self.Client.QueueStatus:Fire(player, "QueueStart", "Regular");
        end
    end

    task.wait(math.random(10,15))

    if self.PlayersPendingToQueue[Players[1].UserId] == "Regular Tournament" and self.PlayersAddedToQueue[Players[1].UserId] == nil then
        if #Players > 1 then
            local Success = Knit.MatchmakingService:QueueParty(Players, "tournament", "Regular Tournament")
            
            --if Success == true then
            --end
            return true;
        elseif #Players == 1 then
            local Success = Knit.MatchmakingService:QueuePlayer(Players[1], "tournament", "Regular Tournament");
    
            --if Success == true then
            --end
            return true;
        end
    end
    
    return false;
end

function TournamentService:RemoveFromQueue(Players : table)
    
    self.PlayersPendingToQueue[Players[1].UserId] = nil;
    
    for _, player in ipairs(Players) do
        self.Client.QueueStatus:Fire(player, "QueueRemove")
    end

    if self.PlayersPendingToQueue[Players[1].UserId] == nil and self.PlayersAddedToQueue[Players[1].UserId] ~= nil then
        if #Players > 1 then
            local Success = Knit.MatchmakingService:RemovePlayersFromQueue(Players);
    
            --if Success == true then
            --end
            return true;
        elseif #Players == 1 then
            local Success = Knit.MatchmakingService:RemovePlayerFromQueue(Players[1]);
    
            --if Success == true then
            --end
            return true;
        end
        
    end
    
    return false;
end

function TournamentService:StartTournament()
    if not RunService:IsServer() or RunService:IsStudio() then
        return;
    end
    Knit.MatchmakingService:StartGame(self.gameData.gameCode, false);
end

function TournamentService:KnitStart()
    -- Set player range to 1, 50
    Knit.MatchmakingService:SetPlayerRange("Regular Tournament", NumberRange.new(10, 50));
    Knit.MatchmakingService:SetPlayerRange("Voicechat Tournament", NumberRange.new(10, 30));

    -- Set the game place
    Knit.MatchmakingService:AddGamePlace("Regular Tournament", 9166842524);
    Knit.MatchmakingService:AddGamePlace("Voicechat Tournament", 9166842524);

    -- Set the game found delay
    --MatchmakingService:SetFoundGameDelay(20)

    -- Set the game joinable
    Knit.MatchmakingService:SetJoinable(9166842524, false);
    Knit.MatchmakingService:SetJoinable(9166842524, false);

    Knit.MatchmakingService.FoundGame:Connect(function(player, gameCode, gameData)
        Knit.MatchmakingService.ApplyCustomTeleportData = function(player, gameData)
            return {["Some"]="Custom",["Data"]="Table"}
        end
        Knit.MatchmakingService.ApplyGeneralTeleportData = function(gameData)
            return {
                ["Tournament"]= true,
                ["Some"]="Custom",
                ["Data"]="Table"
            }
        end
        print(player, gameCode, gameData)

        if gameData then
            if gameData.players then
                for _, userId in ipairs(gameData.players) do
                    local Player = Players:GetPlayerByUserId(userId);

                    if Player then
                        self.Client.QueueStatus:Fire(Player, "FoundMatch");
                    end
                end
            end
        end
    end)

    Knit.MatchmakingService.PlayerAddedToQueue:Connect(function(...)
        print("PlayerAddedToQueue", ...)
        local Array = {...}
        local userId, map, ratingType, roundedRating = Array[1], Array[2], Array[3], Array[4];

        self.PlayersAddedToQueue[userId] = map
        self.PlayersPendingToQueue[userId] = nil;
        
        --if self.PlayersAddedToQueue[Players[1].UserId] ~= nil then return false; end
    end)

    Knit.MatchmakingService.PlayerRemovedFromQueue:Connect(function(...)
        print("PlayerRemovedFromQueue", ...)
        local Array = {...}
        local userId, map, ratingType, roundedRating = Array[1], Array[2], Array[3], Array[4];

        self.PlayersAddedToQueue[userId] = nil;
        self.PlayersPendingToQueue[userId] = nil;
    end)

    game.Players.PlayerRemoving:Connect(function(p)
        self.PlayersAddedToQueue[p.UserId] = nil;
        self.PlayersPendingToQueue[p.UserId] = nil;
        Knit.MatchmakingService:RemovePlayerFromQueue(p)
    end)
end


function TournamentService:KnitInit()
    self.gameData = Knit.MatchmakingService:GetGameData() -- gets the current game's data, includes custom data
	
    print(self.gameData, "DATA")
    self:sortTournamentMapsAndModes()

    game.Players.PlayerRemoving:Connect(function(player)
        if self.IsGameServer == true then
            Knit.MatchmakingService:RemovePlayerFromGame(player, self.gameData.gameCode)
        end
    end)

	if self.gameData then
		if self.gameData["Tournament"] == true then
            self.IsGameServer = true;
            Knit.MatchmakingService:SetIsGameServer(true)
        else
            self.IsGameServer = false;
        end
	end
end



return TournamentService
