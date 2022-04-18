local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CloseStyle = Knit.CreateController { Name = "CloseStyle" }

local CollectionService = game:GetService("CollectionService")

function CloseStyle:StyleButton(Container)
    Container.MouseButton1Click:Connect(function()
        if Container.Parent.Parent.Parent:IsA("ScreenGui") then
            local CurrentController = tostring(Container.Parent.Parent.Parent.Name .. "UI")
            --print(CurrentController)
            Knit.GetController(CurrentController):CloseView();
        end
    end)
end

function CloseStyle:KnitStart()
    CollectionService:GetInstanceAddedSignal("CloseStyle"):Connect(function(v)
        self:StyleButton(v)
    end)

    for _,v in pairs(CollectionService:GetTagged("CloseStyle")) do
        self:StyleButton(v);
    end
end

function CloseStyle:KnitInit()
    
end


return CloseStyle
