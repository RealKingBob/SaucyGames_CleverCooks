local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local DailyView = Knit.CreateController { Name = "DailyView" }

local plr = Players.LocalPlayer

--//Imports
local Rarities;
local CommaValue;
local CrateService;

local HatSkins = require(Knit.ReplicatedHatSkins);
local DeathEffects --= require(Knit.Shared.Assets.DeathEffects);

--//State
local CurrentData;
local ResetTime;
local MyInventory;

--//Private Functions
local function FormatSeconds(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end

--//Public Methods
function DailyView:Update(Data)
    --print("DATA:", Data)
    CurrentData = Data;
    local MainContainer = self.DailyPage:WaitForChild("Main");

    for _,v in pairs(MainContainer:GetChildren()) do
        if (v:IsA("GuiObject")) then
            local Index = tonumber(v.Name);
            local DisplayData = Data.DailyShopItems[Index];      
            local ItemInfo, PurchaseInfo;

            --print(DisplayData)
            --print(HatSkins.getItemFromKey(DisplayData["itemKey"]))

            if DisplayData["itemType"] == "Hats" then
                ItemInfo = HatSkins.getItemFromKey(DisplayData["itemKey"])
            elseif DisplayData["itemType"] == "Effects" then
                ItemInfo = DeathEffects.getItemFromKey(DisplayData["itemKey"])
            end

            if not ItemInfo then
                --print("ItemInfo", ItemInfo)
                return
            end

            local RarityData

            --print(Rarities.getRarityDataFromItemName(ItemInfo.Key))

            if DisplayData["itemType"] == "Hats" then
                RarityData = Rarities.getRarityDataFromItemName(ItemInfo.Key, "Hats");
            elseif DisplayData["itemType"] == "Effects" then
                RarityData = Rarities.getRarityDataFromEffectsName(ItemInfo.Key);
            end

            --print("itemRarity", ItemInfo, RarityData)

            v:WaitForChild("ImageInfo"):WaitForChild("ImageLabel").Image = ItemInfo.DecalId;

            v:WaitForChild("NameInfo"):WaitForChild("ItemName").Text = ItemInfo.Name;
            v.NameInfo:WaitForChild("Rarity").Text = RarityData.Name;
            v.NameInfo.Rarity:WaitForChild("UIGradient").Color = RarityData.Gradient.Color;

            --v:WaitForChild("PriceInfo"):WaitForChild("TextLabel").Text = CommaValue(ItemInfo.IndividualPrice);
            
            --print("MyInventory", MyInventory)

            if DisplayData["itemType"] == "Hats" then
                PurchaseInfo = MyInventory["Hats"]
            end

            if not PurchaseInfo then return end

            --print(PurchaseInfo[ItemInfo.Name])
            
            --v:WaitForChild("BuyButton"):WaitForChild("ImageButton").ImageColor3 = DisplayData.purchased and Color3.fromRGB(34, 102, 50) or Color3.fromRGB(75, 225, 110);
            
            if (PurchaseInfo[ItemInfo.Name] ~= nil or DisplayData.purchased) then
                v.BuyButton.UIStroke.Transparency = 1;
                v.BuyButton.BackgroundTransparency = 1;
                v.BuyButton.ImageLabel.Visible = false;
                v.BuyButton:WaitForChild("TextLabel").Text = "Owned";
            else
                v.BuyButton.UIStroke.Transparency = 0;
                v.BuyButton.BackgroundTransparency = 0;
                v.BuyButton.ImageLabel.Visible = true;
                v.BuyButton:WaitForChild("TextLabel").Text = CommaValue(ItemInfo.IndividualPrice);
            end

            if (PurchaseInfo[ItemInfo.Name] ~= nil or DisplayData.purchased) then
                --CollectionService:RemoveTag(v.BuyButton, "ButtonStyle");
            else
                --CollectionService:AddTag(v.BuyButton, "ButtonStyle");
            end

            v.Visible = true;
        end
    end

    ResetTime = os.time() + Data.TimeLeft;
end

function DailyView:KnitStart()

    local result, policyInfo = pcall(function()
        return PolicyService:GetPolicyInfoForPlayerAsync(plr)
    end)
    
    if not result then
        warn("PolicyService error: " .. policyInfo)
    elseif policyInfo.ArePaidRandomItemsRestricted then
        warn("Player cannot interact with paid random item generators")
        self.DailyPage:WaitForChild("Main").Visible = false;
        self.DailyPage:WaitForChild("PolicyWarning").Visible = true;
        return;
    end

    for _,v in pairs(self.DailyPage:WaitForChild("Main"):GetChildren()) do
        if (not v:IsA("GuiObject")) then
            continue;
        end

        local Index = tonumber(v.Name);
        
        v:WaitForChild("BuyButton").MouseButton1Click:Connect(function()
            local DisplayData = CurrentData.DailyShopItems[Index];

            local CanAfford, AffordPromise = false, nil;
            local PurchaseInfo, Promise = nil, nil;

            local InfoContainer, ItemInfo;

            if DisplayData["itemType"] == "Hats" then
                InfoContainer = MyInventory["Hats"]
            end

            if DisplayData["itemType"] == "Hats" then
                ItemInfo = HatSkins.getItemFromKey(DisplayData["itemKey"])
            elseif DisplayData["itemType"] == "Effects" then
                ItemInfo = DeathEffects.getItemFromKey(DisplayData["itemKey"])
            end

            if not ItemInfo then
                return
            end

            if (InfoContainer[ItemInfo.Name] ~= nil or DisplayData.purchased) then
                return;
            end

            local DataService = Knit.GetService("DataService")

            AffordPromise = DataService:GetCurrency():andThen(function(Coins)
                if Coins then
                    CanAfford = (Coins >= ItemInfo.IndividualPrice)
                    return;
                else
                    CanAfford = false;
                    return;
                end
            end)
    
            repeat task.wait(0) until AffordPromise:getStatus() ~= "Started" or Players.LocalPlayer == nil

            if (CanAfford) then
                Promise = CrateService:PurchaseItem(ItemInfo.Name, DisplayData["itemType"], Index):andThen(function(CaseInfo)
                    PurchaseInfo = CaseInfo;
                    return;
                end);
                repeat task.wait(0) until Promise:getStatus() ~= "Started" or Players.LocalPlayer == nil
                CrateService:GetDailyItems():andThen(function(Data)
                    if (Data) then
                        print("Data", Data)
                        self:Update(Data);
                    end
                end)
            else
                Knit.GetController("ViewsUI"):OpenView("Shop");
                Knit.GetController("ShopView"):GoToArea("Currency");
            end
        end)
    end
    local Character = plr.Character or plr.CharacterAdded:Wait()

    repeat task.wait(0) until Character
    task.wait(1)

    local InventoryService = Knit.GetService("InventoryService")

    InventoryService.ItemChanged:Connect(function(updatedInventory) -- When inventory updatses then give inventory data
        MyInventory = updatedInventory;
    end)

    InventoryService:RequestInventory():andThen(function(inventory) -- When initialized complete, request inventory data
        --print(inventory)
        MyInventory = inventory;
    end)

    CrateService = Knit.GetService("CrateService");
    
    CrateService:GetDailyItems():andThen(function(Data)
        if (Data) then
            self:Update(Data);
        end
    end)

    while task.wait(1) do
        if (not ResetTime) then
            continue;
        end

        local Dt = math.max(ResetTime - os.time(), 0);
        
        self.DailyPage:WaitForChild("TimeLeft").Text = ("Reset: %s"):format(FormatSeconds(Dt));
    end
end

function DailyView:KnitInit()
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local viewsUI = PlayerGui:WaitForChild("Views")

    self.DailyView = viewsUI:WaitForChild("Daily")

    self.DailyPage = self.DailyView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ScrollingFrame"):WaitForChild("DailyPage"):WaitForChild("MainFrame")

    Rarities = require(Knit.ReplicatedAssets.Rarities);
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
end

return DailyView
