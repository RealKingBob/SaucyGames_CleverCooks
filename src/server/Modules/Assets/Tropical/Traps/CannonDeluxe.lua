local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedCannon = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:ShootCannons()
	local Cannon1 = trapFolder.Cannon1
	local Cannon2 = trapFolder.Cannon2
	
	local CannonSpot1 = trapFolder.CannonSpot1
	local CannonSpot2 = trapFolder.CannonSpot2
	
	local Explosion = trapFolder.Explosion
	
	local CannonBall1 = trapFolder.CannonBall1
	local CannonBall2 = trapFolder.CannonBall2
	
	if Cannon1 then
		if not HasStartedCannon then
			local function explosion(pos)

				local newExplosion = Explosion:Clone()
				newExplosion.Parent = workspace
				newExplosion:SetPrimaryPartCFrame(CFrame.new(pos))

				local newSound = newExplosion.PrimaryPart:WaitForChild("ExSound")
				newSound:Play()

				for i,v in pairs(newExplosion:GetChildren()) do
					local cf = v.CFrame * CFrame.Angles(math.random(360),math.random(360),math.random(360))
					game:GetService("TweenService"):Create(v,TweenInfo.new(.1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()

					Connections[#Connections + 1] = v.Touched:Connect(function(hit)
						local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
						if humanoid then
							humanoid.Health = -1
						end
					end)

				end
				task.wait(.1)
				for i,v in pairs(newExplosion:GetChildren()) do
					local cf = v.CFrame * CFrame.Angles(math.random(360),math.random(360),math.random(360))
					game:GetService("TweenService"):Create(v,TweenInfo.new(.5),{Size =v.Size + Vector3.new(15,15,15) , Transparency = 1 , CFrame = cf}):Play()
				end
				task.wait(.5)
				newExplosion:Destroy()
			end

			if Cannon1 then

				local newSound = Cannon1:WaitForChild("CannonSound"):Clone()
				newSound.Parent = Cannon1.Metal
				newSound:Play()
				
				local newSound2 = Cannon2:WaitForChild("CannonSound"):Clone()
				newSound2.Parent = Cannon2.Metal
				newSound2:Play()
				
				local newCan

				task.spawn(function()
					newCan = CannonBall1:Clone()
					newCan.Parent = trapFolder
					newCan.Transparency = 0
					CannonBall1.Transparency = 1
					newCan.CFrame = CannonBall1.CFrame
					game:GetService("TweenService"):Create(newCan,TweenInfo.new(.25,Enum.EasingStyle.Linear),{CFrame = CannonSpot1.CFrame}):Play()
					task.wait(.25)
				end)
				
				local newCan2 = CannonBall2:Clone()
				newCan2.Parent = trapFolder
				newCan2.Transparency = 0
				CannonBall2.Transparency = 1
				newCan2.CFrame = CannonBall2.CFrame
				game:GetService("TweenService"):Create(newCan2,TweenInfo.new(.25,Enum.EasingStyle.Linear),{CFrame = CannonSpot2.CFrame}):Play()
				task.wait(.25)

				task.spawn(function()
					explosion(CannonSpot1.Position)
				end)
				explosion(CannonSpot2.Position)
				newCan:Destroy()
				newCan2:Destroy()
				
				for i = 1,#Connections do
					Connections[i]:Disconnect()
				end

				newSound:Destroy()
				newSound2:Destroy()
			end
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
                --self:ShootCannons()
            end)
        else
            --print("[Shoot Cannon Deluxe] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;