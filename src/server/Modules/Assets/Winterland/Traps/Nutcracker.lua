local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

local oneTimeUse = false
TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:BlowWind()
	local Nutcracker = trapFolder.Nutcracker
	local eye1 = Nutcracker.Eye1
	local eye2 = Nutcracker.Eye2
	
	local HeadModel = Nutcracker.Model
	
	local Breath = HeadModel.Breath
	local Hitbox = HeadModel.Hitbox
	
	local InitialPos = trapFolder.InitialPos
	local LeftPos = trapFolder.LeftPos
	local RightPos = trapFolder.RightPos
	
	if Nutcracker then
		if not HasStarted and not oneTimeUse then
			--oneTimeUse = true
			HasStarted = true

			local info = TweenInfo.new(5)

			local function tweenModel(model, CF)
				local CFrameValue = Instance.new("CFrameValue")
				CFrameValue.Value = model:GetPrimaryPartCFrame()

				Connections[#Connections + 1] = CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
					model:SetPrimaryPartCFrame(CFrameValue.Value)
				end)

				local tween = TweenService:Create(CFrameValue, info, {Value = CF})
				tween:Play()

				Connections[#Connections + 1] = tween.Completed:Connect(function()
					CFrameValue:Destroy()
				end)
			end
			
			eye1.Material = Enum.Material.Neon
			eye2.Material = Enum.Material.Neon
			
			Breath.ParticleEmitter.Enabled = true
			
			CollectionService:AddTag(Hitbox, "KillPart")

			tweenModel(Nutcracker, LeftPos.CFrame)
			wait(6)
			tweenModel(Nutcracker, RightPos.CFrame)
			wait(6)
			tweenModel(Nutcracker, InitialPos.CFrame)
			wait(6)
			
			eye1.Material = Enum.Material.Plastic
			eye2.Material = Enum.Material.Plastic

			Breath.ParticleEmitter.Enabled = false
			CollectionService:RemoveTag(Hitbox, "KillPart")
			
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
                --self:BlowWind()
            end)
        else
            --print("[Drop Boulder & Spawn Crabs] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;