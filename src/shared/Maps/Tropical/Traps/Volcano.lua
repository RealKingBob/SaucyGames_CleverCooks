local TweenService = game:GetService("TweenService")

local TrapObject = {};

TrapObject.Cooldown = 45
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedLava = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:RiseLava()
	local Lava1 = trapFolder.Lava1
	local Lava2 = trapFolder.Lava2
	if Lava1 and not HasStartedLava then
		HasStartedLava = true
		
		TweenService:Create(Lava2,TweenInfo.new(2),{CFrame = Lava2.CFrame + Vector3.new(-12,0,0)}):Play()
		TweenService:Create(Lava1,TweenInfo.new(2),{CFrame = Lava1.CFrame + Vector3.new(0,2,0)}):Play()

		task.wait(7)

		TweenService:Create(Lava2,TweenInfo.new(2),{CFrame = Lava2.CFrame + Vector3.new(12,0,0)}):Play()
		TweenService:Create(Lava1,TweenInfo.new(2),{CFrame = Lava1.CFrame + Vector3.new(0,-2,0)}):Play()

		HasStartedLava = false
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
                self:RiseLava()
            end)
        else
            --print("[Skull Fortress] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
