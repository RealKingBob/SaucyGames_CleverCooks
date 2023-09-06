local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ReplicatedAssets = Knit.Shared.Assets

----- Loaded Modules -----

local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))

return function (food)
    print('[CookingService]: Submitting Food: '.. tostring(food))

    local CookingService = Knit.GetService("CookingService")

	if RecipeModule[tostring(food)] then
		--print(SelectedRecipe,SelectedRecipe["Ingredients"])
		for k, v in ipairs(food:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Weld") then
				continue
			else
				v:Destroy()
			end
		end

		CollectionService:AddTag(food, "Delivering")

		if food:IsA("Model") then
			if food.PrimaryPart then
				for _, v in ipairs(food:GetChildren()) do
					v.Transparency = 1
					v.CanCollide = false
					v.Anchored = true
				end
			end
		else
			food.Transparency = 1
			food.CanCollide = false
			food.Anchored = true
		end

		print("DELIVER TIME")


		table.insert(CookingService.DeliveryQueue, food)
		--table.insert(deliverQueues[player.UserId], food)

		local deliverTime = RecipeModule:GetCookTime(tostring(food))

		local cookingPercentage = (food:IsA("Model") and food.PrimaryPart ~= nil and food.PrimaryPart:GetAttribute("CookingPercentage")) or food:GetAttribute("CookingPercentage")

		--print("cookingPansQueue", cookingPansQueue[player.UserId])

		for _, plr : Player in Players:GetPlayers() do
			CookingService.Client.Deliver:Fire(plr, tostring(food), food, deliverTime)
		end
		
		local cheeserew

		task.spawn(function()
			local waitTime = 2
			local numOfDrops = deliverTime / waitTime
			local cheeseDrop = RecipeModule:GetRecipeRewards(RecipeModule[tostring(food)].Difficulty)
			local rCheeseDropReward = math.random(
				(cheeseDrop[1] - (cheeseDrop[1] * .15)),
				(cheeseDrop[2] - (cheeseDrop[2] * .15)))

			cheeserew = rCheeseDropReward

			local cheeseValuePerDrop = rCheeseDropReward / numOfDrops
			local cheeseObjectPerDrop = 6
			-- oCFrame, obj, amount, value

			print("deliver drop", RecipeModule[tostring(food)], numOfDrops, cheeseDrop, rCheeseDropReward, cheeseValuePerDrop)

			local foodObj

			if food:IsA("Model") then
				foodObj = food.PrimaryPart
			else
				foodObj = food
			end

			local CurrencySessionService = Knit.GetService("CurrencySessionService")
			
			--[[for i = 1, numOfDrops do
				CurrencySessionService:DropCheese(
					foodObj.CFrame, 
					player, 
					cheeseObjectPerDrop, 
					math.floor((cheeseValuePerDrop / cheeseObjectPerDrop))
				)
				task.wait(waitTime)
			end]]

			food:Destroy()
		end)

		--Knit.GetService("OrderService"):completeRecipe(player, tostring(food), cheeserew, cookingPercentage)
		--RewardService:GiveReward(profile, {EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2)})

		print("food delivered:", food)
		
		for _, plr : Player in Players:GetPlayers() do
			Knit.GetService("NotificationService"):Message(false, plr, string.upper(tostring(food)).." WAS DELIVERED!")
		end

		task.wait(deliverTime)

		table.remove(CookingService.DeliveryQueue, table.find(CookingService.DeliveryQueue, food))

		--print("cookingPansQueue", cookingPansQueue[player.UserId])

		--local RawCalculatedEXP = (EXPMultiplier * #SelectedRecipe["Ingredients"])
		for _, plr : Player in Players:GetPlayers() do
			CookingService.Client.ProximitySignal:Fire(plr,"CookVisible",false)
		end
		
		--StatTrackService:SetRecentCookedFood(player, tostring(recipe))
	end
end