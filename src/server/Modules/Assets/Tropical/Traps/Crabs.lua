local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

local oneTimeUse = false
TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedBoulder = false
local HasStartedCrabs = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:DropBoulder()
	local BoulderFolder = trapFolder.Boulder
	if BoulderFolder and not oneTimeUse then
		if not HasStartedBoulder then
			oneTimeUse = true
			HasStartedBoulder = true
			
			Connections[#Connections + 1] = BoulderFolder.Boulder.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = -1
				end
			end)
			
			BoulderFolder.Boulder.Anchored = false
			BoulderFolder.Boulder.Sound:Play()
			
			task.wait(5)
			
			BoulderFolder.Boulder:Destroy()
			
			HasStartedBoulder = false
		end
	end
end

function TrapObject:SpawnCrabs()
	local CrabFolder = trapFolder.Crabs
	local SoundBlock = trapFolder.SoundBlock
	if CrabFolder and not HasStartedCrabs then
		HasStartedCrabs = true
		
		local CrabFolderClone = CrabFolder:Clone()
		CrabFolderClone.Parent = trapFolder

		for _, crab : MeshPart in pairs(CrabFolderClone:GetChildren()) do
			Connections[#Connections +  1] = crab.Touched:Connect(function(hit)
                local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = -1
                end
            end)
		end

		for _, crab : MeshPart in pairs(CrabFolderClone:GetChildren()) do
			task.wait(math.random(0,1))
			task.spawn(function()
				task.wait(math.random(0,1))
				TweenService:Create(crab,TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 5, true),{CFrame = crab.CFrame + Vector3.new(0,3,0)}):Play()
				if SoundBlock:FindFirstChild("Snip") then
					local SnipClone = SoundBlock.Snip:Clone()
					SnipClone.Parent = crab
					SnipClone:Play()
					task.wait(2)
					SnipClone:Destroy()
				end
			end)
		end

		for i = 1,#Connections do
			Connections[i]:Disconnect()
		end

		task.wait(4)

		CrabFolderClone:Destroy()
		
		HasStartedCrabs = false
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
                --self:DropBoulder()
            end)
            task.spawn(function()
                --self:SpawnCrabs()
            end)
        else
            --print("[Drop Boulder & Spawn Crabs] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;