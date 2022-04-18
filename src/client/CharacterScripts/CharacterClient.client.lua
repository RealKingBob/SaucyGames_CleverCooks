local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local contentProvider = game:GetService("ContentProvider")

local player = game.Players.LocalPlayer
local char = player.Character or player.ChildAdded:Wait()
local hum = char:WaitForChild("Humanoid")

task.wait(0.1)

if hum.Parent:FindFirstChild("Sphere") then
	-- // DenseDad
	-- // Animations here, make a folder called "Animations" inside the starterCharacter and add in animations named accordingly below. "Run", "Sit", "Jump", "Fall"
	-- // If you don't need as many animations remove the ones you don't want. Sit = Idle basically
	local Animations = char:WaitForChild("Animations")
	hum = char:FindFirstChild("Humanoid")
	if hum and not CollectionService:HasTag(player, "Hunter") then
		if char.Parent == nil or hum.Parent ~= char then
            return;
        end
		local runAnim = hum:LoadAnimation(Animations:WaitForChild("Run"))
		local sitAnim = hum:LoadAnimation(Animations:WaitForChild("Sit"))
		local jumpAnim = hum:LoadAnimation(Animations:WaitForChild("Jump"))
		local fallAnim = hum:LoadAnimation(Animations:WaitForChild("Fall"))
		
		local running = false
		local jumping = false
		local falling = false
		
		runAnim.Priority = "Action"
		sitAnim.Priority = "Action"
		jumpAnim.Priority = "Action"
		fallAnim.Priority = "Action"
		
		local preloadAssets = {runAnim,sitAnim,jumpAnim,fallAnim}
		contentProvider:PreloadAsync(preloadAssets)
		
		--[[runAnim:GetMarkerReachedSignal("Step"):Connect(function()
			local newSound = char:FindFirstChild("Sphere"):WaitForChild("Step"):Clone()
			newSound.Parent = char:FindFirstChild("Sphere")
			newSound.PlaybackSpeed = math.random(60,90) / 100
			newSound:Play()
			task.wait(3)
			newSound:Destroy()
		end)]]
		
		hum.StateChanged:Connect(function(old,state)
			if state == Enum.HumanoidStateType.Jumping then
				jumping = true
				jumpAnim:Play()
				jumpAnim:AdjustSpeed(.75)
			elseif state == Enum.HumanoidStateType.Landed then
				jumping = false
				falling = false
				fallAnim:Stop()
			elseif state == Enum.HumanoidStateType.Freefall then
				falling = true
			end
		end)
		
		runService.RenderStepped:Connect(function()
			if char ~= nil and hum ~= nil and hum.Health ~= 0 then
			
				if jumpAnim.IsPlaying == false and falling == true then
					if fallAnim.IsPlaying == false then
						fallAnim:Play()
					end
				end
			
				if jumping == false and falling == false then
					
					if hum.MoveDirection ~= Vector3.new(0,0,0) then
						running = true
						if sitAnim.IsPlaying == true then
							sitAnim:Stop()
						end
						if runAnim.IsPlaying == false then
							runAnim:Play()
							runAnim:AdjustSpeed(1.5)
						end
					else
						running = false
						if runAnim.IsPlaying == true then
								runAnim:Stop()
						end
						if sitAnim.IsPlaying == false then
							sitAnim:Play()
						end
					end
				else
					sitAnim:Stop()
					runAnim:Stop()
				end
			end
		end)
	end
end