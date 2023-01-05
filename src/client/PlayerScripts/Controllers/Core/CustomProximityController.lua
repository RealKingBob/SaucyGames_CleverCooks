local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")
local ReplicatedModules = Knit.ReplicatedModules
local ReplicatedAssets = Knit.ReplicatedAssets
local ReplicatedBillboard = GameLibrary:FindFirstChild("BillboardUI")

local localPlayer = Players.LocalPlayer

local Status = {
	PickUp = "Pickup";
	Drop = "Drop";
	Cook = "Cook";
	Deliver = "Deliver";
	Click = "Click";
	IngredientsTable = "IngredientsTable";
}

local currentPansInUse = {};

local currentStatus = Status.PickUp;

local playerGui = localPlayer:WaitForChild("PlayerGui")
local customPrompt = ReplicatedBillboard:WaitForChild("Prompt")
local customHeadUI = ReplicatedBillboard:WaitForChild("HeadUI")

local customBigPrompt = ReplicatedBillboard:WaitForChild("BigPrompt")
local customCookHeadUI = ReplicatedBillboard:WaitForChild("CookHeadUI")
local customDeliverHeadUI = ReplicatedBillboard:WaitForChild("DeliverHeadUI")

local customTableHeadUI = ReplicatedBillboard:WaitForChild("TableHeadUI");

local KeyMapping = require(ReplicatedModules.KeyCodeImages);
local IngredientModule = require(ReplicatedAssets.Ingredients);
local RecipeModule = require(ReplicatedAssets.Recipes);

local CustomProximityController = Knit.CreateController { Name = "CustomProximityController" }

local function tablefind(tab,el) 
	for index, value in pairs(tab) do
		if value == el then
			return index;
		end
	end
	return nil;
end

local function getScreenGui()
	local screenGui = playerGui:FindFirstChild("ProximityPrompts")
	if screenGui == nil then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ProximityPrompts"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui
	end
	return screenGui
end;

function CustomProximityController:createPrompt(prompt, inputType, gui, customStatus)
	local promptUI;
    local headUI;
	if customStatus == Status.Cook then
		promptUI = customBigPrompt:Clone()
    	headUI = customCookHeadUI:Clone()
	elseif customStatus == Status.Deliver then
		promptUI = customPrompt:Clone()
		headUI = customDeliverHeadUI:Clone()	
	elseif customStatus == Status.IngredientsTable then
		promptUI = customPrompt:Clone()
    	headUI = customTableHeadUI:Clone()
	else
		promptUI = customPrompt:Clone()
    	headUI = customHeadUI:Clone()
	end
	

    -- UI that needs to be updated from prompt
    local promptFrame = promptUI:WaitForChild("Frame")
	local inputFrame = promptFrame:WaitForChild("InputFrame")
	local roundFrame = inputFrame:WaitForChild("RoundFrame")
	local titleFrame = promptFrame:WaitForChild("TitleFrame")
	local titleText = titleFrame:WaitForChild("TitleText")
	local buttonImage = inputFrame:WaitForChild("ButtonImage")
	local buttonText = inputFrame:WaitForChild("ButtonText")

    local headFrame, itemsFrame;
	local itemImage, itemImage2, itemImage3, itemImage4, itemImage5;
	if customStatus == Status.IngredientsTable then
		headFrame = headUI:WaitForChild("Frame");
		itemsFrame = headUI:WaitForChild("ItemsFrame");
		itemImage = itemsFrame:WaitForChild("ItemImage1");
		itemImage2 = itemsFrame:WaitForChild("ItemImage2");
		itemImage3 = itemsFrame:WaitForChild("ItemImage3");
		itemImage4 = itemsFrame:WaitForChild("ItemImage4");
		itemImage5 = itemsFrame:WaitForChild("ItemImage5");
	else
		headFrame = headUI:WaitForChild("Frame")
		itemImage = headFrame:WaitForChild("ItemImage");
	end

	if currentStatus == Status.Drop then
		promptUI.StudsOffsetWorldSpace = Vector3.new(0, 0, -1.5);
		headUI.StudsOffsetWorldSpace = Vector3.new(0, 0, -1.5);
	end

	local function getAmountOfItemImages()
		local itemImages = {itemImage, itemImage2, itemImage3, itemImage4, itemImage5};
		local itemCount = 0;

		for index, item in itemImages do
			if item.Image ~= "" then
				itemCount += 1;
			end
		end

		return itemCount;
	end

	-- Updates the cloned prompt to match the information in the ProximityPrompt in workspace
	local function updateUIFromPrompt()
		
		-- Set the input button to the correct input based on the user platform
		if inputType == Enum.ProximityPromptInputType.Gamepad then
			if KeyMapping.GamepadButtonImage[prompt.GamepadKeyCode] then
				buttonImage.Image = KeyMapping.GamepadButtonImage[prompt.GamepadKeyCode]
				buttonText.Text = ""
                buttonImage.Visible = true;
			end
		elseif inputType == Enum.ProximityPromptInputType.Touch then
			buttonImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
			buttonText.Text = ""
            buttonImage.Visible = true;
		else
			buttonImage.Image = "";
            buttonImage.Visible = false;
			local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)

			-- Set buttonTextImage to an image if the KeyboardKeyCode is not representable with a character
			-- Get image representation for Backspace, Return, Tab, Shift
			local buttonTextImage = KeyMapping.KeyboardButtonImage[prompt.KeyboardKeyCode]
			if buttonTextImage == nil then
				-- Get image representation for apostrophe, comma, graveaccent, period, spacebar
				buttonTextImage = KeyMapping.KeyboardButtonIconMapping[buttonTextString]
			end

			-- Set buttonTextString to a string if the KeyboardKeyCode doesn't have a direct character match
			-- Get string representation for Ctrl, Alt, and function keys
			if buttonTextImage == nil then
				local keyCodeMappedText = KeyMapping.KeyCodeToTextMapping[prompt.KeyboardKeyCode]
				if keyCodeMappedText then
					buttonTextString = keyCodeMappedText
				end
			end 

			-- Set the UI ButtonImage or the UI ButtonText
			if buttonTextImage then
				buttonImage.Image = buttonTextImage
			elseif buttonTextString ~= nil and buttonTextString ~= '' then
				buttonText.Text = buttonTextString
			else
				error("ProximityPrompt '" .. prompt.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(prompt.KeyboardKeyCode))
			end
		end

		local ingredients = {
			"i1",
			"i2",
			"i3",
			"i4",
			"i5"
		}
			
		local images = {
			itemImage,
			itemImage2,
			itemImage3,
			itemImage4,
			itemImage5
		}
			
		if CollectionService:HasTag(prompt.Parent, "IngredientsTable") then
			for i, ingredient in ipairs(ingredients) do
				local ingredientValue = prompt.Parent:GetAttribute(ingredient)
				if ingredientValue ~= "" then
					images[i].Visible = true
					images[i].Image = (IngredientModule[ingredientValue] ~= nil and IngredientModule[ingredientValue].BlendedImage ~= nil and IngredientModule[ingredientValue].BlendedImage) or "http://www.roblox.com/asset/?id=4509163032"
				else
					images[i].Visible = false
				end
			end
		else
			local object
			if prompt.Parent.Parent:IsA("Model") then
				object = prompt.Parent.Parent
			else
				object = prompt.Parent
			end
			
			if IngredientModule[object.Name] or RecipeModule[object.Name] then
				itemImage.Image = (IngredientModule[object.Name] ~= nil and IngredientModule[object.Name].Image) or RecipeModule[object.Name].Image
			else
				itemImage.Image = "http://www.roblox.com/asset/?id=4509163032"
			end
		end

	end
	updateUIFromPrompt()
	
	-- Tween Variables
	local tweensForFadeOut = {}
	local tweensForFadeIn = {}

	local tweensForClickOut = {}
	local tweensForClickIn = {}

	local tweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Prompt Frame Tweens
	table.insert(tweensForFadeOut, TweenService:Create(promptFrame, tweenInfoFast, { Size = UDim2.fromScale(0,0), BackgroundTransparency = 1, Visible = false }))
	table.insert(tweensForFadeIn, TweenService:Create(promptFrame, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, Visible = true }))

    -- Head Frame Tweens
	local iSizeX, iSizeY;

	if customStatus == Status.IngredientsTable then
		--print(getAmountOfItemImages(), (0.20 * getAmountOfItemImages()))
		iSizeX = (0.20 * getAmountOfItemImages()) + 0.05;
	else
		iSizeX = 1;
	end

	if customStatus == Status.Cook then
		table.insert(tweensForFadeOut, TweenService:Create(headFrame, tweenInfoFast, { Size = UDim2.fromScale(iSizeX, 0), Visible = false }))
		table.insert(tweensForFadeIn, TweenService:Create(headFrame, tweenInfoFast, { Size = UDim2.fromScale(iSizeX, 0.25), Visible = true }))
	else
		table.insert(tweensForFadeOut, TweenService:Create(headFrame, tweenInfoFast, { Size = UDim2.fromScale(iSizeX, 0), BackgroundTransparency = 1, Visible = false }))
		table.insert(tweensForFadeIn, TweenService:Create(headFrame, tweenInfoFast, { Size = UDim2.fromScale(iSizeX, 1), BackgroundTransparency = 0, Visible = true }))
	end

	if customStatus == Status.IngredientsTable then
		table.insert(tweensForFadeOut, TweenService:Create(itemsFrame, tweenInfoFast, { Size = UDim2.fromScale(1, 0), Visible = false }))
		table.insert(tweensForFadeIn, TweenService:Create(itemsFrame, tweenInfoFast, { Size = UDim2.fromScale(1, 1), Visible = true }))
	end

	-- Prompt Title Frame Tweens
	table.insert(tweensForFadeOut, TweenService:Create(titleText, tweenInfoFast, { Position = UDim2.fromScale(1,0) }))
	table.insert(tweensForFadeIn, TweenService:Create(titleText, tweenInfoFast, { Position = UDim2.fromScale(0, 0) }))

	table.insert(tweensForClickOut, TweenService:Create(roundFrame, tweenInfoFast, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }))
	table.insert(tweensForClickIn, TweenService:Create(roundFrame, tweenInfoFast, { BackgroundColor3 = Color3.fromRGB(179, 179, 179) }))

	if customStatus == Status.IngredientsTable then
		titleText.Text = "Pickup blended food";
	elseif customStatus == Status.Cook then
		if tablefind(currentPansInUse, prompt.Parent) then
			titleText.Text = "Grab";
		else
			titleText.Text = customStatus;
		end
	else
		titleText.Text = customStatus;
	end
	
	
	-- Make the prompt work on mobile / clickable
	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local button = Instance.new("TextButton")
		button.BackgroundTransparency = 1
		button.TextTransparency = 1
		button.Size = UDim2.fromScale(1, 1)
		button.Parent = promptUI

		local buttonDown = false

		button.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and
				input.UserInputState ~= Enum.UserInputState.Change then
				prompt:InputHoldBegin()
				buttonDown = true
			end
		end)
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if buttonDown then
					buttonDown = false
					prompt:InputHoldEnd()
				end
			end
		end)

		promptUI.Active = true
        headUI.Active = true
	end
	
	-- Variables for event connections
	local triggeredConnection
	local triggerEndedConnection

	-- Connect to events to play tweens when Triggered/Ended
	triggeredConnection = prompt.Triggered:Connect(function()
		roundFrame.BackgroundColor3 = Color3.fromRGB(179, 179, 179);
		--[[for _, tween in ipairs(tweensForClickOut) do
			tween:Play()
		end]]
	end)

	triggerEndedConnection = prompt.TriggerEnded:Connect(function()
		roundFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		--[[for _, tween in ipairs(tweensForClickIn) do
			tween:Play()
		end]]
	end)
	
	-- Make the Prompt actually show up on screen
	promptUI.Adornee = prompt.Parent
	promptUI.Parent = gui

	if currentStatus == Status.PickUp or currentStatus == Status.IngredientsTable then
		headUI.Adornee = prompt.Parent
		headUI.Parent = gui
	end

	for _, tween in ipairs(tweensForFadeIn) do
		tween:Play()
	end
	
	local function cleanupFunction()
		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()

		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end

		task.wait(0.2)

		promptUI.Parent = nil
        headUI.Parent = nil
	end

	return cleanupFunction
end

function CustomProximityController:KnitStart()
	--print("CUSTOM")

	local CookingService = Knit.GetService("CookingService");
	CookingService.UpdatePans:Connect(function(currentPans)
		currentPansInUse = currentPans
	end)

    ProximityPromptService.PromptShown:Connect(function(prompt, inputType)

        if prompt.Style == Enum.ProximityPromptStyle.Default then
            return
        end
		
        local gui = getScreenGui();

		local Character = game.Players:GetPlayerFromCharacter(prompt.Parent.Parent);

		if CollectionService:HasTag(prompt.Parent, "ButtonClick") then
			currentStatus = Status.Click;
			local cleanupFunction;

			if prompt.Parent:GetAttribute("Enabled") then
				if prompt.Parent:GetAttribute("Enabled") == true then
					cleanupFunction = self:createPrompt(prompt, inputType, gui, "Turn Off");
				else
					cleanupFunction = self:createPrompt(prompt, inputType, gui, "Turn On");
				end
			else
				cleanupFunction = self:createPrompt(prompt, inputType, gui, prompt.ActionText);
			end

			prompt.PromptHidden:Wait();
		
        	cleanupFunction();
		elseif CollectionService:HasTag(prompt.Parent, "Pan") then
			currentStatus = Status.Cook;
			local cleanupFunction = self:createPrompt(prompt, inputType, gui, "Cook");

			prompt.PromptHidden:Wait();
		
        	cleanupFunction();
		elseif CollectionService:HasTag(prompt.Parent, "Delivering") then
			currentStatus = Status.Deliver;
			local cleanupFunction = self:createPrompt(prompt, inputType, gui, "Deliver");

			prompt.PromptHidden:Wait();
		
			cleanupFunction();
		elseif CollectionService:HasTag(prompt.Parent, "IngredientsTable") then
			currentStatus = Status.IngredientsTable;
			local cleanupFunction = self:createPrompt(prompt, inputType, gui, "IngredientsTable");

			prompt.PromptHidden:Wait();
		
			cleanupFunction();
		elseif Character then
			currentStatus = Status.Drop;
			local cleanupFunction = self:createPrompt(prompt, inputType, gui, "Drop");

			prompt.PromptHidden:Wait();
		
        	cleanupFunction();
		else
			currentStatus = Status.PickUp;
			local cleanupFunction = self:createPrompt(prompt, inputType, gui, "Pickup");

			prompt.PromptHidden:Wait();
		
        	cleanupFunction();
		end
		--[[if prompt.Parent.Parent ~= nil then
			if game.Players:GetPlayerFromCharacter(prompt.Parent.Parent) then
				currentStatus = Status.Drop;
				cleanupFunction = self:createPrompt(prompt, inputType, gui, "Drop");
			elseif CollectionService:HasTag(prompt.Parent, "Pan") then
				currentStatus = Status.Cook;
				cleanupFunction = self:createPrompt(prompt, inputType, gui, "Cook");
			else
				currentStatus = Status.PickUp;
				cleanupFunction = self:createPrompt(prompt, inputType, gui, "Pickup");
			end
		else
			if CollectionService:HasTag(prompt.Parent, "Pan") then
				currentStatus = Status.Cook;
				cleanupFunction = self:createPrompt(prompt, inputType, gui, "Cook");
			else
				currentStatus = Status.PickUp;
				cleanupFunction = self:createPrompt(prompt, inputType, gui, "Pickup");
			end
		end]]
		
        
    end)
end


function CustomProximityController:KnitInit()
    
end


return CustomProximityController
