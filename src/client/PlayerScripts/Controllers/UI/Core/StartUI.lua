local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StartUI = Knit.CreateController { Name = "StartUI" }

local LocalPlayer = Players.LocalPlayer;

function StartUI:KnitStart()
    
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Camera = workspace.Camera

    local function Cinematic()
        local CinematicsFolder = ReplicatedStorage.RatIntro
        local RatIntroRig = workspace.IntroRat
        local prevRatIntroCFrame = nil;

        local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
        local CurrentCameraFOV = workspace.CurrentCamera.FieldOfView
        local FrameTime = 0
        local prevRatRigFrameTime = 0;
        local Connection
        -- Create an empty Part that will be used as the target for the tween
        local targetPart = Instance.new("Part");
        targetPart.CanCollide = false;
        targetPart.Anchored = true;
        targetPart.Size = Vector3.new(.1,.1,.1);
        targetPart.Name = "Target";
        targetPart.Parent = workspace;

        Character.Humanoid.AutoRotate = false
        Camera.CameraType = Enum.CameraType.Scriptable

        -- Create a PropertyChangedSignal for the targetPart's Position property
        local positionSignal = targetPart:GetPropertyChangedSignal("Position")
        positionSignal:Connect(function()
            print("tweennig")
            RatIntroRig:SetPrimaryPartCFrame(targetPart.CFrame)
        end)

        Connection = RunService.RenderStepped:Connect(function(DT)
            FrameTime += (DT * 60) 
            -- This will convert the seconds passed (DT) to the frame of the camera we need.
            -- Then it adds it to the total amount of time passed since the animation started

            local NeededFrame = CinematicsFolder.Frames:FindFirstChild(tonumber(math.ceil(FrameTime)))
            local NeededFOV = CinematicsFolder.FOV:FindFirstChild(tonumber(math.ceil(FrameTime)))

            local RatRigCFrame = CinematicsFolder.RatRig.CFrame:FindFirstChild(tonumber(math.ceil(FrameTime)))
            local RatRigMarker = CinematicsFolder.RatRig.MarkerTrack:FindFirstChild(tonumber(math.ceil(FrameTime)))

            if RatRigCFrame then
                local newCFrame = RatRigCFrame.Values:FindFirstChild("0").Value
                --if newCFrame == prevRatIntroCFrame then return end
                --prevRatIntroCFrame = newCFrame
                local timeDiff = FrameTime - prevRatRigFrameTime
                print(FrameTime, "| timeDiff", timeDiff / 60)
                prevRatRigFrameTime = FrameTime
                local tweenInfo = TweenInfo.new(timeDiff / 60, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(targetPart, tweenInfo, {CFrame = newCFrame})
                print(targetPart)
                tween:Play()
            end

            if RatRigMarker then
                --print("MARKER:", RatRigMarker:FindFirstChild("name").Value)
            end

            if NeededFrame then
                Camera.CFrame = NeededFrame.Value
                Camera.FieldOfView = NeededFOV ~= nil and NeededFOV.Value or 70
            else
                Connection:Disconnect()
                Character.Humanoid.AutoRotate = true
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CFrame = CurrentCameraCFrame	
                Camera.FieldOfView = CurrentCameraFOV	
            end
        end)
    end

    local loaded = LocalPlayer:HasAppearanceLoaded()
	print(loaded)

	while not loaded do
		loaded = LocalPlayer:HasAppearanceLoaded()
		print(loaded)
		task.wait()
	end

    --Cinematic()
    
end


function StartUI:KnitInit()
    
end


return StartUI
