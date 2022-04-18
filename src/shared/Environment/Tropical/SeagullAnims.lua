local SeagullAnim = {};

local RunService = game:GetService("RunService")

function SeagullAnim:Init(MapObject)
	if not MapObject or not MapObject:FindFirstChild("MovableObjects") then
		return;
	end
	if MapObject:FindFirstChild("MovableObjects"):FindFirstChild("Seagulls") then
		for _,seagullGroup in pairs(MapObject.MovableObjects.Seagulls:GetChildren()) do
			if seagullGroup:IsA("Model") and seagullGroup.Name == "GroupSeagulls" then
				task.spawn(function()
					local rNum = math.random(6,8)
					if seagullGroup.PrimaryPart then
						repeat
							game:GetService("TweenService"):Create(seagullGroup.PrimaryPart,TweenInfo.new(rNum, Enum.EasingStyle.Linear), {CFrame = seagullGroup.PrimaryPart.CFrame * CFrame.Angles(0,-360,0)}):Play()
							task.wait(rNum)
						until seagullGroup == nil
					end
				end)
	
				for _,Seagull in pairs (seagullGroup:GetChildren()) do
					if Seagull:IsA("Model") and Seagull.Name == "SeagullTween" then
						local Torso = Seagull:WaitForChild("Body")
	
						local LeftMotor = Torso:WaitForChild("LeftMotor")
						local RightMotor = Torso:WaitForChild("RightMotor")
	
						local function FlapWings() -- Cred to Luckymaxer for the function
							local function Animate(Time)
								local LimbAmplitude = 0.3
								local LimbFrequency = 5
								local LimbDesiredAngle = (LimbAmplitude * math.sin(Time * LimbFrequency))
								LeftMotor.DesiredAngle = LimbDesiredAngle
								RightMotor.DesiredAngle = -LimbDesiredAngle
							end
							RunService.Stepped:Connect(function()
								local _, Time = wait(0.1)
								Animate(Time)
								task.wait(0.5)
							end)
						end
	
						task.wait(math.random(.1,.9))
	
						FlapWings()
	
					end
				end
			end
		end
	end
end

return SeagullAnim;