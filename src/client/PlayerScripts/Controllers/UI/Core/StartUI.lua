local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StartUI = Knit.CreateController { Name = "StartUI" }


function StartUI:KnitStart()
    local RunService = game:GetService("RunService")

    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local Camera = workspace.Camera

    local function Cinematic()
        local CinematicsFolder = ReplicatedStorage.RatIntro

        local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
        local CurrentCameraFOV = workspace.CurrentCamera.FieldOfView
        local FrameTime = 0
        local Connection
        
        Character.Humanoid.AutoRotate = false
        Camera.CameraType = Enum.CameraType.Scriptable
        

        Connection = RunService.RenderStepped:Connect(function(DT)
            FrameTime += (DT * 60) 
            -- This will convert the seconds passed (DT) to the frame of the camera we need.
            -- Then it adds it to the total amount of time passed since the animation started
            
            local NeededFrame = CinematicsFolder.Frames:FindFirstChild(tonumber(math.ceil(FrameTime)))
            local NeededFOV = CinematicsFolder.FOV:FindFirstChild(tonumber(math.ceil(FrameTime)))
            
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

    Cinematic()
end


function StartUI:KnitInit()
    
end


return StartUI
