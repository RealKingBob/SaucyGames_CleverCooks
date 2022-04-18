local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopDailyUI = Knit.CreateController { Name = "ShopDailyUI" }

local plr = Players.LocalPlayer

--//Imports
local Rarities;
local CommaValue;
local CrateService;

local DuckSkins = require(Knit.Shared.Assets.DuckSkins);
local DeathEffects = require(Knit.Shared.Assets.DeathEffects);

--//State
local CurrentData;
local ResetTime;

--//Private Functions
local function FormatSeconds(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end

--//Public Methods
function ShopDailyUI:Update(Data)
    CurrentData = Data;
    local MainContainer = self.DailyPage:WaitForChild("Main");

    for _,v in pairs(MainContainer:GetChildren()) do
        if (v:IsA("GuiObject")) then
            local Index = tonumber(v.Name);
            local DisplayData = Data.DailyShopItems[Index];      
            local ItemInfo;

            if DisplayData["itemType"] == "Skins" then
                ItemInfo = DuckSkins.getItemFromKey(DisplayData["itemKey"])
            elseif DisplayData["itemType"] == "Effects" then
                ItemInfo = DeathEffects.getItemFromKey(DisplayData["itemKey"])
            end

            if not ItemInfo then
                return
            end

            local RarityData

            if DisplayData["itemType"] == "Skins" then
                RarityData = Rarities.getRarityDataFromDuckName(ItemInfo.Key);
            elseif DisplayData["itemType"] == "Effects" then
                RarityData = Rarities.getRarityDataFromEffectsName(ItemInfo.Key);
            end

            v:WaitForChild("ImageInfo"):WaitForChild("Inner"):WaitForChild("ImageLabel").Image = ItemInfo.DecalId;

            v:WaitForChild("NameInfo"):WaitForChild("ItemName").Text = ItemInfo.Name;
            v.NameInfo:WaitForChild("Rarity").Text = RarityData.Name;
            v.NameInfo.Rarity:WaitForChild("UIGradient").Color = RarityData.Gradient.Color;

            v:WaitForChild("PriceInfo"):WaitForChild("TextLabel").Text = CommaValue(ItemInfo.IndividualPrice);
            v.Visible = true;
            
            v:WaitForChild("BuyButton"):WaitForChild("ImageButton").ImageColor3 = DisplayData.purchased and Color3.fromRGB(34, 102, 50) or Color3.fromRGB(75, 225, 110);
            v.BuyButton.ImageButton:WaitForChild("TextLabel").Text = DisplayData.purchased and "Owned" or "Buy"

            if (DisplayData.purchased) then
                CollectionService:RemoveTag(v.BuyButton.ImageButton, "ButtonStyle");
            else
                CollectionService:AddTag(v.BuyButton.ImageButton, "ButtonStyle");
            end
        end
    end

    ResetTime = os.time() + Data.TimeLeft;
end

function ShopDailyUI:KnitStart()
    for _,v in pairs(self.DailyPage:WaitForChild("Main"):GetChildren()) do
        if (not v:IsA("GuiObject")) then
            continue;
        end

        local Index = tonumber(v.Name);
        
        v:WaitForChild("BuyButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
            local Data = CurrentData.DailyShopItems[Index];
            if (Data.purchased) then
                return;
            end

            local CanAfford, AffordPromise = false, nil;
            local PurchaseInfo, Promise = nil, nil;

            local ItemInfo;

            if Data["itemType"] == "Skins" then
                ItemInfo = DuckSkins.getItemFromKey(Data["itemKey"])
            elseif Data["itemType"] == "Effects" then
                ItemInfo = DeathEffects.getItemFromKey(Data["itemKey"])
            end

            if not ItemInfo then
                return
            end

            local DataService = Knit.GetService("DataService")

            AffordPromise = DataService:GetCoins():andThen(function(Coins)
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
                Promise = CrateService:PurchaseItem(ItemInfo.Name, Data["itemType"], Index):andThen(function(CaseInfo)
                    PurchaseInfo = CaseInfo;
                    return;
                end);
                repeat task.wait(0) until Promise:getStatus() ~= "Started" or Players.LocalPlayer == nil
                CrateService:GetDailyItems():andThen(function(Data)
                    if (Data) then
                        self:Update(Data);
                    end
                end)
            else
                Knit.GetController("ShopCoinsUI"):OpenShop();
            end
        end)
    end
    local Character = plr.Character or plr.CharacterAdded:Wait()

    repeat task.wait(0) until Character
    task.wait(1)

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

function ShopDailyUI:KnitInit()
    self.ShopUI = Knit.GetController("ShopUI");
    self.DailyPage = self.ShopUI:GetPage("Daily")

    Rarities = require(Knit.ReplicatedAssets.Rarities);
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
end

return ShopDailyUI
