local lowestFallHeight = 10

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

local humRoot = Character.HumanoidRootPart

local isFalling = false
local deb = false

local function createJumpParticle()
    local jumpEffect = game.ReplicatedStorage.GameLibrary.Effects.JumpEffect:Clone()
    jumpEffect.CanCollide = false
	jumpEffect.Transparency = 1
    jumpEffect.Parent = workspace
    game.Debris:AddItem(jumpEffect,0.3)
    local weld = Instance.new("Weld",jumpEffect)
    weld.Part0 = humRoot
    weld.Part1 = jumpEffect
    weld.C0 = CFrame.new(0,-.72,0) * CFrame.fromEulerAnglesXYZ(0,0,1.5)
    jumpEffect.ParticleEmitter:Emit(45)
end

Humanoid.FreeFalling:Connect(function(falling)
	isFalling = falling
	if isFalling and not deb then
		deb = true
		local maxHeight = 0
		while isFalling do
			local height = math.abs(humRoot.Position.y)
			if height > maxHeight then
				maxHeight = height
			end
			task.wait()
		end
		local fallHeight = maxHeight - humRoot.Position.y
		--print(Character.Name.. " fell " .. math.floor(fallHeight + 0.5) .. " studs")
		print("Damage:", fallHeight)
		if fallHeight >= lowestFallHeight then
			createJumpParticle()
		end
		deb = false
	end
end)