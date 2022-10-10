local CollectionService = game:GetService("CollectionService")
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
            if item:IsA("Model") or item:IsA("MeshPart") then
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
            if item:IsA("Model") or item:IsA("MeshPart") then
                local clonedItem = item:Clone();
                clonedItem.Parent = Directory;
                if Location then
                    if clonedItem:IsA("Model") and clonedItem.PrimaryPart then
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

function SpawnItems:Spawn(UserId, Owner, ItemName, RootFolder, Directory, Location) -- [UserId, Owner, ItemName, [Name]Ojects, [Name]Available, Position]
    PrintL(UserId,"[SpawnItemsAPI]: Spawned item [".. tostring(ItemName) .."] for user[".. tostring(Owner) .."] from RootFolder[".. tostring(RootFolder) .."]");
    if ItemName and RootFolder and Directory then
        local ItemClone = RootFolder:FindFirstChild(ItemName):Clone();
        if Owner then
            if ItemClone:IsA("Model") then
                ItemClone.PrimaryPart:SetAttribute("Owner", tostring(Owner));
            elseif ItemClone:IsA("MeshPart") then
                ItemClone:SetAttribute("Owner", tostring(Owner));
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

return SpawnItems;