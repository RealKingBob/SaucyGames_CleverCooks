local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local GameUI = Knit.CreateController { Name = "GameUI" }

local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local CollectionService = game:GetService('CollectionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LibraryAudios = ReplicatedStorage:WaitForChild("Audios")

local LocalPlayer = Players.LocalPlayer
local PlayerGUI = LocalPlayer.PlayerGui

local MapInfo;

function GameUI:Countdown()
	print("Countdown Began")
	local Countdown = PlayerGUI.MainGUI:WaitForChild("Countdown")
	local Begin = Countdown:WaitForChild("BEGIN")
	local CircleRound = PlayerGUI.MainGUI:WaitForChild("CircleRound")
    local TickSound = LibraryAudios.Effects:WaitForChild("Tick")
	local OneSound, TwoSound, ThreeSound = LibraryAudios.Effects:WaitForChild("One"), LibraryAudios.Effects:WaitForChild("Two"), LibraryAudios.Effects:WaitForChild("Three")
	local RunSound = LibraryAudios.Effects:WaitForChild("Run")
	local CutsceneService = Knit.GetService("CutsceneService")
	Countdown.Visible = true

	for i = 3, 1, -1 do
		if Countdown:FindFirstChild(tostring(i)) then
			local RealFrame = Countdown:FindFirstChild(tostring(i))
			RealFrame.Title.Text = ""
			local ClonedNum = RealFrame:Clone()
			if ClonedNum:FindFirstChild("Title") then
				ClonedNum.Title:Destroy()
			end
			RealFrame.ImageLabel.Size = UDim2.new(0, 0, 0, 0)
			RealFrame.Visible = true
			
			if i == 3 then
				ThreeSound:Play()
			elseif i == 2 then
				TwoSound:Play()
			else
				OneSound:Play()
			end
			
			TweenService:Create(RealFrame.ImageLabel,TweenInfo.new(.05),{
				Size = UDim2.new(ClonedNum.ImageLabel.Size.X.Scale, 0, ClonedNum.ImageLabel.Size.Y.Scale, 0),
			}):Play()
			task.wait(.05)
			ClonedNum.Parent = Countdown
			ClonedNum.Visible = true
			TickSound:Play()
			local ImageLabel = ClonedNum.ImageLabel
			TweenService:Create(ImageLabel,TweenInfo.new(.5),{
				Position = UDim2.new(ImageLabel.Position.X.Scale , 0, ImageLabel.Position.Y.Scale, 0),
				Size = UDim2.new(ImageLabel.Size.X.Scale + 0.2, 0, ImageLabel.Size.Y.Scale + 0.2, 0),
				ImageTransparency = 1
			}):Play()
			task.wait(1)
			ClonedNum:Destroy()
			Countdown:FindFirstChild(tostring(i)).Visible = false
		end
	end

	Begin.Visible = true
	local ClonedNum = Begin:Clone()
	ClonedNum.Parent = Countdown
	if ClonedNum:FindFirstChild("Title") then
		ClonedNum.Title:Destroy()
	end

	Begin.ImageLabel.Size = UDim2.new(0, 0, 0, 0)
	Begin.Visible = true
	local ogX, ogY = ClonedNum.ImageLabel.Size.X.Scale, ClonedNum.ImageLabel.Size.Y.Scale
	RunSound:Play()
	TweenService:Create(Begin.ImageLabel,TweenInfo.new(.05),{
		Size = UDim2.new(ClonedNum.ImageLabel.Size.X.Scale + 0.5, 0, ClonedNum.ImageLabel.Size.Y.Scale + 0.5, 0), --  + 0.5
	}):Play()
	task.wait(.05)
	
	TickSound.PlaybackSpeed = 4
	TickSound:Play()
	local ImageLabel = ClonedNum.ImageLabel
	TweenService:Create(ImageLabel,TweenInfo.new(0.5),{
		Position = UDim2.new(ImageLabel.Position.X.Scale, 0, ImageLabel.Position.Y.Scale, 0),
		Size = UDim2.new(Begin.ImageLabel.Size.X.Scale + 0.3, 0, Begin.ImageLabel.Size.Y.Scale + 0.3, 0),
		ImageTransparency = 1
	}):Play()
	task.wait(0.5)
	local ClonedBegin = Begin:Clone()
	ClonedBegin.Visible = true
	ClonedBegin.Parent = Countdown
	Begin.Visible = false
	TweenService:Create(ClonedBegin.ImageLabel,TweenInfo.new(.3),{
		Size = UDim2.new(ClonedBegin.ImageLabel.Size.X.Scale + 0.2, 0, ClonedBegin.ImageLabel.Size.Y.Scale + 0.2, 0),
	}):Play()
    CutsceneService.CutsceneIntroSignal:Fire();
	task.wait(0.3)
	TweenService:Create(ClonedBegin.ImageLabel,TweenInfo.new(.3),{
		Size = UDim2.new(0, 0, 0, 0),
	}):Play()
	Knit.GetController("DashUI"):Visible(true);
	task.wait(1.2)
	ClonedBegin:Destroy()
	ClonedNum:Destroy()
	Begin.ImageLabel.Size = UDim2.new(ogX, 0, ogY, 0)
	TickSound.PlaybackSpeed = 1
	Countdown.Visible = false
	CircleRound.Visible = false;
	CircleRound.Size = UDim2.new(6, 0, 6, 0);
end

function GameUI:LoadingScreen(Name, GameMode)
	local LoadingScreen = PlayerGUI.MainGUI:WaitForChild("LoadingScreen")
	local Blackout = PlayerGUI.MainGUI:WaitForChild("Blackout")
	local CircleRound = PlayerGUI.MainGUI:WaitForChild("CircleRound")
	local LoadingFrame = LoadingScreen:WaitForChild("LoadingFrame")
	local MapDescription = LoadingScreen:WaitForChild("MapDescription")

	local CharacterText = MapDescription:WaitForChild("Main"):WaitForChild("CharacterText")
	local HunterDesc = MapDescription:WaitForChild("Main"):WaitForChild("HunterDesc")
	local DuckDesc = MapDescription:WaitForChild("Main"):WaitForChild("DuckDesc")
	local TitleText = MapDescription:WaitForChild("Main"):WaitForChild("Title")
	local GameModeText = MapDescription:WaitForChild("Main"):WaitForChild("GameModeText")
	local RaceDesc = MapDescription:WaitForChild("Main"):WaitForChild("RaceDesc")

	Knit.GetController("ResultsUI"):CloseView();

	local BackgroundImage = LoadingScreen:WaitForChild("BackgroundImage") 

	local mapInfo = MapInfo.Maps[Name]

	TitleText.TextColor3 = mapInfo.TitleColor
	TitleText.UIStroke.Color = mapInfo.StrokeColor
	BackgroundImage.Image = mapInfo.DecalId

	TitleText.Text = mapInfo.Name
	GameModeText.Text = tostring(GameMode)

	if GameMode == "HOT POTATO" then
		GameModeText.TextColor3 = Color3.fromRGB(221, 30, 30)
		CharacterText.TextColor3 = Color3.fromRGB(0, 170, 255)
		CharacterText.Text = "YOU ARE A DUCK"
		HunterDesc.Visible = false
		DuckDesc.Visible = false
		RaceDesc.Visible = true
		RaceDesc.Text = "- Don't get the potato!\n- Last player alive wins!"
	elseif GameMode == "DUCK OF THE HILL" then
		GameModeText.TextColor3 = Color3.fromRGB(255, 204, 0)
		CharacterText.TextColor3 = Color3.fromRGB(0, 170, 255)
		CharacterText.Text = "YOU ARE A DUCK"
		HunterDesc.Visible = false
		DuckDesc.Visible = false
		RaceDesc.Visible = true
		RaceDesc.Text = "- No hunters!\n- Stay in the marked zone and push others out with a baguette!"
	elseif GameMode == "DOMINATION" then
		GameModeText.TextColor3 = Color3.fromRGB(5, 138, 247)
		CharacterText.TextColor3 = Color3.fromRGB(0, 170, 255)
		CharacterText.Text = "YOU ARE A DUCK"
		HunterDesc.Visible = false
		DuckDesc.Visible = false
		RaceDesc.Visible = true
		RaceDesc.Text = "- Stay in the hill circle to get points!\n- Team with most points win!"
	elseif GameMode == "RACE MODE" then
		GameModeText.TextColor3 = Color3.fromRGB(5, 138, 247)
		CharacterText.TextColor3 = Color3.fromRGB(0, 170, 255)
		CharacterText.Text = "YOU ARE A DUCK"
		HunterDesc.Visible = false
		DuckDesc.Visible = false
		RaceDesc.Visible = true
		RaceDesc.Text = "- Traps are automatic\n- Reach the end within the time limit first to win!"
	elseif CollectionService:HasTag(LocalPlayer, "Hunter") then
		if GameMode == "INFECTION MODE" then
			GameModeText.TextColor3 = Color3.fromRGB(5, 219, 5)
			DuckDesc.Text = "- Kill ducks to infect them!\n- Traps are disabled!\n- Kill all ducks to win!"
		else
			GameModeText.TextColor3 = Color3.fromRGB(253, 255, 253)
			DuckDesc.Text = "- Prevent ducks from reaching the end\n- Shoot the targets to activate traps\n- Activate the traps to kill ducks!"
		end
		CharacterText.TextColor3 = Color3.fromRGB(255, 80, 80)
		CharacterText.Text = "YOU ARE A HUNTER"
		RaceDesc.Visible = false
		HunterDesc.Visible = true
		DuckDesc.Visible = false
	else
		if GameMode == "INFECTION MODE" then
			GameModeText.TextColor3 = Color3.fromRGB(5, 219, 5)
			DuckDesc.Text = "- Avoid dying or you'll become a hunter\n- Traps are disabled!\n- Reach the end or get the farthest when time runs out to wins"
		else
			GameModeText.TextColor3 = Color3.fromRGB(253, 255, 253)
			DuckDesc.Text = "- Reach the end to win!\n- Avoid the hunter traps"
		end
		CharacterText.TextColor3 = Color3.fromRGB(0, 170, 255)
		CharacterText.Text = "YOU ARE A DUCK"
		RaceDesc.Visible = false
		HunterDesc.Visible = false
		DuckDesc.Visible = true
	end

	game:GetService("TweenService"):Create(Blackout,TweenInfo.new(.25),{BackgroundTransparency = 0}):Play()
	task.wait(1)
	BackgroundImage.Size = UDim2.new(1,0,1,0);
	LoadingScreen.Visible = true

	game:GetService("TweenService"):Create(Blackout,TweenInfo.new(.3),{BackgroundTransparency = 1}):Play()
	task.wait(.03)
	CircleRound.Visible = false;
	CircleRound.Size = UDim2.new(6, 0, 6, 0);
	Blackout.BackgroundTransparency = 1
	TweenService:Create(BackgroundImage,TweenInfo.new(7,Enum.EasingStyle.Linear),{Size = UDim2.new(1.2,0,1.2,0)}):Play()
	local loadingTween = game:GetService("TweenService"):Create(LoadingFrame.LoadingIcon,TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,-1),{Rotation = 360})
	loadingTween:Play()
	task.wait(7.4)
	task.spawn(function()
		task.wait(1)
		loadingTween:Cancel()
		LoadingScreen.Visible = false
		BackgroundImage.Size = UDim2.new(1,0,1,0);
	end)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true);
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false);
	self:EventDescription(Name, GameMode)
end

function GameUI:EventDescription(Name, GameMode)
	--exactly 10 seconds
	local Event = PlayerGUI.MainGUI:WaitForChild("Event")
	local Blackout = PlayerGUI.MainGUI:WaitForChild("Blackout")
	local TextDescription = Event:WaitForChild("Description")
	local TextTitle = Event:WaitForChild("Title")
	local CircleRound = PlayerGUI.MainGUI:WaitForChild("CircleRound")
	local HoverSound = LibraryAudios.Effects:WaitForChild("Hover")
	local mapInfo = MapInfo.Maps[Name]

	TextTitle.TextColor3 = mapInfo.TitleColor
	TextTitle.UIStroke.Color = mapInfo.StrokeColor

	TextTitle.Text = mapInfo.Name
	TextDescription.Text = tostring(GameMode)
--print(GameMode, tostring(GameMode) == "HOT POTATO")
	if tostring(GameMode) == "CLASSIC MODE" then
		TextDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
	elseif tostring(GameMode) == "RACE MODE" then
		TextDescription.TextColor3 = Color3.fromRGB(5, 138, 247)
	elseif tostring(GameMode) == "DOMINATION" then
		TextDescription.TextColor3 = Color3.fromRGB(5, 138, 247)
	elseif tostring(GameMode) == "INFECTION MODE" then
		TextDescription.TextColor3 = Color3.fromRGB(5, 219, 5)
	elseif tostring(GameMode) == "HOT POTATO" then
		TextDescription.TextColor3 = Color3.fromRGB(221, 30, 30)
	elseif tostring(GameMode) == "DUCK OF THE HILL" then
		TextDescription.TextColor3 = Color3.fromRGB(255, 204, 0)
	end
	TextTitle.Position = UDim2.fromScale(0,-0.5)
	TextDescription.Position = UDim2.fromScale(0,1)
	Event.Size = UDim2.fromScale(1,0)
	game:GetService("TweenService"):Create(Blackout,TweenInfo.new(.25),{BackgroundTransparency = 0}):Play()
	task.wait(1)
	Event.Visible = true
	game:GetService("TweenService"):Create(Blackout,TweenInfo.new(.25),{BackgroundTransparency = 1}):Play()
	task.wait(.2)
	Blackout.BackgroundTransparency = 1
	CircleRound.Visible = false;
	CircleRound.Size = UDim2.new(6, 0, 6, 0);
	TweenService:Create(Event,TweenInfo.new(.3, Enum.EasingStyle.Linear),{Size = UDim2.new(1, 0,0.223, 0)}):Play()
	task.spawn(function()
		task.wait(0.7)
		HoverSound:Play()
	end)
	task.wait(1)
	
	TweenService:Create(TextDescription,TweenInfo.new(1, Enum.EasingStyle.Elastic),{Position = UDim2.new(0, 0,0.58, 0)}):Play()
	TweenService:Create(TextTitle,TweenInfo.new(1, Enum.EasingStyle.Elastic),{Position = UDim2.new(0, 0,0.15, 0)}):Play()
	
	task.spawn(function()
		task.wait(9.7)
		HoverSound:Play()
	end)
	task.wait(10)
	TweenService:Create(TextTitle,TweenInfo.new(1, Enum.EasingStyle.Elastic),{Position = UDim2.new(0, 0,-0.5, 0)}):Play()
	TweenService:Create(TextDescription,TweenInfo.new(1, Enum.EasingStyle.Elastic),{Position = UDim2.new(0, 0,1, 0)}):Play()
	
	task.wait(0.5)
	TweenService:Create(Event,TweenInfo.new(.3, Enum.EasingStyle.Linear),{Size = UDim2.new(1, 0,0, 0)}):Play()
	task.wait(1)
	game:GetService("TweenService"):Create(Blackout,TweenInfo.new(.25),{BackgroundTransparency = 0}):Play()
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true);
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true);
	task.wait(0.25)
	Blackout.BackgroundTransparency = 1
	Event.Visible = false
end

function GameUI:SetCharSelect(Name, Description)
	local GameplayFrame = PlayerGUI.GameplayFrame:WaitForChild("GameDesc")
	--local CharSelect = GameplayFrame:WaitForChild("CharSelect")
	--local Title = CharSelect:WaitForChild("Title")
	local Desc = GameplayFrame:WaitForChild("TextLabel")

	--Title.Text = Name
	Desc.Text = Description

	--[[
		YOU ARE A DUCK!
		REACH TO THE MIDDLE OF THE TOWER AND PRESS THE RED BUTTON!

		YOU ARE A HUNTER!
		PREVENT THE DUCKS FROM REACHING THE MIDDLE OF THE TOWER!
	]]
end

function GameUI:KnitStart()
    local assets = {
        "rbxassetid://8401434180", -- these are map images
        "rbxassetid://8637332948",
        "rbxassetid://8599834597",
        "rbxassetid://8401434317",
        "rbxassetid://8400801443",
        "rbxassetid://8400521703",

        "rbxassetid://8321764473", -- unboxing crates images
		"rbxassetid://8322575070",
		"rbxassetid://8322574923",
		"rbxassetid://8322574790",
		"rbxassetid://8322574630",
    }
    
    -- Preload the content and time it
    local ContentProviderUtils = require(script.Parent.Parent.Parent.Parent.Modules.ContentProviderUtils)
    local startTime = os.clock()
    ContentProviderUtils.promisePreload(assets)
    local deltaTime = os.clock() - startTime
	MapInfo = require(Knit.ReplicatedAssets.SystemInfo);
    --print(("Preloading complete, took %.2f seconds"):format(deltaTime))
end


function GameUI:KnitInit()
    
end


return GameUI