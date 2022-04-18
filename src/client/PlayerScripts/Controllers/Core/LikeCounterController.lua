local ProximityPromptService = game:GetService("ProximityPromptService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LikeCounterController = Knit.CreateController { Name = "LikeCounterController" }


--[[
    Payload = {
        ["CurrentLevel"] = 0,
        ["PrevLikeGoal"] = 0,
        ["Claimed"] = false,
        ["Alpha"] = .3
    }
]]

--//Services
local TweenService = game:GetService("TweenService")

local plr = game.Players.LocalPlayer;

--//Const
local LikeGoal = workspace.Lobby:WaitForChild("Like Goal"):WaitForChild("LikeGoal")
local BarHolder = LikeGoal:WaitForChild("BarHolder")
local LikeCounter = LikeGoal:WaitForChild("GoalSign"):WaitForChild("Sign"):WaitForChild("LikeCounter")
local DescText = LikeGoal:WaitForChild("GoalSign"):WaitForChild("Sign"):WaitForChild("DescText")
local ClaimChestUI = LikeGoal:WaitForChild("Circle"):WaitForChild("ClaimChest")
local ProgressBarUI = BarHolder:WaitForChild("LikeCounter");

local SizeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

--//Public Methods
function LikeCounterController:Update(Payload)
    local CommaValue = require(Knit.ReplicatedModules.CommaValue);
    DescText:WaitForChild("SurfaceGui"):WaitForChild("TextLabel").Text = ("Current: %s Likes"):format(CommaValue(Payload.CurrentLikes));
    LikeCounter:WaitForChild("SurfaceGui"):WaitForChild("TextLabel").Text = ("Goal: %s Likes"):format(CommaValue(Payload.LikeGoal));
    ClaimChestUI:WaitForChild("TITLE").Text = ("THANK YOU FOR %s LIKES"):format(CommaValue(Payload.PrevLikeGoal));
    if Payload.Claimed == true then
        ClaimChestUI:WaitForChild("TIMER").Text = "CLAIMED"
    else
        ClaimChestUI:WaitForChild("TIMER").Text = "CLAIM BREAD"
    end
    
    TweenService:Create(ProgressBarUI:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(1, Payload.Alpha) }):Play();
end

function LikeCounterController:KnitStart()
    --[[while task.wait(3) do
        self:Update({
            PrevLikeGoal = math.random(1000, 15000),
            Claimed = math.random(1, 2) == 1 and true or false,
            LikeGoal = math.random(1000, 15000),
            Alpha = math.random()
        });
    end]]
    ProximityPromptService.PromptShown:Connect(function(prompt, inputStyle)
        if prompt.Style == Enum.ProximityPromptStyle.Default then
            return
        end

        if prompt.ActionText == "LikeCounter" then
            local LikeCounterService = Knit.GetService("LikeCounterService")
            LikeCounterService.CounterSignal:Fire()
        end
    end)
end


function LikeCounterController:KnitInit()
    
end


return LikeCounterController
