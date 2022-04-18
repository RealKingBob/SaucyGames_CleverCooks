local TrapObject = {};
local TweenService = game:GetService("TweenService");

TrapObject.Cooldown = 40
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnAction()
	print("On Action")
	for _, object in pairs(trapFolder:GetChildren()) do
		local objectClone = object:Clone()
		objectClone.CanCollide = true
		objectClone.Transparency = 0
		objectClone.Anchored = false
		objectClone.Parent = trapFolder

		task.delay(6, function()
			if objectClone then
				objectClone:Destroy()
			end
		end)
	end
end

function TrapObject:OnStart()
	
end

function TrapObject:Activate(targetObject)
    if not targetObject then
        return
    end
    trapFolder = targetObject.Parent.Parent:FindFirstChild("Trap")
    if trapFolder then
        if (self.StartTime == 0) or (tick() - self.StartTime >= self.Cooldown) then
            print("[Chocolate]: Activated")
            self.StartTime = tick()
			self.Activated = true
            task.spawn(function()
                self:OnAction()
            end)
        else
            --print("[Chocolate] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;