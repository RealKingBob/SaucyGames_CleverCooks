local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Connections = {}
local TrapObject = {};

TrapObject.Cooldown = 30
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil
local spinTime = 2

function TrapObject:OnAction()
	if trapFolder then
		if not HasStarted then
			HasStarted = true

			spinTime = 0.5

			task.wait(5)

			spinTime = 2

			HasStarted = false
		end
	end
end

function TrapObject:OnStart()
	task.wait(1)
	for _, child in pairs(CollectionService:GetTagged("Blades"))do
		if child:IsA("Model") then
			task.wait(1.5)
			local Base1 = child:WaitForChild("Base01")
			local Base2 = child:WaitForChild("Base02")
			local Blades = child:WaitForChild("Blades")
			local Pos1 = child:WaitForChild("Pos1")
			local Pos2 = child:WaitForChild("Pos2")
			if Pos1 and Pos2 then
				task.spawn(function()
					local check = false
					repeat
						--spinTime = math.random(180,220) / 100
						if check == true then
							check = false
							if Base1 and Base2 and Blades and Pos1 then
								TweenService:Create(Base1,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos1.Base01.CFrame }):Play() -- * CFrame.Angles(100,0,0)
								TweenService:Create(Base2,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos1.Base02.CFrame }):Play()
								TweenService:Create(Blades,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos1.Blades.CFrame }):Play()
							end
						else
							check = true
							if Base1 and Base2 and Blades and Pos2 then
								TweenService:Create(Base1,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos2.Base01.CFrame }):Play()
								TweenService:Create(Base2,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos2.Base02.CFrame }):Play()
								TweenService:Create(Blades,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos2.Blades.CFrame }):Play()
							end
						end
						task.wait(spinTime)
					until child == nil
				end)
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
                --self:OnAction()
            end)
        else
            --print("[TrapObject] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
