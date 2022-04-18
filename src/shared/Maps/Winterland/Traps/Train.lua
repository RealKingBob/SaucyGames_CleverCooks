local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

local oneTimeUse = false
TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStartedShark = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:TrainRun()
	local Train = trapFolder.Train
	local TrainEnd = trapFolder.TrainEnd
	
	local Positions1 = trapFolder.Positions1
	local Positions2 = trapFolder.Positions2
	local Positions3 = trapFolder.Positions3
	
	local Snow1 = trapFolder.Snow1
	local Snow2 = trapFolder.Snow2
	local Snow3 = trapFolder.Snow3
	
	if Train and not oneTimeUse then
		if not HasStartedLogFall then
			HasStartedLogFall = true
			
			local info = TweenInfo.new(10)

			local function tweenModel(model, CF)
				local CFrameValue = Instance.new("CFrameValue")
				local storeOldCframe = model:GetPrimaryPartCFrame()
				CFrameValue.Value = model:GetPrimaryPartCFrame()
				local Con1 = #Connections + 1
				Connections[#Connections + 1] = CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()

					if model then
						if model.PrimaryPart ~= nil then
							model:SetPrimaryPartCFrame(CFrameValue.Value)
						else
							Connections[Con1]:Disconnect()
						end
					else
						Connections[Con1]:Disconnect()
					end
				end)

				local tween = TweenService:Create(CFrameValue, info, {Value = CF})
				tween:Play()
				local Con2 = #Connections + 1
				Connections[#Connections + 1] = tween.Completed:Connect(function()
					CFrameValue:Destroy()
					if model then
						if model.PrimaryPart ~= nil then
							model:SetPrimaryPartCFrame(CFrameValue.Value)
						else
							Connections[Con2]:Disconnect()
						end
					else
						Connections[Con2]:Disconnect()
					end
				end)
			end
			
			tweenModel(Train, TrainEnd.CFrame)
			
			local snowClone1 = Snow1:Clone()
			local snowClone2 = Snow2:Clone()
			local snowClone3 = Snow3:Clone()
			
			snowClone1.Parent = trapFolder.Prop
			snowClone2.Parent = trapFolder.Prop
			snowClone3.Parent = trapFolder.Prop
			
			Snow1.Transparency = 1
			Snow2.Transparency = 1
			Snow3.Transparency = 1
			
			
			task.spawn(function()
				task.wait(1)
				for i = 1, 4 do
					if Positions1:FindFirstChild(tostring(i)) then
						local part = Positions1:FindFirstChild(tostring(i))

						local tTime = (snowClone1.Position - part.Position).Magnitude / 75
						TweenService:Create(snowClone1,TweenInfo.new(tTime,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),{CFrame = part.CFrame}):Play()

						wait(tTime)
					end
				end
			end)
			
			task.spawn(function()
				task.wait(2)
				for i = 1, 4 do
					if Positions2:FindFirstChild(tostring(i)) then
						local part = Positions2:FindFirstChild(tostring(i))

						local tTime = (snowClone2.Position - part.Position).Magnitude / 75
						TweenService:Create(snowClone2,TweenInfo.new(tTime,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),{CFrame = part.CFrame}):Play()

						wait(tTime)
					end
				end
			end)
			
			task.spawn(function()
				task.wait(3)
				for i = 1, 4 do
					if Positions3:FindFirstChild(tostring(i)) then
						local part = Positions3:FindFirstChild(tostring(i))

						local tTime = (snowClone3.Position - part.Position).Magnitude / 75
						TweenService:Create(snowClone3,TweenInfo.new(tTime,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),{CFrame = part.CFrame}):Play()

						wait(tTime)
					end
				end
			end)

			task.wait(20)
			
			trapFolder.Prop:ClearAllChildren()
			
			TweenService:Create(Snow1,TweenInfo.new(1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()
			TweenService:Create(Snow2,TweenInfo.new(1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()
			TweenService:Create(Snow3,TweenInfo.new(1,Enum.EasingStyle.Linear),{Transparency = 0}):Play()
			wait(1)
			
			for i = 1,#Connections do
				Connections[i]:Disconnect()
			end

			HasStartedLogFall = false
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
                self:TrainRun()
            end)
        else
        end
    end
end

return TrapObject;