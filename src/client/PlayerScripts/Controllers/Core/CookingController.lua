local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LocalPlayer = game.Players.LocalPlayer;
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary");
local FoodHolderFolder = GameLibrary:FindFirstChild("FoodHolder");

local CookingController = Knit.CreateController { Name = "CookingController" }

function CookingController:FindFoodHolder()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui");
    local GUI = playerGui:FindFirstChild("GUI");
    local FoodHolder = GUI:FindFirstChild("FoodHolder");
    return FoodHolder;
end

function CookingController:AddRecipe(recipe)
    local foundHolder = self:FindFoodHolder();
    if foundHolder then
        local ClonedRecipe = FoodHolderFolder:FindFirstChild(tostring(recipe)):Clone();
        ClonedRecipe.Ingredients.Value = tostring(recipe);
        ClonedRecipe.Parent = foundHolder.ScrollingFrame;
    end;
end;

function CookingController:RemoveRecipe(recipe)
    local foundHolder = self:FindFoodHolder();
    if foundHolder and foundHolder.ScrollingFrame:FindFirstChild(tostring(recipe)) then
        foundHolder.ScrollingFrame:FindFirstChild(tostring(recipe)):Destroy();
    end;
end;

function CookingController:KnitStart()
    --print("cooking controller")
end


function CookingController:KnitInit()
    
    local CookingService = Knit.GetService("CookingService")
    local CookingUI = Knit.GetController("CookingUI")

    CookingService.Cook:Connect(function(Status, RecipeName, Pan, CookingPercentages)
        --print("CLIENT COOK", Status, RecipeName, Pan, CookingPercentages)
        if Status == "Initialize" then
            CookingUI:StartCooking(RecipeName, Pan)
        elseif Status == "CookUpdate" then
            CookingUI:UpdatePanCook(Pan, CookingPercentages)
        elseif Status == "Destroy" then
            CookingUI:DestroyUI(Pan)
        end
    end)

    CookingService.Deliver:Connect(function(RecipeName, DeliveryZone, DeliverTime)
        --print("CLIENT DELIVER", RecipeName, DeliveryZone, DeliverTime)
        CookingUI:StartDelivering(RecipeName, DeliveryZone, DeliverTime)
    end)

    CookingService.PickUp:Connect(function(foodInfo)
        --print("FOOOD",food)
        if foodInfo.Type == "DestroyFood" then
            if foodInfo.Data then foodInfo.Data:Destroy() end
        end
    end)

    CookingService.ParticlesSpawn:Connect(function(food, particleName)

        if particleName == "CookedParticle" then
            CookingUI:SpawnCookedParticles(food)
        end
        
    end)
end


return CookingController
