local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--[[
    Name: SpawnItems API [V1]
    By: Real_KingBob
    Date: 10/2/21
    Description: This module spawns items from a rootfolder and places it in a directory of choice, it does all items or a specific item
]]

----- Private Variables -----

local SpawnItems = {};
local SpawnItemsLogs = {};

local ReplicatedAssets = Knit.Shared.Assets;

----- Private functions -----

local function PrintL(id, string, bool)
    if bool and bool == true then print(string) end;
    if id then
        if not SpawnItemsLogs[id] then SpawnItemsLogs[id] = {} end;
        table.insert(SpawnItemsLogs[id],string);
    else
        table.insert(SpawnItemsLogs,string);
    end;
    return;
end;

local coldRangeVisuals = {min = 0, max = 34};
local cookedRangeVisuals = {min = 35, max = 66};
local burntRangeVisuals = {min = 67, max = 96};

local function percentageInRange(currentNumber, startRange, endRange)
	if startRange > endRange then startRange, endRange = endRange, startRange; end

	local normalizedNum = (currentNumber - startRange) / (endRange - startRange);

	normalizedNum = math.max(0, normalizedNum);
	normalizedNum = math.min(1, normalizedNum);

	return (math.floor(normalizedNum * 100) / 100); -- rounds to .2 decimal places
end

--[[
    print("\n\n\n\n\n\n\n\n\n\n\n")
    print("VISUALZING FOOD", foodObject, percentage)
]]

local function visualizeFood(foodObject, percentage)
    --print("\n\n\n\n\n\n\n\n\n\n\n")
    --print("VISUALZING FOOD", foodObject, percentage)
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
            if item:IsA("Decal") and item.Name == "Burnt" then--if item:IsA("Highlight") and item.Name == "Burnt" then
                item.Transparency = transparency --item.FillTransparency = transparency
            end
        end
    end

    if foodObject:GetAttribute("RawColor") ~= nil then
        foodObject.Color = foodObject:GetAttribute("RawColor")
    end

    if percentage <= coldRangeVisuals.min or (percentage > coldRangeVisuals.min and percentage <= coldRangeVisuals.max) then
        destroyTexture()
    elseif percentage > coldRangeVisuals.max and percentage <= cookedRangeVisuals.max then
        --destroyTexture()
        setTransparency(0)
    elseif percentage > cookedRangeVisuals.max and percentage <= burntRangeVisuals.max then
        setTransparency(0)
        setFillTransparency((1 - percentageInRange(percentage, cookedRangeVisuals.min, burntRangeVisuals.max)))
    else
        setTransparency(0)
        setFillTransparency(0)
    end
end

----- Public functions -----

function SpawnItems:PrintLogs(UserId) -- Prints out a table of logs for that was made by AvatarService
    if SpawnItemsLogs[UserId] then
        print("[SpawnItemsAPI]: Logs[".. tostring(UserId) .."] have been retrieved - ", SpawnItemsLogs[UserId]);
        return SpawnItemsLogs[UserId];
    else
        print("[SpawnItemsAPI]: Logs have been retrieved - ", SpawnItemsLogs);
        return SpawnItemsLogs;
    end;
end;

function SpawnItems:SpawnTutorialIngredient(ingredientName)
    local IngredientOjects = Knit.GameLibrary:WaitForChild("IngredientObjects")
    local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");
    local TutorialSpawnPoints = {};

    for _, spawn in pairs(FoodSpawnPoints) do
        if spawn:GetAttribute("Tutorial") == true then
            table.insert(TutorialSpawnPoints, spawn)
        end
    end

    local Ingredient = IngredientOjects:FindFirstChild(ingredientName);

    local RandomFoodLocation = TutorialSpawnPoints[math.random(1, #TutorialSpawnPoints)]

    if Ingredient then
        local ItemClone = Ingredient:Clone();
        if RandomFoodLocation then
            if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                ItemClone:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
            else
                ItemClone.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5));
            end
        end
        ItemClone.Parent = workspace:WaitForChild("IngredientAvailable");
    end
end

function SpawnItems:SpawnDistributedIngredients(Theme)
    local IngredientOjects = Knit.GameLibrary:WaitForChild("IngredientObjects")
    local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");
    local RareFoodSpawnPoints = {};

    for _, spawn in pairs(FoodSpawnPoints) do
        if spawn:GetAttribute("RareSpawn") == true and spawn:GetAttribute("Tutorial") ~= true then
            table.insert(RareFoodSpawnPoints, spawn)
            CollectionService:RemoveTag(spawn, "FoodSpawnPoints")
        end
    end

    FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");

    local Ingredients = {};

    local RecipeModule = require(ReplicatedAssets:WaitForChild("Recipes"));

    local recipeCopy = RecipeModule:GetRecipes()

    for _, recipeData in pairs(recipeCopy) do
        if recipeData.Origin == Theme then
            local rIng = recipeData.Ingredients
            for _, ingredientName in pairs(rIng) do
                local foundIngredientName, replaced = string.gsub(ingredientName, "%[", "");
                    foundIngredientName = string.gsub(foundIngredientName, "%]", "")
                    foundIngredientName = string.gsub(foundIngredientName, "-", "")
                    foundIngredientName = string.gsub(foundIngredientName, "Blended", "")
                if not Ingredients[foundIngredientName] then Ingredients[foundIngredientName] = 0 end
                Ingredients[foundIngredientName] += 1;
            end
        end
    end

    local indexCount, greatestCount = 0, 0;

    for _, ingredientCount in next, Ingredients do
        if ingredientCount > greatestCount then
            greatestCount = ingredientCount
        end
        indexCount += 1;
    end;

    greatestCount = math.ceil(greatestCount / 3.5);

    for ingredientName, ingredientCount in next, Ingredients do
        ingredientCount = math.ceil(ingredientCount * 1.5)
        if ingredientName and ingredientCount then
            local Ingredient = IngredientOjects:FindFirstChild(ingredientName);

            for i = 1, ingredientCount do
                local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)]

                --print(ingredientCount, greatestCount, ingredientCount <= greatestCount)
                --print(RareFoodSpawnPoints)
                if #RareFoodSpawnPoints > 0 and ingredientCount < greatestCount then
                    RandomFoodLocation = RareFoodSpawnPoints[math.random(1, #RareFoodSpawnPoints)]
                end

                if Ingredient then
                    local ItemClone = Ingredient:Clone();
                    if RandomFoodLocation then
                        if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                            ItemClone:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
                        else
                            ItemClone.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5));
                        end
                    end
                    ItemClone.Parent = workspace:WaitForChild("IngredientAvailable");
                end

            end
        end;
    end;

    for _, spawn in pairs(RareFoodSpawnPoints) do
        CollectionService:AddTag(spawn, "FoodSpawnPoints")
    end
end

function SpawnItems:SpawnAllIngredients(NumOfIngredients)
    local IngredientOjects = Knit.GameLibrary:WaitForChild("IngredientObjects")
    local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");

    for i = 1, NumOfIngredients do
        for _, ingredient in ipairs(IngredientOjects:GetChildren()) do
            local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)]
            
            local ItemClone = ingredient:Clone();
            if RandomFoodLocation then
                if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                    ItemClone:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
                else
                    ItemClone.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5));
                end
            end
            ItemClone.Parent = workspace:WaitForChild("IngredientAvailable");
        end
    end
end

function SpawnItems:SpawnAtRandomSpawns(RootFolder, Directory, SpawnFolder) -- [IngredientOjects, IngredientAvailable],[FoodOjects, FoodAvailable, Location]
    PrintL("[SpawnItemsAPI]: Spawned all items from RootFolder[".. tostring(RootFolder) .."] at random locations");
    local function createSpawnDict()
        local SpawnDictionary = {};
        for _, spawn in pairs(SpawnFolder:GetChildren()) do
            if spawn:IsA("Part") then 
                table.insert(SpawnDictionary, spawn);
            end
        end;
        return SpawnDictionary;
    end

    local SpawnDictionary = createSpawnDict()

    if RootFolder and Directory then
        for _,item in pairs(RootFolder:GetChildren()) do
            if #SpawnDictionary == 0 then
                SpawnDictionary = createSpawnDict()
            end
            local RandomNum = math.random(1, #SpawnDictionary)
            if item:IsA("Model") or item:IsA("BasePart") then
                local clonedItem = item:Clone();
                clonedItem.Parent = Directory;
                if SpawnFolder then
                    if clonedItem:IsA("Model") and clonedItem.PrimaryPart then
                        clonedItem.PrimaryPart.Position = SpawnDictionary[RandomNum].Position;
                    else
                        clonedItem.Position = SpawnDictionary[RandomNum].Position;
                    end
                end;
            end;
        end;
        return true;
    end;
    return false;
end;

function SpawnItems:SpawnAll(RootFolder, Directory, Location) -- [IngredientOjects, IngredientAvailable],[FoodOjects, FoodAvailable, Location]
    PrintL("[SpawnItemsAPI]: Spawned all items from RootFolder[".. tostring(RootFolder) .."]");
    if RootFolder and Directory then
        for _,item in pairs(RootFolder:GetChildren()) do
            if item:IsA("Model") or item:IsA("BasePart") then
                local clonedItem = item:Clone();
                CollectionService:AddTag(clonedItem, "CC_Food")
                clonedItem.Parent = Directory;
                if Location then
                    if clonedItem:IsA("Model") and clonedItem.PrimaryPart then
                        CollectionService:AddTag(clonedItem.PrimaryPart, "CC_Food")
                        clonedItem.PrimaryPart:SetAttribute("Owner", "Real_KingBob");
                        clonedItem.PrimaryPart.Position = Location;
                    else
                        clonedItem:SetAttribute("Owner", "Real_KingBob");
                        clonedItem.Position = Location;
                    end
                end;
            end;
        end;
        return true;
    end;
    return false;
end;

function SpawnItems:SpawnBlenderFood(UserId, Owner, Ingredients, RootFolder, Directory, Location, ColorOfBlendedFood)
    PrintL(UserId,"[SpawnItemsAPI]: Spawned items [".. tostring(Ingredients) .."] for user[".. tostring(Owner) .."] from RootFolder[".. tostring(RootFolder) .."]");
    
    local PartyService = Knit.GetService("PartyService");
	local PartyMembers = {};
	local PartyOwner = Owner;

	if PartyService:IsPlayerInParty(Owner) == true then
        local OwnerId = PartyService:FindPartyFromPlayer(Owner);
		PartyOwner = Players:GetPlayerByUserId(Owner)
        local Party = PartyService:GetParty(Owner)
		for _, memberInParty in pairs(Party.Members) do
			local memberIdToPlayer = memberInParty.Player;
			table.insert(PartyMembers, memberIdToPlayer)
		end
    else
        table.insert(PartyMembers, Owner)
    end
    
    if Ingredients and RootFolder and Directory then
        local ItemClone = RootFolder:FindFirstChild("Blender Cup"):Clone();
        if Owner then
            if ItemClone:IsA("Model") then
                ItemClone.PrimaryPart:SetAttribute("Owner", tostring(PartyOwner));
                ItemClone.PrimaryPart.Color = ColorOfBlendedFood;
                for index, value in Ingredients do
                    ItemClone.PrimaryPart:SetAttribute("i"..tostring(index), tostring(value));
                    print(index, value);
                end
            elseif ItemClone:IsA("BasePart") then
                ItemClone.Color = ColorOfBlendedFood;
                ItemClone:SetAttribute("Owner", tostring(PartyOwner));

                for index, value in Ingredients do
                    ItemClone:SetAttribute("i"..tostring(index), tostring(value));
                    print(index, value);
                end
            end;
            if Location then
                if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                    ItemClone:SetPrimaryPartCFrame(CFrame.new(Location))
                    --ItemClone.PrimaryPart.Position = Location;
                else
                    ItemClone.Position = Location;
                end
            end
            ItemClone.Parent = Directory;

            if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                return ItemClone.PrimaryPart;
            else
                return ItemClone;
            end
            
        else
            ItemClone.Parent = Directory;
            if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                return ItemClone.PrimaryPart;
            else
                return ItemClone;
            end
        end;
    end;
    return nil;
end;

function SpawnItems:Spawn(UserId, Owner, ItemName, RootFolder, Directory, Location, FoodPercentage) -- [UserId, Owner, ItemName, [Name]Ojects, [Name]Available, Position]
    PrintL(UserId,"[SpawnItemsAPI]: Spawned item [".. tostring(ItemName) .."] for user[".. tostring(Owner) .."] from RootFolder[".. tostring(RootFolder) .."]");
    local PartyService = Knit.GetService("PartyService");
	local PartyMembers = {};
	local PartyOwner = Owner;

	local PartyInfo = PartyService:FindPartyFromPlayer(Owner);
	PartyOwner = Players:GetPlayerByUserId(PartyInfo.OwnerId)
	for _, memberInParty in pairs(PartyInfo.Members) do
		local memberIdToPlayer = memberInParty.Player;
		table.insert(PartyMembers, memberIdToPlayer)
	end
    
    if ItemName and RootFolder and Directory then
        local ItemClone = RootFolder:FindFirstChild(ItemName):Clone();
        if Owner then
            if ItemClone:IsA("Model") then
                ItemClone.PrimaryPart:SetAttribute("Owner", tostring(PartyOwner));
            elseif ItemClone:IsA("BasePart") then
                ItemClone:SetAttribute("Owner", tostring(PartyOwner));
            end;
            if Location then
                if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                    ItemClone:SetPrimaryPartCFrame(CFrame.new(Location))
                    --ItemClone.PrimaryPart.Position = Location;
                else
                    ItemClone.Position = Location;
                end
            end

            if FoodPercentage then
                if ItemClone:IsA("Model") then
                    ItemClone.PrimaryPart:SetAttribute("CookingPercentage", FoodPercentage);
                elseif ItemClone:IsA("BasePart") then
                    ItemClone:SetAttribute("CookingPercentage", FoodPercentage);
                end;
                --ItemClone:SetAttribute("CookingPercentage", FoodPercentage)
                visualizeFood(ItemClone, FoodPercentage);
            end

            ItemClone.Parent = Directory;

            if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                return ItemClone.PrimaryPart;
            else
                return ItemClone;
            end
            
        else
            ItemClone.Parent = Directory;
            if ItemClone:IsA("Model") and ItemClone.PrimaryPart then
                return ItemClone.PrimaryPart;
            else
                return ItemClone;
            end
        end;
    end;
    return nil;
end;

return SpawnItems;