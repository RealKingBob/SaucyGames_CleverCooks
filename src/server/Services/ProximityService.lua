local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local PlayerService = game:GetService("Players");

local ProximityService = Knit.CreateService {
    Name = "ProximityService";
    Client = {
        SetAnimations = Knit.CreateSignal();
    };
}

----- Integers -----

local density = 0;
local friction = 0;
local elasticity = 0;
local frictionWeight = 0;
local elasticityWeight = 0;

local density2 = 0.7;
local friction2 = 0.3;
local elasticity2 = 0.5;
local frictionWeight2 = 1;
local elasticityWeight2 = 1;

local PickProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight);
local DropProperties = PhysicalProperties.new(density2, friction2, elasticity2, frictionWeight2, elasticityWeight2);

----- Private functions -----

local function GetYOffset(object)
	if object:IsA('BasePart') then
		return object.Size.Y/2;
	elseif object:IsA('Model') then
		local _, size = object:GetBoundingBox();
		return size.Y/2;
	end;
end;

----- Public functions -----

function ProximityService:LinkItemToPlayer(Character,Object)
    if Character and Object then
        if Object:IsA("Model") and Object.PrimaryPart then
            local _PrimaryPart = Object.PrimaryPart;
            for _,b in pairs(Object:GetChildren()) do
                if b:IsA("MeshPart") then
                    b.CanCollide = false;
                    b.CustomPhysicalProperties = PickProperties;
                    b.Massless = true;
                end;
            end;
            _PrimaryPart.CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame;
            _PrimaryPart.HandJoint.Attachment1 = Character:FindFirstChild("Head").RightGripAttachment;
            _PrimaryPart.FaceJoint.Attachment1 = Character:FindFirstChild("Head").FaceFrontAttachment;
            _PrimaryPart.ProximityPrompt.Enabled = false;
        else
            Object.CanCollide = false;
            Object.Massless = true;
            Object.CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame;
            Object.HandJoint.Attachment1 = Character:FindFirstChild("Head").RightGripAttachment;
            Object.FaceJoint.Attachment1 = Character:FindFirstChild("Head").FaceFrontAttachment;
            Object.CustomPhysicalProperties = PickProperties;
            Object.ProximityPrompt.Enabled = false;
        end;
    end;
end;

function ProximityService:UnlinkItemToPlayer(Character,Object)
	if Character and Object then
		if Object:IsA("Model") and Object.PrimaryPart then
			local _PrimaryPart = Object.PrimaryPart;
			_PrimaryPart:SetAttribute("Owner", PlayerService:GetPlayerFromCharacter(Character).Name);
			_PrimaryPart.HandJoint.Attachment1 = nil;

			if _PrimaryPart:GetAttribute("Type") == "Ingredient" then
				Object.Parent = workspace.IngredientAvailable;
			elseif _PrimaryPart:GetAttribute("Type") == "Food" then
				Object.Parent = workspace.FoodAvailable;
			end;

			for _,part in pairs(Object:GetChildren()) do
				if part:IsA("MeshPart") then
					part.CanCollide = true;
					part.Massless = false;
					part.CustomPhysicalProperties = DropProperties;
				end;
			end;
			_PrimaryPart.Position = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4 + Vector3.new(0,GetYOffset(Object),0);
			_PrimaryPart.ProximityPrompt.Enabled = true;
		elseif Object:IsA("MeshPart") then
			Object:SetAttribute("Owner", PlayerService:GetPlayerFromCharacter(Character).Name);
			Object.HandJoint.Attachment1 = nil;
			if Object:GetAttribute("Type") == "Ingredient" then
				Object.Parent = workspace.IngredientAvailable;
			elseif Object:GetAttribute("Type") == "Food" then
				Object.Parent = workspace.FoodAvailable;
			end;
			Object.CanCollide = true;
			Object.Massless = false;
			Object.CustomPhysicalProperties = DropProperties;
			Object.Position = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4 + Vector3.new(0,GetYOffset(Object),0);
			Object.ProximityPrompt.Enabled = true;
		end;
	end;
end;

function ProximityService:PickUpIngredient(Character, Ingredient)
    if Character and Ingredient then
        Ingredient.Parent = Character;

        local Player = PlayerService:GetPlayerFromCharacter(Character);

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8029004455","rbxassetid://8028996064","rbxassetid://8029001222"}); -- idle, walk, jump animation for standing up
        self:LinkItemToPlayer(Character,Ingredient);

        
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = Ingredient;
        Character:FindFirstChild("Ingredient").Value = Ingredient;
    end;
end;

function ProximityService:PickUpFood(Character, Food)
    if Character and Food then
        Food.Parent = Character;

        local Player = PlayerService:GetPlayerFromCharacter(Character);

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8029004455","rbxassetid://8028996064","rbxassetid://8029001222"}); -- idle, walk, jump animation for standing up
        self:LinkItemToPlayer( Character,Food);
        
        
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = Food;
        Character:FindFirstChild("Ingredient").Value = Food;
    end;
end;

function ProximityService:DropItem( Character, Item)
    print( Character, Item);
    if Character and Item then
        local Ingredient = Character:FindFirstChild("Ingredient").Value;
		local _Ingredient = Character:FindFirstChild(Ingredient.Name);

        self:UnlinkItemToPlayer( Character, _Ingredient);

        local Player = PlayerService:GetPlayerFromCharacter(Character);

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8028990292","rbxassetid://8028984908","rbxassetid://8028993547"}); -- idle, walk, jump animation for normal

        task.wait(1);
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = nil;
		Character:FindFirstChild("Ingredient").Value = nil;
    end;
end;

function ProximityService:KnitStart()
    
end


function ProximityService:KnitInit()
    
end


return ProximityService
