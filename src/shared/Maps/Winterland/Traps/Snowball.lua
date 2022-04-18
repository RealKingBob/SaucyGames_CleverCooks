local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

local oneTimeUse = false
TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedSnowball = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:Snowball()
	local IceBridge = trapFolder.IceBridge
	local Rock = trapFolder.Rock
	local ToxicIce = trapFolder.ToxicIce
	local BigSnowball = trapFolder.BigSnowball
	if BigSnowball then
		if not HasStartedSnowball then
			HasStartedSnowball = true
			
			local newBall = BigSnowball:Clone()
			newBall.Parent = trapFolder.Prop

			newBall.Transparency = 0
			newBall.CanCollide = true
			
			BigSnowball.Transparency = 1
			BigSnowball.CanCollide = false
			
			Rock.Transparency = 1

			newBall.Anchored = false
			newBall.Sound:Play()

			task.wait(4)
			
			local newBridge = IceBridge:Clone()
			newBridge.Parent = trapFolder

			newBridge.Transparency = 0.25
			newBridge.CanCollide = false
			newBridge.Anchored = false

			IceBridge.Transparency = 1
			IceBridge.CanCollide = false
			IceBridge.Anchored = true

			Rock.Transparency = 1

			if newBall then
				newBall:Destroy()
			end
			
			Rock.Transparency = 0
			
			trapFolder.Prop:ClearAllChildren()
			
			task.spawn(function()
				task.wait(5)
				if newBridge then
					newBridge:Destroy()
				end
				IceBridge.Transparency = 0.25
				IceBridge.CanCollide = true
				IceBridge.Anchored = true
			end)
			
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
                self:Snowball()
            end)
        else
            --print("[Rocks and Spikes Trap] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;