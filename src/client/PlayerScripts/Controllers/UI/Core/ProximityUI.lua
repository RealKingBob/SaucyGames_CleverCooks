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

local DropDownDebounce = false -- Prevents spam on the function

local dropConnection = nil;

local ProxFunctions = {}

--// FUNCTIONS \\--

function DropDown() -- Telling the server that you are dropping the item
	if DropDownDebounce == false then
		DropDownDebounce = true
        local CookingService = Knit.GetService("CookingService");
		CookingService.DropDown:Fire()
		task.wait(.5)
		DropDownDebounce = false
	end
end
ProxFunctions["DropDown"] = function(bool)
	--MainUI.DropButton.Visible = tab
	--print(bool)
	
	if bool == true then
		if dropConnection then
			dropConnection:Disconnect();
		end

		local HumRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")

		if not HumRoot then return end;

		local proxim = HumRoot:FindFirstChild("ProximityPrompt")

		if not proxim then return end;

		local Ingredient = localPlayer.Character:FindFirstChild("Ingredient")

		if not Ingredient then return end;

		if Ingredient.Value ~= nil then
			proxim.Enabled = true;

			dropConnection = proxim.TriggerEnded:Connect(function(plr)
				--print("drop down YUP")
				DropDown();
			end);
		end
	else
		if dropConnection then
			dropConnection:Disconnect();
		end

		local proxim = localPlayer.Character.HumanoidRootPart.ProximityPrompt

		proxim.Enabled = false;
	end
	
end

ProxFunctions["CookVisible"] = function(tab)

end

function EatVisible()
	
end

function ProximityUI:KnitStart()

    local CookingService = Knit.GetService("CookingService");

    CookingService.ProximitySignal:Connect(function(action, bool)
        --print(action, bool)

		pcall(ProxFunctions[action], bool)
	end)
end


function ProximityUI:KnitInit()
    
end


return ProximityUI
