local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local OrderService = Knit.CreateService {
    Name = "OrderService";
    Client = {
        AddOrder = Knit.CreateSignal();
        RemoveOrder = Knit.CreateSignal();

        CompleteOrder = Knit.CreateSignal();

        ResetTimePurchase = Knit.CreateSignal();
    };
}

--[[
    -- Example usage: add 3 copies of each of 3 random recipes to player 1's dictionary
    addRandomRecipes(player, serverAvailableRecipes, 3)

    print("playerRecipes:",playerRecipes[player])

    shuffle(playerRecipes[player])
    
    print("playerRecipes:",playerRecipes[player])
    
    -- Mark the first recipe as completed for player 1
    completeRecipe(player, "Recipe 1")
]]

----- Services -----

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MarketplaceService = game:GetService("MarketplaceService");
local ServerScriptService = game:GetService("ServerScriptService");

----- Directories -----

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary");

local IngredientsAvailable = workspace:WaitForChild("IngredientAvailable");
local FoodAvailable = workspace:WaitForChild("FoodAvailable");

local ReplicatedAssets = Knit.Shared.Assets;
local ReplicatedModules = Knit.Shared.Modules;
local ServerModules = Knit.Modules;
local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects");
local FoodObjects = GameLibrary:FindFirstChild("FoodObjects");

----- Loaded Modules -----
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"));

----- Variables -----
-- Create an empty table to store the recipes for each player
local playerRecipes = {}

-- Create an empty table to store the recipes for each player
local serverAvailableRecipes = RecipeModule:GetAllRecipeNames()

-- Create a flag variable to indicate whether the timer should be reset
local resetTimer = false

-- Create an empty table to store the resetTime orderIds for each player
local resetTimeOrderIds = {};

-- Create an empty table to store all product ids
local productFunctions = {}

-- Product ID for reset time on order
local resetTimeProductId = 123456;

local recipeTimer = 50; -- 300
local playerTimer = 20; -- 180

-- Create a count value to give a unique id for each recipe given to a user
local countId = 0;

function fromHex(str)
	return (str:gsub('..', function (cc)
		return string.char(tonumber(cc, 16))
	end))
end

function toHex(str)
	return (str:gsub('.', function (c)
		return string.format('%02X', string.byte(c))
	end))
end

--print(toHex("Test")) -> 54657374
--print(fromHex("54657374")) -> Test

-- Function to shuffle a list in-place
local function shuffle(list)
    -- Iterate through the list, swapping each element with a random element
    for i = 1, #list do
        local j = math.random(i, #list)
        list[i], list[j] = list[j], list[i]
    end

    -- Return the shuffled list
    return list
end

-- Function to check how many orders are in the player storage
function OrderService:orderCount(player)
    -- Counts the amount of times it sees the recipe
    local count = 0;

    -- Find the recipe in the player's list and count it
    for _, r in ipairs(playerRecipes[player].storage) do
        if r and r.id then
            count += 1;
        end
    end
    return count;
end


-- Function to check how many of the same recipe is in the player storage
function OrderService:recipeCount(player, recipe)
    -- Counts the amount of times it sees the recipe
    local count = 0;

    -- Find the recipe in the player's list and count it
    for _, r in ipairs(playerRecipes[player].storage) do
        if r.name == recipe then
            count += 1;
        end
    end
    return count;
end


-- Function to add a recipe to a player's list of recipes
function OrderService:addRecipe(player, recipe, value)
    -- Check if the player already has a list of recipes
    if playerRecipes[player] == nil then
        -- If not, create a new list for the player
        playerRecipes[player] = {
            storage = {}, -- player storage
            timer = playerTimer, -- 3 minute timer
        };
    end

    if self:orderCount(player) >= 5 then
        return;
    end

    countId += 1;

    -- Add the recipe to the player's list, with a timer of 5 minutes and a completion value
    local recipeData = {
        name = recipe, 
        id = tostring(toHex(recipe) .."_".. countId),
        image = RecipeModule:GetImage(tostring(recipe)),
        timer = recipeTimer, 
        value = value, 
        completed = false
    }
    table.insert(playerRecipes[player].storage, recipeData)
    self.Client.AddOrder:Fire(player, recipeData)
    Knit.GetService("NotificationService"):Message(false, player, "NEW ORDER ADDED!")
end

-- Function to add a random recipe to a player's list
function OrderService:addRandomRecipe(player, recipes)
    -- Choose a random recipe from the list
    --local recipe = recipes[math.random(1, #recipes)]
    local recipe = nil;

    local function getRecipe() -- gets random recipe
        -- Calculate the cumulative probabilities
        local cumulativeProbabilities = {}
        local probabilitySum = 0
        for _, item in ipairs(recipes) do
            if item.difficulty == "Easy" then
                probabilitySum = probabilitySum + 100
            elseif item.difficulty == "Medium" then
                probabilitySum = probabilitySum + 50
            elseif item.difficulty == "Hard" then
                probabilitySum = probabilitySum + 10
            end
            cumulativeProbabilities[#cumulativeProbabilities + 1] = probabilitySum
        end

        -- Generate a random number between 0 and the sum of the probabilities
        local randomNumber = math.random(probabilitySum)

        -- Iterate through the cumulative probabilities and return the corresponding item
        for i, probability in ipairs(cumulativeProbabilities) do
            if probability > randomNumber then
                return recipes[i];
            end
        end
    end

    repeat
        recipe = getRecipe();
    until recipe ~= nil

    -- Add the recipe to the player's list
    self:addRecipe(player, recipe.name, recipe.value)
end

-- Function to remove a recipe from a player's list
function OrderService:removeRecipe(player, recipeId)
    -- Find the recipe in the player's list and remove it
    for i, r in ipairs(playerRecipes[player].storage) do
        --print(r.id, recipeId, r.id == recipeId)
        if r.id == recipeId then
            self.Client.RemoveOrder:Fire(player, r.id)
            table.remove(playerRecipes[player].storage, i) 
            break
        end
    end
end

-- Function to remove a recipe from a player's list
function OrderService:getRecipe(player, recipeId)
    -- Check if the player already has a list of recipes
    if playerRecipes[player] == nil then
        -- If not, create a new list for the player
        playerRecipes[player] = {
            storage = {}, -- player storage
            timer = playerTimer, -- 3 minute timer
        };
    end
    
    -- Find the recipe in the player's list and remove it
    for i, r in ipairs(playerRecipes[player].storage) do
        --print(r.id, recipeId, r.id == recipeId)
        if r.id == recipeId then
            return r;
        end
    end
end

-- Function to remove expired recipes from a player's table
function OrderService:removeExpiredRecipes(player)
    -- Iterate through the player's recipes
    for i, recipe in ipairs(playerRecipes[player].storage) do
        -- Decrement the timer
        recipe.timer = recipe.timer - 1

        -- If the timer has expired, remove the recipe from the table
        if recipe.timer <= 0 then
            print("timer expired for", recipe.name, playerRecipes[player])
            --table.remove(playerRecipes[player].storage, i)
            self:removeRecipe(player, recipe.id)
        end
    end
end

-- Function to mark a recipe as completed for a player
function OrderService:completeRecipe(player, recipe, reward)
    -- Find the recipe in the player's list and mark it as completed
    for _, r in ipairs(playerRecipes[player].storage) do
        if r.name == recipe and r.completed == false then
            print("COMPLETE RECIPE:", player, recipe)
            r.completed = true

            local bonusReward = (reward * 0.3) -- 30%

            Knit.GetService("DataService"):GiveCurrency(player, bonusReward, false, "+BONUS %")

            self.Client.CompleteOrder:Fire(player, r.id)
            self:removeRecipe(player, recipe.id)
            break
        end
    end
end

-- Function to add all recipes to a player's list in random order
function OrderService:addRandomRecipes(player, recipes, numCopies)
    -- Shuffle the list of recipes
    local shuffledRecipes = shuffle(recipes)

    -- Add each recipe to the player's list
    for _, recipe in ipairs(shuffledRecipes) do
        for i = 1, numCopies do
            self:addRecipe(player, recipe.name, recipe.value)
        end
    end
end


-- Function to update the recipes for a player
function OrderService:updatePlayerRecipes(player)
    if playerRecipes[player] then
        --print("timer:", playerRecipes[player].timer)
        if playerRecipes[player].timer <= 0 then
            -- Add a random recipe to the player's table
            self:addRandomRecipe(player, serverAvailableRecipes)

            local CalculatedTime = playerTimer --180 + ((#playerRecipes[player].storage * 60) - 90)

            playerRecipes[player].timer = CalculatedTime; -- reset to 3 minutes
            print("add recipe:", playerRecipes[player], "| adjusted CalculatedTime:", CalculatedTime)
        end

        -- Remove any expired recipes from the player's table
        self:removeExpiredRecipes(player)
    end
end


local function PlayerAdded(player)
    playerRecipes[player] = {
        storage = {}, -- player storage
        timer = math.random(10,30), -- 10-30 seconds to automatically give one recipe
    };
    resetTimeOrderIds[player] = 0;
end;

local function PlayerRemoving(player)
    playerRecipes[player] = nil;
    resetTimeOrderIds[player] = nil;
end;

function OrderService:SetupProducts()
    -- ProductId [resetTimeProductId] resets the time of the players order
    productFunctions[resetTimeProductId] = function(receipt, player)
        local returnedRecipe = self:getRecipe(player, resetTimeOrderIds[player]);
        returnedRecipe.timer = recipeTimer
        self.Client.ResetTimePurchase:Fire(player, returnedRecipe.id, recipeTimer)
    end
end

local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local player = Players:GetPlayerByUserId(userId)
	if player then
		-- Get the handler function associated with the product ID and attempt to run it
		local handler = productFunctions[productId]
		local success, result = pcall(handler, receiptInfo, player)
		if success then
			-- The player has received their benefits!
			-- return PurchaseGranted to confirm the transaction.
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("Failed to process receipt:", receiptInfo, result)
		end
	end
	-- the player's benefits couldn't be awarded.
	-- return NotProcessedYet to try again next time the player joins.
	return Enum.ProductPurchaseDecision.NotProcessedYet
end


function OrderService:KnitStart()
    while true do
        for plr, data in pairs(playerRecipes) do
            data.timer -= 1;
            self:updatePlayerRecipes(plr)
        end

        task.wait(1)
    end
end


function OrderService:KnitInit()
    print('ORDER SERVICE')
    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(PlayerAdded)(player);
    end

    Players.PlayerAdded:Connect(PlayerAdded);
    Players.PlayerRemoving:Connect(PlayerRemoving);

    -- Set the callback; this can only be done once by one script on the server!
    MarketplaceService.ProcessReceipt = processReceipt

    self.Client.ResetTimePurchase:Connect(function(player, orderId)
        if resetTimeOrderIds[player] ~= nil then
            resetTimeOrderIds[player] = orderId;

            if game:GetService("RunService"):IsStudio() then -- if on studio
                local returnedRecipe = self:getRecipe(player, orderId);
                returnedRecipe.timer = recipeTimer
                self.Client.ResetTimePurchase:Fire(player, returnedRecipe.id, recipeTimer)
            else
                MarketplaceService:PromptProductPurchase(player, resetTimeProductId)
            end

        end
    end)
end


return OrderService
