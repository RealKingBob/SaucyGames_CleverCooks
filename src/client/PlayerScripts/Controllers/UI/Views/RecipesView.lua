local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local RecipesView = Knit.CreateController { Name = "RecipesView" }

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary")
local Shared = ReplicatedStorage:WaitForChild("Common")

local ReplicatedAssets = Shared:WaitForChild("Assets")
local ReplicatedModules = Shared:WaitForChild("Modules")
local ReplicatedGuiFrames = GameLibrary:WaitForChild("GuiFrames")

local FoodTemplate = ReplicatedGuiFrames:WaitForChild("FoodTemplate")
local IngredientTemplate = ReplicatedGuiFrames:WaitForChild("IngredientTemplate")
local PageTemplate = ReplicatedGuiFrames:WaitForChild("PageTemplate")
local HoverIngredientTemplate = ReplicatedGuiFrames:WaitForChild("HoverIngredientTemplate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local mainGui = PlayerGui:WaitForChild("GUI")
local viewsUI = PlayerGui:WaitForChild("Views")

local RecipesGui = viewsUI:WaitForChild("Recipes")

local mainScreen = PlayerGui:WaitForChild("GUI"):WaitForChild("MainScreen")
local IngredientsTab = mainScreen:WaitForChild("IngredientsTab")
local foodNameDisplayed = mainScreen:FindFirstChild("FoodName")


local recipeSection = RecipesGui:WaitForChild("RecipeFrame")
local recipeList = recipeSection:WaitForChild("RecipeList")
local recipeTitle = recipeSection:WaitForChild("RecipeTitle")
local ingredientList = recipeSection:WaitForChild("IngredientsList"):WaitForChild("ScrollingFrame")
local selectedRecipeFrame = recipeSection:WaitForChild("SelectedRecipe")
local selectedIconImage = selectedRecipeFrame:WaitForChild("Icon"):WaitForChild("IconImage")

local selectButton = recipeSection:WaitForChild("SelectButton")

local notSelectedColors = {Color3.fromRGB(199, 77, 47), Color3.fromRGB(129, 48, 30)}; -- button, button.parent or button, shadow
local selectedColors = {Color3.fromRGB(255, 170, 0), Color3.fromRGB(125, 83, 0)};
local completedColors = {Color3.fromRGB(0, 184, 0),Color3.fromRGB(0, 80, 0)};
local notCompletedColors = {Color3.fromRGB(223, 190, 149),Color3.fromRGB(124, 94, 69)};

local recipeSelected = nil;
local allIngredientsFound = false;

local RecipeModule = require(ReplicatedAssets.Recipes)
local IngredientModule = require(ReplicatedAssets.Ingredients)

local myReplicatedIngredients = {}
local ShortDistanceObject
local CookDebounce = false;
local CookButton = mainGui.Cook

-- setup

function recipePageCreated(PageNumber,PageData)
	local PageLimit = 6 -- 6 buttons per page
	local recipeCount = 0
	local Page = PageTemplate:Clone()
	Page.Name = tostring(PageNumber)
	Page.Parent = recipeList

	if PageData then
		for key, value in next, PageData do
			if key and value then
				if type(value) == "table" then
					recipeCount += 1
					if recipeCount < PageLimit then
						local ClonedFoodTemplate = FoodTemplate:Clone()
						ClonedFoodTemplate.Name = tostring(key)
						ClonedFoodTemplate.FoodTitle.Text = tostring(key)
						if value["Image"] == "" or value["Image"] == nil then
							ClonedFoodTemplate.ImageFrame.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
						else
							ClonedFoodTemplate.ImageFrame.Icon.IconImage.Image = value.Image
						end
						ClonedFoodTemplate.Parent = Page
						PageData[key] = nil
					else
						local ClonedFoodTemplate = FoodTemplate:Clone()
						ClonedFoodTemplate.Name = tostring(key)
						ClonedFoodTemplate.FoodTitle.Text = tostring(key)
						if value["Image"] == "" or value["Image"] == nil then
							ClonedFoodTemplate.ImageFrame.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
						else
							ClonedFoodTemplate.ImageFrame.Icon.IconImage.Image = value.Image
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
	end
end

function setupRecipes()
    print("setupRecipes")
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
		local TotalPages = 0
		for _,page in pairs(recipeList:GetChildren()) do
			if page:IsA("Frame") then
				TotalPages += 1
			end
		end
		Pages.Text = "Page "..tostring(PageOrganizer.CurrentPage).."/"..tostring(TotalPages)
	end)

    LeftButton.MouseButton1Click:Connect(function()
		PageOrganizer:Previous()
		local TotalPages = 0
		for _,page in pairs(recipeList:GetChildren()) do
			if page:IsA("Frame") then
				TotalPages += 1
			end
		end
		Pages.Text = "Page "..tostring(PageOrganizer.CurrentPage).."/"..tostring(TotalPages)
	end)
	setupRecipeButtons()
end


function setupRecipeButtons()
	local prevFoodName = nil
	local prevIngredientTab = nil;
	local prevConnection = nil;

    local function displayIngredients()
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
			return
		end

		foodNameDisplayed.Text = recipeSelected

		local greenIngredients = {};
		allIngredientsFound = false;
		CookButton.Visible = false;

		for _,ingredient in pairs(RecipeModule[recipeSelected]["Ingredients"]) do
			local foundIngredient = IngredientModule[ingredient]
			local clonedIngredientFrame = HoverIngredientTemplate:Clone()
			clonedIngredientFrame.Size = UDim2.fromScale(0,0)
			clonedIngredientFrame.Name = tostring(ingredient)
			if foundIngredient then
				clonedIngredientFrame.Icon.IconImage.Image = foundIngredient["Image"]
				clonedIngredientFrame.Icon.IconImageShadow.Image = foundIngredient["Image"]
			else
				clonedIngredientFrame.Icon.IconImage.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
				clonedIngredientFrame.Icon.IconImageShadow.Image = "http://www.roblox.com/asset/?id=4509163032" -- ???
			end
			
			if myReplicatedIngredients then
				if #myReplicatedIngredients == 0 then
					clonedIngredientFrame.BackgroundColor3 = notCompletedColors[2]
					clonedIngredientFrame.Icon.BackgroundColor3 = notCompletedColors[1]
				else
					for _,v in pairs(myReplicatedIngredients) do
						if clonedIngredientFrame.Name == tostring(v) then
							clonedIngredientFrame.BackgroundColor3 = completedColors[2]
							clonedIngredientFrame.Icon.BackgroundColor3 = completedColors[1]
							break;
						else
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
		print('checkIfAllGreen', checkIfAllGreen)
		if checkIfAllGreen == true then
			allIngredientsFound = true;
		end

		local CookingService = Knit.GetService("CookingService")
		
		prevConnection = CookingService.SendIngredients:Connect(function(args)
			greenIngredients = {};
			print(args)
			if args then
				myReplicatedIngredients = args
				if #myReplicatedIngredients == 0 then
					for _, frame in pairs(IngredientsTab:GetChildren()) do
						if frame:IsA("Frame") then
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
									frame.BackgroundColor3 = completedColors[2]
									frame.Icon.BackgroundColor3 = completedColors[1]
									break;
								else
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
				print('checkIfAllGreen', checkIfAllGreen)
				if checkIfAllGreen == true then
					allIngredientsFound = true;
				end
			end
		end)
	end

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
				local foundIngredient = IngredientModule[value]
				local clonedIngredientFrame = IngredientTemplate:Clone()
				clonedIngredientFrame.Name = tostring(value)
				clonedIngredientFrame.IngredientTitle.Text = tostring(value)
				if foundIngredient then
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


function RecipesView:KnitStart()
    
    setupRecipes()

    CookButton.MouseButton1Click:Connect(function()
        if CookDebounce == false then
            CookDebounce = true
            if recipeSelected then
                --CookEvent:FireServer(recipename)
                print(recipeSelected)
                local CookingService = Knit.GetService("CookingService")
                CookingService.Cook:Fire(LocalPlayer, recipeSelected)
            end	
            task.wait(.5)
            CookButton.Visible = false;
            CookDebounce = false
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        for _, Pan in pairs (workspace:WaitForChild("Pans"):WaitForChild("PanHitboxes"):GetChildren()) do
            if not Pan:IsA("Folder") then
                local Mag = (Pan.Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude
                if Mag <= 11 then
                    ShortDistanceObject = Pan
                    local IngredientValue = LocalPlayer:FindFirstChild("Data").GameValues.Ingredient
                    if IngredientValue.Value == nil and CookButton.Visible == false and recipeSelected ~= nil and allIngredientsFound == true then
                        CookButton.Visible = true
                        --break
                    end
                else
                    if ShortDistanceObject then
                        local IngredientValue = LocalPlayer:FindFirstChild("Data").GameValues.Ingredient
                        local OldMag = (ShortDistanceObject.Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude
                        --print("OldMag",OldMag)
                        if OldMag > 11 then -- and CookGUI.Visible == true or IngredientValue.Value ~= nil and CookGUI.Visible == true
                            CookButton.Visible = false
                            --break
                        end
                    end
                end
            end
        end
    end);
end


function RecipesView:KnitInit()
    
end


return RecipesView
