local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local SpectateUI = Knit.CreateController { Name = "SpectateUI" }

local LocalPlayer = Players.LocalPlayer

local cam = game.Workspace.CurrentCamera
local currentPlayer = LocalPlayer;

local debounce = false
local PlayerGui = LocalPlayer.PlayerGui

local Views = PlayerGui:WaitForChild("Views")
local GameplayFrame = PlayerGui:WaitForChild("GameplayFrame")

local SpectateView = Views:WaitForChild("Spectate")
local SpectateFrame = SpectateView:WaitForChild("SpectateFrame")

local title = SpectateFrame:WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("PlayerText")

local prevButton = SpectateView:WaitForChild("Previous"):WaitForChild("Main"):WaitForChild("Button")
local nextButton = SpectateView:WaitForChild("Next"):WaitForChild("Main"):WaitForChild("Button")

local SpecButton = GameplayFrame:WaitForChild("GameplayFrame"):WaitForChild("SpectateButton"):WaitForChild("Main"):WaitForChild("Button")

local connection;

function get(players)
	for i,v in pairs(players)do
		if v.Name == title.Text then
			return i
		end
	end
end

function GetPlayers()
    local players = {};
    for _, player : Player in pairs(CollectionService:GetTagged("Duck")) do
        table.insert(players, player)
    end

    for _, player : Player in pairs(CollectionService:GetTagged("Hunter")) do
        table.insert(players, player)
    end
    return players;
end

SpecButton.MouseButton1Click:Connect(function()
    if LocalPlayer then
		local ViewsUI = Knit.GetController("ViewsUI");
		ViewsUI:OpenView("Spectate");
		if CollectionService:HasTag(LocalPlayer, "Ghost") then return end
        if CollectionService:HasTag(LocalPlayer, "Duck") or CollectionService:HasTag(LocalPlayer, "Hunter") then
            pcall(function() 
				currentPlayer = LocalPlayer;
				cam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid 
			end)
            pcall(function()
                title.Text = game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent).Name
            end)
            return;
        end
    end
	if debounce == false then debounce = true
		pcall(function()
			title.Text = game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent).Name
		end)
	elseif debounce == true then debounce = false
		pcall(function() 
			currentPlayer = LocalPlayer;
			cam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid 
		end)
	end
end)

prevButton.MouseButton1Click:Connect(function()
	task.wait(.1)
    if LocalPlayer then
        if CollectionService:HasTag(LocalPlayer, "Duck") or CollectionService:HasTag(LocalPlayer, "Hunter") then
            return;
        end
    end
	local players = GetPlayers()
	local num = get(players)
	if not pcall(function() 
		currentPlayer = players[num-1];
		cam.CameraSubject = players[num-1].Character.Humanoid
	end) then
		if players[#players] then
			currentPlayer = players[#players];
			cam.CameraSubject = players[#players].Character.Humanoid
		end
	end
	pcall(function()
		title.Text = game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent).Name
	end)

	if connection then
		connection:Disconnect();
	end

	connection = currentPlayer.CharacterRemoving:Connect(function()
		print(currentPlayer.Name, "Died")
		
		currentPlayer.CharacterAdded:Wait()
		
		local s,e = pcall(function() 
			cam.CameraSubject = currentPlayer.Character:WaitForChild("Humanoid") 
		end)

		print(s,e)
	end)
end)

nextButton.MouseButton1Click:Connect(function()
	task.wait(.1)
    if LocalPlayer then
        if CollectionService:HasTag(LocalPlayer, "Duck") or CollectionService:HasTag(LocalPlayer, "Hunter") then
            return;
        end
    end
	local players = GetPlayers()
	local num = get(players)
	if not pcall(function() 
		currentPlayer = players[num+1]
		cam.CameraSubject = players[num+1].Character.Humanoid
	end) then
		if players[1] then
			currentPlayer = players[1]
			cam.CameraSubject = players[1].Character.Humanoid
		end
	end
	pcall(function()
		title.Text = game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent).Name
	end)

	if connection then
		connection:Disconnect();
	end

	connection = currentPlayer.CharacterRemoving:Connect(function()
		print(currentPlayer.Name, "Died")
		
		currentPlayer.CharacterAdded:Wait()
		
		local s,e = pcall(function() 
			cam.CameraSubject = currentPlayer.Character:WaitForChild("Humanoid") 
		end)

		print(s,e)
	end)
end)

function SpectateUI:KnitStart()
	
end

function SpectateUI:KnitInit()
    pcall(function()
        title.Text = game.Players:GetPlayerFromCharacter(cam.CameraSubject.Parent).Name
    end)
end

return SpectateUI