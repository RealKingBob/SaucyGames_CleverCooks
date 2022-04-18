local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedShark = false
local trapFolder = nil

function TrapObject:OnStart()
	
end


function TrapObject:SpawnShark()
	local SharkMob = trapFolder.Shark
	local killPart = trapFolder.KillPart
	if SharkMob then
		if not HasStartedShark then
			HasStartedShark = true
			
			local SharkClone = SharkMob:Clone()
			SharkClone.Parent = trapFolder
			
			SharkClone.Shark.Transparency = 0
			
			Connections[#Connections + 1] = killPart.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = -1
				end
			end)
			
			local SharkBiteAnimation = Instance.new("Animation")
			SharkBiteAnimation.AnimationId = "rbxassetid://8239274777"
			
			local Controller = SharkClone:WaitForChild("AnimationController")
			
			local animationTrack = Controller:LoadAnimation(SharkBiteAnimation)

			-- Play the animation
			animationTrack:Play()

			task.wait(2.7)
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end
			
			SharkClone:Destroy()
			
			HasStartedShark = false
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
                self:SpawnShark()
            end)
        else
            --print("[Spawn Shark] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;