local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
    
local TrapObject = {};
local Connections = {}
TrapObject.Cooldown = 45
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil
local Factor = 0.03

function TrapObject:OnAction()

	if not HasStarted then
		HasStarted = true

		Factor = 0.09

		task.wait(5)

		Factor = 0.03

		HasStarted = false
	end
end

function TrapObject:OnStart()
	for _, v in pairs(CollectionService:GetTagged("SpinningWheels")) do
		if v:IsA("Model") then
			task.spawn(function()
				while v:FindFirstChild("Spinner01") ~= nil do
					task.wait(0)
					if v:FindFirstChild("Spinner01") then
						v.Spinner01.CFrame = v.Spinner01.CFrame * CFrame.new(0, 0, 0) * CFrame.fromEulerAnglesXYZ(0, -Factor, 0)
						v.Spinner02.CFrame = v.Spinner02.CFrame * CFrame.new(0, 0, 0) * CFrame.fromEulerAnglesXYZ(0, -Factor, 0)
						v.Spinner02.RotVelocity = Vector3.new(0,-Factor*30,0)
					end
				end
			end)
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
                self:OnAction()
            end)
        else
            --print("[TrapObject] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
