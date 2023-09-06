local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local FoodAvailable = workspace:WaitForChild("FoodAvailable")
local IngredientAvailable = workspace:WaitForChild("IngredientAvailable")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")

local HiddenObjects = ReplicatedStorage:WaitForChild("HiddenObjects")

local GameController = Knit.CreateController { Name = "GameController" }

local LocalPlayer = Players.LocalPlayer
local CollectedItems = {}
local Cooldown = false

local partyOwner = LocalPlayer

function TableFind(tab,el) -- table,value
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end

function GameController:ForIngredient(Ingredient)
	if not Ingredient then return end
	table.insert(CollectedItems,Ingredient)

	if Ingredient:IsA("Model") then Ingredient = Ingredient.PrimaryPart end

	if not Ingredient then return end

	--self:createProximityPrompt(Ingredient,"Ingredient")

	if not Ingredient:FindFirstChild("ProximityPrompt") then return end
	Ingredient:WaitForChild("ProximityPrompt").Enabled = true
	Ingredient.ProximityPrompt.TriggerEnded:Connect(function(plr)
		--print("HUH")
		if Ingredient.Transparency == 1 then return end
		if Cooldown == false then
			Cooldown = true
			--print("triggered")
			if plr.Character:FindFirstChild("Ingredient") then
				--print("character")
				if plr.Character:FindFirstChild("Ingredient").Value == nil then
					--print("mag")
					local Mag

					Mag = (Ingredient.Position - Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude
					--print("Pickup Mag:",Mag)
					if Mag and Mag <= 6 then
						--print(tostring(Ingredient).." is Ingredient")
						--print(Ingredient, Ingredient.Parent)
						local objToDelete = (Ingredient:GetAttribute("Type") ~= nil and Ingredient.Parent:IsA("Model") and Ingredient.Parent.PrimaryPart and Ingredient.Parent) or Ingredient

						local CookingService = Knit.GetService("CookingService")
						CookingService.PickUp:Fire(Ingredient)
						task.wait(.1)

						--print(Ingredient, objToDelete)

						--[[local objToDelete = (Ingredient:GetAttribute("Type") ~= nil and Ingredient.Parent:IsA("Model") and Ingredient.Parent.PrimaryPart and Ingredient.Parent) or Ingredient

						objToDelete:Destroy()]]

						objToDelete:Destroy()

						if Ingredient.Parent then
							if Ingredient.Parent.Name == Ingredient.Name then
								--print(Ingredient.Parent.Name, Ingredient.Name )
								Ingredient.Parent:Destroy()
							end
						end

						if Ingredient then
							--print(Ingredient)
							Ingredient:Destroy()
						end
						
					end
				end
			end

			task.wait(.1)
			Cooldown = false
		end
	end)
end


function GameController:ForFood(Food)
	if not Food then return end
	table.insert(CollectedItems,Food)

	if Food:IsA("Model") then Food = Food.PrimaryPart end 

	if not Food then return end

	--self:createProximityPrompt(Food,"Food")

	if not Food:FindFirstChild("ProximityPrompt") then return end
	Food:WaitForChild("ProximityPrompt").Enabled = true
	Food.ProximityPrompt.TriggerEnded:Connect(function(plr)
		if Food.Transparency == 1 then return end
		if Cooldown == false then
			Cooldown = true
			if plr.Character:FindFirstChild("Ingredient") then
				if plr.Character:FindFirstChild("Ingredient").Value == nil then
					local Mag

					Mag = (Food.Position - Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude
					--print("Pickup Mag:",Mag)
					if Mag and Mag <= 6 then
						--print(tostring(Food).." is Food")
						local objToDelete = (Food:GetAttribute("Type") ~= nil and Food.Parent:IsA("Model") and Food.Parent.PrimaryPart and Food.Parent) or Food

						local CookingService = Knit.GetService("CookingService")
						CookingService.PickUp:Fire(Food)
						task.wait(.1)

						objToDelete:Destroy()

						if Food.Parent then
							if Food.Parent.Name == Food.Name then
								--print(Food.Parent.Name, Food.Name )
								Food.Parent:Destroy()
							end
						end

						if Food then
							--print(Food)
							Food:Destroy()
						end
					end
				end
			end

			task.wait(.1)
			Cooldown = false
		end
	end)
end

function GameController:KnitStart()
	--print("game controller")
    task.wait(1)

    for _,Ingredient in ipairs(IngredientAvailable:GetChildren()) do
        self:ForIngredient(Ingredient)
    end
    
    for _,Food in ipairs(FoodAvailable:GetChildren()) do
        self:ForFood(Food)
    end

    IngredientAvailable.ChildAdded:Connect(function(Ingredient)
        task.wait(0.5)
        self:ForIngredient(Ingredient)
    end)

    IngredientAvailable.ChildRemoved:Connect(function(Ingredient)
        table.remove(CollectedItems,TableFind(CollectedItems,Ingredient))
    end)

    FoodAvailable.ChildAdded:Connect(function(Food)
        task.wait(0.5)
        self:ForFood(Food)
    end)

    FoodAvailable.ChildRemoved:Connect(function(food)
       	table.remove(CollectedItems,TableFind(CollectedItems,food))
    end)
end


function GameController:KnitInit()

	local function checkObject(object)
		local typeObject = object:IsA("Model") and object.PrimaryPart and object.PrimaryPart:GetAttribute("Type") or object:GetAttribute("Type")

		if typeObject == "Food" then
			object.Parent = FoodAvailable
		elseif typeObject == "Ingredient" then
			--object.Parent = IngredientAvailable
			if object:IsA("Model") and object.PrimaryPart then
				for _,b in pairs(object:GetChildren()) do
					if b:IsA("BasePart") then b.Transparency = (b:GetAttribute("CustomTransparency") ~= nil and b:GetAttribute("CustomTransparency")) or 0 end
					for _, t in pairs(object:GetChildren()) do
						if t:IsA("Texture") then t.Transparency = (object.PrimaryPart:GetAttribute("ExtraTexture") ~= nil and object.PrimaryPart:GetAttribute("ExtraTexture")) or 0 end
					end
				end
			else
				object.Transparency = (object:GetAttribute("CustomTransparency") ~= nil and object:GetAttribute("CustomTransparency")) or 0
				for _, t in pairs(object:GetChildren()) do
					if t:IsA("Texture") then t.Transparency = (object:GetAttribute("ExtraTexture") ~= nil and object:GetAttribute("ExtraTexture")) or 0 end
				end
			end
		end
	end

    game:GetService("RunService").RenderStepped:Connect(function()

		for _, player in pairs(Players:GetPlayers()) do
			if player then
				if player == LocalPlayer then continue end
				local Character = player.Character
				if Character then
					local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						local DropProximity = HumanoidRootPart:FindFirstChildWhichIsA("ProximityPrompt")
						if not DropProximity then
							continue
						end
						if DropProximity.Enabled == true then
							DropProximity.Enabled = false
						end
					end
				end
			end
		end

		for _, v in pairs(CollectionService:GetTagged("OwnerId")) do
			local OwnerId = v:GetAttribute("OwnerId") 
			if OwnerId then
				if OwnerId ~= LocalPlayer.UserId then
					print("destroying hte v")
					v:Destroy()
				end
			end
		end

        for _,v in pairs(FoodAvailable:GetChildren()) do
            checkObject(v)
        end

        for _,v in pairs(IngredientAvailable:GetChildren()) do
            checkObject(v)
        end

		for _,v in pairs(HiddenObjects:GetChildren()) do
            checkObject(v)
        end
    end)
end


return GameController
