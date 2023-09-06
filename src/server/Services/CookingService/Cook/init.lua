local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ReplicatedAssets = Knit.Shared.Assets

----- Loaded Modules -----

local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))

return function (player, Character, recipe, pan)

	print("\n\n\n\n\n\n\n\n\n\n\n\n\n")
	print('[CookingService]: Cooking Food: '.. tostring(recipe), player)
	print('[CookingService]: Additional info:', player, Character, recipe, pan)

	if not player or not pan then return false end

    local CookingService = Knit.GetService("CookingService")

	if CookingService.CookingDebounce[player] then
		warn('CANT COOK BECAUSE COOLDOWN:', CookingService.CookingDebounce[player].Value)
		Knit.GetService("NotificationService"):Message(false, player, "Cooking cooldown, try again.", {Effect = false, Color = Color3.fromRGB(255, 255, 255)})
		return
	end

	local CanCook = require(script.CanCookOnPan)(player, pan)
	print('Check if can cook:', CanCook)
	if CanCook == false then return false end

	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)

	if profile then
		if recipe and RecipeModule[tostring(recipe)] then -- if not food and all ingredients
			print("Cooking new food")
			local SelectedRecipe = RecipeModule[tostring(recipe)]
			local previousPercentage = 0
			local IngredientsUsed = require(script.GetIngredients)(recipe) --ingredientCheck(player, recipe)

			if #SelectedRecipe["Ingredients"] == #IngredientsUsed then
				print('[CookingService]: Found all ingredients',IngredientsUsed)
				require(script.DestroyIngredients)(IngredientsUsed) --destroyIngredients(IngredientsUsed)
				IngredientsUsed = {}
			else
				recipe, previousPercentage = require(script.GetCurrentFood)(player) --checkForFood(player)

				if not recipe then 
					warn("couldnt find food")
					return 
				end
				IngredientsUsed = {}
			end

			--print("COOKING TIME")

			CookingService:StartCookingProcess(player, pan, recipe, previousPercentage)
		else -- if food
			print("Cooking existing food")
			local previousPercentage = 0

			recipe, previousPercentage = require(script.GetCurrentFood)(player)
			if not recipe then 
				warn("couldnt find food")
				return 
			end

			CookingService:StartCookingProcess(player, pan, recipe, previousPercentage)
		end
	else
		warn("Could not find user["..tostring(player.UserId).."] profile to cook the food, please retry")
	end
end