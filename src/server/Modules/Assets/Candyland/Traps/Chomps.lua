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
	local Hershey = trapFolder:FindFirstChild("Hershey")

	if Hershey and not HasStarted then
		HasStarted = true

		for _, part in pairs(trapFolder:GetChildren()) do
			if part.Name == "Hershey" and part:IsA("Model") then
				task.spawn(function()
					local chompAttack = "rbxassetid://8313361208"

					local smallcontroller = part:WaitForChild("AnimationController")


					local smallAnimation = Instance.new("Animation")
					smallAnimation.AnimationId = chompAttack

					local smallAnim = smallcontroller:LoadAnimation(smallAnimation)

					smallAnim.Priority = "Action"

					smallAnim:Play()
					task.wait(.7)
					TweenService:Create(part.PrimaryPart,TweenInfo.new(.86,Enum.EasingStyle.Linear),{Position = Vector3.new(part.PrimaryPart.Position.X + 30,part.PrimaryPart.Position.Y ,part.PrimaryPart.Position.Z + 30)}):Play()
					task.wait(0.86)
					part.PrimaryPart.Anchored = false
					task.spawn(function()
						task.wait(1)
						if part.PrimaryPart then
							part.PrimaryPart.CanCollide = false
							task.wait(3)
							if part.PrimaryPart then
								part:Destroy()
							end
						end
					end)
				end)
			end
		end
		--HasStarted = false
	end
end

function TrapObject:Activate(targetObject)
    if not targetObject then
        return
    end
    trapFolder = targetObject.Parent.Parent:FindFirstChild("Trap")
    if trapFolder then
        if (self.StartTime == 0) or (tick() - self.StartTime >= self.Cooldown) then
            print("[Chomps]: Activated")
            self.StartTime = tick()
			self.Activated = true
            task.spawn(function()
                --self:OnAction()
            end)
        else
            --print("[Chomps] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;