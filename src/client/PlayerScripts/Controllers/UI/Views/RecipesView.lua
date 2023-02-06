local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local RecipesView = Knit.CreateController { Name = "RecipesView" }

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary")
local BillboardUI = GameLibrary:WaitForChild("BillboardUI")
local Shared = ReplicatedStorage:WaitForChild("Common")

local ReplicatedAssets = Shared:WaitForChild("Assets")
local ReplicatedModules = Shared:WaitForChild("Modules")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainGui = PlayerGui:WaitForChild("GUI")
local viewsUI = PlayerGui:WaitForChild("Main"):WaitForChild("Views")

local RecipesGui = viewsUI:WaitForChild("Recipes")

local BottomFrame = PlayerGui:WaitForChild("Main"):WaitForChild("BottomFrame")
local IngredientsTab = BottomFrame:WaitForChild("IngredientsTab")
local foodNameDisplayed = BottomFrame:FindFirstChild("FoodName")

local recipeSection = RecipesGui:WaitForChild("RecipeFrame")
local recipeList = recipeSection:WaitForChild("RecipeList")
local recipeTitle = recipeSection:WaitForChild("RecipeTitle")
local ingredientList = recipeSection:WaitForChild("IngredientsList"):WaitForChild("ScrollingFrame")
local selectedRecipeFrame = recipeSection:WaitForChild("SelectedRecipe")
local selectedIconImage = selectedRecipeFrame:WaitForChild("IconImage")

local selectButton = recipeSection:WaitForChild("SelectButton")

local notSelectedColors = {Color3.fromRGB(199, 77, 47), Color3.fromRGB(129, 48, 30)}; -- button, button.parent or button, shadow
local selectedColors = {Color3.fromRGB(255, 170, 0), Color3.fromRGB(125, 83, 0)};
local completedColors = {Color3.fromRGB(0, 184, 0),Color3.fromRGB(0, 80, 0)};
local notCompletedColors = {Color3.fromRGB(223, 190, 149),Color3.fromRGB(124, 94, 69)};

local recipeSelected = nil;
local allIngredientsFound = false;

local RecipeModule = require(ReplicatedAssets.Recipes)
local IngredientModule = require(ReplicatedAssets.Ingredients)

local myReplicatedIngredients = {};
local highlightedItems = {};
local currentPansInUse = {};
local ShortDistanceObject
local CookDebounce = false;
local CookButton = mainGui.Cook

local prevFoodName = nil
local prevIngredientTab = nil;
local prevConnection = nil;
local prevIngredientButton = nil;

local pageRecipeSound = "rbxassetid://552900451";

local ZoneAPI = require(ReplicatedModules:FindFirstChild("Zone"));
local panZone = ZoneAPI.new(CollectionService:GetTagged("Pan"));

-- setup

local function playLocalSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId;
    sound.Volume = volume;
    SoundService:PlayLocalSound(sound)
    sound.Ended:Wait()
    sound:Destroy()
end

local function tablefind(tab,el) 
	for index, value in pairs(tab) do
		if value == el then
			return index;
		end
	end
	return nil;
end

-- Define the sorting function
local function sortByDifficulty(a, b)
	local difficultyOrder = {["Easy"] = 1, ["Medium"] = 2, ["Hard"] = 3}
	return difficultyOrder[a.Difficulty] < difficultyOrder[b.Difficulty]
end

local function sortByName(a, b)
    return a.Key < b.Key
end

function getNearestPan(fromPosition)
	local selectedPan, dist = nil, math.huge
	for _, pan in ipairs(CollectionService:GetTagged("Pan")) do
		if pan and (pan.Position - fromPosition).Magnitude < dist then
			selectedPan, dist = pan, (pan.Position - fromPosition).Magnitude
		end
	end
	return selectedPan
end

function getNearestBlender(fromPosition)
	local selectedPan, dist = nil, math.huge
	for _, blender in ipairs(CollectionService:GetTagged("Blender")) do
		blender = blender:IsA("Model") and blender.PrimaryPart or blender
		if blender and (blender.Position - fromPosition).Magnitude < dist then
			selectedPan, dist = blender, (blender.Position - fromPosition).Magnitude
		end
	end
	return selectedPan
end

function getNearestDelivery(fromPosition)
	local selectedDeliverZone, dist = nil, math.huge
	for _, deliverZone in ipairs(CollectionService:GetTagged("DeliverStation")) do
		if deliverZone and (deliverZone.Position - fromPosition).Magnitude < dist then
			selectedDeliverZone, dist = deliverZone, (deliverZone.Position - fromPosition).Magnitude
		end
	end
	return selectedDeliverZone
end

function highlightItems(itemsData)
	for i = 1,#highlightedItems do
		CollectionService:RemoveTag(highlightedItems[i], "Marker")
		--highlightedItems[i]:Destroy();
	end

	local MarkerTemplate = BillboardUI:WaitForChild("MarkerUI")

	if not itemsData then
		return
	end

	for _, itemName in pairs(itemsData) do
		local originalVal = itemName
		local foundIngredient = IngredientModule[originalVal]
		local foundBlendedIngredient, replaced = string.gsub(originalVal, "%[", "");
			foundBlendedIngredient = string.gsub(foundBlendedIngredient, "%]", "")
			foundBlendedIngredient = string.gsub(foundBlendedIngredient, "-", "")
			foundBlendedIngredient = string.gsub(foundBlendedIngredient, "Blended", "")

		if IngredientModule[originalVal] == nil then
			foundIngredient = IngredientModule[foundBlendedIngredient]
		end

		--print(foundIngredient, tostring(itemName):find("[Blended]"), foundBlendedIngredient, IngredientModule[originalVal] , IngredientModule[foundBlendedIngredient])

		if not foundIngredient then
			foundIngredient = {
				Name = "~Not An Item~";
			}
		end

		local function findClosestIngredient(table, position)
			local closestPart, closestPartMagnitude
		
			local tmpMagnitude
			for i, v in pairs(table) do
				local primaryPart = v:IsA("Model") and v.PrimaryPart ~= nil and v.PrimaryPart or v
				if closestPart then
					tmpMagnitude = (position - primaryPart.Position).magnitude

					if tmpMagnitude < closestPartMagnitude then
						closestPart = v
						closestPartMagnitude = tmpMagnitude 
					end
				else
					closestPart = v
					closestPartMagnitude = (position - primaryPart.Position).magnitude
				end
			end
			return closestPart --, closestPartMagnitude
		end

		local itemsList = {};

		for _, item in pairs(workspace:WaitForChild("IngredientAvailable"):GetChildren()) do
			local owner = item:IsA("Model") and item.PrimaryPart and item.PrimaryPart:GetAttribute("Owner") or item:GetAttribute("Owner")

			if item.Name == foundIngredient.Name and (owner == LocalPlayer.Name or owner == "Default") then
				table.insert(itemsList, item)
			end
		end

		local Character = LocalPlayer.Character

		local item = (Character ~= nil and Character.PrimaryPart ~= nil and findClosestIngredient(itemsList, Character.PrimaryPart.Position)) or workspace:WaitForChild("IngredientAvailable"):FindFirstChild(foundIngredient.Name)
		if not item then continue end
		--local markerClone = MarkerTemplate:Clone();
		CollectionService:AddTag(item, "Marker")
		highlightedItems[#highlightedItems +  1] = item--markerClone
		--markerClone.Parent = item;
	end
end

function recipePageCreated(PageNumber,PageData)
	local PageLimit = 6 -- 6 buttons per page
	local recipeCount = 0
	local Prefabs = LocalPlayer.PlayerGui:WaitForChild("Prefabs")
	local FoodTemplate = Prefabs:WaitForChild("FoodTemplate")
	local PageTemplate = Prefabs:WaitForChild("PageTemplate")
	local Page = PageTemplate:Clone()
	Page.Name = tostring(PageNumber)
	Page.Parent = recipeList

	local difficultyTable = {};

	if PageData then
		for key, value in next, PageData do
			if key and value then
				if type(value) == "table" then
					table.insert(difficultyTable, {Key = key, Difficulty = value.Difficulty})
				end
			end;
		end;
	end

	table.sort(difficultyTable, sortByName)
	table.sort(difficultyTable, sortByDifficulty)

	print(difficultyTable)

	for _, itemData in ipairs(difficultyTable) do
		recipeCount += 1
		local key, value = itemData.Key, PageData[itemData.Key];
		if recipeCount < PageLimit then
			local ClonedFoodTemplate = FoodTemplate:Clone()
			ClonedFoodTemplate.Name = tostring(key)
			ClonedFoodTemplate.FoodTitle.Text = tostring(key)
			if value["Image"] == "" or value["Image"] == nil then
				ClonedFoodTemplate.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
			else
				ClonedFoodTemplate.Icon.IconImage.Image = value.Image
			end
			ClonedFoodTemplate.Parent = Page
			PageData[itemData.Key] = nil
		else
			local ClonedFoodTemplate = FoodTemplate:Clone()
			ClonedFoodTemplate.Name = tostring(key)
			ClonedFoodTemplate.FoodTitle.Text = tostring(key)
			if value["Image"] == "" or value["Image"] == nil then
				ClonedFoodTemplate.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
			else
				ClonedFoodTemplate.Icon.IconImage.Image = value.Image
			end
			ClonedFoodTemplate.Parent = Page
			PageData[itemData.Key] = nil
			--table.remove(PageData,TableFind(PageData,v))
			local NewPage = PageData
			recipeCount = 0
			PageNumber += 1
			--print(NewPage,PageNumber)
			return recipePageCreated(PageNumber,NewPage)
		end
	end

	--[[if PageData then
		for key, value in next, PageData do
			if key and value then
				if type(value) == "table" then
					recipeCount += 1
					if recipeCount < PageLimit then
						local ClonedFoodTemplate = FoodTemplate:Clone()
						ClonedFoodTemplate.Name = tostring(key)
						ClonedFoodTemplate.FoodTitle.Text = tostring(key)
						if value["Image"] == "" or value["Image"] == nil then
							ClonedFoodTemplate.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
						else
							ClonedFoodTemplate.Icon.IconImage.Image = value.Image
						end
						ClonedFoodTemplate.Parent = Page
						PageData[key] = nil
					else
						local ClonedFoodTemplate = FoodTemplate:Clone()
						ClonedFoodTemplate.Name = tostring(key)
						ClonedFoodTemplate.FoodTitle.Text = tostring(key)
						if value["Image"] == "" or value["Image"] == nil then
							ClonedFoodTemplate.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
						else
							ClonedFoodTemplate.Icon.IconImage.Image = value.Image
						end
						ClonedFoodTemplate.Parent = Page
						PageData[key] = nil
						--table.remove(PageData,TableFind(PageData,v))
						local NewPage = PageData
						recipeCount = 0
						PageNumber += 1
						--print(NewPage,PageNumber)
						return recipePageCreated(PageNumber,NewPage)
					end
				end
			end;
		end;
	end]]
end

function setupRecipes()
    --print("setupRecipes")
	local Pages = recipeSection:WaitForChild("Pages")
	local PageOrganizer = recipeList:WaitForChild("PageOrganizer")
	
	local LeftButton = recipeSection:WaitForChild("Left")
	local RightButton = recipeSection:WaitForChild("Right")
	
	for _,pages in pairs(recipeList:GetChildren()) do
		if pages:IsA("Frame") then
			pages:Destroy()
		end
	end

    local duplicatedData = RecipeModule:Copy()
	
	print(duplicatedData)
	recipePageCreated(1,duplicatedData)
	local TotalPages = 0
	for _,page in pairs(recipeList:GetChildren()) do
		if page:IsA("Frame") then
			TotalPages += 1
		end
	end
	Pages.Text = "Page "..tostring(PageOrganizer.CurrentPage).."/"..tostring(TotalPages)
	
	RightButton.MouseButton1Click:Connect(function() -- Page click
		PageOrganizer:Next()
		task.spawn(playLocalSound, pageRecipeSound, 0.2)
		local TotalPages = 0
		for _,page in pairs(recipeList:GetChildren()) do
			if page:IsA("Frame") then
				TotalPages += 1
			end
		end
	end)

    LeftButton.MouseButton1Click:Connect(function()
		PageOrganizer:Previous()
		task.spawn(playLocalSound, pageRecipeSound, 0.2)
		local TotalPages = 0
		for _,page in pairs(recipeList:GetChildren()) do
			if page:IsA("Frame") then
				TotalPages += 1
			end
		end
	end)

	PageOrganizer:GetPropertyChangedSignal("CurrentPage"):Connect(function()
		Pages.Text = "Page "..tostring(PageOrganizer.CurrentPage).."/"..tostring(TotalPages)
	end)
	setupRecipeButtons()
end

local function displayIngredients(clearItems)
	if clearItems then
		foodNameDisplayed.Text = ""
		allIngredientsFound = false;
		highlightItems()
		return
	end
	if prevIngredientTab == recipeSelected then
		return
	end
	prevIngredientTab = recipeSelected
	if prevConnection then
		prevConnection:Disconnect()
		prevConnection = nil;
	end
	for _, frame in pairs(IngredientsTab:GetChildren()) do
		if frame:IsA("Frame") then
			--frame:TweenSize(UDim2.fromScale(0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic)
			frame:Destroy()
		end
	end;

	if recipeSelected == nil then
		foodNameDisplayed.Text = ""
		allIngredientsFound = false;
		highlightItems()
		return
	end

	foodNameDisplayed.Text = recipeSelected

	local greenIngredients = {};
	allIngredientsFound = false;
	CookButton.Visible = false;

	highlightItems(RecipeModule[recipeSelected]["Ingredients"])

	for _,ingredient in pairs(RecipeModule[recipeSelected]["Ingredients"]) do
		local originalVal = ingredient
		local foundIngredient = IngredientModule[originalVal]
		local foundBlendedIngredient, replaced = string.gsub(originalVal, "%[", "");
			foundBlendedIngredient = string.gsub(foundBlendedIngredient, "%]", "")
			foundBlendedIngredient = string.gsub(foundBlendedIngredient, "-", "")
			foundBlendedIngredient = string.gsub(foundBlendedIngredient, "Blended", "")

		--print(foundIngredient, tostring(ingredient):find("[Blended]"), foundBlendedIngredient, IngredientModule[originalVal] , IngredientModule[foundBlendedIngredient])

		if IngredientModule[originalVal] == nil then
			foundIngredient = IngredientModule[foundBlendedIngredient]
		end

		local Prefabs = LocalPlayer.PlayerGui:WaitForChild("Prefabs")
		local HoverIngredientTemplate = Prefabs:WaitForChild("HoverIngredientTemplate")
		local clonedIngredientFrame = HoverIngredientTemplate:Clone()
		clonedIngredientFrame.Size = UDim2.fromScale(0,0)
		clonedIngredientFrame.Name = tostring(originalVal)
		if tostring(ingredient):match("Blended") then
			clonedIngredientFrame.Icon.IconImage.Image = foundIngredient["BlendedImage"]
			clonedIngredientFrame.Icon.IconImageShadow.Image = foundIngredient["BlendedImage"]
		elseif foundIngredient then
			clonedIngredientFrame.Icon.IconImage.Image = foundIngredient["Image"]
			clonedIngredientFrame.Icon.IconImageShadow.Image = foundIngredient["Image"]
		else
			clonedIngredientFrame.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
			clonedIngredientFrame.Icon.IconImageShadow.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
		end
		
		if myReplicatedIngredients then
			if #myReplicatedIngredients == 0 then
				clonedIngredientFrame.UIStroke.Color = notCompletedColors[2]
				clonedIngredientFrame.BackgroundColor3 = notCompletedColors[2]
				clonedIngredientFrame.Icon.BackgroundColor3 = notCompletedColors[1]
			else
				for _,v in pairs(myReplicatedIngredients) do
					if clonedIngredientFrame.Name == tostring(v) then
						clonedIngredientFrame.UIStroke.Color = completedColors[2]
						clonedIngredientFrame.BackgroundColor3 = completedColors[2]
						clonedIngredientFrame.Icon.BackgroundColor3 = completedColors[1]
						break;
					else
						clonedIngredientFrame.UIStroke.Color = notCompletedColors[2]
						clonedIngredientFrame.BackgroundColor3 = notCompletedColors[2]
						clonedIngredientFrame.Icon.BackgroundColor3 = notCompletedColors[1]
					end
				end
			end
		end
		table.insert(greenIngredients, clonedIngredientFrame)
		clonedIngredientFrame.Parent = IngredientsTab;
		clonedIngredientFrame:TweenSize(UDim2.fromScale(0.081,1), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic);
		--task.wait(0.01)
	end

	local checkIfAllGreen = true;
	for _, v in pairs(greenIngredients) do
		if v.BackgroundColor3 ~= completedColors[2] then
			checkIfAllGreen = false
			break;
		end
	end
	--print('checkIfAllGreen', checkIfAllGreen)
	if checkIfAllGreen == true then
		allIngredientsFound = true;
		for _, pan in pairs(CollectionService:GetTagged("Pan")) do
			if pan:FindFirstChild("CookHeadUI") then continue end;
			print("tryee")
			pan.ProximityPrompt.Enabled = true;
		end
	else
		allIngredientsFound = false;
		for _, pan in pairs(CollectionService:GetTagged("Pan")) do
			if tablefind(currentPansInUse, pan) then continue end;
			print("not truurueuee")
			pan.ProximityPrompt.Enabled = false;
		end
	end

	local CookingService = Knit.GetService("CookingService")
	
	prevConnection = CookingService.SendIngredients:Connect(function(args)
		greenIngredients = {};
		--print(args)
		if args then
			myReplicatedIngredients = args
			if #myReplicatedIngredients == 0 then
				for _, frame in pairs(IngredientsTab:GetChildren()) do
					if frame:IsA("Frame") then
						frame.UIStroke.Color = notCompletedColors[2]
						frame.BackgroundColor3 = notCompletedColors[2]
						frame.Icon.BackgroundColor3 = notCompletedColors[1]
						table.insert(greenIngredients, frame)
					end
				end
			else
				for _, frame in pairs(IngredientsTab:GetChildren()) do
					for _,v in pairs(myReplicatedIngredients) do
						if frame:IsA("Frame") then
							if frame.Name == tostring(v) then
								frame.UIStroke.Color = completedColors[2]
								frame.BackgroundColor3 = completedColors[2]
								frame.Icon.BackgroundColor3 = completedColors[1]
								break;
							else
								frame.UIStroke.Color = notCompletedColors[2]
								frame.BackgroundColor3 = notCompletedColors[2]
								frame.Icon.BackgroundColor3 = notCompletedColors[1]
							end
							table.insert(greenIngredients, frame)
						end
					end
				end
			end

			checkIfAllGreen = true;
			for _, v in pairs(greenIngredients) do
				if v.BackgroundColor3 ~= completedColors[2] then
					checkIfAllGreen = false
					break;
				end
			end
			--print('checkIfAllGreen', checkIfAllGreen)
			if checkIfAllGreen == true then
				allIngredientsFound = true;
				for _, pan in pairs(CollectionService:GetTagged("Pan")) do
					if pan:FindFirstChild("CookHeadUI") then continue end;
					print("asdasdas")
					pan.ProximityPrompt.Enabled = true;
				end
			else
				allIngredientsFound = false;
				for _, pan in pairs(CollectionService:GetTagged("Pan")) do
					if tablefind(currentPansInUse, pan) then continue end;
					print("falsese asdasdas")
					pan.ProximityPrompt.Enabled = false;
				end
			end
		end
	end)
end


function setupRecipeButtons()

	local function setupIngredients(foodName)
		if foodName == prevFoodName then
			return
		end
		prevFoodName = foodName
		local selectedRecipe = RecipeModule[foodName]
		if selectedRecipe then
			if selectedRecipe["Image"] == "" or selectedRecipe["Image"] == nil then
				selectedIconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
			else
				selectedIconImage.Image = selectedRecipe["Image"]
			end
			
			recipeTitle.Text = "-"..selectedRecipe["Name"].."-"
			
			for _, frame in pairs(ingredientList:GetChildren()) do
				if frame:IsA("Frame") then
					frame:Destroy();
				end
			end
			
			for _, value in pairs(selectedRecipe["Ingredients"]) do

				local originalVal = value
				local foundIngredient = IngredientModule[originalVal]

				local foundBlendedIngredient, replaced = string.gsub(originalVal, "%[", "");
				foundBlendedIngredient = string.gsub(foundBlendedIngredient, "%]", "")
				foundBlendedIngredient = string.gsub(foundBlendedIngredient, "-", "")
				foundBlendedIngredient = string.gsub(foundBlendedIngredient, "Blended", "")
				
				--print("DATA", tostring(value):match("Blended"), tostring(originalVal), foundIngredient, foundBlendedIngredient, IngredientModule[value] , IngredientModule[foundBlendedIngredient])

				if IngredientModule[originalVal] == nil then
					foundIngredient = IngredientModule[foundBlendedIngredient]
				end
				
				local Prefabs = LocalPlayer.PlayerGui:WaitForChild("Prefabs")
				local IngredientTemplate = Prefabs:WaitForChild("IngredientTemplate")
				local clonedIngredientFrame = IngredientTemplate:Clone()
				clonedIngredientFrame.Name = tostring(originalVal)
				clonedIngredientFrame.IngredientTitle.Text = tostring(originalVal)
				if tostring(value):match("Blended") then
					clonedIngredientFrame.ImageFrame.Icon.IconImage.Image = foundIngredient["BlendedImage"]
				elseif foundIngredient then
					clonedIngredientFrame.ImageFrame.Icon.IconImage.Image = foundIngredient["Image"]
				else
					clonedIngredientFrame.ImageFrame.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
				end
				
				clonedIngredientFrame.Parent = ingredientList
			end
			
			if recipeSelected == foodName then
				selectButton.BackgroundColor3 = selectedColors[1]
				selectButton.StrokeText.Color = selectedColors[2]
                selectButton.StrokeBorder.Color = selectedColors[2]
				selectButton.Text = "Selected Recipe"
			else
				selectButton.BackgroundColor3 = notSelectedColors[1]
				selectButton.StrokeText.Color = notSelectedColors[2]
                selectButton.StrokeBorder.Color = notSelectedColors[2]
				selectButton.Text = "Select Recipe"
			end;
		end
	end
	
	for _,page in pairs(recipeList:GetChildren()) do
		if page:IsA("Frame") then
			for _, frame in pairs(page:GetChildren()) do
				if frame:IsA("Frame") then
					frame.Button.MouseButton1Click:Connect(function()
						if prevIngredientButton ~= nil then
							prevIngredientButton.FoodTitle.SelectedStroke.Enabled = false;
						end
						prevIngredientButton = frame;
						frame.FoodTitle.SelectedStroke.Enabled = true;
						task.spawn(playLocalSound, pageRecipeSound, 0.2)
						setupIngredients(frame.Name)
					end)
				end
			end
		end
	end

	local debounce = false;

	selectButton.MouseButton1Click:Connect(function()
		if debounce == false then
			debounce = true;
			if prevFoodName then
				if recipeSelected == nil or recipeSelected ~= prevFoodName then
					selectButton.BackgroundColor3 = selectedColors[1]
					selectButton.StrokeText.Color = selectedColors[2]
                    selectButton.StrokeBorder.Color = selectedColors[2]
					selectButton.Text = "Selected Recipe"
					recipeSelected = prevFoodName
				else
					selectButton.BackgroundColor3 = notSelectedColors[1]
					selectButton.StrokeText.Color = notSelectedColors[2]
                    selectButton.StrokeBorder.Color = notSelectedColors[2]
					selectButton.Text = "Select Recipe"
					recipeSelected = nil
					allIngredientsFound = false;
				end
				displayIngredients()
			end
			task.wait(1)
			debounce = false;
		end;
	end)
end

function RecipesView:GetRecipeIngredients(recipeName)
	recipeSelected = recipeName
	if prevIngredientButton ~= nil then
		prevIngredientButton.FoodTitle.SelectedStroke.Enabled = false;
	end
	for _,page in pairs(recipeList:GetChildren()) do
		if page:IsA("Frame") then
			for _, frame in pairs(page:GetChildren()) do
				if frame:IsA("Frame") then
					if frame.Name == recipeName then
						prevIngredientButton = frame;
						frame.FoodTitle.SelectedStroke.Enabled = true;
					end
				end
			end
		end
	end
	displayIngredients()
end

function RecipesView:ViewRecipe(recipeName)
	
end

function RecipesView:Cook(pan)
	if CookDebounce == false then
		CookDebounce = true
		local CookingService = Knit.GetService("CookingService")
		CookingService.Cook:Fire(recipeSelected, pan)
		task.wait(.5)
		CookButton.Visible = false;
		CookDebounce = false
	end
end

-- Private functions
local getRadius = function(part)
	return (part.Size.Z<part.Size.Y and part.Size.Z or part.Size.Y)/2
	--[[In the above we are returning the smallest, first we check if Z is smaller
	than Y, if so then we return Z or else we return Y.]]
end;

local function checkPans(panHitbox) -- checks if any object is on the pans
	local panArray = {};
	local radiusOfPanZone = getRadius(panHitbox)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
	overlapParams.FilterType = Enum.RaycastFilterType.Blacklist;

	local objectsInPanZone = workspace:GetPartBoundsInRadius(panHitbox.Position, radiusOfPanZone, overlapParams)
	for _, object in pairs(objectsInPanZone) do
		local touchedType, touchedOwner, touchedObject;

		local tObject = nil;
		if object then
			if object.Parent then
				if object.Parent:IsA("Model") then
					if object.Parent.PrimaryPart then
						tObject = object.Parent.PrimaryPart;
						touchedObject = tObject.Parent;
					end
				else
					tObject = object;
					touchedObject = object;
				end
			end
		end
		
		if tObject == nil then continue end;

		touchedType = tObject:GetAttribute("Type");
		touchedOwner = tObject:GetAttribute("Owner");

		if touchedObject and touchedType and touchedOwner then
			table.insert(panArray, object)
		end
	end

	return panArray;
end

function RecipesView:KnitStart()
    
    setupRecipes()

	local CookingService = Knit.GetService("CookingService");
	CookingService.UpdatePans:Connect(function(currentPans)
		currentPansInUse = currentPans
		for _, pan in pairs(CollectionService:GetTagged("Pan")) do
			if tablefind(currentPansInUse, pan) then
				print("xxxxxxxxxx")
				pan.ProximityPrompt.Enabled = true;
			end
		end
	end)

	local ProximityService = Knit.GetService("ProximityService")
	local PlayerController = Knit.GetController("PlayerController")

	ProximityService.TrackItem:Connect(function(tracking, itemObj)
		if tracking == true then
			local currentItem = nil;
			local Character = LocalPlayer.Character;
			if Character and Character.PrimaryPart then
				if recipeSelected then
					local ingredients = RecipeModule[recipeSelected]["Ingredients"];
					
					for _, ingredient in pairs(ingredients) do
						local originalVal = ingredient
						local foundBlendedIngredient, replaced = string.gsub(originalVal, "%[", "");
							foundBlendedIngredient = string.gsub(foundBlendedIngredient, "%]", "")
							foundBlendedIngredient = string.gsub(foundBlendedIngredient, "-", "")
							foundBlendedIngredient = string.gsub(foundBlendedIngredient, "Blended", "")
						
						if tostring(ingredient) == tostring(itemObj) then
							currentItem = getNearestPan(Character.PrimaryPart.Position);
						elseif tostring(foundBlendedIngredient) == tostring(itemObj) then
							currentItem = getNearestBlender(Character.PrimaryPart.Position)
						end
					end
					if RecipeModule[tostring(itemObj)] then
						currentItem = getNearestDelivery(Character.PrimaryPart.Position);
					end
					if not currentItem then
						currentItem = getNearestPan(Character.PrimaryPart.Position);
					end
				else
					if RecipeModule[tostring(itemObj)] then
						currentItem = getNearestDelivery(Character.PrimaryPart.Position);
					end
					if not currentItem then
						currentItem = getNearestPan(Character.PrimaryPart.Position);
					end
				end
			end
			if currentItem then
				PlayerController:TrackItem(currentItem);
			end
		else
			PlayerController:UnTrackItem();
		end
	end)

	local debounce = false;

	for _, pan in pairs(CollectionService:GetTagged("Pan")) do
		pan.ProximityPrompt.TriggerEnded:Connect(function(plr)
			if not tablefind(currentPansInUse, pan) then
				if debounce == false then
					debounce = true;
					local ProximityPrompts = PlayerGui:FindFirstChild("ProximityPrompts")
					if ProximityPrompts then
						local BigPrompt = ProximityPrompts:FindFirstChild("BigPrompt")
						if BigPrompt then
							BigPrompt.Frame.TitleFrame.TitleText.Text = "Grab"
						end
					end
					self:Cook(pan);
					pan.ProximityPrompt.Enabled = false;
					task.wait(0.5)
					pan.ProximityPrompt.Enabled = true;
					debounce = false;
				end
			else
				if debounce == false then
					debounce = true;
					local ProximityPrompts = PlayerGui:FindFirstChild("ProximityPrompts")
					if ProximityPrompts then
						local BigPrompt = ProximityPrompts:FindFirstChild("BigPrompt")
						if BigPrompt then
							BigPrompt.Frame.TitleFrame.TitleText.Text = ""
						end
					end
					self:Cook(pan);
					task.wait(0.5)
					debounce = false;
				end
			end
		end);
	end

    game:GetService("RunService").RenderStepped:Connect(function()
        for _, panHitbox in pairs (CollectionService:GetTagged("Pan")) do

			local specificPanArray = checkPans(panHitbox)

			if #specificPanArray > 0 then
				for _, touchedPart in ipairs(specificPanArray) do
					local tTouchedPart;
	
					if touchedPart.Parent:IsA("Model") and touchedPart.Parent.PrimaryPart then
						tTouchedPart = touchedPart.Parent.PrimaryPart;
					else
						tTouchedPart = touchedPart
					end
	
					local touchedType = tTouchedPart:GetAttribute("Type");
					local touchedOwner = tTouchedPart:GetAttribute("Owner");
	
					if touchedType and touchedType == "Food" and panZone:findPart(touchedPart) == true then
						panHitbox.ProximityPrompt.Enabled = true;
					else
						if allIngredientsFound == true or tablefind(currentPansInUse, panHitbox) then continue end;
						print("falsese")
						panHitbox.ProximityPrompt.Enabled = false;
					end;
				end
			else
				if allIngredientsFound == true or tablefind(currentPansInUse, panHitbox) then continue end;
				if panHitbox.ProximityPrompt.Enabled ~= false then
					print("falsese  22" ) 
					panHitbox.ProximityPrompt.Enabled = false;
				end
			end
        end
    end);
end


function RecipesView:KnitInit()
    
end


return RecipesView
