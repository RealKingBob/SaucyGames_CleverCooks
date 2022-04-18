--[[
    Name: Leaderboard Service [V1]
    By: Real_KingBob

    [REMOTE FUNCTION] LeaderboardService.Client:GetLeaderboardData()
            -- Example return: {
        ["LevelData"] = { -- LEVELS DATA FIRST
            [1] = {
                ["UserId"] = 21311241,
                ["Value"] = 103,
            },
            [2] = {
                ["UserId"] = 73434232,
                ["Value"] = 95,
            },
            [3] = {
                ["UserId"] = 43534432,
                ["Value"] = 83,
            },
            ...
            [100] = {
                ["UserId"] = 13426544,
                ["Value"] = 63,
            },
        }, 
        ["WinData"] = { -- WINS DATA SECOND
            [1] = {
                ["UserId"] = 21311241,
                ["Value"] = 45,
            },
            [2] = {
                ["UserId"] = 73434232,
                ["Value"] = 32,
            },
            [3] = {
                ["UserId"] = 43534432,
                ["Value"] = 21,
            },
            ...
            [100] = {
                ["UserId"] = 13426544,
                ["Value"] = 5,
            },
        }
    } -- In order from biggest to smallest


    LeaderboardSignal Data Sends: {
        ["LevelData"] = { -- LEVELS DATA FIRST
            [1] = {
                ["UserId"] = 21311241,
                ["Value"] = 103,
            },
            [2] = {
                ["UserId"] = 73434232,
                ["Value"] = 95,
            },
            [3] = {
                ["UserId"] = 43534432,
                ["Value"] = 83,
            },
            ...
            [100] = {
                ["UserId"] = 13426544,
                ["Value"] = 63,
            },
        }, 
        ["WinData"] = { -- WINS DATA SECOND
            [1] = {
                ["UserId"] = 21311241,
                ["Value"] = 45,
            },
            [2] = {
                ["UserId"] = 73434232,
                ["Value"] = 32,
            },
            [3] = {
                ["UserId"] = 43534432,
                ["Value"] = 21,
            },
            ...
            [100] = {
                ["UserId"] = 13426544,
                ["Value"] = 5,
            },
        }
    } -- In order from biggest to smallest
]]


----- Services -----
local Players = game:GetService("Players")
local UserService = game:GetService("UserService");
local DataStoreService = game:GetService("DataStoreService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

----- Datastores -----
--local LevelsStore = DataStoreService:GetOrderedDataStore("LevelStoreTest3")
local WinsStore = DataStoreService:GetOrderedDataStore("WinsStore1")
local CoinsStore = DataStoreService:GetOrderedDataStore("CoinsStore1")

local Promise = require(Knit.Util.Promise);
local TableUtil = require(Knit.Util.TableUtil);

--local levelData = {};
local winData = {};
local coinData = {};

local PlayerUserInfos = {};

----- Leaderboard Service -----
local LeaderboardService = Knit.CreateService {
    Name = "LeaderboardService";
    Client = {
        LeaderboardSignal = Knit.CreateSignal();
        DonationSignal = Knit.CreateSignal();
    };
}

LeaderboardService.displayFromSmallest = false;
LeaderboardService.amountOfPlayers = 100;
LeaderboardService.minValue = 1;
LeaderboardService.maxValue = 10e30;
LeaderboardService.reload = 60;

--//Private Functions
local GetUserInfosByUserIdsAsync = Promise.promisify(function(UserIds)
    return UserService:GetUserInfosByUserIdsAsync(UserIds);
end)

----- Public Methods -----

function LeaderboardService.Client:GetLeaderboardData()
    --print("Requested for leaderboard")
    return {
        --LevelData = levelData, 
        WinData = winData,
        CoinData = coinData,
    }
end

function LeaderboardService:SetupLeaderboards()
    print("Setting up leaderboards")
    task.spawn(function()
        task.wait(5)
        while true do
            --local LevelPages = LevelsStore:GetSortedAsync(self.displayFromSmallest, self.amountOfPlayers, self.minValue, self.maxValue);
            local WinPages = WinsStore:GetSortedAsync(self.displayFromSmallest, self.amountOfPlayers, self.minValue, self.maxValue);
            local CoinsPages = CoinsStore:GetSortedAsync(self.displayFromSmallest, self.amountOfPlayers, self.minValue, self.maxValue);
           
            --local TopLevels = LevelPages:GetCurrentPage();
            local TopWins = WinPages:GetCurrentPage();
            local TopCoins = CoinsPages:GetCurrentPage();

            --levelData = {};
            winData = {};
            coinData = {};

            --[[for _, player in pairs(Players:GetPlayers()) do
                local profile = Knit.DataService:GetProfile(player);
                if profile then
                    pcall(function()
                        LevelsStore:UpdateAsync(player.UserId,function(oldValue)
                            return profile.Data.PlayerInfo.Level;
                        end)
                    end)
                end
            end]]

            for _, player in pairs(Players:GetPlayers()) do
                local profile = Knit.DataService:GetProfile(player);
                if profile then
                    --print("LEADERBOARD WINS:", player, profile.Data.PlayerInfo.TotalWins)
                    pcall(function()
                        WinsStore:UpdateAsync(player.UserId,function(oldValue)
                            return profile.Data.PlayerInfo.TotalWins;
                        end)
                    end)
                end
            end

            for _, player in pairs(Players:GetPlayers()) do
                local profile = Knit.DataService:GetProfile(player);
                if profile then
                    --print("LEADERBOARD COINS:", player, profile.Data.PlayerInfo.CoinsBought)
                    pcall(function()
                        CoinsStore:UpdateAsync(player.UserId,function(oldValue)
                            return profile.Data.PlayerInfo.CoinsBought;
                        end)
                    end)
                end
            end

            local Data = {};

            for _, data in ipairs(TopWins) do
                local userId = data.key
                if not PlayerUserInfos[userId] then
                    table.insert(Data,{
                        UserId = tonumber(userId)
                    });
                end
            end

            for _, data in ipairs(TopCoins) do
                local userId = data.key
                if not PlayerUserInfos[userId] then
                    table.insert(Data, {
                        UserId = tonumber(userId)
                    });
                end
            end

            local UserIds = TableUtil.Map(Data, function(v)
                return v.UserId;
            end)

            local Success, Result = GetUserInfosByUserIdsAsync(UserIds):await();

            if (Success) then
                for _,v in pairs(Result) do
                    PlayerUserInfos[tonumber(v.Id)] = v;
                end
            end

            --[[for _, data in ipairs(TopLevels) do
                local userId, value = data.key, data.value;
                table.insert(levelData,{
                    UserId = tonumber(userId),
                    Value = tonumber(value)
                });
            end]]

            for _, data in ipairs(TopWins) do
                local userId, value = data.key, data.value;
                --print(PlayerUserInfos, PlayerUserInfos[tonumber(userId)], userId)
                table.insert(winData,{
                    UserId = tonumber(userId),
                    UserName = (PlayerUserInfos[tonumber(userId)] ~= nil and PlayerUserInfos[tonumber(userId)].Username or "N/A"),
                    DisplayName = (PlayerUserInfos[tonumber(userId)] ~= nil and PlayerUserInfos[tonumber(userId)].DisplayName or "N/A"),
                    Value = tonumber(value)
                });
            end

            for _, data in ipairs(TopCoins) do
                local userId, value = data.key, data.value;
                table.insert(coinData,{
                    UserId = tonumber(userId),
                    UserName = (PlayerUserInfos[tonumber(userId)] ~= nil and PlayerUserInfos[tonumber(userId)].Username or "N/A"),
                    DisplayName = (PlayerUserInfos[tonumber(userId)] ~= nil and PlayerUserInfos[tonumber(userId)].DisplayName or "N/A"),
                    Value = tonumber(value)
                });
            end

            self.Client.LeaderboardSignal:FireAll({
                --LevelData = levelData, 
                WinData = winData,
                CoinData = coinData,
            });

            --self.Client.DonationSignal:FireAll(DonationData);
            task.wait(self.reload);
        end
    end)
end


function LeaderboardService:KnitStart()
    --[[local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Rarities = require(ReplicatedStorage.Common.Modules.Assets.DuckSkins)
    print(Rarities.getDuckSkinFromName("Goose"))
    print(Rarities.getCrateItemsFromId(1))
    print(Rarities.selectRandomDuck())]]
end


function LeaderboardService:KnitInit()
    print("[SERVICE]: LeaderboardService Initialized")
    self:SetupLeaderboards();
end


return LeaderboardService;