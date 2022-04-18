local TweenService = game:GetService("TweenService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedWaterFlood = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:WaterFlood()
	local Wave = trapFolder.Wave
	local Dam1 = trapFolder.Dam1
	local Dam2 = trapFolder.Dam2
	local WavePath = trapFolder.Path
	if Wave then
		if not HasStartedWaterFlood then
			HasStartedWaterFlood = true

			--Wave:WaitForChild("WaveSound"):Play()

			local newWave = Wave:Clone()
			newWave.Parent = trapFolder.TemporaryWave
			
			newWave.Water.Transparency = 0

			local partCount = 0
			
			for _,v in pairs(Dam1:GetDescendants()) do
				if v:IsA("MeshPart") then
					v.Transparency = 1
				end
			end
			
			for _,v in pairs(Dam2:GetDescendants()) do
				if v:IsA("MeshPart") then
					v.Transparency = 1
				end
			end
				
			
			--[[for _,v : MeshPart in pairs(Dam1:GetDescendants()) do
				v.Transparency = 1
			end
			
			for _,v : MeshPart in pairs(Dam2:GetDescendants()) do
				v.Transparency = 1
			end]]
			
			
			for i,v in pairs(WavePath:GetChildren()) do
				if v:IsA("BasePart") then
					partCount += 1
				end
			end

			for i = 1, partCount do
				if WavePath:FindFirstChild(tostring(i)) then
					local part = WavePath:FindFirstChild(tostring(i))

					local tTime = (newWave.PrimaryPart.Position - part.Position).Magnitude / 60
					TweenService:Create(newWave.PrimaryPart,TweenInfo.new(tTime,Enum.EasingStyle.Linear),{CFrame = part.CFrame}):Play()

					wait(tTime)
				end
			end

			wait(2)
			for _,v in pairs(Dam1:GetDescendants()) do
				if v:IsA("MeshPart") then
					v.Transparency = 0
				end
			end

			for _,v in pairs(Dam2:GetDescendants()) do
				if v:IsA("MeshPart") then
					v.Transparency = 0
				end
			end
			trapFolder.TemporaryWave:ClearAllChildren()
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end

			HasStartedWaterFlood = false
		end
	end
end

function TrapObject:Activate(targetObject)
    if not targetObject then
        return
    end
    trapFolder = targetObject.Parent.Parent:FindFirstChild("Trap")
    if trapFolder then
        if (self.StartTime == 0) or (tick() - self.StartTime >= self.Cooldown) then
            self.StartTime = tick()
			self.Activated = true
            task.spawn(function()
                self:WaterFlood()
            end)
        else
            --print("[Volcano Meteor] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
