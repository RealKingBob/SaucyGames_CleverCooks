local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ClockUI = Knit.CreateController { Name = "ClockUI" }

local plr = game.Players.LocalPlayer;

local PlayerGui = plr:WaitForChild("PlayerGui");

function ClockUI:AdjustTime(Day, Time, IsNight)
    local LeftBar = PlayerGui:WaitForChild("LeftBar");
    local MainContainer = LeftBar:WaitForChild("MainContainer");

    local DayFrame = MainContainer:WaitForChild("Day");
    local TimeFrame = MainContainer:WaitForChild("Time");

    DayFrame.TextLabel.Text = "Day " .. tostring(Day);

    --[[if IsNight then
        TimeFrame.TextLabel.TextColor3 = Color3.fromRGB(160, 35, 185)
    else
        TimeFrame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end]]
    TimeFrame.TextLabel.Text = tostring(Time);
end

function ClockUI:KnitStart()
    local GameService = Knit.GetService("GameService")

    GameService.AdjustTimeSignal:Connect(function(Package)
        local Day, Time, IsNight = Package["Day"], Package["Time"], Package["IsNight"];
        self:AdjustTime(Day, Time, IsNight);
    end)
    
end


function ClockUI:KnitInit()
    
end


return ClockUI
