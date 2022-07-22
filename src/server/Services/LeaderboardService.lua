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

function LeaderboardService:SetupLeaderboards()
 
end


function LeaderboardService:KnitStart()

end


function LeaderboardService:KnitInit()
    print("[SERVICE]: LeaderboardService Initialized")
    self:SetupLeaderboards();
end


return LeaderboardService;