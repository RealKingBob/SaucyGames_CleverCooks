local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopCratesUI = Knit.CreateController { Name = "ShopCratesUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Imports
local DuckSkins;
local DeathEffects;
local CommaValue;
local Rarities;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

--//State
local SelectedCase, SelectedType, CategoryType;


local CategoryTypes = {
    ["Default"] = "Skins",
    ["Options"] = {
        ["Skins"] = { 1, true },
        ["Effects"] = { 2, true },
        --["Emotes"] = { 3, true },
    }
}

--//Private Functions
function getRarityDataFromType(ItemName, Type)
    if Type == "Skins" then
        return Rarities.getRarityDataFromDuckName(ItemName);
    elseif Type == "Effects" then
        return Rarities.getRarityDataFromEffectsName(ItemName);
    elseif Type == "Emotes" then
        return Rarities.getRarityDataFromEmotesName(ItemName);
    else
        return nil;
    end
end

function getDuckDataFromType(ItemName, Type)
    if Type == "Skins" then
        return DuckSkins.SkinsTable[ItemName]
    elseif Type == "Effects" then
        return DeathEffects.EffectsTable[ItemName]
    elseif Type == "Emotes" then
        --return DuckSkins.SkinsTable[ItemName]
    else
        return nil;
    end
end

--//Public Methods
function ShopCratesUI:SelectCategory(CaseType)
    for _, case in pairs(self.CaseContainer:GetChildren()) do
        if case:IsA("Frame") then
            case.Visible = (case:GetAttribute("Type") == CaseType)
        end
    end
end

function ShopCratesUI:SelectCase(CaseName, CaseType)
    SelectedCase = CaseName;
    SelectedType = CaseType;

    local CaseData;

    if SelectedType == "Skins" then
        CaseData = DuckSkins.CratesTable[CaseName];
    elseif SelectedType == "Effects" then
        CaseData = DeathEffects.CratesTable[CaseName];
    end

    self.BodyContainer:WaitForChild("BuyInfo"):WaitForChild("CostData"):WaitForChild("TextLabel").Text = CommaValue(CaseData.Price);
    
    for _,v in pairs(self.BodyContainer:WaitForChild("Items"):GetChildren()) do
        if (v:IsA("GuiObject")) then
            v:Destroy();
        end
    end

    local CrateContents;

    if SelectedType == "Skins" then
        CrateContents = DuckSkins.getCrateContentsFromId(CaseData.CrateId);
    elseif SelectedType == "Effects" then
        CrateContents = DeathEffects.getCrateContentsFromId(CaseData.CrateId);
    end

    local RarityItemAmount = {};

    for _,DuckData in pairs(CrateContents) do
        local ItemName = DuckData.Key or DuckData.Name;
        local RarityData;

        if SelectedType == "Skins" then
            RarityData = getRarityDataFromType(ItemName, "Skins");
        elseif SelectedType == "Effects" then
            RarityData = getRarityDataFromType(ItemName, "Effects");
        end

        RarityItemAmount[RarityData.Name] = RarityItemAmount[RarityData.Name] or 0;
        RarityItemAmount[RarityData.Name] += 1;
    end

    local CrateDuckItemPrefab = PlayerGui.Prefabs:WaitForChild("CrateDuckItem");

    for _,DuckData in pairs(CrateContents) do
        if (not DuckData.Key) then
            warn("[ShopCrates]: Insert key");
        end

        local ItemName = DuckData.Key or DuckData.Name;
        local InnerContainer;

        local RarityData;

        if SelectedType == "Skins" then
            RarityData = getRarityDataFromType(ItemName, "Skins");
        elseif SelectedType == "Effects" then
            RarityData = getRarityDataFromType(ItemName, "Effects");
        end

        local Clone = CrateDuckItemPrefab:Clone() do
            InnerContainer = Clone.Outer.Inner;

            Clone.Name = DuckData.Key or DuckData.Name;
            Clone:WaitForChild("Outer"):WaitForChild("BannerColor").ImageColor3 = RarityData.Color
            
            Clone.Outer:WaitForChild("RarityText").Text = ("%s%%"):format(RarityData.Chance / RarityItemAmount[RarityData.Name]);
            Clone.Outer:WaitForChild("RarityText"):WaitForChild("UIGradient").Color = RarityData.Gradient.Color;

            InnerContainer:WaitForChild("MainImage"):WaitForChild("ImageLabel").Image = DuckData.DecalId;
            Clone.Parent = self.BodyContainer.Items;
    
            Clone.LayoutOrder = -RarityData.Chance;

            Clone:SetAttribute("Locked", false); -- math.random(1, 2) == 1
        end

        local function UpdateItem()
            if (Clone:GetAttribute("Locked")) then
                InnerContainer.Locked.Visible = true;
                InnerContainer.Equipped.Visible = false;
                
                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0);
                InnerContainer.BackgroundColor3 = InnerContainer.Locked.BackgroundColor3;                
            else
                InnerContainer.Locked.Visible = false;
                InnerContainer.Equipped.Visible = false;
                
                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255);
                InnerContainer.BackgroundColor3 = Color3.fromRGB(146, 108, 71);
            end
        end

        Clone.AttributeChanged:Connect(UpdateItem)
        UpdateItem();
    end
end

function ShopCratesUI:KnitStart()
    
    task.wait(3)

    local UnboxerUI = Knit.GetController("UnboxerUI");
    local ShopUI = Knit.GetController("ShopUI");
    local CaseItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("CaseItem");
    self.CratesPage = ShopUI:GetPage("Crates");
    self.CategoryContainer = self.CratesPage:WaitForChild("Main"):WaitForChild("CaseContainer"):WaitForChild("Categories");
    self.CaseContainer = self.CratesPage:WaitForChild("Main"):WaitForChild("CaseContainer"):WaitForChild("Holder"):WaitForChild("Inner"):WaitForChild("ScrollingFrame");
    self.BodyContainer = self.CratesPage.Main:WaitForChild("Body"):WaitForChild("Inner");

    local Debounce = false;

    local OptionButtonPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("OptionButton");

    for Name, _ in next, CategoryTypes.Options do
        local Clone = OptionButtonPrefab:Clone() do
            Clone.Name = Name;
            Clone:WaitForChild("TextLabel").Text = Name
            Clone.Parent = self.CategoryContainer.Menu;

            Clone.MouseButton1Click:Connect(function()
                if Debounce == false then
                    Debounce = true;
                    self:SelectCategory(tostring(Name))
                    self:SelectCase("Crate1", tostring(Name))
                    self.CategoryContainer:WaitForChild("ImageButton").TextLabel.Text = Name
                    self.CategoryContainer:WaitForChild("ImageButton").ImageLabel.Rotation = 180;
                    self.CategoryContainer.Menu.Visible = false;
                    Debounce = false;
                end
            end)
        end
        self.CategoryContainer.Menu.CanvasSize = UDim2.new(1, 0, 0, self.CategoryContainer.Menu.UIList.AbsoluteContentSize.Y)
    end

    self.CategoryContainer:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        if Debounce == false then
            Debounce = true;
            self.CategoryContainer.Menu.Visible = not self.CategoryContainer.Menu.Visible;
            if self.CategoryContainer.Menu.Visible == true then
                self.CategoryContainer:WaitForChild("ImageButton").ImageLabel.Rotation = 0;
            else
                self.CategoryContainer:WaitForChild("ImageButton").ImageLabel.Rotation = 180;
            end
            Debounce = false;
        end
    end)

    self.BodyContainer:WaitForChild("BuyInfo"):WaitForChild("Buy"):WaitForChild("Button").MouseButton1Click:Connect(function()
        if (not UnboxerUI:CanOpen()) then
            return;
        end
        
        local CaseData;

        if SelectedType == "Skins" then
            CaseData = DuckSkins.CratesTable[SelectedCase];
        elseif SelectedType == "Effects" then
            CaseData = DeathEffects.CratesTable[SelectedCase];
        end
        
        local CanAfford, AffordPromise = false, nil;
        local PurchaseInfo, CratePromise = nil, nil;

        local DataService = Knit.GetService("DataService")
        local CrateService = Knit.GetService("CrateService")

        AffordPromise = DataService:GetCoins():andThen(function(Coins)
            if Coins then
                CanAfford = (Coins >= CaseData.Price);
                return;
            else
                CanAfford = false;
                return;
            end
        end)

        repeat task.wait(0) until AffordPromise:getStatus() ~= "Started" or Players.LocalPlayer == nil

        if (CanAfford) then
            CratePromise = CrateService:PurchaseCrate(CaseData.CrateId,CaseData.CrateType):andThen(function(CaseInfo)
                PurchaseInfo = CaseInfo;
                return;
            end)

            repeat task.wait(0) until CratePromise:getStatus() ~= "Started" or Players.LocalPlayer == nil

            if (PurchaseInfo.Status == "Success") then
                UnboxerUI:StartHatching(DuckSkins.getCrateInfoFromId(PurchaseInfo.ItemInfo.CrateId).Key, PurchaseInfo.ItemInfo.Key, PurchaseInfo.ItemInfo.ItemType, PurchaseInfo.DuplicateInfo)
            end
        else
            Knit.GetController("ShopCoinsUI"):OpenShop();
        end
    end)

    for CrateName, CrateData in pairs(DuckSkins.CratesTable) do
        local Clone = CaseItemPrefab:Clone() do
            Clone.Name = CrateName;
            Clone.LayoutOrder = CrateData.CrateId;
            Clone:WaitForChild("Main"):WaitForChild("ImageLabel").Image = CrateData.DecalId;
            Clone:WaitForChild("Main"):WaitForChild("TextLabel").Text = CrateData.Name
            Clone.Parent = self.CaseContainer;
            Clone:SetAttribute("Type", CrateData.CrateType)

            Clone:WaitForChild("Main"):WaitForChild("TextButton").MouseButton1Click:Connect(function()
                self:SelectCase(CrateName, Clone:GetAttribute("Type"))
            end)
        end
    end

    for CrateName, CrateData in pairs(DeathEffects.CratesTable) do
        local Clone = CaseItemPrefab:Clone() do
            Clone.Name = CrateName;
            Clone.LayoutOrder = CrateData.CrateId;
            Clone:WaitForChild("Main"):WaitForChild("ImageLabel").Image = CrateData.DecalId;
            Clone:WaitForChild("Main"):WaitForChild("TextLabel").Text = CrateData.Name
            Clone.Parent = self.CaseContainer;
            Clone:SetAttribute("Type", CrateData.CrateType)

            Clone:WaitForChild("Main"):WaitForChild("TextButton").MouseButton1Click:Connect(function()
                self:SelectCase(CrateName, Clone:GetAttribute("Type"))
            end)
        end
    end

    self:SelectCategory(CategoryTypes["Default"])
    self:SelectCase("Crate1", CategoryTypes["Default"])
end

function ShopCratesUI:KnitInit()
    DuckSkins = require(Knit.ReplicatedAssets.DuckSkins);
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
    DeathEffects = require(Knit.ReplicatedAssets.DeathEffects);
    Rarities = require(Knit.ReplicatedAssets.Rarities);

    
end

return ShopCratesUI
