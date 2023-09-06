local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ReplicatedAssets = Knit.Shared.Assets
local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"))

return function (player, pan, recipe, previousPercentage)
	print("player, pan, recipe, previousPercentage:", player, pan, recipe, previousPercentage)

    local CookingService = Knit.GetService("CookingService")

	CookingService:DebounceCooking(player, 1)

	CookingService.PansInUse[pan] = {
		Recipe = recipe,
		Percentage = previousPercentage,
	}

	local ProgressionService = Knit.GetService("ProgressionService")
	local playerCurrency, playerStorage, progressionStorage = ProgressionService:GetProgressionData(player, workspace:GetAttribute("Theme"))


	warn("PROGRESSION DATA:", playerCurrency, playerStorage, progressionStorage)
	-- cookingTime = (Default_Time / Player_Cook_Speed) * 2
	local cookingTime = (RecipeModule:GetCookTime(tostring(recipe)) / progressionStorage["Cook Speed"].Data[playerStorage["Cook Speed"]].Value) * 2

	--print("cookingPansQueue", cookingPansQueue[player.UserId])

	for _, plr : Player in Players:GetPlayers() do
		Knit.GetService("NotificationService"):Message(false, plr, "COOKING STARTED!")

		CookingService.Client.Cook:Fire(plr, "Initialize", tostring(recipe), pan)
		CookingService.Client.UpdatePans:Fire(plr, CookingService.PansInUse[pan])
	end

	local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end

	-- Function to get a number within the range 0 to 100 from a range from 0 to [num]
	local function getNumberInRange(num, maxRange)
		-- Calculate the number in the range 0 to 100
		local numberInRange = (num / maxRange) * 100

		-- Return the calculated number
		return numberInRange
	end

	-- Function to get a number within the range 0 to [num] from a range from 0 to 100
	local function getNumberInRange2(num, maxRange)
		-- Calculate the number in the range 0 to 100
		local numberInRange = (num / 100) * maxRange

		-- Return the calculated number
		return numberInRange
	end

	local count = getNumberInRange2(previousPercentage,  cookingTime)
	local isOverLimit = false

	local waitTime = 2
	local numOfDrops = (cookingTime / 2) / waitTime

	local CurrencySessionService = Knit.GetService("CurrencySessionService")
	local CookPerfection = progressionStorage["Cooking Perfection"].Data[playerStorage["Cooking Perfection"]].Value
	local MaxCookSpeed = (progressionStorage["Cook Speed"].Max == playerStorage["Cook Speed"] and true) or false
	--print(CookPerfection, MaxCookSpeed)

	pan.parent:SetAttribute("Enabled", true)
	
	if CookPerfection == true and MaxCookSpeed == true then
		if previousPercentage ~= 50 then
			if previousPercentage < 50 then
				local cheeseDrop = RecipeModule:GetRecipeRewards(RecipeModule[tostring(recipe)].Difficulty)
				local rCheeseDropReward = math.random(
					(cheeseDrop[1] - (cheeseDrop[1] * .15)),
					(cheeseDrop[2] - (cheeseDrop[2] * .15)))
	
				local cheeseValuePerDrop = rCheeseDropReward
				local cheeseObjectPerDrop = 6
	
				CurrencySessionService:DropCheese(
					pan.CFrame, 
					player, 
					cheeseObjectPerDrop, 
					math.floor((cheeseValuePerDrop / cheeseObjectPerDrop))
				)
			end
			
			for _, plr : Player in Players:GetPlayers() do
				Knit.GetService("NotificationService"):Message(false, plr, "Perfect Cooking!", {Effect = false, Color = Color3.fromRGB(255, 200, 21)})
			end

			if CookingService.PansInUse[pan] then
				CookingService.PansInUse[pan] = {
					Recipe = recipe,
					Percentage = 50,
				}
			end
			return require(script.Parent.CanCookOnPan)(player, pan) --self:CanCookOnPan(player, pan)
		end
	end

	task.spawn(function()
		repeat
			if count >= cookingTime then
				count = cookingTime
				isOverLimit = true
			else
				count += 1
			end

			print("count", count)
			--if count == math.ceil((cookingTime / 2)) then
				--local CookPerfection = progressionStorage["Cooking Perfection"].Data[playerStorage["Cooking Perfection"]].Value
				--[[f CookPerfection == true then
					for _, member in pairs(PartyMembers) do
						Knit.GetService("NotificationService"):Message(false, member, "Perfect Cooking!", {Effect = false, Color = Color3.fromRGB(255, 200, 21)})
					end
					if additionalPansInfo[PartyOwner.UserId][pan] then
						additionalPansInfo[PartyOwner.UserId][pan] = {
							Recipe = recipe,
							Percentage = getNumberInRange(count + 1,  cookingTime),
						}
					end
					self:CanCookOnPan(PartyOwner, pan)
				end]]
			--end

			if (count % waitTime == 0) and (count <= (cookingTime / 2)) then

				local cheeseDrop = RecipeModule:GetRecipeRewards(RecipeModule[tostring(recipe)].Difficulty)
				local rCheeseDropReward = math.random(
					(cheeseDrop[1] - (cheeseDrop[1] * .15)),
					(cheeseDrop[2] - (cheeseDrop[2] * .15)))

				local cheeseValuePerDrop = rCheeseDropReward / numOfDrops
				local cheeseObjectPerDrop = 6

				CurrencySessionService:DropCheese(
					pan.CFrame, 
					player, 
					cheeseObjectPerDrop, 
					math.floor((cheeseValuePerDrop / cheeseObjectPerDrop))
				)
			end

			if CookingService.PansInUse[pan] then
				CookingService.PansInUse[pan] = {
					Recipe = recipe,
					Percentage = getNumberInRange(count,  cookingTime),
				}
				--print("ehm: ", additionalPansInfo[player.UserId][pan])
				local previousNumberInRange = getNumberInRange(count - 1, cookingTime)
				local currentNumberInRange = getNumberInRange(count,  cookingTime)

				--print("nums", count, count-1, previousNumberInRange, currentNumberInRange)

				for _, plr : Player in Players:GetPlayers() do
					CookingService.Client.Cook:Fire(plr, "CookUpdate", tostring(recipe), pan, {previous = previousNumberInRange, current = currentNumberInRange, overCookingLimit = isOverLimit})
				end
				task.wait(1)
			end
		until not player or CookingService.PansInUse[pan] == nil
	end)
end