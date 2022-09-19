local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CookingUI = Knit.CreateController { Name = "CookingUI" }

--[[
    Payload = {
        ["CurrentTime"] = 0,
        ["Alpha"] = .3
    }
]]

--//Services
local TweenService = game:GetService("TweenService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

--local ProgressBar = TierFrame:WaitForChild("InnerFrame"):WaitForChild("ProgressBar");

local SizeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

--//Public Methods
function CookingUI:Update(CurrentFrame, Payload)
    --[[local InnerFrame = TierFrame:WaitForChild("InnerFrame");
    local MaxXP = BattlepassInfo["Tier "..Payload.CurrentLevel] ~= nil and BattlepassInfo["Tier "..Payload.CurrentLevel].XP or 2000 * Payload.CurrentLevel
    local currentXP = math.floor(MaxXP * Payload.Alpha)

    InnerFrame:WaitForChild("TierLabel").Text = "Tier "..Payload.CurrentLevel;
    InnerFrame:WaitForChild("XPLabel").Text = tostring(currentXP) .. " / " .. tostring(MaxXP);

    local BattlepassUI = Knit.GetController("BattlepassUI")

    BattlepassUI:HighlightContentBars(Payload.CurrentLevel)

    --ProgressBar:WaitForChild("End"):WaitForChild("Frame"):WaitForChild("TextLabel").Text = Payload.CurrentLevel + 1;

    TweenService:Create(ProgressBar:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(Payload.Alpha, 1) }):Play();]]
end

function CookingUI:KnitStart()
    --[[while task.wait(3) do
        CookingUI:Update({
            CurrentLevel = math.random(1, 200),
            Alpha = math.random(),
        });
    end]]
end


function CookingUI:KnitInit()
    
end


return CookingUI
