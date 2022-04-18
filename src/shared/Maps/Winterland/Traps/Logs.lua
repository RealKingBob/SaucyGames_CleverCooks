local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:LogFall()
	local Log = trapFolder.Snowfall
	if Log then
		if not HasStarted then
			HasStarted = true
			
			for i = 1, 3 do
				task.wait(math.random(1,3))
				for a,log in pairs(trapFolder:GetChildren()) do
					if log:IsA("Model") and log.Name == "Log" then
						task.spawn(function()
							task.wait(a)
							local logClone = log:Clone()
							logClone.Parent = trapFolder.Prop

							logClone.PrimaryPart.CanCollide = true
							logClone.PrimaryPart.Anchored = false

							task.wait(4)
							if logClone then
								logClone:Destroy()
							end
						end)
					end
				end
			end

			task.wait(10)
			
			trapFolder.Prop:ClearAllChildren()
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end

			HasStarted = false
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
                self:LogFall()
            end)
        else
            --print("[LogFall] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;