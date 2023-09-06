local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProximityService = Knit.CreateService {
    Name = "ProximityService",
    Client = {
        TrackItem = Knit.CreateSignal(),
        CurrencyCollected = Knit.CreateSignal(),
        SetAnimations = Knit.CreateSignal(),
    }
}

--[[
    -- to add texture on foods
local decalTexture = "http://www.roblox.com/asset/?id=5352896021"

local part =(game:GetService("Selection"):Get()[1])
for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
    local decal = Instance.new("Decal")
    decal.Name = "Burnt"
    decal.Transparency = 1
    decal.Color3 = Color3.fromRGB(0,0,0)
    decal.Parent = part
    decal.Face = face
    decal.Texture = decalTexture
end]]

----- Integers -----

local density = 0
local friction = 0
local elasticity = 0
local frictionWeight = 0
local elasticityWeight = 0

local density2 = 0.7
local friction2 = 0.3
local elasticity2 = 0.5
local frictionWeight2 = 1
local elasticityWeight2 = 1

local PickProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)
local DropProperties = PhysicalProperties.new(density2, friction2, elasticity2, frictionWeight2, elasticityWeight2)

----- Private functions -----

local function GetYOffset(object)
	if object:IsA('BasePart') then
		return object.Size.Y/2
	elseif object:IsA('Model') then
		local _, size = object:GetBoundingBox()
		return size.Y/2
	end
end

local coldRangeVisuals = {min = 20, max = 50}
local cookedRangeVisuals = {min = 51, max = 75}
local burntRangeVisuals = {min = 76, max = 96}

local function percentageInRange(currentNumber, startRange, endRange)
	if startRange > endRange then startRange, endRange = endRange, startRange end

	local normalizedNum = (currentNumber - startRange) / (endRange - startRange)

	normalizedNum = math.max(0, normalizedNum)
	normalizedNum = math.min(1, normalizedNum)

	return (math.floor(normalizedNum * 100) / 100) -- rounds to .2 decimal places
end

local function visualizeFood(foodObject, percentage)
    print("\n\n\n\n\n\n\n\n\n\n\n")
    print("VISUALZING FOOD", foodObject, percentage)
    if not foodObject or not percentage then return end

    local function destroyTexture()
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("SurfaceAppearance") and item.Name == "Texture" then
                item:Destroy()
            end

            if item:IsA("Decal") and item.Name == "Texture" then
                item:Destroy()
            end
        end
    end

    local function setTransparency(transparency)
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("Decal") and item.Name == "Texture" then
                item.Transparency = transparency
            end
        end
    end

    local function setFillTransparency(transparency)
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("Highlight") and item.Name == "Burnt" then
                item.FillTransparency = transparency
            end
        end
    end

    if foodObject:GetAttribute("RawColor") ~= nil then
        foodObject.Color = foodObject:GetAttribute("RawColor")
    end

    if percentage <= coldRangeVisuals.min or (percentage > coldRangeVisuals.min and percentage <= coldRangeVisuals.max) then
        destroyTexture()
    elseif percentage > coldRangeVisuals.max and percentage <= cookedRangeVisuals.max then
        destroyTexture()
        setTransparency(0)
    elseif percentage > cookedRangeVisuals.max and percentage <= burntRangeVisuals.max then
        setTransparency(0)
        setFillTransparency((1 - percentageInRange(percentage, cookedRangeVisuals.min, burntRangeVisuals.max)))
    else
        setTransparency(0)
        setFillTransparency(0)
    end
end

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
            --print(Object.PrimaryPart:GetAttribute("i1"))
            local _PrimaryPart = Object.PrimaryPart
            for _,b in pairs(Object:GetChildren()) do
                if b:IsA("BasePart") then
                    b.CanCollide = false
                    b.CustomPhysicalProperties = PickProperties
                    b.Massless = true
                    b.CollisionGroup = "Food"
                    CollectionService:AddTag(b, "CC_Food")
                end
            end
            CollectionService:AddTag(Object, "CC_Food")
            Object:SetPrimaryPartCFrame(Character:FindFirstChild("HumanoidRootPart").CFrame)
            _PrimaryPart.HandJoint.Attachment1 = Character:FindFirstChild("Head").RightGripAttachment
            _PrimaryPart.FaceJoint.Attachment1 = Character:FindFirstChild("Head").FaceFrontAttachment


            Character.PrimaryPart.ProximityPrompt.Enabled = true
            _PrimaryPart.ProximityPrompt.Enabled = false
            --print("FALSE")
        else
            Object.CanCollide = false
            Object.Massless = true
            Object.CollisionGroup = "Food"
            Object.CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame
            Object.HandJoint.Attachment1 = Character:FindFirstChild("Head").RightGripAttachment
            Object.FaceJoint.Attachment1 = Character:FindFirstChild("Head").FaceFrontAttachment
            Object.CustomPhysicalProperties = PickProperties
            Character.PrimaryPart.ProximityPrompt.Enabled = true
            Object.ProximityPrompt.Enabled = false
            CollectionService:AddTag(Object, "CC_Food")
            --print("false!!")
        end
    end
end

function fixHighlight(obj)
    for _, obj_item in pairs(obj:GetDescendants()) do
        if obj_item:IsA("Highlight") then
            obj_item.Parent = ReplicatedStorage:WaitForChild("HiddenObjects")
            task.wait(0.001)
            obj_item.Parent = obj
        end
    end
end

function ProximityService:UnlinkItemToPlayer(Character,Object)

	if Character and Object then
		if Object:IsA("Model") and Object.PrimaryPart then
            --print(Object.PrimaryPart:GetAttribute("i1"))
			local _PrimaryPart = Object.PrimaryPart
			_PrimaryPart:SetAttribute("Owner", "Server")
			_PrimaryPart.HandJoint.Attachment1 = nil

			if _PrimaryPart:GetAttribute("Type") == "Ingredient" then
				Object.Parent = workspace.IngredientAvailable
			elseif _PrimaryPart:GetAttribute("Type") == "Food" then
                --local cookingPercentage = _PrimaryPart:GetAttribute("CookingPercentage")
                --visualizeFood(Object, cookingPercentage)
				Object.Parent = workspace.FoodAvailable
                --task.spawn(fixHighlight, Object)
			end

            CollectionService:RemoveTag(Object, "CC_Food")

			for _,part in pairs(Object:GetChildren()) do
				if part:IsA("BasePart") then
                    part.CollisionGroup = "Food"
					part.CanCollide = true
					part.Massless = false
					part.CustomPhysicalProperties = DropProperties
                    CollectionService:RemoveTag(part, "CC_Food")
                    part:SetNetworkOwner(game.Players:GetPlayerFromCharacter(Character))
				end
			end

        	--_PrimaryPart.Position = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4 + Vector3.new(0,GetYOffset(Object),0)
            
			Character.PrimaryPart.ProximityPrompt.Enabled = false
            _PrimaryPart.ProximityPrompt.Enabled = true
		elseif Object:IsA("BasePart") then
			Object:SetAttribute("Owner", "Server")
			Object.HandJoint.Attachment1 = nil
			if Object:GetAttribute("Type") == "Ingredient" then
				Object.Parent = workspace.IngredientAvailable
			elseif Object:GetAttribute("Type") == "Food" then
                --local cookingPercentage = Object:GetAttribute("CookingPercentage")
                --visualizeFood(Object, cookingPercentage)
				Object.Parent = workspace.FoodAvailable
                --task.spawn(fixHighlight, Object)
			end
            Object.CollisionGroup = "Food"
			Object.CanCollide = true
			Object.Massless = false
            CollectionService:RemoveTag(Object, "CC_Food")
			Object.CustomPhysicalProperties = DropProperties

            Object:SetNetworkOwner(game.Players:GetPlayerFromCharacter(Character))

			Object.Position = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.lookVector * 4 + Vector3.new(0,GetYOffset(Object),0)
			Character.PrimaryPart.ProximityPrompt.Enabled = false
            Object.ProximityPrompt.Enabled = true
		end
	end
end

function ProximityService:PickUpIngredient(Character, Ingredient)
    if Character and Ingredient then
        Ingredient.Parent = Character

        local Player = PlayerService:GetPlayerFromCharacter(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        local Animator = Humanoid:FindFirstChildOfClass("Animator")
        local AnimationTracks = Animator:GetPlayingAnimationTracks()

        for _, track in pairs (AnimationTracks) do
            track:Stop()
        end

        --print(Ingredient, Ingredient:GetAttribute("i1"), Ingredient.PrimaryPart:GetAttribute("i1"))

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8029004455","rbxassetid://8028996064","rbxassetid://8029001222"}) -- idle, walk, jump animation for standing up
        self:LinkItemToPlayer(Character,Ingredient)

        self.Client.TrackItem:Fire(Player, true, Ingredient) -- self:GetNearestPan(Character.PrimaryPart.Position)
        
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = Ingredient
        if Character:FindFirstChild("Ingredient") then
            Character:FindFirstChild("Ingredient").Value = Ingredient
        end
    end
end

function ProximityService:PickUpFood(Character, Food)
    if Character and Food then
        Food.Parent = Character

        local Player = PlayerService:GetPlayerFromCharacter(Character)

        local Humanoid = Character:WaitForChild("Humanoid")
        local Animator = Humanoid:FindFirstChildOfClass("Animator")
        local AnimationTracks = Animator:GetPlayingAnimationTracks()

        for _, track in pairs (AnimationTracks) do
            track:Stop()
        end

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8029004455","rbxassetid://8028996064","rbxassetid://8029001222"}) -- idle, walk, jump animation for standing up
        self:LinkItemToPlayer( Character,Food)
        
        self.Client.TrackItem:Fire(Player, true, Food) -- self:GetNearestDelivery(Character.PrimaryPart.Position)
        
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = Food
        if Character:FindFirstChild("Ingredient") then
            Character:FindFirstChild("Ingredient").Value = Food
        end
    end
end

function ProximityService:DropItem( Character, Item)
    --print( Character, Item)
    if Character and Item then
        local Ingredient = Character:FindFirstChild("Ingredient").Value
		local _Ingredient = Character:FindFirstChild(Ingredient.Name)

        self:UnlinkItemToPlayer( Character, _Ingredient)

        local Player = PlayerService:GetPlayerFromCharacter(Character)

        local Humanoid = Character:WaitForChild("Humanoid")
        local Animator = Humanoid:FindFirstChildOfClass("Animator")
        local AnimationTracks = Animator:GetPlayingAnimationTracks()

        for _, track in pairs (AnimationTracks) do
            track:Stop()
        end

        self.Client.TrackItem:Fire(Player, false)

		self.Client.SetAnimations:Fire(Player, {"rbxassetid://8028990292","rbxassetid://8028984908","rbxassetid://8028993547"}) -- idle, walk, jump animation for normal

        task.wait(.3)
        Player:FindFirstChild("Data").GameValues.Ingredient.Value = nil
        if Character:FindFirstChild("Ingredient") then
            Character:FindFirstChild("Ingredient").Value = nil
        end
    end
end

function ProximityService:KnitStart()
    
end


function ProximityService:KnitInit()
    
end


return ProximityService
