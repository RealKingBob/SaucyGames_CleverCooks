local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ClockUI = Knit.CreateController { Name = "ClockUI" }

function ClockUI:AdjustTime(Day, Time)
    
end

function ClockUI:KnitStart()
    local GameService = Knit.GetService("GameService")

    GameService.AdjustTimeSignal:Connect(function(Day, Time)
        self:AdjustTime(Day, Time)
    end)
    
end


function ClockUI:KnitInit()
    
end


return ClockUI
