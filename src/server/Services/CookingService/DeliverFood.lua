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
			print("firewiriweirwirw")
			CookingService.Client.Deliver:Fire(plr, tostring(food), food, deliverTime)
		end
		
		Knit.GetService("OrderService"):completeRecipe(tostring(food), cookingPercentage)
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