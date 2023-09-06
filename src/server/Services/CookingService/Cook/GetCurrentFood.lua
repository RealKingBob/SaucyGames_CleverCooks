local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local CollectionService = game:GetService("CollectionService")

return function (player)
	local foundFood = false
	local currentRecipe, currentPercentage

    local CookingService = Knit.GetService("CookingService")
	
	for _, ingredientFromTable in pairs(CookingService.CurrentIngredientObjects) do
		local obj = (ingredientFromTable:IsA("Model") and ingredientFromTable.PrimaryPart ~= nil and ingredientFromTable.PrimaryPart) or ingredientFromTable

		if obj:GetAttribute("Type") == "Food" then
			currentRecipe = ingredientFromTable.Name
			--print(obj:GetAttribute("CookingPercentage"))
			currentPercentage = obj:GetAttribute("CookingPercentage") or 0

			if currentPercentage >= 100 then
				if require(script.Parent.Parent.WarnOvercooked)(player, ingredientFromTable) == false then return nil end
			end
            
			local objToDelete = (obj:GetAttribute("Type") ~= nil and obj.Parent:IsA("Model") and obj.Parent) or obj
			CollectionService:AddTag(objToDelete, "OnCookingDelete")
			print("checkforfood:", objToDelete:GetFullName(), ingredientFromTable:GetFullName())
			objToDelete:Destroy()
			foundFood = true
			break
		end
	end
	if foundFood == false then return nil end
	return currentRecipe, currentPercentage
end