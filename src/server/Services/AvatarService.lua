--[[
    Name: Avatar Service [V1]
    By: Real_KingBob
    Date: 12/10/21
    Description: This module handles all functions that changes the avatar of the duck
]]

----- Private Variables -----

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local AvatarService = Knit.CreateService {
    Name = "AvatarService";
    Client = {
        CreatePH = Knit.CreateSignal(); -- ParticleHolder
        CreateB = Knit.CreateSignal(); -- Create Baguette
        RemoveB = Knit.CreateSignal(); -- Remove Baguette
    };
}

local PlayerProfileData = {};

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService);
local InventoryService = require(script.Parent.InventoryService);
local Rarity = Knit.ReplicatedRarities

local DuckModels = ReplicatedStorage:WaitForChild("Assets").DuckModels
local DeathEffects = ReplicatedStorage:WaitForChild("Assets").DeathEffects

----- Public functions -----

function AvatarService:RefreshAvatar(UserId, Character) -- [Texture : String]
    if Character then

    end;
end;

-- Getters() --

function AvatarService:GetAvatarSkin(Player) -- [Player : Instance]
    local PlayerData = PlayerProfileData[Player] or DataService:GetProfile(Player)
    if PlayerData then
        return PlayerData.Data.Inventory.CurrentDuckSkin
    else
        return nil;
    end
end;

function AvatarService:GetDeathEffect(Player) -- [Player : Instance]
    local PlayerData = PlayerProfileData[Player] or DataService:GetProfile(Player)
    if PlayerData then
        return PlayerData.Data.Inventory.CurrentDeathEffect
    else
        return nil;
    end
end;

-- Setters() --

function ChangeText(PLAYER, NEW_UI)
	-- // NAME CHANGE
	if PLAYER.DisplayName == PLAYER.Name then
		NEW_UI.USER.Text = ""
		NEW_UI.NICK.Text = PLAYER.Name
	else
		NEW_UI.NICK.Text = PLAYER.DisplayName
		NEW_UI.USER.Text = "@"..PLAYER.Name
	end
end

function AvatarService:SetNametag(Player)
    if not workspace.Lobby.NameTags:FindFirstChild(Player.UserId) then
		local NEW_UI = game.ReplicatedStorage.Assets.HEAD_UI:Clone()
		NEW_UI.Name = Player.UserId
		NEW_UI.Parent = workspace.Lobby.NameTags
        if Player.Character:FindFirstChild("Head") then
            NEW_UI.Adornee = Player.Character.Head
        end
		ChangeText(Player, NEW_UI)
	else
		local NEW_UI = workspace.Lobby.NameTags:FindFirstChild(Player.UserId)
		if Player.Character:FindFirstChild("Head") then
            NEW_UI.Adornee = Player.Character.Head
        end
		ChangeText(Player, NEW_UI)
	end
end

function AvatarService:SetParticleHolder(Player)
    if not workspace.Lobby.NameTags:FindFirstChild(Player.UserId) then
		local NEW_UI = game.ReplicatedStorage.Assets.HEAD_UI:Clone()
		NEW_UI.Name = Player.UserId
		NEW_UI.Parent = workspace.Lobby.NameTags
        if Player.Character:FindFirstChild("Head") then
            NEW_UI.Adornee = Player.Character.Head
        end
		ChangeText(Player, NEW_UI)
	else
		local NEW_UI = workspace.Lobby.NameTags:FindFirstChild(Player.UserId)
		if Player.Character:FindFirstChild("Head") then
            NEW_UI.Adornee = Player.Character.Head
        end
		ChangeText(Player, NEW_UI)
	end
end

function AvatarService:SetRandomDeathEffect(Player)
    local PlayerData = DataService:GetProfile(Player)
    if PlayerData then
        local EffectName = DeathEffects:GetChildren()[math.random(1, #DeathEffects:GetChildren())]
        self:SetDeathEffect(Player, EffectName)
    else
        return
    end
end;

function AvatarService:SetDeathEffect(Player, EffectName)
    local PlayerData
    if not PlayerProfileData[Player] then
        PlayerData = DataService:GetProfile(Player)
    else
        PlayerData = PlayerProfileData[Player]
    end
    if typeof(EffectName) == "string" then
        EffectName = DeathEffects:FindFirstChild(EffectName)
    end 
    if PlayerData then 
        if PlayerData.Data.Inventory.CurrentDeathEffect and EffectName then
            if PlayerData.Data.Inventory.CurrentDeathEffect ~= EffectName then
                PlayerData.Data.Inventory.CurrentDeathEffect = tostring(EffectName)
                InventoryService:InventoryChanged(Player);
            end
        end
    else
        return
    end
end;

function AvatarService:SetRandomAvatarSkin(Player)
    local PlayerData = DataService:GetProfile(Player)
    if PlayerData then
        local SkinName = DuckModels:GetChildren()[math.random(1, #DuckModels:GetChildren())]
        self:SetAvatarSkin(Player, SkinName)
    else
        return
    end
end;

function AvatarService:SetAvatarSkin(Player, SkinName)
    self:SetNametag(Player)
    local PlayerData
    if not PlayerProfileData[Player] then
        PlayerData = DataService:GetProfile(Player)
    else
        PlayerData = PlayerProfileData[Player]
    end
    if typeof(SkinName) == "string" then
        SkinName = DuckModels:FindFirstChild(SkinName)
    end
    if PlayerData then 
        --print(PlayerData.Data.Inventory.CurrentDuckSkin, SkinName)
        Knit.AvatarService.Client.CreatePH:Fire(Player, Player, tostring(SkinName))
        if PlayerData.Data.Inventory.CurrentDuckSkin and SkinName then
            if PlayerData.Data.Inventory.CurrentDuckSkin ~= SkinName then
                PlayerData.Data.Inventory.CurrentDuckSkin = tostring(SkinName)
                InventoryService:InventoryChanged(Player);
            end
            if DuckModels:FindFirstChild(tostring(SkinName)) then
                if DuckModels:FindFirstChild(tostring(SkinName)):GetAttribute("Custom") == nil then
                    if Player.Character:GetAttribute("Custom") ~= nil then
                        --print("old pos???")
                        local oldPos = Player.Character.PrimaryPart.CFrame
                        Player:LoadCharacter()
                        self:SetNametag(Player)
                        Player.Character:SetPrimaryPartCFrame(oldPos)
                        return;
                    end
                    if Player.Character:FindFirstChild("Sphere") then
                        Player.Character:FindFirstChild("Sphere").TextureID = DuckModels:FindFirstChild(tostring(SkinName)):FindFirstChild("DuckV2").TextureID;
                        local oldsurfaceApp = Player.Character:FindFirstChild("Sphere"):FindFirstChildWhichIsA("SurfaceAppearance")
                        if oldsurfaceApp then
                            oldsurfaceApp:Destroy()
                        end

                        local surfaceApp = DuckModels:FindFirstChild(tostring(SkinName)):FindFirstChild("DuckV2"):FindFirstChildWhichIsA("SurfaceAppearance");
                        if surfaceApp then
                            local surfaceAppearanceClone = surfaceApp:Clone()
                            surfaceAppearanceClone.Parent = Player.Character:FindFirstChild("Sphere")
                        end
                        for _, accessory in pairs(Player.Character:GetChildren()) do
                            if accessory:IsA("MeshPart") and accessory.Name == "Accessory" then
                                accessory:Destroy()
                            end
                        end

                        for _, attachment in pairs(Player.Character:FindFirstChild("Sphere"):GetChildren()) do
                            if attachment:IsA("ParticleEmitter") then
                                attachment:Destroy()
                            end
                        end

                        for _, particle in pairs(DuckModels:FindFirstChild(tostring(SkinName)):FindFirstChild("DuckV2"):GetChildren()) do
                            if particle:IsA("ParticleEmitter") then
                                local accessoryClone = particle:Clone();
                                accessoryClone.Name = particle.Name;
                                accessoryClone.Parent = Player.Character:FindFirstChild("Sphere");
                            end
                        end

                        if Player.Character:FindFirstChild("ParticleHolder") then
                            for _, attachment in pairs(Player.Character:FindFirstChild("ParticleHolder"):GetChildren()) do
                                if not attachment:GetAttribute("Default") and attachment.Name ~= "RigidConstraint" then
                                    attachment:Destroy()
                                end
                            end
                            local ParticleHolder = SkinName:FindFirstChild("ParticleHolder")
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
                        
                        for _, accessory in pairs(SkinName:GetChildren()) do
                            if accessory:IsA("MeshPart") and accessory.Name ~= "DuckV2" and accessory.Name ~= "RootPart" and accessory.Name ~= "ParticleHolder" then
                                local accessoryClone =  accessory:Clone()
                                accessoryClone.Name = "Accessory"
                                local motor6D = Instance.new("Motor6D")
                                motor6D.Part1 = accessoryClone
                                motor6D.Part0 = Player.Character:FindFirstChild("Sphere")
                                motor6D.Parent = accessoryClone
                                accessoryClone.Parent = Player.Character
                            end
                        end
                    end
                else
                    if Player.Character.Parent == nil then
                        repeat task.wait(0) until Player.Character.Parent == workspace
                    end
                    task.wait(.1)
                    --print("OPTION 2", Player.Character , Player.Character.Parent , Player.Character:FindFirstChild("Sphere") ~= nil)
                    if Player.Character and Player.Character.Parent 
                    and Player.Character:FindFirstChild("Sphere") ~= nil 
                    and Player.Character:GetAttribute("Custom") ~= tostring(SkinName) then -- Destroy an already-existing character
                        
                        local oldPos = Player.Character.PrimaryPart.CFrame
                        local char = DuckModels:FindFirstChild(tostring(SkinName)):Clone()
                        char.Name = Player.Name
                
                        local humanoid
                        for i, child in pairs(char:GetChildren()) do -- Find the humanoid
                            if child:IsA("Humanoid") then
                                humanoid = child
                                break
                            end
                        end
                    
                        if not humanoid then -- If no humanoid was found, make one
                            humanoid = Instance.new("Humanoid", char)
                        end
                    
                        Player.Character = char
                        char.Parent = game.Workspace
                        Player.Character.Animate.Disabled = false
                        Player.Character.CharacterClient.Disabled = false
                        self:SetNametag(Player)
                        Player.Character:SetPrimaryPartCFrame(oldPos)
                        
                        humanoid.Died:Connect(function()
                            if Player.Character:GetAttribute("Custom") ~= nil then
                                --// Initiliaze Death Effect
                                Knit.DeathEffectService:Init(Player, Player.Character);
                            end
                        end)
                        --humanoid.Died:Wait() -- Wait until they die	
                    end
                end
            end
        end
    else
        return
    end
end;

function AvatarService:SetHunterSkin(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    repeat task.wait(0) until Character:FindFirstChild("Humanoid")
    local GameService = Knit.GetService("GameService")
    local PresetAvatar = GameService:GetPreviousMap()
    local Hunt = ReplicatedStorage:FindFirstChild("Characters"):FindFirstChild(PresetAvatar)
    if Hunt then
        if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Sphere") ~= nil then -- Destroy an already-existing character
            local oldPos = Character.PrimaryPart.CFrame
            local char = Hunt:Clone()
            char.Name = Player.Name
    
            local humanoid
            for i, child in pairs(char:GetChildren()) do -- Find the humanoid
                if child:IsA("Humanoid") then
                    humanoid = child
                    break
                end
            end
        
            if not humanoid then -- If no humanoid was found, make one
                humanoid = Instance.new("Humanoid", char)
            end
        
            Player.Character = char
            char.Parent = game.Workspace
            Player.Character.Animate.Disabled = false
            Player.Character:SetPrimaryPartCFrame(Player.RespawnLocation.CFrame * CFrame.new(Vector3.new(math.random(-9,9),1,math.random(-9,9))) +
            Vector3.new(0,2.3,0))

            
            humanoid.Died:Wait() -- Wait until they die	
        end
    end
end

function AvatarService:KnitStart()
    
end


function AvatarService:KnitInit()
    
end

return AvatarService;