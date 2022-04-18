local TrapObject = {};
local TweenService = game:GetService("TweenService");

TrapObject.Cooldown = 40
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:OnAction()
	local Candycane = trapFolder:FindFirstChild("Wafer")

	if Candycane and not HasStarted then	
		HasStarted = true
		
		local function getWafers()
			local chosenWafers = {}
			local wafers = {}
			
			local numOfWafers = math.random(3,5)
			
			for i, meshPart in pairs(trapFolder:GetChildren()) do
				if meshPart:IsA("Model") and meshPart.Name == "Wafer" then
					wafers[i] = meshPart
				end
			end
			
			for i = 1, numOfWafers do
				local randomWafer = math.random(1, #wafers)
				chosenWafers[i] = wafers[randomWafer]
				table.remove(wafers, randomWafer)
			end
			
			return chosenWafers
		end
		
		local wafersFalling = getWafers()
		local wafersCloneTab = {}
		
		for _, wafer in pairs(wafersFalling) do
			local waferClone = wafer:Clone()
			table.insert(wafersCloneTab,waferClone)
			waferClone.Parent = trapFolder
			for _, part in pairs(wafer:GetChildren()) do
				if part:IsA("MeshPart") or part:IsA("Part") then
					part.Transparency = 1
					part.CanCollide = false
				end
			end
			TweenService:Create(waferClone.Top,TweenInfo.new(1,Enum.EasingStyle.Linear),{Color = Color3.fromRGB(117, 0, 0)}):Play()
		end

		task.wait(2)
		
		
		
		for _, wafer in pairs(wafersCloneTab) do
			for _, part in pairs(wafer:GetChildren()) do
				if part:IsA("MeshPart") or part:IsA("Part") then
					part.Anchored = false
					part.CanCollide = false
				end
			end
		end
		
		task.wait(7)
		
		for _, wafer in pairs(wafersCloneTab) do
			if wafer then	
				wafer:Destroy()
			end
		end
		
		for _, wafer in pairs(wafersFalling) do
			for _, part in pairs(wafer:GetChildren()) do
				if part:IsA("MeshPart") or part:IsA("Part") then
					part.Transparency = 0
					part.CanCollide = true
				end
			end
		end

		HasStarted = false
	end
end

function TrapObject:Activate(targetObject)
    if not targetObject then
        return
    end
    trapFolder = targetObject.Parent.Parent:FindFirstChild("Trap")
    if trapFolder then
        if (self.StartTime == 0) or (tick() - self.StartTime >= self.Cooldown) then
            print("[Wafers]: Activated")
            self.StartTime = tick()
			self.Activated = true
            task.spawn(function()
                --self:OnAction()
            end)
        else
            --print("[Wafers] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;