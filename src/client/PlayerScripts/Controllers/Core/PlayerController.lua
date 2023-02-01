local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PlayerController = Knit.CreateController { Name = "PlayerController" }
local LocalPlayer = Players.LocalPlayer;

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary")
local BillboardUI = GameLibrary:WaitForChild("BillboardUI")

local tweenInfoFast = TweenInfo.new(.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function PlayerController:UnTrackItem()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if not HumanoidRootPart then return end;

    HumanoidRootPart:FindFirstChild("TrackBeam").Attachment0 = nil;
end

function PlayerController:TrackItem(itemObj)
    local itemAttachment;
    if not itemObj:FindFirstChildWhichIsA("Attachment") then
        itemAttachment = Instance.new("Attachment");
        itemAttachment.Name = "trackAttachment";
        itemAttachment.Parent = itemObj;
    end

    itemAttachment = itemObj:FindFirstChildWhichIsA("Attachment");

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if not HumanoidRootPart then return end;

    HumanoidRootPart:FindFirstChild("TrackBeam").Attachment0 = itemAttachment;
end

function PlayerController:WarnExclaim()
    local ExclamationPointUI = BillboardUI:WaitForChild("ExclamationPointUI");
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if not Character.Head then return end;
    if Character.Head:FindFirstChild("ExclamationPointUI") then return end
    
    local ExclaimMarker = ExclamationPointUI:Clone() do
        --TargetMarker:WaitForChild("RotateLabel").Visible = true;
        if Character.Head then
            ExclaimMarker.Parent = Character.Head
        end

        task.wait(2.5)

        if ExclaimMarker then
            for _, a in pairs(ExclaimMarker:GetChildren()) do
                if a:IsA("Frame") then
                    TweenService:Create(a, tweenInfoFast, { BackgroundTransparency = 1 }):Play()
                    for _, b in pairs(a:GetChildren()) do
                        if b:IsA("UIStroke") then
                            TweenService:Create(b, tweenInfoFast, { Thickness = 0, Transparency = 1 }):Play()
                        end
                    end
                end
            end
            task.wait(.45)
            ExclaimMarker:Destroy();
        end
    end
end

function PlayerController:KnitStart()

end

function PlayerController:KnitInit()
    
end


return PlayerController
