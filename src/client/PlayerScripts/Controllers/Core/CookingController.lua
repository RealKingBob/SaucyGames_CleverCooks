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
    print("cooking controller")
end


function CookingController:KnitInit()
    
end


return CookingController
