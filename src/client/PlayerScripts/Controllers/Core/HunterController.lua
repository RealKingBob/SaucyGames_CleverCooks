local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local HunterController = Knit.CreateController { Name = "HunterController" }

local LocalPlayer = Players.LocalPlayer

local HunterConnection;
local Mouse = LocalPlayer:GetMouse()

local PlayerPositions = {};

function HunterController:UpdatePosition(player, pos)
    if player and pos then
        if workspace.Terrain:FindFirstChild(tostring(player.UserId)) then
            if PlayerPositions[player.UserId] == nil then
                workspace.Terrain:FindFirstChild(tostring(player.UserId)).Position = pos;
                PlayerPositions[player.UserId] = pos;
            else
                local LaserAtt = workspace.Terrain:FindFirstChild(tostring(player.UserId));
                TweenService:Create(LaserAtt, TweenInfo.new(0.04, Enum.EasingStyle.Linear),{Position = pos}):Play()
                PlayerPositions[player.UserId] = pos;
            end
        end
    end
end

function HunterController:KnitStart()
    local HUNTER_TAG = "Hunter";
    local HunterService = Knit.GetService("HunterService");

    CollectionService:GetInstanceAddedSignal(HUNTER_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            local function onRender()
                HunterService.HunterEyesOn:Fire(Mouse.Hit.Position)
                for _, player : Player in pairs(game.Players:GetPlayers()) do
                    if CollectionService:HasTag(player, HUNTER_TAG) == true then
                        if player and player.Character then
                            local Head = player.Character:FindFirstChild("Head");
                            if Head and Head:FindFirstChild("Lasers") then
                                if Head:FindFirstChild("Lasers"):FindFirstChild("LaserBeam") then
                                    Head:FindFirstChild("Lasers"):FindFirstChild("LaserBeam").Enabled = false;
                                end
                            end
                        end
                    end
                end
            end
            HunterConnection = RunService.RenderStepped:Connect(onRender)
        end
    end)

    CollectionService:GetInstanceRemovedSignal(HUNTER_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            if HunterConnection then
                HunterConnection:Disconnect();
                HunterConnection = nil;
            end
            PlayerPositions = {};
        end
    end)
    
    HunterService.updatePosition:Connect(function(targetPlayer, mousePos)
        self:UpdatePosition(targetPlayer, mousePos)
    end)
end


function HunterController:KnitInit()
    
end


return HunterController
