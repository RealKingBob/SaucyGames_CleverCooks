local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MarkerUI = Knit.CreateController { Name = "MarkerUI" }

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService");

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui");

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary")

local Markers = {};

function ClampMarkerToBorder(X,Y,Absolute)
    local MarkersGui = PlayerGui:WaitForChild("Markers")
    local Holder = MarkersGui:WaitForChild("Holder")
    local ScreenHolder = Holder.AbsoluteSize;

	X = ScreenHolder.X - X
	Y = ScreenHolder.Y - Y

	local DistanceToXBorder = math.min(X,ScreenHolder.X-X)
	local DistanceToYBorder = math.min(Y,ScreenHolder.Y-Y)

	if DistanceToYBorder < DistanceToXBorder then 
		if Y < (ScreenHolder.Y-Y) then
			return math.clamp(X,0,ScreenHolder.X-Absolute.X),0
		else
			return math.clamp(X,0,ScreenHolder.X-Absolute.X),ScreenHolder.Y - Absolute.Y
		end
	else
		if X < (ScreenHolder.X-X) then
			return 0,math.clamp(Y,0,ScreenHolder.Y-Absolute.Y)
		else
			return ScreenHolder.X - Absolute.X,math.clamp(Y,0,ScreenHolder.Y-Absolute.Y)
		end
	end
end

function MarkerUI:ClearMarkers()
	for _,Stat in pairs(Markers) do
        local Marker = Stat[1]
        if Marker then
            Marker:Destroy();
        end
    end
    Markers ={};
end

function MarkerUI:BoundaryCheck(Gui1, Gui2)
	local bound = true
	
	local pos1, size1 = Gui1.AbsolutePosition, Gui1.AbsoluteSize;
	local pos2, size2 = Gui2.AbsolutePosition, Gui2.AbsoluteSize;

	local top = pos2.Y-pos1.Y
	local bottom = pos2.Y+size2.Y-(pos1.Y+size1.Y)
	local left = pos2.X-pos1.X
	local right = pos2.X+size2.X-(pos1.X+size1.X)

	if top > 0 then
		bound = false
	elseif bottom < 0 then
		bound = false
	end
	if left > 0 then
		bound = false
	elseif right < 0 then
		bound = false
	end
	return bound;
end

function MarkerUI:KnitStart()
    local MarkersGui = PlayerGui:WaitForChild("Markers")
    local Holder = MarkersGui:WaitForChild("Holder")
    local ScreenHolder = Holder.AbsoluteSize;

    local BillboardUI = GameLibrary:WaitForChild("BillboardUI")
    --local MarkerTemplate = BillboardUI:WaitForChild("MarkerUI")

    CollectionService:GetInstanceAddedSignal("Marker"):Connect(function(obj)
        local MarkerPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("MarkerPrefab");
        local TargetMarker = MarkerPrefab:Clone() do
            --TargetMarker:WaitForChild("RotateLabel").Visible = true;
            TargetMarker.Parent = Holder
            table.insert(Markers,{Marker = TargetMarker,Object = (obj:IsA("Model") and obj.PrimaryPart ~= nil and obj.PrimaryPart or obj)})
        end
    end)

    CollectionService:GetInstanceRemovedSignal("Marker"):Connect(function(obj)
        for i, marker in pairs(Markers) do
            if marker.Object == (obj:IsA("Model") and obj.PrimaryPart ~= nil and obj.PrimaryPart or obj) then
                marker.Marker:Destroy();
                table.remove(Markers, i)
            end
        end
    end)
    
    for _, obj in pairs(CollectionService:GetTagged("Marker")) do
        local MarkerPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("MarkerPrefab");
        local TargetMarker = MarkerPrefab:Clone() do
            TargetMarker.Parent = Holder
            table.insert(Markers,{Marker = TargetMarker, Object = (obj:IsA("Model") and obj.PrimaryPart ~= nil and obj.PrimaryPart or obj)})
        end
    end

    game:GetService("RunService").Heartbeat:Connect(function()
        for i,Stat in pairs(Markers) do
            local Marker, Object = Stat.Marker, Stat.Object
            if not Marker or not Object then continue end;
            Marker.Visible = true
    
            local MarkerPosition, MarkerVisible = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
            local MarkerRotation = workspace.CurrentCamera.CFrame:Inverse() * Object.CFrame
            local MarkerAbsolute = Marker.AbsoluteSize

            local MarkerPositionX = MarkerPosition.X - MarkerAbsolute.X/2
            local MarkerPositionY = MarkerPosition.Y - MarkerAbsolute.Y/2

            if MarkerPosition.Z < 0  then
                MarkerPositionX,MarkerPositionY = ClampMarkerToBorder(MarkerPositionX,MarkerPositionY,MarkerAbsolute)
            else
                if MarkerPositionX < 0 then
                    MarkerPositionX = 0
                elseif MarkerPositionX > (ScreenHolder.X - MarkerAbsolute.X) then
                    MarkerPositionX = ScreenHolder.X - MarkerAbsolute.X
                end
                if MarkerPositionY < 0 then
                    MarkerPositionY = 0
                elseif MarkerPositionY > (ScreenHolder.Y - MarkerAbsolute.Y) then
                    MarkerPositionY = ScreenHolder.Y - MarkerAbsolute.Y
                end
            end

            --Marker.RotateLabel.Visible = not MarkerVisible
            --Marker.RotateLabel.Rotation = 90 + math.deg(math.atan2(MarkerRotation.Z,MarkerRotation.X))
            Marker.Position = UDim2.new(0,MarkerPositionX,0,MarkerPositionY)
        end
    end)
end


function MarkerUI:KnitInit()
    
end


return MarkerUI
