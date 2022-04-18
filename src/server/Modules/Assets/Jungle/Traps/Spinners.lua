local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil
local Num = 0.005

function TrapObject:OnAction()
	if trapFolder then
		if not HasStarted then
			HasStarted = true

			Num = 0.05

			task.wait(5)
			
			Num = 0.005

			HasStarted = false
		end
	end
end

function TrapObject:OnStart()
	for _, v in pairs(CollectionService:GetTagged("Spinners")) do
		if v:IsA("Model") then
			task.spawn(function()
				while v.PrimaryPart ~= nil do
					if v.PrimaryPart then
						v.PrimaryPart.CFrame = v.PrimaryPart.CFrame * CFrame.new(0, 0, 0) * CFrame.fromEulerAnglesXYZ(0, Num, 0)
						task.wait()
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
                --self:OnAction()
            end)
        else
            --print("[TrapObject] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
