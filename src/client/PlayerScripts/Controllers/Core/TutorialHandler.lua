local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TutorialHandler = Knit.CreateController { Name = "TutorialHandler" }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer;

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local TutorialUI = PlayerGui:WaitForChild("Tutorial");

local HoverInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

function TutorialHandler:TransitionBackground(alpha)
    local BackgroundFrame = TutorialUI:WaitForChild("Background")
    TweenService:Create(BackgroundFrame, HoverInfo, {
        BackgroundTransparency = alpha
    }):Play()
end

function TutorialHandler:CancelTutorial()
    local TutorialService = Knit.GetService("TutorialService")
    TutorialService.TutorialEnd:Fire()
end

function TutorialHandler:ShowTutorial(tutorialStep)
    
end

function TutorialHandler:KnitStart()
    
end


function TutorialHandler:KnitInit()
    
end


return TutorialHandler
