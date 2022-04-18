local TweenService = game:GetService("TweenService")

local TrapObject = {};
local Connections = {}
TrapObject.Cooldown = 45
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedSnowball = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:SnowfallSection()
	local Snowfall = trapFolder.Snowfall
	if Snowfall then
		if not HasStartedSnowball then
			HasStartedSnowball = true
			
			for i,snow in pairs(trapFolder:GetChildren()) do
				if snow:IsA("MeshPart") and snow.Name == "Snowfall" then
					task.spawn(function()
						task.wait(i)
						if trapFolder:FindFirstChild("Prop") then
							local snowClone = snow:Clone()
							snowClone.Parent = trapFolder.Prop
							
							TweenService:Create(snowClone,TweenInfo.new(1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()
							snowClone.CanCollide = false
							task.wait(1)
							snowClone.Anchored = false
							
							task.wait(2)
							if snowClone then
								snowClone:Destroy()
							end
						end
					end)
				end
			end
			
			task.wait(8)
			
			trapFolder.Prop:ClearAllChildren()
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end

			HasStartedSnowball = false
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
                self:SnowfallSection()
            end)
        else
            --print("[Skull Fortress] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
