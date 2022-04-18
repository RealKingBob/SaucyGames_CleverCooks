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
	local Puncher = trapFolder["Puncher"]

	if Puncher and not HasStarted then	
		HasStarted = true
		
		local newSize = 20
		
		local Handle = Puncher:FindFirstChild("Handle")

		local endSize = Vector3.new(10.49, 11.792, 139.283)
		local endPosition = Vector3.new(454.297, 53.084, -188.034)
		TweenService:Create(Handle,TweenInfo.new(.5,Enum.EasingStyle.Elastic),{Size = endSize, Position = endPosition}):Play()
		
		TweenService:Create(Puncher.PrimaryPart,TweenInfo.new(.5,Enum.EasingStyle.Elastic),{Position = Vector3.new(379.88, 52.663, -195.36)}):Play()
		
		task.wait(5)

		local endSize = Vector3.new(10.491, 11.792, 48.965)
		local endPosition = Vector3.new(499.284, 53.084, -184.099)
		TweenService:Create(Handle,TweenInfo.new(.5,Enum.EasingStyle.Elastic),{Size = endSize, Position = endPosition}):Play()

		TweenService:Create(Puncher.PrimaryPart,TweenInfo.new(.5,Enum.EasingStyle.Elastic),{Position = Vector3.new(490.035, 52.663, -185.723)}):Play()

		HasStarted = false
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
                self:OnAction()
            end)
        else
            --print("[TrapObject] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;