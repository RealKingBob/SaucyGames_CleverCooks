local CollectionService = game:GetService("CollectionService")

return function (IngredientsUsed)
	local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints")
	for i, ingredient in pairs(IngredientsUsed) do
		if ingredient then
			if CollectionService:HasTag(ingredient, "OnDelete") then
				ingredient:Destroy()
				table.remove(IngredientsUsed, i)
				continue
			end
			if ingredient:IsA("Model") and ingredient.PrimaryPart then
				ingredient.PrimaryPart.ProximityPrompt.Enabled = false
			else
				ingredient.ProximityPrompt.Enabled = false
			end
		end
	end
	for _, ingredient in pairs(IngredientsUsed) do
		task.spawn(function()
			if ingredient then
				local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)]
				if RandomFoodLocation then
					if ingredient:IsA("Model") then
						if ingredient.PrimaryPart then
							ingredient:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
						else
							ingredient = nil
						end
					else
						ingredient.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))
					end
				end

				task.wait(0.1)

				if ingredient ~= nil then
					CollectionService:RemoveTag(ingredient, "OnCookingDelete")
					if ingredient:IsA("Model") and ingredient.PrimaryPart then
						ingredient.PrimaryPart.ProximityPrompt.Enabled = true
					else
						ingredient.ProximityPrompt.Enabled = true
					end
				end
			end
		end)
	end
end