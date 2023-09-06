local Players = game:GetService("Players")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ReplicatedAssets = Knit.Shared.Assets
local ServerModules = Knit.Modules

local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"))

local EXPMultiplier = 10
local MaxFoodSpawnRange = 25


local GameLibrary = game:GetService("ReplicatedStorage"):FindFirstChild("GameLibrary")
local FoodAvailable = workspace:WaitForChild("FoodAvailable")
local FoodObjects = GameLibrary:FindFirstChild("FoodObjects")

return function (player, pan)
	--print("CanCookOnPan:", cookingPansQueue[player.UserId])

    local CookingService = Knit.GetService("CookingService")

	--print("cookingPansQueue", cookingPansQueue[player.UserId], tablefind(cookingPansQueue[player.UserId], pan) )
	--print("CanCookOnPan 2:", #cookingPansQueue[player.UserId])
	if not CookingService.PansInUse[pan] then return true end

	local function removeFood()
		if CookingService.PansInUse[pan] then 
			-- something is on the pan i will clear it for u
			print("Removing food from pan")
			pan.Parent:SetAttribute("Enabled", false)

			for _, player : Player in Players:GetPlayers() do
				CookingService.Client.UpdatePans:Fire(player, CookingService.PansInUse[pan])
			end

			--print("cookingPansQueue", cookingPansQueue[player.UserId])
			local SelectedRecipe = RecipeModule[tostring(CookingService.PansInUse[pan].Recipe)]
			local RawCalculatedEXP = (EXPMultiplier * #SelectedRecipe["Ingredients"])
			CookingService.Client.ProximitySignal:Fire(player,"CookVisible",false)
			--RewardService:GiveReward(profile, {EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2)})
	
			local DistanceBetweenPlayerAndPan = player:DistanceFromCharacter(pan.Position)
			local food
	
			--print("OUTPUT:", additionalPansInfo[player.UserId][pan])
	
			if DistanceBetweenPlayerAndPan > MaxFoodSpawnRange or DistanceBetweenPlayerAndPan == 0 then
				food = SpawnItemsAPI:Spawn(
					player.UserId, 
					player, 
					CookingService.PansInUse[pan].Recipe, 
					FoodObjects, 
					FoodAvailable, 
					pan.Position + Vector3.new(0,5,0),
					CookingService.PansInUse[pan].Percentage
				)
			else
				food = SpawnItemsAPI:Spawn(
					player.UserId, 
					player, 
					CookingService.PansInUse[pan].Recipe, 
					FoodObjects, 
					FoodAvailable,
					player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.lookVector * 4,
					CookingService.PansInUse[pan].Percentage
				)
			end
	
			--print("GENERATED FOOD:", food)

			for _, plr : Player in Players:GetPlayers() do
				Knit.GetService("NotificationService"):Message(false, plr, string.upper(tostring(food)).." WAS MADE!")
	
				CookingService.Client.ParticlesSpawn:Fire(plr, food, "CookedParticle")
				CookingService.Client.Cook:Fire(plr, "Destroy", tostring(CookingService.PansInUse[pan].Recipe), pan)
			end

			CookingService.PansInUse[pan] = nil
			return true
		end

		return false
	end

	local hasRemovedItem = removeFood()
	--print("CanCookOnPan 3:",hasRemovedItem)

	if hasRemovedItem == true then return false end
	return false
end