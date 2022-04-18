local TweenService = game:GetService("TweenService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedVolcano = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:VolcanoEruption()
	local Volcano = trapFolder.Volcano
	local VolcanoPath = trapFolder.VolcanoPath
	local Meteor = trapFolder.Meteor
	local MeteorsFolder = trapFolder.Meteors
	local ExplosionFolder = trapFolder.Explosions
	local Explosion = trapFolder.Explosion
	if Meteor then
		if not HasStartedVolcano then
			HasStartedVolcano = true

			Volcano:WaitForChild("VolcanoSound"):Play()

			local newRock = Meteor:Clone()
			newRock.Parent = workspace

			local partCount = 0

			for _,v in pairs(VolcanoPath:GetChildren()) do
				if v:IsA("BasePart") then
					partCount += 1
				end
			end
			
			MeteorsFolder.ChildAdded:Connect(function(Object)
				for i = 1,2 do
					local newTime = 0
					local newPart = nil
					if Object.Name == "R" then
						newPart = VolcanoPath:WaitForChild("R"):FindFirstChild(tostring(i))
						newTime = (Object.Position - newPart.Position).Magnitude / 200
					else
						newPart = VolcanoPath:WaitForChild("L"):FindFirstChild(tostring(i))
						newTime = (Object.Position - newPart.Position).Magnitude / 200
					end
					TweenService:Create(Object,TweenInfo.new(newTime,Enum.EasingStyle.Linear),{CFrame = newPart.CFrame}):Play()
					task.wait(newTime)
				end
			end)

			for i = 1, partCount do
				if VolcanoPath:FindFirstChild(tostring(i)) then
					local part = VolcanoPath:FindFirstChild(tostring(i))

					local tTime = (newRock.Position - part.Position).Magnitude / 200
					TweenService:Create(newRock,TweenInfo.new(tTime,Enum.EasingStyle.Linear),{CFrame = part.CFrame}):Play()

					if i == 6 then
						local r = false
						for c = 1,2 do
							if r == false then
								r = true
								local p = newRock:Clone()
								p.Name = "R"
								p.Parent = MeteorsFolder
							else
								local p = newRock:Clone()
								p.Name = "L"
								p.Parent = MeteorsFolder
							end
						end
					end
					task.wait(tTime)
				end
			end

			local function explosion(pos)

				local newExplosion = Explosion:Clone()
				newExplosion.Parent = workspace
				newExplosion:SetPrimaryPartCFrame(CFrame.new(pos))

				newExplosion.PrimaryPart.ExSound:Play()

				for i,v in pairs(newExplosion:GetChildren()) do
					if v:IsA("MeshPart") then
						local cf = v.CFrame * CFrame.Angles(math.random(360),math.random(360),math.random(360))
						TweenService:Create(v,TweenInfo.new(.1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()
	
						Connections[#Connections + 1] = v.Touched:Connect(function(hit)
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
							if humanoid then
								humanoid.Health = -1
							end
						end)
					end
				end
				task.wait(.1)
				for i,v in pairs(newExplosion:GetChildren()) do
					if v:IsA("MeshPart") then
						local cf = v.CFrame * CFrame.Angles(math.random(360),math.random(360),math.random(360))
						TweenService:Create(v,TweenInfo.new(.5),{Size =v.Size + Vector3.new(25,25,25) , Transparency = 1 , CFrame = cf}):Play()
					end
				end
				task.wait(.5)

				newExplosion:Destroy()
			end


			ExplosionFolder.ChildAdded:Connect(function(child)
				task.wait(.25)
				explosion(child.Position)
				child:Destroy()
			end)

			TweenService:Create(newRock,TweenInfo.new(.25),{Size = Vector3.new(1,1,1)}):Play()
			newRock.Parent = ExplosionFolder
			for _,v in pairs(MeteorsFolder:GetChildren()) do
				TweenService:Create(v,TweenInfo.new(.25),{Size = Vector3.new(1,1,1)}):Play()
				v.Parent = ExplosionFolder
			end

			task.wait(5)
			MeteorsFolder:ClearAllChildren()
			ExplosionFolder:ClearAllChildren()
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end

			HasStartedVolcano = false
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
                self:VolcanoEruption()
            end)
        else
            --print("[Volcano Meteor] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
