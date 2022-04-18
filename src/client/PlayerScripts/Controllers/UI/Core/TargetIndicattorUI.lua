local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService");
local CollectionService = game:GetService("CollectionService");

local TargetMarkers = {};

local TargetIndicattorUI = Knit.CreateController { Name = "TargetIndicattorUI" }

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui");

local WeaponsSystemGui = PlayerGui:WaitForChild("WeaponsSystemGui")
local TargetIndicatorsGui = PlayerGui:WaitForChild("TargetIndicators")

local Hitbox = TargetIndicatorsGui:WaitForChild("Hitbox")
local Holder = TargetIndicatorsGui:WaitForChild("Holder")
local ScreenHolder = Holder.AbsoluteSize;

local cooldownIcon = "rbxassetid://8652339450"
local readyIcon = "rbxassetid://8628556268"

function ClampMarkerToBorder(X,Y,Absolute)
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

function TargetIndicattorUI:ClearMarkers()
	for _,Stat in pairs(TargetMarkers) do
        local Marker = Stat[1]
        if Marker then
            Marker:Destroy();
        end
    end
    TargetMarkers ={};
end

function TargetIndicattorUI:BoundaryCheck(Gui1, Gui2)
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

function TargetIndicattorUI:KnitStart()
    CollectionService:GetInstanceAddedSignal("Target"):Connect(function(obj)
        local ArrowPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("Arrow");
        local TargetMarker = ArrowPrefab:Clone() do
            TargetMarker:WaitForChild("RotateLabel").Visible = true;
            TargetMarker.Parent = Holder
            table.insert(TargetMarkers,{TargetMarker,obj})
        end
    end)
    
    for _, v in pairs(CollectionService:GetTagged("Target")) do
        local ArrowPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("Arrow");
        local TargetMarker = ArrowPrefab:Clone() do
            TargetMarker.Parent = Holder
            table.insert(TargetMarkers,{TargetMarker,v})
        end
    end

    game:GetService("RunService").Heartbeat:Connect(function()
        for _,Stat in pairs(TargetMarkers) do
            local Marker, Target = Stat[1], Stat[2]
            Marker.Visible = false
            
            if WeaponsSystemGui and WeaponsSystemGui:FindFirstChild("Scope") then
                if WeaponsSystemGui:FindFirstChild("Scope").Visible == false then
                    continue;
                end
            else
                continue;
            end
            if self:BoundaryCheck(Marker, Hitbox) == false then
                if Target:GetAttribute("Enabled") == true then
                    Marker.Icon.Image = readyIcon
                    Marker.TimeLeft.Text = ""
                    Marker.RotateLabel.Arrow.ImageColor3 = Color3.fromRGB(255, 67, 67)
                    Marker.Visible = true
                elseif Target:GetAttribute("Cooldown") >= 0 then
                    Marker.Icon.Image = cooldownIcon
                    Marker.TimeLeft.Text = tostring(Target:GetAttribute("Cooldown")).."s"
                    Marker.RotateLabel.Arrow.ImageColor3 = Color3.fromRGB(255, 152, 67)
                    Marker.Visible = true
                end
            else
                if Target:GetAttribute("Cooldown") >= 0 then
                    Marker.Icon.Image = cooldownIcon
                    Marker.TimeLeft.Text = tostring(Target:GetAttribute("Cooldown")).."s"
                    Marker.RotateLabel.Arrow.ImageColor3 = Color3.fromRGB(255, 152, 67)
                    Marker.Visible = true
                end
            end
    
            if Target:GetAttribute("Enabled") or Target:GetAttribute("Cooldown") > 0 then
                local MarkerPosition, MarkerVisible = workspace.CurrentCamera:WorldToScreenPoint(Target.Position)
                local MarkerRotation = workspace.CurrentCamera.CFrame:Inverse() * Target.CFrame
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
    
                Marker.RotateLabel.Visible = not MarkerVisible
                Marker.RotateLabel.Rotation = 90 + math.deg(math.atan2(MarkerRotation.Z,MarkerRotation.X))
                Marker.Position = UDim2.new(0,MarkerPositionX,0,MarkerPositionY)
    
                --TweenService:Create(Marker,TweenInfo.new(.5),{ImageColor3 = Color3.fromRGB(170, 0, 0)}):Play()
            end
        end
    end)
end


function TargetIndicattorUI:KnitInit()
end


return TargetIndicattorUI