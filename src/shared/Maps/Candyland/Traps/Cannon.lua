local TrapObject = {};
local TweenService = game:GetService("TweenService");

TrapObject.Cooldown = 40
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnAction()
	print("On Action")
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
            --print("[Cannon]: Activated")
            self.StartTime = tick()
			self.Activated = true
            task.spawn(function()
                self:OnAction()
            end)
        else
            --print("[Cannon] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;