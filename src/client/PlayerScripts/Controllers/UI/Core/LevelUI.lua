local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LevelUI = Knit.CreateController { Name = "LevelUI" }

--[[
    Payload = {
        ["CurrentLevel"] = 0,
        ["Alpha"] = .3
    }
]]

--//Services
local TweenService = game:GetService("TweenService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local ProgressBar = PlayerGui:WaitForChild("Level"):WaitForChild("ProgressBar");

local SizeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

--//Public Methods
function LevelUI:Update(Payload)
    ProgressBar:WaitForChild("Level").Text = Payload.CurrentLevel;
    --ProgressBar:WaitForChild("End"):WaitForChild("Frame"):WaitForChild("TextLabel").Text = Payload.CurrentLevel + 1;

    TweenService:Create(ProgressBar:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(Payload.Alpha, 1) }):Play();
end

function LevelUI:KnitStart()
    while task.wait(3) do
        LevelUI:Update({
            CurrentLevel = math.random(1, 200),
            Alpha = math.random(),
        });
    end
end

function LevelUI:KnitInit()
    
end

return LevelUI
