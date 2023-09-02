local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local HoverStyle = Knit.CreateController { Name = "HoverStyle" }

--//Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

--//Imports
local Maid = require(Knit.Util.Maid);

--//Const
local LocalPlayer = Players.LocalPlayer;

local HoverInfo = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local HoverContainer = PlayerGui:WaitForChild("HoverGui");
local HoverText = HoverContainer:WaitForChild("HoverText");
local HoverTextBorder = HoverText:WaitForChild("Border");

local mouse = game.Players.LocalPlayer:GetMouse();

--//State
local Styles = {};

--//Private Functions
local function updateHoverTextBorderSize() -- This function updates the size of the border based on the size of the text
	local textBounds = HoverText.TextBounds;

	HoverTextBorder.Size = UDim2.new(0, textBounds.X + 10, 0, textBounds.Y + 5);
end

--//Public Methods
function HoverStyle:StyleFrame(Container)
    local FrameMaid = Maid.new();
    local Frame = Container;

    if not Frame then return; end

    Styles[Container] = FrameMaid;

    FrameMaid:GiveTask(Frame.MouseMoved:Connect(function(x, y)
        HoverText.Position = UDim2.new(0, mouse.X + 20, 0, mouse.Y + 5);
    end))
    
    FrameMaid:GiveTask(Frame.MouseEnter:Connect(function()
        HoverText.Text = Frame.Name;
        updateHoverTextBorderSize();
        HoverText.Visible = true;
    end))
    
    FrameMaid:GiveTask(Frame.MouseLeave:Connect(function()
        HoverText.Visible = false;
    end))
end

function HoverStyle:RemoveStyle(Container)
    local FrameMaid = Styles[Container];
    
    if (FrameMaid) then
        FrameMaid:DoCleaning();
    end

    TweenService:Create(Container, HoverInfo, { Size = UDim2.fromScale(1, 1) }):Play();
end

function HoverStyle:KnitStart()

    CollectionService:GetInstanceAddedSignal("HoverStyle"):Connect(function(v)
        self:StyleFrame(v);
    end)
    
    CollectionService:GetInstanceRemovedSignal("HoverStyle"):Connect(function(v)
        self:RemoveStyle(v);
    end)

    for _,v in pairs(CollectionService:GetTagged("HoverStyle")) do
        self:StyleFrame(v);
    end
end

function HoverStyle:KnitInit()
    
end

return HoverStyle
