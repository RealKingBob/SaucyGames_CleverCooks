local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local TweenService = game:GetService("TweenService")

local NotificationUI = Knit.CreateController { Name = "NotificationUI" }

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local indexNum = 0;

function NotificationUI:Message(text)
    local notificationUI = PlayerGui:WaitForChild("Notification")
    local CenterFrame = notificationUI:WaitForChild("Frame"):WaitForChild("CenterFrame")
    local notificationItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("NotificationMessage");
    local messageClone = notificationItemPrefab:Clone() do
        indexNum += 1;
        messageClone.Name = "Notification"..indexNum;
        messageClone.LayoutOrder = indexNum;
        messageClone.Text = text;
        messageClone.TextTransparency = 0;
        messageClone.Parent = CenterFrame;
            
        task.delay(5, function()
            TweenService:Create(messageClone, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play();
            task.wait(.4)
            messageClone:Destroy();
        end)
    end
end

function NotificationUI:KnitStart()
    
end


function NotificationUI:KnitInit()
    
end


return NotificationUI
