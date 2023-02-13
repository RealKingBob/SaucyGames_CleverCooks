local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PlayerController = Knit.CreateController { Name = "PlayerController" }
local LocalPlayer = Players.LocalPlayer;

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary")
local BillboardUI = GameLibrary:WaitForChild("BillboardUI")

local SGEffects = require(game.ReplicatedStorage.Common.Modules.SGEffects);

local tweenInfoFast = TweenInfo.new(.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function decimalRandom(minimum, maximum)
    return math.random()*(maximum-minimum) + minimum
end

function PlayerController:UnTrackItem()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if not HumanoidRootPart then return end;

    HumanoidRootPart:FindFirstChild("TrackBeam").Attachment0 = nil;
end

function PlayerController:TrackItem(itemObj)
    local itemAttachment;
    if not itemObj:FindFirstChildWhichIsA("Attachment") then
        itemAttachment = Instance.new("Attachment");
        itemAttachment.Name = "trackAttachment";
        itemAttachment.Parent = itemObj;
    end

    itemAttachment = itemObj:FindFirstChildWhichIsA("Attachment");

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    if not HumanoidRootPart then return end;

    HumanoidRootPart:FindFirstChild("TrackBeam").Attachment0 = itemAttachment;
end

function PlayerController:Poof(positon, color)
    if not positon and not color then return end
	local poofTemplate = Instance.new("Part")
	poofTemplate.Position = positon
	poofTemplate.Anchored = true
	poofTemplate.CanCollide = false
	poofTemplate.Size = Vector3.new(0.562, 0.523, 0.53)
	poofTemplate.Transparency = 1
	poofTemplate.CastShadow = false

    local partColor = (color ~= nil and color) or Color3.fromRGB(192, 192, 192)

	for i = 1, 30 do
		local Clone = poofTemplate:Clone()
		Clone.Parent = workspace:WaitForChild("Spawnables"):WaitForChild("Effects")
		Clone.Material = Enum.Material.SmoothPlastic
        local darkenMultiplier = decimalRandom(0, 0.1)
		Clone.Color = Color3.new(
            partColor.R - darkenMultiplier,
            partColor.G - darkenMultiplier,
            partColor.B - darkenMultiplier
        )
		Clone.Transparency = 0
		Clone.Name = "Effect"
		local SO = SGEffects:ScatterOut(Clone, nil, {-1.5,1.5}, 0.6) --SGEffects:ScatterOut(Clone)
		local SF = SGEffects:SizeFactor(Clone)
		SO:Play()
		SF:Play()
	end
	poofTemplate:Destroy()
end

function PlayerController:DeathEffect(character)
	local poofTemplate = Instance.new("Part")
	poofTemplate.Position = character:WaitForChild("HumanoidRootPart").Position
	poofTemplate.Anchored = true
	poofTemplate.CanCollide = false
	poofTemplate.Size = Vector3.new(0.562, 0.523, 0.53)
	poofTemplate.Transparency = 1
	poofTemplate.CastShadow = false

    local characterColor = character:WaitForChild("Head").Color

	for i = 1, 50 do
		local Clone = poofTemplate:Clone()
		Clone.Parent = workspace:WaitForChild("Spawnables"):WaitForChild("Effects")
		Clone.Material = Enum.Material.SmoothPlastic
        local darkenMultiplier = decimalRandom(0, 0.1)
		Clone.Color = Color3.new(
            characterColor.R - darkenMultiplier,
            characterColor.G - darkenMultiplier,
            characterColor.B - darkenMultiplier
        )
		Clone.Transparency = 0
		Clone.Name = "Effect"
		local SO = SGEffects:ScatterOut(Clone, nil, {-5,5}, 0.6) --SGEffects:ScatterOut(Clone)
		local SF = SGEffects:SizeFactor(Clone)
		SO:Play()
		SF:Play()
	end
	poofTemplate:Destroy()
end

function PlayerController:WarnExclaim()
    local ExclamationPointUI = BillboardUI:WaitForChild("ExclamationPointUI");
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if not Character.Head then return end;
    if Character.Head:FindFirstChild("ExclamationPointUI") then return end
    
    local ExclaimMarker = ExclamationPointUI:Clone() do
        --TargetMarker:WaitForChild("RotateLabel").Visible = true;
        if Character.Head then
            ExclaimMarker.Parent = Character.Head
        end

        task.wait(2.5)

        if ExclaimMarker then
            for _, a in pairs(ExclaimMarker:GetChildren()) do
                if a:IsA("Frame") then
                    TweenService:Create(a, tweenInfoFast, { BackgroundTransparency = 1 }):Play()
                    for _, b in pairs(a:GetChildren()) do
                        if b:IsA("UIStroke") then
                            TweenService:Create(b, tweenInfoFast, { Thickness = 0, Transparency = 1 }):Play()
                        end
                    end
                end
            end
            task.wait(.45)
            ExclaimMarker:Destroy();
        end
    end
end

function PlayerController:KnitStart()

end

function PlayerController:KnitInit()
    
end


return PlayerController
