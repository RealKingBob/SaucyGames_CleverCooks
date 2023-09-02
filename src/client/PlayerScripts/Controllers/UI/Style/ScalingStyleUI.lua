local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ScalingStyleUI = Knit.CreateController { Name = "ScalingStyleUI" }

--//Imports
local Maid = require(Knit.Util.Maid); 

--//Const
local MainMaid = Maid.new();

--//State
local GridLayouts = {};

--//Public Methods
function ScalingStyleUI:ListenGrids()
	MainMaid:DoCleaning();
	
	for _,v in pairs(GridLayouts) do
		local Connection = v:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			self:UpdateAllGrids();
		end)
		
		MainMaid:GiveTask(Connection);
	end
	
	self:UpdateAllGrids();
end

function ScalingStyleUI:AddGrid(Grid)
	CollectionService:AddTag(Grid, "ScrollingLayout");
end

function ScalingStyleUI:UpdateGrid(Grid)
	local ScrollingFrame = Grid:FindFirstAncestorOfClass("ScrollingFrame");
	
	if (not ScrollingFrame) then return; end
	
	if (ScrollingFrame.ScrollingDirection == Enum.ScrollingDirection.Y) then
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, Grid.AbsoluteContentSize.Y ); -- 15
	elseif (ScrollingFrame.ScrollingDirection == Enum.ScrollingDirection.X) then
		ScrollingFrame.CanvasSize = UDim2.fromOffset(Grid.AbsoluteContentSize.X + 15, 0);
	else
		ScrollingFrame.CanvasSize = UDim2.fromOffset(Grid.AbsoluteContentSize.X + 15, Grid.AbsoluteContentSize.Y + 15);
	end
end

function ScalingStyleUI:UpdateAllGrids()
	for _,v in pairs(GridLayouts) do
		self:UpdateGrid(v);
	end
end

function ScalingStyleUI:KnitStart()
    CollectionService:GetInstanceAddedSignal("ScrollingLayout"):Connect(function(Tag)
		GridLayouts = CollectionService:GetTagged("ScrollingLayout");
		
		self:ListenGrids();
	end)
	
	GridLayouts = CollectionService:GetTagged("ScrollingLayout");
	self:ListenGrids();
	
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		self:UpdateAllGrids();
	end)
end

function ScalingStyleUI:KnitInit()
    
end

return ScalingStyleUI
