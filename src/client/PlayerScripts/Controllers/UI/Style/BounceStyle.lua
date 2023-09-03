local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local BounceStyle = Knit.CreateController { Name = "BounceStyle" }

--//Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

--//Const
local BounceInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)

local BouncingObjects = {}

-- Runs every 1.5 seconds
local LastPulse = 0

local function Bounce(Container)
    local Frame = Container--:FindFirstChildWhichIsA("Frame")
    local isHorizontal = Frame:GetAttribute("Horizontal")

    local Tween

    if isHorizontal then
        Tween = TweenService:Create(Frame, BounceInfo, {
            Position = Frame.Position + UDim2.new(0, 6, 0, 0)
        })
    else
        Tween = TweenService:Create(Frame, BounceInfo, {
            Position = Frame.Position + UDim2.new(0, 0, 0, 6)
        })
    end

    Tween:Play()
end

function BounceStyle:StyleFrame(Container)
    table.insert(BouncingObjects, Container)
end

function BounceStyle:RemoveStyle(Container)
    local Index = table.find(BouncingObjects, Container)
	if Index then
		table.remove(BouncingObjects, Index)
	end
end

function BounceStyle:KnitStart()
    CollectionService:GetInstanceAddedSignal("BounceStyle"):Connect(function(v)
        self:StyleFrame(v)
    end)
    
    CollectionService:GetInstanceRemovedSignal("BounceStyle"):Connect(function(v)
        self:RemoveStyle(v)
    end)

    for _,v in pairs(CollectionService:GetTagged("BounceStyle")) do
        self:StyleFrame(v)
    end

    RunService.RenderStepped:Connect(function()
        if os.clock() - LastPulse < .7 then return end
        LastPulse = os.clock()
        for i, GuiObject in ipairs(BouncingObjects) do
            Bounce(GuiObject)
        end
    end)
end


function BounceStyle:KnitInit()
    
end


return BounceStyle