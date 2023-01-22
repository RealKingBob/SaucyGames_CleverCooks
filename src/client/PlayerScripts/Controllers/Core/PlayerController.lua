local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PlayerController = Knit.CreateController { Name = "PlayerController" }
local LocalPlayer = Players.LocalPlayer;

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

function PlayerController:KnitStart()

end

function PlayerController:KnitInit()
    
end


return PlayerController
