local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CookingUI = Knit.CreateController { Name = "CookingUI" }

--[[
    Payload = {
        ["CurrentTime"] = 0,
        ["Alpha"] = .3
    }
]]


--[[

    local part1 = game:GetService("Selection"):Get()[1]
    print(part1)
    local attachment1 = part1.Raw.LinkPoint
    local attachment2 = workspace.Pans.Pan2.Pan2Hitbox.MidAttach

    part1:SetPrimaryPartCFrame(attachment2.WorldCFrame * attachment1.CFrame:Inverse())

]]

--//Services
local TweenService = game:GetService("TweenService");
local SoundService = game:GetService("SoundService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

local GoodMagicSound = "rbxassetid://9116394545";
local GoodPoofSound = "rbxassetid://9125639499";
local BadPoofSound = "rbxassetid://9116406899";
local SizzleSound = "rbxassetid://9119165436";

local ColdIcon = "rbxassetid://12025423929";
local ReadyIcon = "rbxassetid://11961241690";
local HotIcon = "rbxassetid://12025424257";
local SkullIcon = "rbxassetid://12025423642";

local PanUIs = {}

local CookingPreviews = Knit.GameLibrary:WaitForChild("CookingPreviews"); --local ProgressBar = TierFrame:WaitForChild("InnerFrame"):WaitForChild("ProgressBar");

local SizeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

local function playLocalSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId;
    sound.Volume = volume;
    SoundService:PlayLocalSound(sound)
    sound.Ended:Wait()
    sound:Destroy()
end

local roundDecimals = function(num, places) --num is your number or value and places is number of decimal places, in your case you would need 2
    
    places = math.pow(10, places or 0)
    num = num * places
   
    if num >= 0 then 
        num = math.floor(num + 0.5) 
    else 
        num = math.ceil(num - 0.5) 
    end
    
    return num / places
    
end

local coldRangeIcons = {min = 0, max = 34};
local cookedRangeIcons = {min = 35, max = 66};
local burntRangeIcons = {min = 67, max = 96};

local coldRangeVisuals = {min = 20, max = 50};
local cookedRangeVisuals = {min = 51, max = 75};
local burntRangeVisuals = {min = 76, max = 96};

local function changeIcons(percentage, mainFrame)
    if percentage >= coldRangeIcons.min and percentage <= coldRangeIcons.max then
        mainFrame:WaitForChild("ItemImage").Image = ColdIcon;
    elseif percentage > coldRangeIcons.max and percentage <= cookedRangeIcons.max then
        mainFrame:WaitForChild("ItemImage").Image = ReadyIcon;
    elseif percentage > cookedRangeIcons.max and percentage <= burntRangeIcons.max then
        mainFrame:WaitForChild("ItemImage").Image = HotIcon;
    else
        mainFrame:WaitForChild("ItemImage").Image = SkullIcon;
    end
end

local function rangeInPercentage(percentage, startPercent, endPercent, startRange, endRange)
    return (startRange + (percentage / endPercent) * (endRange - startRange));
end

local function percentageInRange(currentNumber, startRange, endRange)
    if startRange > endRange then startRange, endRange = endRange, startRange; end

    local normalizedNum = (currentNumber - startRange) / (endRange - startRange);

    normalizedNum = math.max(0, normalizedNum);
    normalizedNum = math.min(1, normalizedNum);

    return (math.floor(normalizedNum * 100) / 100); -- rounds to .2 decimal places
end

local function visualizeSizzle(pan, isEnabled)
    if not pan or not isEnabled then return end
    local obj;
    
    if pan:FindFirstChild("CookSmokes") then
        obj = pan:FindFirstChild("CookSmokes")
        local attachment1 = obj.LinkPoint
        local attachment2 = pan.MidAttach
        obj.CFrame = (attachment2.WorldCFrame * attachment1.CFrame:Inverse())
    else
        obj = Knit.GameLibrary.Effects.CookSmokes:Clone();
        obj.Parent = pan
        local attachment1 = obj.LinkPoint
        local attachment2 = pan.MidAttach
        obj.CFrame = (attachment2.WorldCFrame * attachment1.CFrame:Inverse())
    end

    if obj then
        for _, v in pairs(obj:GetChildren()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = isEnabled;
            end
        end
    end

    return (obj == nil and Instance.new("Part")) or obj;
end

local function visualizeCookFood(foodObject, pan, percentage, fireEffect)
    if not foodObject or not pan or not percentage then return end
    
    local cookedRangeMin = cookedRangeVisuals.min
    local cookedRangeMax = cookedRangeVisuals.max
    local burntRangeMax = burntRangeVisuals.max
    local coldRangeMin = coldRangeVisuals.min
    local coldRangeMax = coldRangeVisuals.max

    local function fillTransparency(transparency)
        for _, item in pairs(foodObject.Cooked:GetChildren()) do
            if item:IsA("Decal") and item.Name == "Burnt" then--if item:IsA("Highlight") and item.Name == "Burnt" then
                item.Transparency = transparency --item.FillTransparency = transparency
            end
        end
    end

    fillTransparency(1)
    --foodObject.Cooked.Burnt.FillTransparency = 1
    foodObject.Cooked.Transparency = 0

    if percentage <= coldRangeMin then
        foodObject.Raw.Transparency = 0

    elseif percentage > coldRangeMin and percentage <= coldRangeMax then
        if foodObject.Cooked:FindFirstChild("Decal") then
            foodObject.Cooked:FindFirstChild("Decal").Transparency = (1 - percentageInRange(percentage, coldRangeMin, coldRangeMax))
        end
        foodObject.Raw.Transparency = percentageInRange(percentage, coldRangeMin, coldRangeMax)

    elseif percentage > coldRangeMax and percentage <= cookedRangeMax then
        foodObject.Raw.Transparency = 1

    elseif percentage > cookedRangeMax and percentage <= burntRangeMax then
        fillTransparency((1 - percentageInRange(percentage, cookedRangeMin, burntRangeMax)))
        --foodObject.Cooked.Burnt.FillTransparency = (1 - percentageInRange(percentage, cookedRangeMin, burntRangeMax))
        foodObject.Raw.Transparency = 1

    else
        fillTransparency(0)
        --foodObject.Cooked.Burnt.FillTransparency = 0
        foodObject.Raw.Transparency = 1

        if not foodObject:FindFirstChild("Fire") then
            fireEffect.Parent = foodObject
            local attachment1 = fireEffect.LinkPoint
            local attachment2 = pan.MidAttach
            fireEffect.CFrame = (attachment2.WorldCFrame * attachment1.CFrame:Inverse())
        end
    end
end

--//Public Methods

function CookingUI:SpawnCookedParticles(food)
    local MidAttachClone = Knit.Spawnables:WaitForChild("CookedParticle"):WaitForChild("MidAttach"):Clone()
    MidAttachClone.Parent = food;

    local cookingPercentage = (food:IsA("Model") and food.PrimaryPart ~= nil and food.PrimaryPart:GetAttribute("CookingPercentage")) or food:GetAttribute("CookingPercentage")

    if cookingPercentage >= cookedRangeIcons.min 
    and cookingPercentage <= cookedRangeIcons.max then
        task.spawn(playLocalSound, GoodMagicSound, 0.4)
        task.spawn(playLocalSound, GoodPoofSound, 0.4)
    else
        task.spawn(playLocalSound, BadPoofSound, 0.4)
    end
    

    for _, v in ipairs(MidAttachClone:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v:Emit(60)
        end
    end

    task.wait(1)

    MidAttachClone:Destroy()
end

function CookingUI:DestroyUI(RecipeName, Pan)
    if PanUIs[Pan] == nil then return; end
    local cookBillUI = PanUIs[Pan].cookBillUI;
    --local fireEffect = PanUIs[Pan].fireEffect;
    local returnedFood = PanUIs[Pan].returnedFood

    for _, v in pairs(Pan:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false;
        end
    end

    local obj = visualizeSizzle(Pan, true);
    
    obj:Destroy();
    returnedFood:Destroy();
    cookBillUI:Destroy()
end

function CookingUI:UpdatePanCook(RecipeName, Pan, Percentages)
    if PanUIs[Pan] == nil then return; end
    local cookBillUI = PanUIs[Pan].cookBillUI;
    local fireEffect = PanUIs[Pan].fireEffect;
    --local recipeAssets = require(Knit.ReplicatedAssets.Recipes);

    --local currentRecipeImage = recipeAssets[RecipeName].Image;

    local mainFrame = cookBillUI:WaitForChild("Frame")

    local numValue = Instance.new("NumberValue");

    cookBillUI.Parent = Pan

    local PosInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

    for _, v in pairs(Pan:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = true;
        end
    end

    visualizeSizzle(Pan, true);

    numValue.Changed:Connect(function()
        if not mainFrame or not mainFrame:FindFirstChild("BarHolder") then return end;
        mainFrame.BarHolder:WaitForChild("Bar").Position = UDim2.fromScale((numValue.Value / 100), .5)
        changeIcons(numValue.Value, mainFrame)
        visualizeCookFood(PanUIs[Pan].returnedFood, Pan, numValue.Value, fireEffect)
    end)

    if Percentages.overCookingLimit == true then
        numValue.Value = Percentages.current;
    else
        numValue.Value = Percentages.previous;
    end
    
    --TweenService:Create(mainFrame.BarHolder:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(1, 1) }):Play();
    
    TweenService:Create(numValue, PosInfo, { Value = Percentages.current }):Play();
end


function CookingUI:StartDelivering(RecipeName, DeliverZone, DeliverTime)
    local deliverBillUI = Knit.GameLibrary.BillboardUI.DeliverHeadUI:Clone();
    local recipeAssets = require(Knit.ReplicatedAssets.Recipes);

    local currentRecipeImage = recipeAssets[RecipeName].Image;

    local mainFrame = deliverBillUI:WaitForChild("Frame")

    mainFrame:WaitForChild("ItemImage").Image = currentRecipeImage;
    mainFrame:WaitForChild("Duration").Text = tostring(DeliverTime).."s";

    deliverBillUI.Parent = DeliverZone

    local SizeInfo = TweenInfo.new(DeliverTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

    for _, v in pairs(DeliverZone:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = true;
        end
    end

    --task.spawn(playLocalSound, SizzleSound, 0.3)

    TweenService:Create(mainFrame.BarHolder:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(1, 1) }):Play();

    for i = DeliverTime, 0, -1 do
        mainFrame:WaitForChild("Duration").Text = tostring(roundDecimals(i, 1)).."s";

        if i == 0 then
            
        end
        task.wait(1);
    end

    for _, v in pairs(DeliverZone:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false;
        end
    end

    deliverBillUI:Destroy()
end

-- TODO: CONVERT THIS INTO A FUNCTION PER PERCENTAGE
function CookingUI:StartCooking(RecipeName, Pan, CookingTime)
    if PanUIs[Pan] == nil then
        PanUIs[Pan] = {}
    end
    PanUIs[Pan].cookBillUI = Knit.GameLibrary.BillboardUI.CookHeadUI:Clone();
    PanUIs[Pan].fireEffect = Knit.GameLibrary.Effects.Fire:Clone();

    --local currentRecipeImage = recipeAssets[RecipeName].Image;

    task.spawn(playLocalSound, SizzleSound, 0.3)

    local mainFrame = PanUIs[Pan].cookBillUI:WaitForChild("Frame")

    local function visualizeCreateFood(foodName)
        local FoodPreviewClone = CookingPreviews:FindFirstChild(foodName):Clone()

        local attachment1 = FoodPreviewClone:WaitForChild("Raw"):WaitForChild("LinkPoint")
        local attachment2 = Pan:WaitForChild("MidAttach")

        FoodPreviewClone:SetPrimaryPartCFrame(attachment2.WorldCFrame * attachment1.CFrame:Inverse())

        FoodPreviewClone.Parent = workspace:WaitForChild("WorkspaceBin");

        return FoodPreviewClone;
    end

    mainFrame:WaitForChild("ItemImage").Image = ColdIcon;
    --mainFrame:WaitForChild("Duration").Text = tostring(CookingTime).."s";

    PanUIs[Pan].cookBillUI.Parent = Pan
    PanUIs[Pan].returnedFood = visualizeCreateFood(RecipeName)

    for _, v in pairs(Pan:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = true;
        end
    end

    visualizeSizzle(Pan, true);
end

function CookingUI:KnitStart()
    --[[while task.wait(3) do
        CookingUI:Update({
            CurrentLevel = math.random(1, 200),
            Alpha = math.random(),
        });
    end]]
end


function CookingUI:KnitInit()
    
end


return CookingUI
