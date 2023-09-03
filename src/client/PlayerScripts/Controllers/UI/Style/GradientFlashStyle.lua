local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local GradientFlashStyle = Knit.CreateController { Name = "GradientFlashStyle" }

local CollectionService = game:GetService("CollectionService")

--//Const
local FlashInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local StartOffset, EndOffset = Vector2.new(-1, -1), Vector2.new(1, 1)

--//State
local MovingGradients = {}

function GradientFlashStyle:AddGradient(Gradient)
    table.insert(MovingGradients, Gradient)
end

function GradientFlashStyle:RemoveGradient(Gradient)
    local Index = table.find(MovingGradients, Gradient)

    if (Index) then
        table.remove(MovingGradients, Index)
    end
end

function GradientFlashStyle:KnitStart()
    local TweenModule = require(Knit.Modules.Tween)

    local GradientTween = TweenModule.new(FlashInfo, function(Alpha)
        for _,v in pairs(MovingGradients) do
            if (v.Enabled and v.Parent.Visible) then
                v.Offset = StartOffset:Lerp(EndOffset, Alpha)
            end
        end
    end)

    GradientTween.Completed:Connect(function()
        wait(3)
        GradientTween:Play()
    end)

    CollectionService:GetInstanceAddedSignal("GradientFlash"):Connect(function(Gradient)
        self:AddGradient(Gradient)
    end)

    CollectionService:GetInstanceRemovedSignal("GradientFlash"):Connect(function(Gradient)
        self:RemoveGradient(Gradient)
    end)

    for _,v in pairs(CollectionService:GetTagged("GradientFlash")) do
        self:AddGradient(v)
    end

    GradientTween:Play()
end

function GradientFlashStyle:KnitInit()
    
end


return GradientFlashStyle
