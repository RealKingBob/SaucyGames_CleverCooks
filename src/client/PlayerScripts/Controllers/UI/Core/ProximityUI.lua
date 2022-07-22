local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ProximityUI = Knit.CreateController { Name = "ProximityUI" }

-- Description: This script controls all the buttons within this GUI to fire to RemoteEvents
-- Made by: Real_KingBob
--Sidenote: Got lazy to make it organized as u can tell afterwards 

--// VARIABLES \\--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")

local localPlayer = Players.LocalPlayer

local PlayerGui = localPlayer.PlayerGui
local MainUI = PlayerGui:WaitForChild("GUI")

local DropDownDebounce = false -- Prevents spam on the function

local ProxFunctions = {}

--// FUNCTIONS \\--

function DropDown() -- Telling the server that you are dropping the item
	if DropDownDebounce == false then
		DropDownDebounce = true
        local CookingService = Knit.GetService("CookingService");
		CookingService.DropDown:Fire()
		task.wait(.5)
		MainUI.DropButton.Visible = false
		DropDownDebounce = false
	end
end
ProxFunctions["DropDown"] = function(tab)
	MainUI.DropButton.Visible = tab
end

ProxFunctions["CookVisible"] = function(tab)
	MainUI.RecipeTitle.Visible = tab
	MainUI.Cook.Visible = tab
end

function EatVisible()
	MainUI.Cook.Visible = false
	MainUI.Eat.Visible = true
end

function ProximityUI:KnitStart()

	print("proximity core ")

    local CookingService = Knit.GetService("CookingService");

    CookingService.ProximitySignal:Connect(function(action, bool)
        print(action, bool)

		pcall(ProxFunctions[action], bool)
	end)

    MainUI.DropButton.MouseButton1Click:Connect(DropDown)
    
end


function ProximityUI:KnitInit()
    
end


return ProximityUI
