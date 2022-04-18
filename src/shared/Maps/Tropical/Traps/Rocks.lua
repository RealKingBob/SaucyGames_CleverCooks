local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

local oneTimeUse = false
TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedSpikes = false
local HasStartedRocks = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:DropSpikes()
	local CaveSpikes = trapFolder.CaveSpikes
	local DebrisBlock = trapFolder.DebrisBlock
	local SoundBlock = trapFolder.SoundBlock
	if CaveSpikes and not oneTimeUse then
		if not HasStartedSpikes then
			oneTimeUse = true
			HasStartedSpikes = true
			local CaveSpikeClone = CaveSpikes:Clone()
			CaveSpikeClone.Parent = trapFolder
			for _, spike in pairs(CaveSpikeClone:GetChildren()) do
				spike.Transparency = 0
			end

			for _, spike in pairs(CaveSpikeClone:GetDescendants()) do
                Connections[#Connections +  1] = spike.Touched:Connect(function(hit)
                    local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = -1
                    end
                end)
			end
			
			for _, particle in pairs(DebrisBlock:GetChildren()) do
				if particle:IsA("ParticleEmitter") then
					particle.Enabled = true
				end
			end
			
			for _, particle in pairs(SoundBlock:GetChildren()) do
				if particle:IsA("Sound") and particle.Name ~= "Spike" then
					particle:Play()
				end
			end
			
			for _, spike in pairs(CaveSpikeClone:GetChildren()) do
                task.wait(math.random(0,3))
                task.spawn(function()
                    TweenService:Create(spike,TweenInfo.new(0.6),{CFrame = spike.CFrame + Vector3.new(0,-40,0)}):Play()
                    task.wait(0.6)
					if SoundBlock and SoundBlock:FindFirstChild("Spike") then
						SoundBlock.Spike:Play()
					end
                end)
			end
			
			for _, particle in pairs(DebrisBlock:GetChildren()) do
				if particle:IsA("ParticleEmitter") then
					particle.Enabled = false
				end
			end
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end
			
			task.wait(1)
			
			for _, spike in pairs(CaveSpikeClone:GetChildren()) do
				task.spawn(function()
					TweenService:Create(spike,TweenInfo.new(1),{Transparency = 1, CanCollide = false}):Play()
					task.wait(1)
				end)
			end
			
			for _, particle in pairs(SoundBlock:GetChildren()) do
				if particle:IsA("Sound") then
					particle:Stop()
				end
			end
			
			task.wait(1)
			
			CaveSpikeClone:Destroy()
			
			HasStartedSpikes = false
		end
	end
end

function TrapObject:HideRocks()
	local RocksFolder = trapFolder.Rocks
	if RocksFolder and not HasStartedRocks then
		HasStartedRocks = true
		for _, rock in pairs(RocksFolder:GetChildren()) do
			task.spawn(function()
				TweenService:Create(rock, TweenInfo.new(0.6),{CFrame = rock.CFrame + Vector3.new(0,-10,0)}):Play()
				task.wait(0.6)
			end)
		end
		
		task.wait(5)
		
		for _, rock in pairs(RocksFolder:GetChildren()) do
			task.spawn(function()
				TweenService:Create(rock, TweenInfo.new(0.6),{CFrame = rock.CFrame + Vector3.new(0,10,0)}):Play()
				task.wait(0.6)
			end)
		end
		
		HasStartedRocks = false
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
                self:DropSpikes()
            end)
            task.spawn(function()
                self:HideRocks()
            end)
        else
            --print("[Rocks and Spikes Trap] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;