----- Services -----
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local ServerModules = Knit.Modules
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"))
--local RewardService = require(Knit.Services.RewardService)
local Config = require(Knit.Shared.Modules.Config)

----- Settings -----
local GAMEPLAY_TIME = Config.DEFAULT_SANDBOX_TIME
local NIGHT_TIME = Config.DEFAULT_NIGHT_TIME

local ThemeData = workspace:GetAttribute("Theme")

local SandboxMode = Knit.CreateService {
    Name = "SandboxMode",
    Client = {},
}

local TS = game:GetService("TweenService")

local dayGoal = {}
dayGoal.Ambient = Color3.fromRGB(143, 101, 50)

local nightGoal = {}
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
SandboxMode.numOfDays = 1

SandboxMode.Intermission = nil
SandboxMode.PreviousMap = nil
SandboxMode.PreviousMode = nil
SandboxMode.GameMode = nil

SandboxMode.percentageTillNight = 90 --// 10%

-- Private Functions
local startPercent, endPercent, dayStartShift, dayEndShift = 0, 1, Config.DAY_START_SHIFT, Config.DAY_END_SHIFT -- 9 am to 5 pm
local nightStartShift, nightEndShift = Config.NIGHT_START_SHIFT, Config.NIGHT_END_SHIFT -- 12 am to 6 am
-- f(x)=b(x−min)+a(max−x) / max−min
-- m+t/10(M−m)

local function dayShiftHours(timeVal)
    return (dayStartShift + (timeVal / endPercent) * (dayEndShift - dayStartShift))
    --return (((endPercent * (timeVal - dayStartShift)) + (startPercent * (dayEndShift - timeVal))) / (dayEndShift - dayStartShift))
end

local function nightShiftHours(timeVal)
    return (nightStartShift + (timeVal / endPercent) * (nightEndShift - nightStartShift))
end

function SandboxMode:StartMode()
    print("SANDBOX MODE STARTED")

    local GameService = Knit.GetService("GameService")

    --print("[GameService]: Intermission Started")

    while true do

        GameService:ClearTracked()

        task.wait(5)

        Knit.GetService("OrderService"):pauseOrders(false)
            
        local numOfRecipes = 1
        --local listOfRecipes = Knit.GetService("OrderService"):getNumOfRandomRecipes(numOfRecipes)

        for _, player in pairs(Players:GetPlayers()) do
            Knit.GetService("NotificationService"):LargeMessage(false, player, "RESTUARANT OPENED!", {Effect = true, Color = Color3.fromRGB(255,255,255)})
            --Knit.GetService("OrderService"):addRecipes(listOfRecipes)
        end
        print("MUSIC")
        -- print("[GameService]: Gameplay Started")
        task.spawn(function()
            local MusicService = Knit.GetService("MusicService")
            MusicService:StartBackgroundMusic(ThemeData, "Day")
            --Lighting.Ambient = Color3.fromRGB(143, 101, 50)
            dayTween:Play()
        end)
        

        print("DAY")
        
        for _, blender in pairs(CollectionService:GetTagged("Blender")) do
            blender:SetAttribute("Enabled", true)
        end
        print("BLENDER")

        SpawnItemsAPI:SpawnDistributedIngredients(ThemeData)
        --SpawnItemsAPI:SpawnAllIngredients(1)

        local startTime = os.time()
        for i = 0, GAMEPLAY_TIME do
            local currentTime = dayShiftHours((i / GAMEPLAY_TIME))
            print("sasa")
            GameService.Client.AdjustTimeSignal:FireAll({
                Day = self.numOfDays,
                Time = currentTime, 
                IsNight = false,
            })

            --print("Day:", self.numOfDays, i,  GAMEPLAY_TIME, i/GAMEPLAY_TIME, "| Time:", currentTime)
            task.wait(1)
        end

        for _, player in pairs(Players:GetPlayers()) do
            Knit.GetService("NotificationService"):LargeMessage(false, player, "RESTUARANT IS CLOSING...", {Effect = true, Color = Color3.fromRGB(255,255,255)})
        end

        task.wait(1)

        Knit.GetService("OrderService"):pauseOrders(true)
        for _, player in pairs(Players:GetPlayers()) do
            Knit.GetService("OrderService"):removeAllRecipes(player)
            Knit.GetService("NotificationService"):LargeMessage(false, player, "RESTUARANT CLOSED!", {Effect = true, Color = Color3.fromRGB(255,255,255)})
            Knit.GetService("CookingService"):DropDown(player, player.Character)
        end

        for _, blender in pairs(CollectionService:GetTagged("Blender")) do
            blender:SetAttribute("Enabled", false)
        end

        if workspace:FindFirstChild("IngredientAvailable") then
            workspace:FindFirstChild("IngredientAvailable"):ClearAllChildren()
        end

        if workspace:FindFirstChild("FoodAvailable") then
            workspace:FindFirstChild("FoodAvailable"):ClearAllChildren()
        end

        task.spawn(function()
            nightTween:Play()
            Knit.GetService("MusicService"):StartBackgroundMusic(ThemeData, "Night")
        end)

        
        for i = 0, NIGHT_TIME do
            local currentTime = nightShiftHours((i / NIGHT_TIME))
            GameService.Client.AdjustTimeSignal:FireAll({
                Day = self.numOfDays,
                Time = currentTime,
                IsNight = true,
            })
            --print("Night:", self.numOfDays, i,  NIGHT_TIME, i/NIGHT_TIME, "| Time:", currentTime)
            task.wait(1)
        end

        --// Game Round Ended
        print("[GameService]: Gameplay Ended")
        self.numOfDays += 1
    end
end

function SandboxMode:KnitStart()
end


function SandboxMode:KnitInit()
    
end


return SandboxMode
