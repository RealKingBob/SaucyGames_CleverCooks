local Connections = {}
local TrapObject = {};

local oneTimeUse = false
TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedBoulder = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:DropBoulder()
	local Boulder = trapFolder.Boulder
	
	local Wood1 = trapFolder.Wood1
	local Wood2 = trapFolder.Wood2
	local Wood3 = trapFolder.Wood3
	if Boulder and not oneTimeUse then
		if not HasStartedBoulder then
			oneTimeUse = true
			HasStartedBoulder = true
			
			Connections[#Connections + 1] = Boulder.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = -1
				end
			end)
			
			Boulder.Anchored = false
			trapFolder.Wall:Destroy()
			task.spawn(function()
				task.wait(1.4)
				Wood1.Anchored = false
				Wood1.CanCollide = false
				Wood2.Anchored = false
				Wood2.CanCollide = false
				Wood3.Anchored = false
				Wood3.CanCollide = false
			end)
			Boulder.Sound:Play()
			
			task.wait(5)
			
			Boulder:Destroy()
			
			HasStartedBoulder = false
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
                --self:DropBoulder()
            end)
        else
            --print("[Skull Fortress] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
