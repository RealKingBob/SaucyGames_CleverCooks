local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local CollectionService = game:GetService("CollectionService")

local ReplicatedAssets = Knit.Shared.Assets
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))

return function (recipe)

    local CookingService = Knit.GetService("CookingService")

	local IngredientsUsed = {}
	local SelectedRecipe = RecipeModule[tostring(recipe)]
	local previousPercentage = 0
	--print(SelectedRecipe,SelectedRecipe["Ingredients"])
	for _,ingredientFromRecipe in pairs(SelectedRecipe["Ingredients"]) do
		--print("AB",ingredientFromRecipe,CurrentIngredientObjects[player.Name])
		if CookingService.CurrentIngredientObjects then
			for _, ingredientFromTable in pairs(CookingService.CurrentIngredientObjects) do
				if typeof(ingredientFromTable) == "table" then
					if tostring(ingredientFromTable.Ingredient) == tostring(ingredientFromRecipe) then
						CollectionService:AddTag(ingredientFromTable.Source, "OnDelete")
						CollectionService:AddTag(ingredientFromTable.Source, "OnCookingDelete")
						table.insert(IngredientsUsed,ingredientFromTable.Source)
						break
					end
				else
					if tostring(ingredientFromTable) == tostring(ingredientFromRecipe) then
						CollectionService:AddTag(ingredientFromTable, "OnCookingDelete")
						table.insert(IngredientsUsed,ingredientFromTable)
						break
					end
				end
			end
		end
	end

	return IngredientsUsed
end