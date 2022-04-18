local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGUI = Players.LocalPlayer.PlayerGui
local MainGUI = PlayerGUI:WaitForChild("GameplayFrame")
local GameplayFrame = MainGUI:WaitForChild("GameplayFrame")
local ProgressBar = GameplayFrame:WaitForChild("ProgressBar")
local BarLabel = ProgressBar:WaitForChild("Bar")
local MiddleFrame = ProgressBar:WaitForChild("MiddleFrame")

local GameLibrary = ReplicatedStorage:WaitForChild("Common")
local Services = GameLibrary:WaitForChild("Services")

local MapProgressUtil = require(Services:WaitForChild("MapProgressUtil"))
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PathDataPoints = {}
local Enabled = false;

local ProgressionController = Knit.CreateController { Name = "ProgressionController" }

function CreatePlayerImage(Player)
    if Player then
        local ImageLabel = Instance.new("ImageLabel");
        local userThumbnail, isReady = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420);
        if isReady == false then
            userThumbnail = "rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"
        end
        ImageLabel.Image = userThumbnail
        ImageLabel.BackgroundTransparency = 1;
        ImageLabel.Name = Player.Name;
        ImageLabel.Size = UDim2.new(0.041, 0,20, 0);
        ImageLabel.Position = UDim2.new(0, 0, 1, 0);
        ImageLabel.ScaleType = Enum.ScaleType.Fit
        ImageLabel.ZIndex = 11;

        local UICorner = Instance.new("UICorner");
        UICorner.CornerRadius = UDim.new(1,0);
        UICorner.Parent = ImageLabel;

        return ImageLabel;
    end
    return nil;
end

function StartProgressBar()
    --print("[ProgressionHandler]: Starting Now")
    Enabled = true
    PathDataPoints = {};

    local Children = ProgressBar:GetChildren()
    for _, child in pairs(Children) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if workspace:FindFirstChild("CurrentMap") then
        local CurrentMap = workspace:FindFirstChild("CurrentMap"):GetChildren()[1];
        if CurrentMap then
            if CurrentMap:FindFirstChild("PathData")  then
                local PathPoints = CurrentMap.PathData:GetChildren()
                for i = 1, #PathPoints do
                    if CurrentMap.PathData:FindFirstChild(tostring(i)) then
                        table.insert(PathDataPoints,CurrentMap.PathData:FindFirstChild(i).Position)
                    end
                end
            end
        end
    end

    local MapLength = MapProgressUtil:GetMapLength(PathDataPoints)

    ProgressBar:TweenPosition(UDim2.new(0.5, 0, 0.086, 0),"InOut","Quad",.8,true)

    while Enabled do
        task.wait(0.5)
        for _, player : Player in pairs(Players:GetPlayers()) do
            if not MiddleFrame:FindFirstChild(player.Name) and CollectionService:HasTag(player, "Duck") then
                local NewPlayerImage = CreatePlayerImage(player)
                NewPlayerImage.Parent = MiddleFrame
            elseif MiddleFrame:FindFirstChild(player.Name) and not CollectionService:HasTag(player, "Duck") then
                MiddleFrame:FindFirstChild(player.Name):Destroy()
            end
            if CollectionService:HasTag(player, "Duck") then
                if player == Players.LocalPlayer then
                    if player.Character:FindFirstChild("HumanoidRootPart") then
                        local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        local Position, Distance = MapProgressUtil:GetPositionOnMap(HumanoidRootPart.Position, MapProgressUtil:GetMapRays(PathDataPoints))
                        if Position then
                            local Progress = Distance / MapLength
                            BarLabel:TweenSize(UDim2.new(Progress + 0.02, 0, 1, 0), "Out", "Linear", .5, true)
                        end
                    end
                end
            elseif MiddleFrame:FindFirstChild(player.Name) then
                MiddleFrame:FindFirstChild(player.Name):Destroy()
            end
            
            if CollectionService:HasTag(player, "Duck") then
                if player.Character then
                    if player.Character:FindFirstChild("HumanoidRootPart") then
                        local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        local Position, Distance = MapProgressUtil:GetPositionOnMap(HumanoidRootPart.Position, MapProgressUtil:GetMapRays(PathDataPoints))
                        if Position then
                            local Progress = Distance / MapLength
                            local Label = MiddleFrame:FindFirstChild(player.Name)
                            Label:TweenPosition(UDim2.new(Progress, 0, 0, 0), "Out", "Linear", .5, true)
                        end
                    end
                end
            elseif MiddleFrame:FindFirstChild(player.Name) then
                MiddleFrame:FindFirstChild(player.Name):Destroy()
            end
        end
    end

    for _, player : Player in pairs(Players:GetPlayers()) do
        if MiddleFrame:FindFirstChild(player.Name) then
            MiddleFrame:FindFirstChild(player.Name):Destroy()
        end
    end

    for _, playerImage : ImageLabel in pairs(MiddleFrame:GetChildren()) do
        print(playerImage:IsA("ImageLabel"))
    end

    for _, plr in pairs(MiddleFrame:GetChildren()) do
        if plr:IsA("ImageLabel") then
            plr:Destroy()
        end
    end

    BarLabel:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Linear", .5, true)
    ProgressBar:TweenPosition(UDim2.new(0.5, 0, -0.05, 0),"InOut","Quad",.8,true)
end

function ProgressionController:setupConnections()
    --print("ProgressionController setupConnections")
    ProgressBar:TweenPosition(UDim2.new(0.5, 0, -0.05, 0),"InOut","Quad",.8,true)

    local MapProgessService = Knit.GetService("MapProgessService")

    MapProgessService.MapProgressStartSignal:Connect(function()
        if Enabled == false then
            StartProgressBar()
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player == Players.LocalPlayer then
            Enabled = false;
        end
        if MiddleFrame:FindFirstChild(player.Name) then
            MiddleFrame:FindFirstChild(player.Name):Destroy()
        end
    end)

    MapProgessService.MapProgressEndSignal:Connect(function()
        Enabled = false;
    end)
end

function ProgressionController:KnitInit()
    --print("ProgressionController KnitInit called")
end


function ProgressionController:KnitStart()
    --print("ProgressionController KnitStart called")
    self:setupConnections()
end

return ProgressionController