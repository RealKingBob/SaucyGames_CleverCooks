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
	Click = "Click";
}

local currentStatus = Status.PickUp;

local playerGui = localPlayer:WaitForChild("PlayerGui")
local customPrompt = ReplicatedBillboard:WaitForChild("Prompt")
local customHeadUI = ReplicatedBillboard:WaitForChild("HeadUI")

local customBigPrompt = ReplicatedBillboard:WaitForChild("BigPrompt")
local customCookHeadUI = ReplicatedBillboard:WaitForChild("CookHeadUI")

local KeyMapping = require(ReplicatedModules.KeyCodeImages);
local IngredientModule = require(ReplicatedAssets.Ingredients);
local RecipeModule = require(ReplicatedAssets.Recipes);

local CustomProximityController = Knit.CreateController { Name = "CustomProximityController" }

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
	else
		promptUI = customPrompt:Clone()
    	headUI = customHeadUI:Clone()
	end
	

    -- UI that needs to be updated from prompt
    local promptFrame = promptUI:WaitForChild("Frame")
	local inputFrame = promptFrame:WaitForChild("InputFrame")
	local titleFrame = promptFrame:WaitForChild("TitleFrame")
	local titleText = titleFrame:WaitForChild("TitleText")
	local buttonImage = inputFrame:WaitForChild("ButtonImage")
	local buttonText = inputFrame:WaitForChild("ButtonText")

    local headFrame = headUI:WaitForChild("Frame")
	local itemImage = headFrame:WaitForChild("ItemImage")

	if currentStatus == Status.Drop then
		promptUI.StudsOffsetWorldSpace = Vector3.new(0, 0, -1.5);
		headUI.StudsOffsetWorldSpace = Vector3.new(0, 0, -1.5);
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

		if prompt.Parent.Parent:IsA("Model") then
			if IngredientModule[prompt.Parent.Parent.Name] then
				itemImage.Image = IngredientModule[prompt.Parent.Parent.Name].Image
			else
				itemImage.Image = "http://www.roblox.com/asset/?id=4509163032" --???
			end;
		else
			if IngredientModule[prompt.Parent.Name] then
				itemImage.Image = IngredientModule[prompt.Parent.Name].Image
			else
				itemImage.Image = "http://www.roblox.com/asset/?id=4509163032" --???
			end;
		end

		--print(prompt.Parent:GetAttribute("Type"))
		if prompt.Parent:GetAttribute("Type") == "Food" then
			if prompt.Parent.Parent:IsA("Model") then
				if RecipeModule[prompt.Parent.Parent.Name] then
					itemImage.Image = RecipeModule[prompt.Parent.Parent.Name].Image
				else
					itemImage.Image = "http://www.roblox.com/asset/?id=4509163032" --???
				end;
			else
				if RecipeModule[prompt.Parent.Name] then
					itemImage.Image = RecipeModule[prompt.Parent.Name].Image
				else
					itemImage.Image = "http://www.roblox.com/asset/?id=4509163032" --???
				end;
			end
		elseif prompt.Parent:GetAttribute("Type") == "Ingredient" then
			if prompt.Parent.Parent:IsA("Model") then
				if IngredientModule[prompt.Parent.Parent.Name] then
					itemImage.Image = IngredientModule[prompt.Parent.Parent.Name].Image
				else
					itemImage.Image = "http://www.roblox.com/asset/?id=4509163032" --???
				end;
			else
				if IngredientModule[prompt.Parent.Name] then
					itemImage.Image = IngredientModule[prompt.Parent.Name].Image
				else
					itemImage.Image = "http://www.roblox.com/asset/?id=4509163032" --???
				end;
			end
		end
	end
	updateUIFromPrompt()
	
	-- Tween Variables
	local tweensForFadeOut = {}
	local tweensForFadeIn = {}
	local tweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Prompt Frame Tweens
	table.insert(tweensForFadeOut, TweenService:Create(promptFrame, tweenInfoFast, { Size = UDim2.fromScale(0,0), BackgroundTransparency = 1, Visible = false }))
	table.insert(tweensForFadeIn, TweenService:Create(promptFrame, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, Visible = true }))

    -- Head Frame Tweens
	table.insert(tweensForFadeOut, TweenService:Create(headFrame, tweenInfoFast, { Size = UDim2.fromScale(1,0), BackgroundTransparency = 1, Visible = false }))
	table.insert(tweensForFadeIn, TweenService:Create(headFrame, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, Visible = true }))

	-- Prompt Title Frame Tweens
	table.insert(tweensForFadeOut, TweenService:Create(titleText, tweenInfoFast, { Position = UDim2.fromScale(1,0) }))
	table.insert(tweensForFadeIn, TweenService:Create(titleText, tweenInfoFast, { Position = UDim2.fromScale(0, 0) }))

	titleText.Text = customStatus;
	
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
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
	end)       

	triggerEndedConnection = prompt.TriggerEnded:Connect(function()
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Play()
		end
	end)
	
	-- Make the Prompt actually show up on screen
	promptUI.Adornee = prompt.Parent
	promptUI.Parent = gui

	if currentStatus == Status.PickUp then
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
