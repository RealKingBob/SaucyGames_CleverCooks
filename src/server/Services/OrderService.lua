--[[
	Name: Order Service [V1]
	Creator: Real_KingBob
	Made in: 12/31/22
    Updated: 12/31/22
	Description: Handles Order Mechanics for rat players
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local OrderService = Knit.CreateService {
    Name = "OrderService",
    Client = {
        AddOrder = Knit.CreateSignal(),
        RemoveOrder = Knit.CreateSignal(),
        RemoveAllOrders = Knit.CreateSignal(),

        CompleteOrder = Knit.CreateSignal(),

        ResetTimePurchase = Knit.CreateSignal(),

        RecipesUpdate = Knit.CreateSignal(),
    }
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

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

----- Directories -----
local ReplicatedAssets = Knit.Shared.Assets

----- Loaded Modules -----
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))

----- Variables -----
-- Create an empty table to store the recipes for each player
local playerRecipes = {}

-- Create an empty table to store the recipes for each player
local serverAvailableRecipes = RecipeModule:GetAllRecipeNames()

-- Create a flag variable to indicate whether the orders should proceed
local pauseOrders = false

-- Create an empty table to store the resetTime orderIds for each player
local resetTimeOrderIds = 0

-- Create an empty table to store all product ids
local productFunctions = {}

-- Product ID for reset time on order
local resetTimeProductId = 123456

local recipeTimer = 300 -- 300, 50
local playerTimer = 30 -- 180

local cookedRange = {min = 35, max = 66}

-- Create a count value to give a unique id for each recipe given to a user
local countId = 0

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

-- Function to pause orders
function OrderService:pauseOrders(boolean)
    pauseOrders = boolean
end

-- Function to check how many orders are in the player storage
function OrderService:orderCount()
    if not playerRecipes then return end
    -- Counts the amount of times it sees the recipe
    local count = 0

    -- Find the recipe in the player's list and count it
    for _, r in ipairs(playerRecipes.storage) do
        if r and r.id then
            count += 1
        end
    end
    return count
end


function OrderService.Client:GetUnlockedRecipes(player) -- Updates daily shop time and shop data
	--print("[DailyService]: Watching time for ",player,profile, lastLogin,dailyshopTime)
    local DataService = Knit.GetService("DataService")
    local profile = DataService:GetProfile(player)

    if profile then
        if profile.Data.RecipesCooked then
            warn(profile.Data.RecipesCooked)
            return profile.Data.RecipesCooked
        end
    end
    return {}
end


-- Function to check how many of the same recipe is in the player storage
function OrderService:recipeCount(recipe)
    if not recipe then return end
    if not playerRecipes then return end
    -- Counts the amount of times it sees the recipe
    local count = 0

    -- Find the recipe in the player's list and count it
    for _, r in ipairs(playerRecipes.storage) do
        if r.name == recipe then
            count += 1
        end
    end
    return count
end

-- Function to add a recipe to a player's list of recipes
function OrderService:addRecipe(recipe, value)
    if not recipe or not value then return end

    if pauseOrders == true then return end
    -- Check if the player already has a list of recipes
    if playerRecipes == nil then
        -- If not, create a new list for the player
        playerRecipes = {
            storage = {}, -- player storage
            timer = playerTimer, -- 3 minute timer
        }
    end

    warn("self:orderCount(PartyOwner)", playerRecipes, self:orderCount())

    if self:orderCount() >= 5 then
        return
    end

    countId += 1

    -- Add the recipe to the player's list, with a timer of 5 minutes and a completion value
    local recipeData = {
        name = recipe, 
        id = tostring(toHex(recipe) .."_".. countId),
        orderNumber = countId,
        image = RecipeModule:GetImage(tostring(recipe)),
        timer = recipeTimer, 
        value = value, 
        completed = false
    }
    if pauseOrders == true then return end
    table.insert(playerRecipes.storage, recipeData)

    warn("playerRecipes", playerRecipes)

    for _, player : Player in Players:GetPlayers() do
        self.Client.AddOrder:Fire(player, recipeData)
        Knit.GetService("NotificationService"):Message(false, player, "NEW ORDER ADDED!")
    end
end

-- Function to add a random recipe to a player's list
function OrderService:addRandomRecipe(recipes)
    if not recipes then return end
    -- Choose a random recipe from the list
    --local recipe = recipes[math.random(1, #recipes)]
    local recipe = nil

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
                return recipes[i]
            end
        end
    end

    repeat
        recipe = getRecipe()
    until recipe ~= nil

    -- Add the recipe to the player's list
    self:addRecipe(recipe.name, recipe.value)
end

-- Function to remove a recipe from a player's list
function OrderService:removeAllRecipes()
    if not playerRecipes then return end
    -- Find the recipe in the player's list and remove it
    playerRecipes.storage = {}

    countId = 0
    
    for _, player : Player in Players:GetPlayers() do
        self.Client.RemoveAllOrders:Fire(player)
    end
end

-- Function to remove a recipe from a player's list
function OrderService:removeRecipe(recipeId)
    if not recipeId then return end
    if not playerRecipes then return end

    for i, r in ipairs(playerRecipes.storage) do
        --print(r.id, recipeId, r.id == recipeId)
        if r.id == recipeId then
            for _, player : Player in Players:GetPlayers() do
                self.Client.RemoveOrder:Fire(player, r.id)
            end
            
            table.remove(playerRecipes.storage, i) 
            break
        end
    end
end

-- Function to remove a recipe from a player's list
function OrderService:getRecipe(recipeId)
    if not recipeId then return end
    -- Check if the player already has a list of recipes
    if playerRecipes == nil then
        -- If not, create a new list for the player
        playerRecipes = {
            storage = {}, -- player storage
            timer = playerTimer, -- 3 minute timer
        }
    end
    
    -- Find the recipe in the player's list and remove it
    for i, r in ipairs(playerRecipes.storage) do
        --print(r.id, recipeId, r.id == recipeId)
        if r.id == recipeId then
            return r
        end
    end
end

-- Function to remove expired recipes from a player's table
function OrderService:removeExpiredRecipes()
    if not playerRecipes then return end
    if pauseOrders == true then return end
    -- Iterate through the player's recipes
    for i, recipe in ipairs(playerRecipes.storage) do
        -- pause orders if paused
        if pauseOrders == true then continue end

        -- Decrement the timer
        recipe.timer = recipe.timer - 1

        -- If the timer has expired, remove the recipe from the table
        if recipe.timer <= 0 then
            -- --print("timer expired for", recipe.name, playerRecipes[player])
            --table.remove(playerRecipes[player].storage, i)

            self:removeRecipe(recipe.id)
        end
    end
end

-- Function to mark a recipe as completed for a player
function OrderService:completeRecipe(recipe, reward, percentage)
    if not recipe or not reward or not percentage then return end
    if not playerRecipes then return end

    -- Find the recipe in the player's list and mark it as completed
    for _, r in ipairs(playerRecipes.storage) do
        if r.name == recipe and r.completed == false then
            --print("COMPLETE RECIPE:", player, recipe)
            r.completed = true

            local bonusReward = (reward * 0.3) -- 30%

            --print("uh", percentage, (percentage >= cookedRange.min and percentage <= cookedRange.max))

            if percentage then

                if percentage >= cookedRange.min and percentage <= cookedRange.max then
                    print("% bonus")
                    --Knit.GetService("DataService"):GiveCurrency(player, bonusReward, false, "+BONUS %")
                end

                --[[for _, member in pairs(PartyMembers) do
                    local profile = DataService:GetProfile(member)

                    if percentage >= cookedRange.min and percentage <= cookedRange.max then
                        
                        if profile then
                            -- check if this is the first time unlocking the recipe 
                            if not profile.Data.RecipesCooked[recipe] then
                                profile.Data.RecipesCooked[recipe] = 0
                                Knit.GetService("NotificationService"):Message(false, member, "NEW RECIPE UNLOCKED!", {Effect = false, Color = Color3.fromRGB(255, 200, 21)})
                            end
                        end

                    end
    
                    if profile.Data.RecipesCooked[recipe] then
                        profile.Data.RecipesCooked[recipe] += 1
                        self.Client.RecipesUpdate:Fire(member, profile.Data.RecipesCooked)
                    end
                end]]
            end

            --[[for _, player : Player in Players:GetPlayers() do
                local profile = Knit.GetService("DataService"):GetProfile(player)
                if not profile.Data.RecipesCooked[recipe] then
                    Knit.GetService("NotificationService"):Message(false, player, "MUST BE COOKED PERFECTLY TO UNLOCK RECIPE!", {Effect = false, Color = Color3.fromRGB(229, 129, 6)})
                end
                self.Client.CompleteOrder:Fire(player, r.id)
            end]]
            
            self:removeRecipe(r.id)
            break
        end
    end
end

-- Function to add all recipes to a player's list in random order
function OrderService:addRandomRecipes(recipes, numCopies)
    if not recipes or not numCopies then return end
    -- Shuffle the list of recipes
    local shuffledRecipes = shuffle(recipes)

    -- Add each recipe to the player's list
    for _, recipe in ipairs(shuffledRecipes) do
        for i = 1, numCopies do
            self:addRecipe(recipe.name, recipe.value)
        end
    end
end


-- Function to update the recipes for a player
function OrderService:updatePlayerRecipes()
    if playerRecipes then
        --print("timer:", playerRecipes[player].timer)
        if playerRecipes.timer <= 0 and pauseOrders == false then
            -- Add a random recipe to the player's table
            self:addRandomRecipe(serverAvailableRecipes)

            local CalculatedTime = playerTimer --180 + ((#playerRecipes[player].storage * 60) - 90)

            playerRecipes.timer = CalculatedTime -- reset to 3 minutes
            -- --print("add recipe:", playerRecipes[player], "| adjusted CalculatedTime:", CalculatedTime)
        end

        -- Remove any expired recipes from the player's table
        self:removeExpiredRecipes()
    end
end

function OrderService:SetupProducts()
    -- ProductId [resetTimeProductId] resets the time of the players order
    productFunctions[resetTimeProductId] = function(receipt, player)
        local returnedRecipe = self:getRecipe(resetTimeOrderIds)
        returnedRecipe.timer = recipeTimer
        self.Client.ResetTimePurchase:Fire(player, returnedRecipe.id, recipeTimer)
    end
end

local function processReceipt(receiptInfo)
    if not receiptInfo then return end
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

        if pauseOrders == false then 
            print(playerRecipes)
            playerRecipes.timer -= 1
            self:updatePlayerRecipes()
        end

        task.wait(1)
    end
end


function OrderService:KnitInit()
    print('ORDER SERVICE')

    -- Set the callback this can only be done once by one script on the server!
    MarketplaceService.ProcessReceipt = processReceipt

    playerRecipes = {
        storage = {}, -- player storage
        timer = math.random(10,30), -- 10-30 seconds to automatically give one recipe
    }
    resetTimeOrderIds = 0

    self.Client.ResetTimePurchase:Connect(function(player, orderId)
        if resetTimeOrderIds ~= nil then
            resetTimeOrderIds = orderId

            if game:GetService("RunService"):IsStudio() then -- if on studio
                local returnedRecipe = self:getRecipe(orderId)
                returnedRecipe.timer = recipeTimer
                self.Client.ResetTimePurchase:Fire(player, returnedRecipe.id, recipeTimer)
            else
                MarketplaceService:PromptProductPurchase(player, resetTimeProductId)
            end

        end
    end)
end


return OrderService
