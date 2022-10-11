local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local FoodAvailable = workspace:WaitForChild("FoodAvailable");
local IngredientAvailable = workspace:WaitForChild("IngredientAvailable");

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary");

local GameController = Knit.CreateController { Name = "GameController" }

local LocalPlayer = Players.LocalPlayer
local CollectedItems = {};
local Cooldown = false;

function TableFind(tab,el) -- table,value
	for index, value in pairs(tab) do
		if value == el then
			return index;
		end;
	end;
end;

--[[function GameController:createProximityPrompt(object, type)
	if object:IsA("Model") 
	and (not object.PrimaryPart:FindFirstChild("ProximityPrompt") or not object.PrimaryPart:FindFirstChildWhichIsA("ProximityPrompt")) then
		local prox = Instance.new("ProximityPrompt");
		prox.ActionText = "Pick Up";
		prox.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton;
		prox.HoldDuration = 0;
		prox.GamepadKeyCode = Enum.KeyCode.ButtonX;
		prox.KeyboardKeyCode = Enum.KeyCode.E;
		prox.MaxActivationDistance = 6;
		prox.Name = "ProximityPrompt";
		prox.ObjectText = tostring(type);
		prox.RequiresLineOfSight = true;
		prox.ClickablePrompt = true;
		prox.Parent = object.PrimaryPart;
	elseif object:IsA("MeshPart") 
	and (not object:FindFirstChild("ProximityPrompt") or not object:FindFirstChildWhichIsA("ProximityPrompt")) then
		local prox = Instance.new("ProximityPrompt");
		prox.ActionText = "Pick Up";
		prox.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton;
		prox.HoldDuration = 0;
		prox.GamepadKeyCode = Enum.KeyCode.ButtonX;
		prox.KeyboardKeyCode = Enum.KeyCode.E;
		prox.MaxActivationDistance = 6;
		prox.Name = "ProximityPrompt";
		prox.ObjectText = tostring(type);
		prox.RequiresLineOfSight = true;
		prox.ClickablePrompt = true;
		prox.Parent = object;
	end;
end;]]


function GameController:ForIngredient(Ingredient)
	table.insert(CollectedItems,Ingredient);

	if Ingredient:IsA("Model") then Ingredient = Ingredient.PrimaryPart end 

	--self:createProximityPrompt(Ingredient,"Ingredient");

	if not Ingredient:FindFirstChild("ProximityPrompt") then return end
	Ingredient:WaitForChild("ProximityPrompt").Enabled = true;
	Ingredient.ProximityPrompt.Triggered:Connect(function(plr)
		if Cooldown == false then
			Cooldown = true;
			--print("triggered")
			if plr.Character:FindFirstChild("Ingredient") then
				--print("character")
				if plr.Character:FindFirstChild("Ingredient").Value == nil then
					--print("mag")
					local Mag;

					Mag = (Ingredient.Position - Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude;
					--print("Pickup Mag:",Mag)
					if Mag and Mag <= 6 then
						--print(tostring(Ingredient).." is Ingredient");

						local CookingService = Knit.GetService("CookingService");
						CookingService.PickUp:Fire(Ingredient);
						task.wait(.1);

						if Ingredient.Parent then
							if Ingredient.Parent.Name == Ingredient.Name then
								Ingredient.Parent:Destroy();
							end
						end

						if Ingredient then
							Ingredient:Destroy();
						end
						
					end;
				end;
			end;

			task.wait(1);
			Cooldown = false;
		end;
	end);
end;


function GameController:ForFood(Food)
    local CookingService = Knit.GetService("CookingService");
	table.insert(CollectedItems,Food);

	if Food:IsA("Model") then Food = Food.PrimaryPart end 

	--self:createProximityPrompt(Food,"Food");

	if not Food:FindFirstChild("ProximityPrompt") then return end
	Food:WaitForChild("ProximityPrompt").Enabled = true;
	Food.ProximityPrompt.Triggered:Connect(function(plr)
		if Cooldown == false then
			Cooldown = true;
			if plr.Character:FindFirstChild("Ingredient") then
				if plr.Character:FindFirstChild("Ingredient").Value == nil then
					local Mag;

					Mag = (Food.Position - Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude;
					--print("Pickup Mag:",Mag)
					if Mag and Mag <= 6 then
						--print(tostring(Food).." is Food");

						local CookingService = Knit.GetService("CookingService");
						CookingService.PickUp:Fire(Food);
						task.wait(.1);

						if Food.Parent then
							if Food.Parent.Name == Food.Name then
								Food.Parent:Destroy();
							end
						end

						if Food then
							Food:Destroy();
						end
					end;
				end;
			end;

			task.wait(1);
			Cooldown = false;
		end;
	end);
end;

function GameController:KnitStart()
	--print("game controller")
    task.wait(1)

    for _,Ingredient in ipairs(IngredientAvailable:GetChildren()) do
        self:ForIngredient(Ingredient);
    end;
    
    for _,Food in ipairs(FoodAvailable:GetChildren()) do
        self:ForFood(Food);
    end;

    IngredientAvailable.ChildAdded:Connect(function(Ingredient)
        task.wait(0.5);
        self:ForIngredient(Ingredient);
    end);

    IngredientAvailable.ChildRemoved:Connect(function(Ingredient)
        table.remove(CollectedItems,TableFind(CollectedItems,Ingredient));
    end);

    FoodAvailable.ChildAdded:Connect(function(Food)
        task.wait(0.5);
        self:ForFood(Food);
    end);

    FoodAvailable.ChildRemoved:Connect(function(food)
        table.remove(CollectedItems,TableFind(CollectedItems,food));
    end);
end


function GameController:KnitInit()

    game:GetService("RunService").RenderStepped:Connect(function()

		for _, player in pairs(Players:GetPlayers()) do
			if player then
				if player == LocalPlayer then continue end
				local Character = player.Character
				if Character then
					local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart");
					if HumanoidRootPart then
						local DropProximity = HumanoidRootPart:FindFirstChildWhichIsA("ProximityPrompt")
						if DropProximity.Enabled == true then
							DropProximity.Enabled = false
						end
					end
				end
			end
		end

		for _, v in pairs(CollectionService:GetTagged("OwnerId")) do
			local OwnerId = v:GetAttribute("OwnerId") 
			if OwnerId then
				if OwnerId ~= LocalPlayer.UserId then
					v:Destroy()
				end
			end
		end

        for _,v in pairs(game.Workspace:FindFirstChild("FoodAvailable"):GetChildren()) do
            if v:IsA("Model") then
				if v.PrimaryPart == nil 
                or v.PrimaryPart:GetAttribute("Owner") == "Default" 
                or v.PrimaryPart:GetAttribute("Owner") == nil 
                or v.PrimaryPart:GetAttribute("Owner") == Players.LocalPlayer.Name then else
                    print(v.PrimaryPart:GetAttribute("Owner"));
                    print(v,"is getting destroyed in workspace");
                    v:Destroy();
                end;
            elseif v:IsA("MeshPart") then
                if v:GetAttribute("Owner") == "Default" 
                or v:GetAttribute("Owner") == nil 
                or v:GetAttribute("Owner") == Players.LocalPlayer.Name then else
                    print(v:GetAttribute("Owner"));
                    print(v,"is getting destroyed in workspace");
                    v:Destroy();
                end;
            end;
        end;
        for _,v in pairs(game.Workspace:FindFirstChild("IngredientAvailable"):GetChildren()) do
            if v:IsA("Model") then
				if v.PrimaryPart == nil
				or v.PrimaryPart:GetAttribute("Owner") == "Default"
				or v.PrimaryPart:GetAttribute("Owner") == nil 
				or v.PrimaryPart:GetAttribute("Owner") == Players.LocalPlayer.Name then else
					print(v.PrimaryPart:GetAttribute("Owner"));
					print(v,"is getting destroyed in workspace");
					v:Destroy();
				end;
            elseif v:IsA("MeshPart") then
                if v:GetAttribute("Owner") == "Default" 
                or v:GetAttribute("Owner") == nil 
                or v:GetAttribute("Owner") == Players.LocalPlayer.Name then else
                    print(v:GetAttribute("Owner"));
                    print(v,"is getting destroyed in workspace");
                    v:Destroy();
                end;
            end;
        end;
    end);
end


return GameController
