local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil
local spinTime = 2

function TrapObject:OnAction()
	--[[if trapFolder then
		if not HasStarted then
			HasStarted = true

			spinTime = 0.5

			task.wait(5)

			spinTime = 2

			HasStarted = false
		end
	end]]
end

function TrapObject:OnStart()
	task.wait(1)
	for _, part in pairs(CollectionService:GetTagged("Sliders")) do
		task.spawn(function()
			task.wait(math.random(10,50) / 10)
			if part.Name == "SliderR" then
				TweenService:Create(part,TweenInfo.new(1,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),{Position = Vector3.new(part.Position.X + 27.507995605469,part.Position.Y , part.Position.Z + 7.3710021972656)}):Play()
			elseif part.Name == "Slider" then
				TweenService:Create(part,TweenInfo.new(1,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),{Position = Vector3.new(part.Position.X - 27.507995605469,part.Position.Y , part.Position.Z - 7.3710021972656)}):Play()
			end
			local hitDeb = false
			
			part.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if humanoid then
					if hitDeb == false then
						hitDeb = true
						humanoid.Sit = true
						hitDeb = false
					end
				end
			end)
		end)
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
