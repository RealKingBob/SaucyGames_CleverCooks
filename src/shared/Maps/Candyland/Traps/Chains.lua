local TrapObject = {};
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService");

TrapObject.Cooldown = 45
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil
local spinTime = 2.3

function TrapObject:OnAction()
	if trapFolder then
		if not HasStarted then
			HasStarted = true

			spinTime = 0.5

			task.wait(5)

			spinTime = 2.3

			HasStarted = false
		end
	end
end

function TrapObject:OnStart()
	task.wait(1)
	for _, child in pairs(CollectionService:GetTagged("CandyBlades"))do
		if child:IsA("Model") then
			task.wait(1.5)
			--print("BLADE", child, child:GetChildren() )
			local ChainSaws = child:WaitForChild("ChainSaws")
			local Pos1 = child:WaitForChild("Pos1")
			local Pos2 = child:WaitForChild("Pos2")
			if Pos1 and Pos2 then
				task.spawn(function()
					local check = false
					repeat
						--spinTime = math.random(180,220) / 100
						if check == true then
							check = false
							if ChainSaws and Pos1 then
								TweenService:Create(ChainSaws,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos1.ChainSaws.CFrame }):Play()
							end
						else
							check = true
							if ChainSaws and Pos2 then
								TweenService:Create(ChainSaws,TweenInfo.new(spinTime,Enum.EasingStyle.Linear),{CFrame = Pos2.ChainSaws.CFrame }):Play()
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
                self:OnAction()
            end)
        else
            --print("[Chains] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;