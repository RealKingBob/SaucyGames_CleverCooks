----- Services -----
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Intermission = require(Knit.Modules.Intermission);
local TableUtil = require(Knit.Util.TableUtil);
local ServerModules = Knit.Modules;
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"));
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

local ThemeData = workspace:GetAttribute("Theme")

local SandboxMode = Knit.CreateService {
    Name = "SandboxMode",
    Client = {},
}

local TS = game:GetService("TweenService")

local dayGoal = {};
dayGoal.Ambient = Color3.fromRGB(143, 101, 50);

local nightGoal = {};
nightGoal.Ambient = Color3.fromRGB(35, 24, 12)

local tweenInfo = TweenInfo.new(
    1, -- Time
    Enum.EasingStyle.Linear, -- EasingStyle
    Enum.EasingDirection.Out, -- EasingDirection
    0, -- RepeatCount (when less than zero the tween will loop indefinitely)
    false, -- Reverses (tween will reverse once reaching it's goal)
    0 -- DelayTime
)

local dayTween = TS:Create(game.Lighting, tweenInfo, dayGoal)
local nightTween = TS:Create(game.Lighting, tweenInfo, nightGoal)

----- Sandbox Mode -----
SandboxMode.numOfDays = 1;

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

local function dayShiftHours(timeVal)
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

local function createChefNPC()
    local npcClone = Knit.GameLibrary:WaitForChild("NPCs"):WaitForChild("Chef"):Clone()
    npcClone.Parent = workspace:WaitForChild("NPCS");
    CollectionService:AddTag(npcClone, "NPC")
end

function SandboxMode:StartMode()
    print("SANDBOX MODE STARTED")

    local GameService = Knit.GetService("GameService");

    --print("[GameService]: Intermission Started")

    while true do
        
        GameService:ClearCooldowns()
        GameService:ClearTracked()

        task.wait(5)

        Knit.GetService("OrderService"):pauseOrders(false)
        for _, randomSpot in pairs(workspace:WaitForChild("RandomSpots"):GetChildren()) do
            randomSpot:SetAttribute("Activated", false)
        end
            
        local numOfRecipes = 1;
        --local listOfRecipes = Knit.GetService("OrderService"):getNumOfRandomRecipes(numOfRecipes);

        for _, player in pairs(Players:GetPlayers()) do
            Knit.GetService("NotificationService"):LargeMessage(false, player, "RESTUARANT OPENED!", {Effect = true, Color = Color3.fromRGB(255,255,255)})
            --Knit.GetService("OrderService"):addRecipes(listOfRecipes);
        end
        -- print("[GameService]: Gameplay Started")
        local MusicService = Knit.GetService("MusicService");
        MusicService:StartBackgroundMusic(ThemeData, "Day")
        --Lighting.Ambient = Color3.fromRGB(143, 101, 50)
        dayTween:Play();

        local amountOfNpcs = math.random(4,5);
        local intervalTime = GAMEPLAY_TIME / (amountOfNpcs + 1)
        local called = 0
        
        for _, blender in pairs(CollectionService:GetTagged("Blender")) do
            blender:SetAttribute("Enabled", true);
        end

        SpawnItemsAPI:SpawnDistributedIngredients(ThemeData);
        --SpawnItemsAPI:SpawnAllIngredients(5)

        local startTime = os.time()
        for i = 0, GAMEPLAY_TIME do
            local currentTime = dayShiftHours((i / GAMEPLAY_TIME))
            GameService.Client.AdjustTimeSignal:FireAll({
                Day = self.numOfDays,
                Time = currentTime, 
                IsNight = false,
            });

            if os.time() - startTime > 10 then
                if os.time() - startTime > intervalTime * called and called < amountOfNpcs then
                    createChefNPC()
                    called = called + 1
                end
            end
            --print("Day:", self.numOfDays, i,  GAMEPLAY_TIME, i/GAMEPLAY_TIME, "| Time:", currentTime)
            task.wait(1)
        end

        for _, player in pairs(Players:GetPlayers()) do
            Knit.GetService("NotificationService"):LargeMessage(false, player, "RESTUARANT IS CLOSING...", {Effect = true, Color = Color3.fromRGB(255,255,255)})
        end

        for _, v in pairs(workspace:WaitForChild("NPCS"):GetChildren()) do
            CollectionService:RemoveTag(v, "NPC")
        end

        local timeOut = 0
        repeat 
            timeOut += 1
            task.wait(1)
        until timeOut > 30 or #workspace:WaitForChild("NPCS"):GetChildren() == 0

        workspace:WaitForChild("NPCS"):ClearAllChildren();
        for _, randomSpot in pairs(workspace:WaitForChild("RandomSpots"):GetChildren()) do
            randomSpot:SetAttribute("Activated", false)
        end
        task.wait(1);

        Knit.GetService("OrderService"):pauseOrders(true)
        for _, player in pairs(Players:GetPlayers()) do
            Knit.GetService("OrderService"):removeAllRecipes(player)
            Knit.GetService("NotificationService"):LargeMessage(false, player, "RESTUARANT CLOSED!", {Effect = true, Color = Color3.fromRGB(255,255,255)})
            Knit.GetService("CookingService"):DropDown(player, player.Character)
        end

        for _, blender in pairs(CollectionService:GetTagged("Blender")) do
            blender:SetAttribute("Enabled", false);
        end

        if workspace:FindFirstChild("IngredientAvailable") then
            workspace:FindFirstChild("IngredientAvailable"):ClearAllChildren();
        end

        if workspace:FindFirstChild("FoodAvailable") then
            workspace:FindFirstChild("FoodAvailable"):ClearAllChildren();
        end

        nightTween:Play();
        MusicService:StartBackgroundMusic(ThemeData, "Night")
        for i = 0, NIGHT_TIME do
            local currentTime = nightShiftHours((i / NIGHT_TIME))
            GameService.Client.AdjustTimeSignal:FireAll({
                Day = self.numOfDays,
                Time = currentTime,
                IsNight = true,
            });
            --print("Night:", self.numOfDays, i,  NIGHT_TIME, i/NIGHT_TIME, "| Time:", currentTime)
            task.wait(1)
        end

        --// Game Round Ended
        print("[GameService]: Gameplay Ended")
        self.numOfDays += 1;
    end
end

--[[local Synced = require(Knit.ReplicatedModules.Synced);
        local DailyShopOffset = (60 * 60 * Knit.Config.DAILY_SHOP_OFFSET); 
        local Day = math.floor((Synced.time() + DailyShopOffset) / (60 * 60 * 24))
        local seed = Random.new(Day);

        local weightNumber = seed:NextNumber(0, 100);

        if weightNumber <= self.percentageTillNight then
            --warn("OOO SPOOKY NIGHT")
            self.percentageTillNight = 2;
            Lighting.Ambient = Color3.fromRGB(35, 24, 12)
            MusicService:StartBackgroundMusic(ThemeData, "Night")
            for i = 0, NIGHT_TIME do
                local currentTime = nightShiftHours((i / NIGHT_TIME))
                GameService.Client.AdjustTimeSignal:FireAll({
                    Day = self.numOfDays,
                    Time = currentTime,
                    IsNight = true,
                });
                --print("Night:", self.numOfDays, i,  NIGHT_TIME, i/NIGHT_TIME, "| Time:", currentTime)
                task.wait(1)
            end
        else
            self.percentageTillNight += 10;
        end]]
        
        --TimeTween:Play();
        --TimeTween.Completed:Wait();


function SandboxMode:KnitStart()
    local Admins = {"Real_KingBob"}
    local Prefix = "/" 

    game.Players.PlayerAdded:Connect(function(plr)
        for _,v in pairs(Admins) do
            if plr.Name == v then
                print("adasda")
                plr.Chatted:Connect(function(msg)
                    local loweredString = string.lower(msg)
                    local args = string.split(loweredString," ")
                    print(args)
                    if args[1] == Prefix.."create" then
                        args[2] = args[2] ~= nil and args[2] or 1
                        for i = 0, args[2] do
                            createChefNPC();
                        end
                    elseif args[1] == Prefix.."destroy" then
                        args[2] = args[2] ~= nil and args[2] or 1
                        local count = 0
                        
                        for _, n in pairs(CollectionService:GetTagged("NPC")) do
                            CollectionService:RemoveTag(n, "NPC")
                            task.spawn(function()
                                task.wait(20)
                                if n then n:Destroy(); end
                            end)
                            count += 1;
                            if count == args[2] then break end
                        end
                    end
                end)
            end
        end
    end)
end


function SandboxMode:KnitInit()
    
end


return SandboxMode
