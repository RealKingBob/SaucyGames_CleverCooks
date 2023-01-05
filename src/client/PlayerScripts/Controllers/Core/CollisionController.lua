local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CollisionController = Knit.CreateController { Name = "CollisionController" }


function CollisionController:KnitStart()
    
end


function CollisionController:KnitInit()
    local PhysicsService = game:GetService("PhysicsService")
    local Players = game:GetService("Players")

    local function onDescendantAdded(descendant)
        if descendant:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(descendant, "NoCollision")
            --print("descendant.CollisionGroup:", descendant:GetFullName(), descendant.CollisionGroup)
        end
    end

    local function onCharacterAdded(character)
        --print("no collision here")
        if not character then return end
        
        for _, descendant in pairs(character:GetDescendants()) do
            onDescendantAdded(descendant)
        end
        character.DescendantAdded:Connect(onDescendantAdded)
    end

    local function onPlayerAdded(player)
        if player == Players.LocalPlayer then return end
        onCharacterAdded(player.Character)
        player.CharacterAdded:Connect(onCharacterAdded)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(onPlayerAdded)(player);
    end    

    Players.PlayerAdded:Connect(onPlayerAdded);
end


return CollisionController
