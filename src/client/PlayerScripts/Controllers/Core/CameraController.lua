--// Services
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--// Variables
local PlayerGUI = Players.LocalPlayer.PlayerGui
local cam = game.Workspace.CurrentCamera
local debounce = false
local prevEnabled = true

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--// Controllers
local CameraController = Knit.CreateController { Name = "CameraController" }

--// Private Functions
local coreCall do
    local MAX_RETRIES = 8

    local StarterGui = game:GetService('StarterGui')
    local RunService = game:GetService('RunService')

    function coreCall(method, ...)
        local result = {}
        for retries = 1, MAX_RETRIES do
            result = {pcall(StarterGui[method], StarterGui, ...)}
            if result[1] then
                break
            end
            RunService.Stepped:Wait()
        end
        return unpack(result)
    end
end

function CameraController:KillCam(killerPlayer)
	--print("KILL CAM: ", killerPlayer);
	if killerPlayer then
		local KillCamGUI = PlayerGUI:WaitForChild("KillCam")
		local MainFrame = KillCamGUI:WaitForChild("MainFrame")
		local PlayerText = MainFrame:WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("PlayerText")
		task.wait(0.3)
		if killerPlayer and killerPlayer.Character then
			pcall(function() cam.CameraSubject = killerPlayer.Character.Humanoid end)
		end
		PlayerText.Text = tostring(killerPlayer);
		KillCamGUI.Enabled = true;

		task.delay(2, function()
			KillCamGUI.Enabled = false;
		end)
	end
end

function CameraController:CutsceneIntro(MapModel, GameMode) --// [MapModel : Instance]
	local a = tick()
	--// Variables
    local CurrentCamera = workspace.CurrentCamera
	local UIController = Knit.GetController("GameUI")
	local MainGUI = PlayerGUI:WaitForChild("MainGUI")
	local Blackout = MainGUI:WaitForChild("Blackout")
	local CircleRound = MainGUI:WaitForChild("CircleRound");
	--local MainScreenFrame = MainGUI:WaitForChild("MainScreen")
 
	if MapModel then
		--// Proceeds with getting CameraData points and just tweening making it a cutscene.
		local MapCameras = MapModel.CameraData
		coreCall('SetCore', 'ResetButtonCallback', false)

		--TweenService:Create(Blackout,TweenInfo.new(1),{Transparency = 0}):Play()
		Knit.GetController("DashUI"):Visible(false);
		CircleRound.Visible = true;
		TweenService:Create(CircleRound,TweenInfo.new(.85, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),{Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(1)
		Blackout.Transparency = 0;
		CircleRound.Size = UDim2.new(6, 0, 6, 0);
		CircleRound.Visible = false;
		--MainScreenFrame.Visible = false

		CurrentCamera.CameraSubject = nil
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		CurrentCamera.CFrame = MapCameras.Camera1.CFrame

		task.spawn(function()
			UIController:LoadingScreen(tostring(MapModel), tostring(GameMode))
		end)

		task.wait(9.6)

		TweenService:Create(CurrentCamera,TweenInfo.new(4,Enum.EasingStyle.Linear),{CFrame = MapCameras.Camera1_Spot2.CFrame}):Play()
		TweenService:Create(Blackout,TweenInfo.new(1),{Transparency = 1}):Play()
		task.wait(4)
		
		CurrentCamera.CFrame = MapCameras.Camera2.CFrame
		TweenService:Create(CurrentCamera,TweenInfo.new(4,Enum.EasingStyle.Linear),{CFrame = MapCameras.Camera2_Spot2.CFrame}):Play()
		task.wait(4)

		CurrentCamera.CFrame = MapCameras.Camera3.CFrame
		TweenService:Create(CurrentCamera,TweenInfo.new(4,Enum.EasingStyle.Linear),{CFrame = MapCameras.Camera3_Spot2.CFrame}):Play()
		task.wait(3)
		
		TweenService:Create(Blackout,TweenInfo.new(1),{Transparency = 0}):Play()
		task.wait(1)
		--CircleRound.Size = UDim2.new(0, 0, 0, 0);
		--Blackout.Transparency = 1;
		
		CurrentCamera.CameraSubject = Players.LocalPlayer.Character.HumanoidRootPart
		CurrentCamera.CameraType = Enum.CameraType.Custom

		--// If the player is in-game disable the UI
		if CollectionService:HasTag(Players.LocalPlayer, "Duck") or
		CollectionService:HasTag(Players.LocalPlayer, "Hunter") then
			--MainScreenFrame.Visible = false
		else
			--MainScreenFrame.Visible = true
		end
		
		--TweenService:Create(CircleRound,TweenInfo.new(.85, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),{Size = UDim2.new(3, 0, 3, 0)}):Play()
		TweenService:Create(Blackout,TweenInfo.new(1),{Transparency = 1}):Play()
		task.wait(1)
		UIController:Countdown()
		print("Cutscene Elapsed Time:", tick() - a)
    end
end

function CameraController:DisableCamera(enabled)
	--print("Camera Hunter:", enabled)
	if prevEnabled == enabled then
		return
	end
	prevEnabled = enabled
	local plr = game:GetService("Players").LocalPlayer
	local TargetIndicators = PlayerGUI:WaitForChild("TargetIndicators")
	local char = plr.Character or plr.CharacterAdded:Wait()
	
	local camModule = require(ReplicatedStorage.Common.WeaponsSystem.WeaponsSystem)
	camModule.camera:setEnabled(enabled)
	if enabled then
		workspace.CurrentCamera.CameraSubject = char:FindFirstChild("HumanoidRootPart")
	end
	if char:FindFirstChildWhichIsA("Tool") then
		local weapon = char:FindFirstChildWhichIsA("Tool")
		if CollectionService:HasTag(weapon,"WeaponsSystemWeapon") then
			camModule.gui:setEnabled(true)
			Knit.GetController("DashUI"):Visible(false);
			TargetIndicators.Enabled = true
			local CurrentMap = workspace:FindFirstChild("CurrentMap")
			if #CurrentMap:GetChildren() > 0 then
				local Map = CurrentMap:GetChildren()[1]
				for _, child in pairs (Map:GetDescendants()) do
					if child:IsA("Part") then
						if child.Transparency == 1 and child.CanCollide == true then
							if not CollectionService:HasTag(child, "KillPart") then
								child:Destroy();
							end
						end
					end
				end
			end
			task.spawn(function()
				task.wait(1)
				if CollectionService:HasTag(plr, "Duck") then
					camModule.gui:setEnabled(false)
					Knit.GetController("DashUI"):Visible(true);
					TargetIndicators.Enabled = false
				end
			end)
		else
			TargetIndicators.Enabled = false
			camModule.gui:setEnabled(false)
			Knit.GetController("DashUI"):Visible(true);
		end
	else
		TargetIndicators.Enabled = false
		camModule.gui:setEnabled(false)
		Knit.GetController("DashUI"):Visible(true);
	end
	camModule.camera.mouseLocked = enabled
	--print("Camera mouseLocked:", enabled)
	if not enabled then 
		workspace.CurrentCamera.CameraSubject = char:FindFirstChild("Humanoid") 
		workspace.CurrentCamera.DiagonalFieldOfView = 127.833;
		workspace.CurrentCamera.FieldOfView = 70;
		workspace.CurrentCamera.MaxAxisFieldOfView = 102.5;
		workspace.CurrentCamera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical;
	end
end

function CameraController:setupConnections()
	--print("CameraController setup connections")
	local GameService = Knit.GetService("GameService")
    local CutsceneService = Knit.GetService("CutsceneService")

	GameService.HunterCameraSignal:Connect(function(enabled)
		self:DisableCamera(enabled)
	end)

	GameService.KillCam:Connect(function(player)
		print('CALLED:', player)
		self:KillCam(player)
	end)

    CutsceneService.CutsceneIntroSignal:Connect(function(mapModel, gameMode)
		--print("cutscene intro:", mapModel, gameMode)
        self:CutsceneIntro(mapModel, gameMode)
    end)

    CutsceneService.CutsceneEndSignal:Connect(function(player)

    end)

	self:DisableCamera(false)

end

function CameraController:KnitInit()
    --print("CameraController KnitInit called")
end


function CameraController:KnitStart()
    --print("CameraController KnitStart called")
    self:setupConnections()
end


return CameraController
