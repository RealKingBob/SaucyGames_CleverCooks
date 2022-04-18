local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 60
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedKrakenAttack = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:AttackKraken()
	local SwimAnimation = trapFolder.SwimAnimation
	local AttackAnimation = trapFolder.AttackAnimation
	
	local SoundBlock = trapFolder.SoundBlock
	if trapFolder then
		if not HasStartedKrakenAttack then
			HasStartedKrakenAttack = true
			
			for _, krakenArm in pairs(trapFolder:GetChildren()) do
				if krakenArm:IsA("Model") and krakenArm.Name == "Tentacle" then
					local Controller = krakenArm:WaitForChild("AnimationController")

					local animationTrack = Controller:LoadAnimation(AttackAnimation)

					animationTrack:Play()
				end
			end

			task.wait(4.6)
			
			for _, killPart in pairs(trapFolder:GetChildren()) do
				if killPart.Name == "KillPart" then
					Connections[#Connections + 1] = killPart.Touched:Connect(function(hit)
						--print(hit)
						local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
						if humanoid then
							humanoid.Health = -1
						end
					end)
				end
			end
			
			SoundBlock.Splash:Play()
			SoundBlock.WoodBreak:Play()
			
			task.wait(2)
			
			for _, krakenArm in pairs(trapFolder:GetChildren()) do
				if krakenArm:IsA("Model") and krakenArm.Name == "Tentacle" then
					local Controller = krakenArm:WaitForChild("AnimationController")

					local animationTrack = Controller:LoadAnimation(SwimAnimation)
					
					animationTrack.Looped = true
					animationTrack:Play()
				end
			end

			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end
			
			HasStartedKrakenAttack = false
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
                self:AttackKraken()
            end)
        else
            --print("[Spawn Kraken] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
