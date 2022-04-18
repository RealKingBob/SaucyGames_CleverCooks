local TrapObject = {};

local TweenService = game:GetService("TweenService");

TrapObject.Cooldown = 45
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnAction()
	local Candycane = trapFolder:FindFirstChild("Candycane Spike")

	if Candycane then
		if not HasStarted then
			HasStarted = true

            for _, meshPart in pairs(trapFolder:GetChildren()) do
                if meshPart:IsA("MeshPart") and meshPart.Name == "Candycane Spike" then
                    TweenService:Create(meshPart,TweenInfo.new(.5,Enum.EasingStyle.Elastic),{Size = Vector3.new(meshPart.Size.X, meshPart.Size.Y + 70, meshPart.Size.Z)}):Play()
                end
            end
            
            task.wait(5)
            
            for _, meshPart in pairs(trapFolder:GetChildren()) do
                if meshPart:IsA("MeshPart") and meshPart.Name == "Candycane Spike" then
                    TweenService:Create(meshPart,TweenInfo.new(.5,Enum.EasingStyle.Elastic),{Size = Vector3.new(meshPart.Size.X, meshPart.Size.Y - 70, meshPart.Size.Z)}):Play()
                end
            end

			HasStarted = false
		end
	end
end

function TrapObject:OnStart()
	
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
            --print("[Candyspikes] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
