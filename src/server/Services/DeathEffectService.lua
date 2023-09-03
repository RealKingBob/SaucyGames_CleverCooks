local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local DeathEffectService = Knit.CreateService {
    Name = "DeathEffectService",
    Client = {
        ClientDeath = Knit.CreateSignal(),
    }
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(script.Parent.DataService)

function DeathEffectService:GetEffect(player)
    repeat task.wait(0) until DataService:GetProfile(player) ~= nil
    local Profile = DataService:GetProfile(player)
    local playerDeathEffect = Profile.Data.Inventory.CurrentDeathEffect
    return playerDeathEffect
end

function DeathEffectService:Fire(player, character)
    print("DeathEffectService Fired")
    if player and character then
        local DeathEffects = {}
        local newPart = Instance.new("Part")
        local attachment = Instance.new("Attachment")
        newPart.Size = Vector3.new(1,1,1)
        newPart.Anchored = true
        newPart.CanCollide = false
        newPart.Transparency = 1
        attachment.Parent = newPart
        newPart.Parent = workspace:WaitForChild("Spawnables"):WaitForChild("Effects")
        if not character then
            newPart:Destroy()
            return
        end
        if character.PrimaryPart then
            newPart.CFrame = character.PrimaryPart.CFrame
        else
            newPart.CFrame = character:FindFirstChild("Mouse.001").CFrame
        end

        local deathEffectName = tostring(self:GetEffect(player))

        if deathEffectName == nil then
            deathEffectName = "Default"
        end
        --print(deathEffectName)
        local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")

        local newSound = GameLibrary.Sounds.DeathEffects:FindFirstChild(deathEffectName):WaitForChild("Poof"):Clone()
        newSound.Parent = newPart
        newSound:Play()
        local currentPlayerEffect = GameLibrary.DeathEffects:FindFirstChild(deathEffectName)
        self.Client.ClientDeath:Fire(player, character)
        task.spawn(function()
            for _,v in pairs(currentPlayerEffect:GetChildren()) do
                task.spawn(function()
                    if v:IsA("Folder") and v.Name == "Attachment" then
                        for _, k in pairs(v:GetChildren()) do
                            if k:IsA("ParticleEmitter") then
                                local b = k:Clone()
                                b.Parent = attachment
                                b:Clear()
                                b:Emit(b:GetAttribute("Emit"))
                                table.insert(DeathEffects,b)
                            end
                        end
                    else
                        local b = v:Clone()
                        b.Parent = newPart
                        b:Clear()
                        b:Emit(b:GetAttribute("Emit"))
                        table.insert(DeathEffects,b)
                    end
                end)
            end
            task.wait(0.15)
            for _,v in pairs(DeathEffects) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
        end)
        character:Destroy()
        player.Character = nil
        task.wait(1)
        newPart:Destroy()
    end
end

function DeathEffectService:KnitStart()
    
end


function DeathEffectService:KnitInit()
    
end


return DeathEffectService