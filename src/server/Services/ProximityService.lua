local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local PlayerService = game:GetService("Players");

local ProximityService = Knit.CreateService {
    Name = "ProximityService";
    Client = {
        TrackItem = Knit.CreateSignal();
        CurrencyCollected = Knit.CreateSignal();
        SetAnimations = Knit.CreateSignal();
    };
}

local DropUtil = require(Knit.Shared.Modules.DropUtil);

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

function ProximityService:GetNearestPan(fromPosition)
	local selectedPan, dist = nil, math.huge
	for _, pan in ipairs(CollectionService:GetTagged("Pan")) do
		if pan and (pan.Position - fromPosition).Magnitude < dist then
			selectedPan, dist = pan, (pan.Position - fromPosition).Magnitude
		end
	end
	return selectedPan
end

function ProximityService:GetNearestDelivery(fromPosition)
	local selectedDeliverZone, dist = nil, math.huge
	for _, deliverZone in ipairs(CollectionService:GetTagged("DeliverStation")) do
		if deliverZone and (deliverZone.Position - fromPosition).Magnitude < dist then
			selectedDeliverZone, dist = deliverZone, (deliverZone.Position - fromPosition).Magnitude
		end
	end
	return selectedDeliverZone
end

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
            Object:SetPrimaryPartCFrame(Character:FindFirstChild("HumanoidRootPart").CFrame)
            _PrimaryPart.HandJoint.Attachment1 = Character:FindFirstChild("Head").RightGripAttachment;
            _PrimaryPart.FaceJoint.Attachment1 = Character:FindFirstChild("Head").FaceFrontAttachment;
            Character.PrimaryPart.ProximityPrompt.Enabled = true;
            _PrimaryPart.ProximityPrompt.Enabled = false;
            --print("FALSE")
        else
            Object.CanCollide = false;
            Object.Massless = true;
            Object.CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame;
            Object.HandJoint.Attachment1 = Character:FindFirstChild("Head").RightGripAttachment;
            Object.FaceJoint.Attachment1 = Character:FindFirstChild("Head").FaceFrontAttachment;
            Object.CustomPhysicalProperties = PickProperties;
            Character.PrimaryPart.ProximityPrompt.Enabled = true;
            Object.ProximityPrompt.Enabled = false;
            --print("false!!")
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

            Object:SetPrimaryPartCFrame(CFrame.new(Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4 + Vector3.new(0,GetYOffset(Object),0)))
			--_PrimaryPart.Position = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4 + Vector3.new(0,GetYOffset(Object),0);
            
			Character.PrimaryPart.ProximityPrompt.Enabled = false;
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
			Character.PrimaryPart.ProximityPrompt.Enabled = false;
            Object.ProximityPrompt.Enabled = true;
		end;
	end;
end;

function ProximityService:PickUpIngredient(Character, Ingredient)
    if Character and Ingredient then
        Ingredient.Parent = Character;

        local Player = PlayerService:GetPlayerFromCharacter(Character);
        local Humanoid = Character:WaitForChild("Humanoid");
        local Animator = Humanoid:FindFirstChildOfClass("Animator");
        local AnimationTracks = Animator:GetPlayingAnimationTracks();

        for _, track in pairs (AnimationTracks) do
            track:Stop();
        end;

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8029004455","rbxassetid://8028996064","rbxassetid://8029001222"}); -- idle, walk, jump animation for standing up
        self:LinkItemToPlayer(Character,Ingredient);

        self.Client.TrackItem:Fire(Player, true, self:GetNearestPan(Character.PrimaryPart.Position))
        
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = Ingredient;
        Character:FindFirstChild("Ingredient").Value = Ingredient;
    end;
end;

function ProximityService:PickUpFood(Character, Food)
    if Character and Food then
        Food.Parent = Character;

        local Player = PlayerService:GetPlayerFromCharacter(Character);

        local Humanoid = Character:WaitForChild("Humanoid");
        local Animator = Humanoid:FindFirstChildOfClass("Animator");
        local AnimationTracks = Animator:GetPlayingAnimationTracks();

        for _, track in pairs (AnimationTracks) do
            track:Stop();
        end;

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8029004455","rbxassetid://8028996064","rbxassetid://8029001222"}); -- idle, walk, jump animation for standing up
        self:LinkItemToPlayer( Character,Food);
        
        self.Client.TrackItem:Fire(Player, true, self:GetNearestDelivery(Character.PrimaryPart.Position))
        
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

        local Humanoid = Character:WaitForChild("Humanoid");
        local Animator = Humanoid:FindFirstChildOfClass("Animator");
        local AnimationTracks = Animator:GetPlayingAnimationTracks();

        for _, track in pairs (AnimationTracks) do
            track:Stop();
        end;

        self.Client.TrackItem:Fire(Player, false)

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8028990292","rbxassetid://8028984908","rbxassetid://8028993547"}); -- idle, walk, jump animation for normal

        task.wait(1);
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = nil;
		Character:FindFirstChild("Ingredient").Value = nil;
    end;
end;

function ProximityService:CollectedCurrency(player, dropable, RootCFrame, DropAmount)
    if dropable:GetAttribute("OwnerId") == player.UserId then
        dropable:Destroy()
        local DataService = Knit.GetService("DataService")
        DataService:GiveCurrency(player, tonumber(DropAmount))
        self.Client.CurrencyCollected:Fire(player, RootCFrame, DropAmount)
        --DropUtil.DropCurrencyText(RootCFrame, DropAmount, player.UserId)
    end
end

function ProximityService:KnitStart()
    self.Client.CurrencyCollected:Connect(function(player, dropable, RootCFrame, DropAmount)
        self:CollectedCurrency(player, dropable, RootCFrame, DropAmount)
    end)
end


function ProximityService:KnitInit()
    
end


return ProximityService
