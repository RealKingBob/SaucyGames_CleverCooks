local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PulseStyle = Knit.CreateController { Name = "PulseStyle" }

--//Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

--//Const
local PulseInfo = TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local PulsingObjects = {}

-- Runs every 1.5 seconds
local LastPulse = 0

local function Pulse(Container)
    local Frame = Container:FindFirstChild("Pulse")--:FindFirstChildWhichIsA("Frame")
    local Clone = Frame:Clone()
    Clone:ClearAllChildren()
    Clone.ZIndex = Frame.ZIndex + 1;
    Clone.BackgroundColor3 = Color3.fromRGB(255, 191, 0);
    Clone.BackgroundTransparency = .3;
    Clone.Parent = Container
    Clone.Visible = true;
    
    local Tween = TweenService:Create(Clone, PulseInfo, {
        BackgroundTransparency = 1,
        Size = UDim2.new(Frame.Size.X.Scale * 1.7, 0, Frame.Size.Y.Scale * 1.7, 0)
    })
    Tween:Play()
    -- delete the clone after tween is done
    Tween.Completed:Connect(function(PlaybackState)
        Clone:Destroy()
    end)
end

function PulseStyle:StyleFrame(Container)
    table.insert(PulsingObjects, Container)
end

function PulseStyle:RemoveStyle(Container)
    local Index = table.find(PulsingObjects, Container)
	if Index then
		table.remove(PulsingObjects, Index)
	end
end

function PulseStyle:KnitStart()
    CollectionService:GetInstanceAddedSignal("PulseStyle"):Connect(function(v)
        self:StyleFrame(v)
    end)
    
    CollectionService:GetInstanceRemovedSignal("PulseStyle"):Connect(function(v)
        self:RemoveStyle(v)
    end)

    for _,v in pairs(CollectionService:GetTagged("PulseStyle")) do
        self:StyleFrame(v);
    end

    RunService.RenderStepped:Connect(function()
        if os.clock() - LastPulse < 1.5 then return end
        LastPulse = os.clock()
        for i, GuiObject in ipairs(PulsingObjects) do
            Pulse(GuiObject)
        end
    end)
end


function PulseStyle:KnitInit()
    
end


return PulseStyle