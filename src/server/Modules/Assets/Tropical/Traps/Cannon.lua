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

function TrapObject:ShootCannon()
	local Cannon = trapFolder.Cannon
	local CannonSpot = trapFolder.CannonSpot
	local Explosion = trapFolder.Explosion
	local CannonBall = trapFolder.CannonBall
	if Cannon then
		if not HasStartedCannon then
			local function explosion(pos)

				local newExplosion = Explosion:Clone()
				newExplosion.Parent = workspace
				newExplosion:SetPrimaryPartCFrame(CFrame.new(pos))

				local newSound = newExplosion.PrimaryPart:WaitForChild("ExSound")
				newSound:Play()

				for i,v in pairs(newExplosion:GetChildren()) do
					local cf = v.CFrame * CFrame.Angles(math.random(360),math.random(360),math.random(360))
					TweenService:Create(v,TweenInfo.new(.1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()

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
					TweenService:Create(v,TweenInfo.new(.5),{Size =v.Size + Vector3.new(15,15,15) , Transparency = 1 , CFrame = cf}):Play()
				end
				task.wait(.5)
				newExplosion:Destroy()
			end

			if Cannon then
				local cannon = Cannon
				local endSpot = CannonSpot

				local newSound = Cannon:WaitForChild("CannonSound"):Clone()
				newSound.Parent = cannon.Metal
				newSound:Play()

				local newCan = CannonBall:Clone()
				newCan.Parent = trapFolder
				newCan.Transparency = 0
				CannonBall.Transparency = 1
				newCan.CFrame = CannonBall.CFrame
				TweenService:Create(newCan,TweenInfo.new(.25,Enum.EasingStyle.Linear),{CFrame = endSpot.CFrame}):Play()
				task.wait(.25)

				explosion(endSpot.Position)
				newCan:Destroy()
				
				for i = 1,#Connections do
					Connections[i]:Disconnect()
				end

				newSound:Destroy()

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
                --self:ShootCannon()
            end)
        else
            --print("[Shoot Cannon] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;