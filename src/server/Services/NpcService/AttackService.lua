local AttackService = {};

local Players = game:GetService("Players")
local DebrisService = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary")
local LibraryEffects = GameLibrary:WaitForChild("Effects")

local rockColor = Color3.fromRGB(159, 161, 172);
local rockDespawnTime = 5;

local stompRange = 20;

local plr = Players.LocalPlayer
local char = plr.Character
local mouse = plr:GetMouse()

local armOffset = char.UpperTorso.CFrame:Inverse() * char.RightUpperArm.CFrame

local armWeld = Instance.new("Weld")
armWeld.Part0 = char.UpperTorso
armWeld.Part1 = char.RightUpperArm
armWeld.Parent = char

local taskAnim = Instance.new("Animation");
taskAnim.Name = "TaskAnim";

function AttackService:Stomp(animator, position)
	
	--print("STOMP", position)
	
	local stompAnimId = "rbxassetid://10453571674"
	
	if not taskAnim then taskAnim = Instance.new("Animation"); taskAnim.Name = "TaskAnim"; end
	taskAnim.AnimationId = stompAnimId;
	
	local controller = animator;
	
	local taskAnimTrack = controller:LoadAnimation(taskAnim);
	taskAnimTrack.Priority = Enum.AnimationPriority.Action;

	repeat task.wait(0.1) until taskAnimTrack.length ~= 0;
	
	taskAnimTrack:Play();
	task.wait(taskAnimTrack.Length / 1.5);
	
	if workspace:FindFirstChild("EffectDebris") == nil then
		local EffectsFolder = Instance.new("Folder", workspace)
		EffectsFolder.Name = "EffectDebris"
	end
	
	local StompBlockClone = LibraryEffects:WaitForChild("StompBlock"):Clone()
	StompBlockClone.Position = position
	StompBlockClone.Parent = workspace:FindFirstChild("EffectDebris")
	
	for i,v in pairs(StompBlockClone:GetChildren()) do if v:IsA("ParticleEmitter") then v:Emit(60) end end
	
	for i, v in next, game.Players:GetPlayers() do
		if not v.Character then continue end
		local HRP = v.Character:FindFirstChild("HumanoidRootPart");
		if HRP then
			if (HRP.Position - StompBlockClone.Position).magnitude < stompRange then
				v.Character:FindFirstChild("Humanoid").Health = -1;
			end
		end
	end
	
	--for i,v in pairs(StompBlockClone:GetChildren()) do if v:IsA("ParticleEmitter") then v.Enabled = true end end
	
	task.wait(2)
	
	StompBlockClone:Destroy()
	
	return true;
end



function AttackService:Swing(animator, fistPart)
	
	fistPart.Size = Vector3.new(8.518, 8.84, 6.045)

	--print("STOMP", position)

	local swingAnimId = "rbxassetid://10477361080";
	local fistConnection = nil;

	if not taskAnim then taskAnim = Instance.new("Animation"); taskAnim.Name = "TaskAnim"; end
	taskAnim.AnimationId = swingAnimId;

	local controller = animator;

	local taskAnimTrack = controller:LoadAnimation(taskAnim);
	taskAnimTrack.Priority = Enum.AnimationPriority.Action;

	repeat task.wait(0.1) until taskAnimTrack.length ~= 0;
	
	for _, v in pairs(fistPart:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true;
		end
	end

	fistConnection = fistPart.Touched:Connect(function(hit)
		local Player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if Player then
			print("hit player:", Player)
		end
	end)

	taskAnimTrack:Play();
	taskAnimTrack:AdjustSpeed(0.5)

	--RunService.Heartbeat:Connect(function()
	local cframe = CFrame.new(char.UpperTorso.Position, mouse.Hit.Position) * CFrame.Angles(math.pi/2, 0, 0)
	armWeld.C0 = armOffset * char.UpperTorso.CFrame:toObjectSpace(cframe)
	--end)
	
	taskAnimTrack.Stopped:Wait()
	
	for _, v in pairs(fistPart:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false;
		end
	end
	
	fistConnection:Disconnect()
	fistConnection = nil;

	--StompBlockClone:Destroy()

	return true;
end


function AttackService:Shockwave(position)
	
	local rocks = Instance.new("Folder", workspace)
	rocks.Name = "RockDebris"
	
	DebrisService:AddItem(rocks, rockDespawnTime + 2)
	
	for i = 1, 30 do
		
		local rock = Instance.new("Part", rocks)
		rock.Anchored = true;
		rock.CanCollide = false;
		rock.Size = Vector3.new(math.random(1,3), 5, math.random(1,3))
		
		local upperPartColor = Color3.fromRGB(159, 161, 172);
		local upperPartMaterial = "SmoothPlastic"
		
		local raySettings = RaycastParams.new()
		raySettings.FilterType = Enum.RaycastFilterType.Blacklist
		local ray = workspace:Raycast((position * CFrame.Angles(0, math.rad(12 * i), 0) * CFrame.new(15, -5, 0)).Position, (position * CFrame.Angles(0, math.rad(12 * i), 0) * CFrame.new(15, 5, 0)).Position, raySettings)

		if ray then
			if ray.Instance:IsA("Part") or ray.Instance:IsA("UnionOperation") or ray.Instance:IsA("MeshPart") or ray.Instance:IsA("WedgePart") then
				upperPartColor = Color3.fromRGB(159, 161, 172); --ray.Instance.BrickColor;
				upperPartMaterial = ray.Instance.Material;
			end
		end
		
		local rock2 = Instance.new("Part", rocks);
		rock2.Material = upperPartMaterial;
		rock2.Color = upperPartColor;
		rock2.Size = Vector3.new(rock.Size.X, .5, rock.Size.Z);
		rock2.CFrame = rock.CFrame;
		
		local weld = Instance.new("Weld", rock2)
		weld.Part0 = rock;
		weld.Part1 = rock2;
		weld.C1 = CFrame.new(0, -5.25, 0);
		
		rock.CFrame = position * CFrame.new(0, -10, 0) * CFrame.Angles(0, math.rad(12 * i), 0) * CFrame.new(15, 0, 0);
		rock.CFrame = rock.CFrame* CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(-180, 180)), math.rad(math.random(-10, 10)));
		rock.Color = rockColor;
		rock.Material = "Rock";
		
		local tween = game:GetService("TweenService"):Create(rock, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = position * CFrame.new(0, -5, 0) * CFrame.Angles(0, math.rad(12 * i), 0) * CFrame.new(7, 0, 0) * CFrame.Angles(math.rad(math.random(-60, 60)), math.rad(math.random(-180, 180)), math.rad(math.random(-60, 60)))})
		tween:Play()

		coroutine.resume(coroutine.create(function()
			task.wait(rockDespawnTime)
			local tween = game:GetService("TweenService"):Create(rock, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = position * CFrame.new(0, -20, 0) * CFrame.Angles(0, math.rad(12 * i), 0) * CFrame.new(7, 0, 0) * CFrame.Angles(math.rad(math.random(-60, 60)), math.rad(math.random(-180, 180)), math.rad(math.random(-60, 60)))})
			tween:Play()

			tween.Completed:Connect(function()
				rock:Destroy()
				rock2:Destroy()
			end)
		end))
		
	end
end

return AttackService;
