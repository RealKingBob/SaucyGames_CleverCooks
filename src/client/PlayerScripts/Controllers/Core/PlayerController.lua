local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PlayerController = Knit.CreateController { Name = "PlayerController" }
local DuckModels = ReplicatedStorage:WaitForChild("Assets").DuckModels

function PlayerController:CreateParticleHolder(Player, SkinModel)
    if Player and Player.Character then
        if Player ~= Players.LocalPlayer then
            return
        end
        if Player.Character:FindFirstChild("ParticleHolder") == nil then
            local ParticleHolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("DuckModels"):WaitForChild("ParticleHolder")
            local ParticleHolderClone = ParticleHolder:WaitForChild("ParticleHolder"):Clone()
            local RigidConstraint = Instance.new("RigidConstraint")
            if Player.Character:FindFirstChild("Sphere") then
                if Player.Character.Sphere:FindFirstChild("HumanoidRootPart") then
                    RigidConstraint.Attachment0 = Player.Character.Sphere.HumanoidRootPart.Torso.Neck.Head
                    RigidConstraint.Attachment1 = ParticleHolderClone:FindFirstChild("PHAttachment")
                elseif Player.Character.HumanoidRootPart:FindFirstChild("HumanoidRootPart") then
                    RigidConstraint.Attachment0 = Player.Character.HumanoidRootPart.HumanoidRootPart.Torso.Neck.Head
                    RigidConstraint.Attachment1 = ParticleHolderClone:FindFirstChild("PHAttachment")
                end
                ParticleHolderClone.Parent = Player.Character
                RigidConstraint.Parent = Player.Character.Sphere
            end
        end
    
        if SkinModel then
            if Player.Character:FindFirstChild("ParticleHolder") then
                for _, attachment in pairs(Player.Character:FindFirstChild("ParticleHolder"):GetChildren()) do
                    if not attachment:GetAttribute("Default") and attachment.Name ~= "RigidConstraint" then
                        attachment:Destroy()
                    end
                end
                DuckModels = ReplicatedStorage:WaitForChild("Assets").DuckModels
                local ParticleHolder = DuckModels:FindFirstChild(SkinModel):FindFirstChild("ParticleHolder")
                if ParticleHolder then
                    for _, attachment in pairs(ParticleHolder:GetChildren()) do
                        if attachment:IsA("Attachment") and attachment.Name ~= "PHAttachment" then
                            local accessoryClone = attachment:Clone();
                            accessoryClone.Name = attachment.Name;
                            accessoryClone.Parent = Player.Character:FindFirstChild("ParticleHolder");
                        end
                    end
                    for _, attachment in pairs(ParticleHolder:GetChildren()) do
                        if attachment:IsA("Beam") then
                            local accessoryClone = attachment:Clone();
                            accessoryClone.Name = attachment.Name;
                            accessoryClone.Attachment0 = Player.Character:FindFirstChild("ParticleHolder"):FindFirstChild(tostring(attachment.Attachment0))
                            accessoryClone.Attachment1 = Player.Character:FindFirstChild("ParticleHolder"):FindFirstChild(tostring(attachment.Attachment1))
                            accessoryClone.Parent = Player.Character:FindFirstChild("ParticleHolder");
                        end
                    end
                end
            end
        end
    end
end

function PlayerController:CreateBaguette(Player)
    if Player and Player.Character then
        if Player ~= Players.LocalPlayer then
            local accessoryClone =  DuckModels:FindFirstChild("BaguetteDuck").Baguette:Clone()
            accessoryClone.Name = "BreadTool"
            local motor6D = Instance.new("Motor6D")
            motor6D.Part1 = accessoryClone
            motor6D.Part0 = Player.Character:FindFirstChild("Sphere")
            motor6D.Parent = accessoryClone
            accessoryClone.Parent = Player.Character
            return
        end
        if Player.Character:FindFirstChild("BreadTool") == nil then
            if not Player.Character:FindFirstChild("ParticleHolder") then
                self:CreateParticleHolder(Player)
            end
            if Player.Character:FindFirstChild("ParticleHolder") then
                local BreadTool = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("BreadTool")
                local BreadToolClone = BreadTool:Clone()
                BreadToolClone.FaceJoint.Attachment1 = Player.Character.ParticleHolder.Forward
                BreadToolClone.HandJoint.Attachment1 = Player.Character.ParticleHolder.MouthAttachment
                BreadToolClone.Position = Player.Character.ParticleHolder.Position
                BreadToolClone.Parent = Player.Character
            end
        end
    end
end

function PlayerController:RemoveBaguette(Player)
    if Player and Player.Character then
        if Player.Character:FindFirstChild("BreadTool") then
            Player.Character:FindFirstChild("BreadTool"):Destroy();
        end
    end
end

function PlayerController:SwingBaguette(Player)
    if Player and Player.Character then
        if Player ~= Players.LocalPlayer then
            return
        end
        local BreadTool = Player.Character:FindFirstChild("BreadTool")
        if BreadTool then
            if Player ~= Players.LocalPlayer then
                BreadTool:FindFirstChild("RigidConstraint").Enabled = false;
            end
            if BreadTool and BreadTool:FindFirstChild("FaceJoint") and BreadTool:FindFirstChild("HandJoint") then
                BreadTool:FindFirstChild("FaceJoint").Enabled = true;
                BreadTool:FindFirstChild("HandJoint").Enabled = false;
            end
            task.wait(.35);
            if BreadTool and BreadTool:FindFirstChild("FaceJoint") and BreadTool:FindFirstChild("HandJoint") then
                BreadTool:FindFirstChild("FaceJoint").Enabled = false;
                BreadTool:FindFirstChild("HandJoint").Enabled = true;
            end
            if Player ~= Players.LocalPlayer then
                BreadTool:FindFirstChild("RigidConstraint").Enabled = true;
            end
        end
    end
end

function PlayerController:CreateHitEffect(player, TPlayer)
    local TargetCharacter = TPlayer.Character;
    local Root = TargetCharacter:FindFirstChild("HumanoidRootPart")
    if Root then
        if TargetCharacter.PrimaryPart then
            local HitEffect = ReplicatedStorage.Assets.GameEffects:WaitForChild("HitEffect")
            local HClone = HitEffect:Clone()
            HClone.Position = TargetCharacter.PrimaryPart.Position + TargetCharacter.PrimaryPart.CFrame.LookVector * 2
            HClone.Parent = workspace

            local HitSFX = Instance.new("Sound", HClone)
            HitSFX.SoundId = "rbxassetid://145486953"
            HitSFX.PlayOnRemove = true;
            
            for _, k in ipairs(HClone:GetDescendants()) do
                if k:IsA("ParticleEmitter") then
                    k:Clear();
                    k:Emit(k:GetAttribute("Emit"))
                end
            end
            HitSFX:Destroy()
            game:GetService("Debris"):AddItem(HClone,.10)

            task.wait(.5)
        end
    end
end

function PlayerController:KnitStart()
    
    local GameService = Knit.GetService("GameService")
    local AvatarService = Knit.GetService("AvatarService")

    GameService.ToolAttack:Connect(function(player)
        self:SwingBaguette(player);
    end)

    GameService.HEffect:Connect(function(player, TPlayer)
        self:CreateHitEffect(player, TPlayer);
    end)

    AvatarService.CreatePH:Connect(function(player, SkinModel)
        self:CreateParticleHolder(player, SkinModel)
    end)

    --[[for _, player in pairs(game.Players:GetPlayers()) do
        self:CreateParticleHolder(player)
    end]]

    AvatarService.CreateB:Connect(function(player)
        self:CreateBaguette(player)
    end)

    AvatarService.RemoveB:Connect(function(player)
        self:RemoveBaguette(player)
    end)

    --[[for _, player in pairs(game.Players:GetPlayers()) do
        self:CreateBaguette(player)
    end]]
end


function PlayerController:KnitInit()
    
end


return PlayerController
