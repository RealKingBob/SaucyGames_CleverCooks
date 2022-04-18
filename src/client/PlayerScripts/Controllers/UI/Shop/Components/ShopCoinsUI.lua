local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopCoinsUI = Knit.CreateController { Name = "ShopCoinsUI" }

--//Service
local MarketplaceService = game:GetService("MarketplaceService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

local ProductData = {
    {
        ["Name"] = "Handful of Bread",
        ["Image"] = "rbxassetid://8475059273",
        ["ProductId"] = 1229503030,
        ["Amount"] = 1000
    },
    {
        ["Name"] = "Pile of Bread",
        ["Image"] = "rbxassetid://8475059142",
        ["ProductId"] = 1229503040,
        ["Amount"] = 3000
    },
    {
        ["Name"] = "Stack of Bread",
        ["Image"] = "rbxassetid://8475058995",
        ["ProductId"] = 1229502993,
        ["Amount"] = 5000
    },
    {
        ["Name"] = "Mountain of Bread",
        ["Image"] = "rbxassetid://8475058841",
        ["ProductId"] = 1229503096,
        ["Amount"] = 10000
    },
    {
        ["Name"] = "Chest of Bread",
        ["Image"] = "rbxassetid://8475058704",
        ["ProductId"] = 1229503007,
        ["Amount"] = 20000
    }
}

function ShopCoinsUI:OpenShop()
    self.ViewsUI:OpenView("Shop");
    self.ShopUI:GoToPage("Coins");
end

function ShopCoinsUI:KnitStart()
    self.ShopUI = Knit.GetController("ShopUI");
    self.ShopGiftsUI = Knit.GetController("ShopGiftsUI");
    self.ViewsUI = Knit.GetController("ViewsUI");
    local CoinsPage = self.ShopUI:GetPage("Coins");
    local CommaValue = require(Knit.ReplicatedModules.CommaValue);
    local currentProductId;

    for _,ItemData in pairs(ProductData) do
        local CoinItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("CoinItem");
        local ItemClone = CoinItemPrefab:Clone() do
            ItemClone.Name = ItemData.Name;
            ItemClone:WaitForChild("ImageLabel").Image = ItemData.Image;
            ItemClone:WaitForChild("ItemName").Text = ItemData.Name;
            ItemClone:WaitForChild("Amount").Text = ("+%s"):format(CommaValue(ItemData.Amount));
            ItemClone.Parent = CoinsPage:WaitForChild("ScrollingFrame");

            ItemClone:WaitForChild("GiftButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                self.ShopGiftsUI:OpenView(currentProductId, false);
            end)

            ItemClone:WaitForChild("BuyButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                local DataService = Knit.GetService("DataService")
                DataService:PurchaseProduct(plr):andThen(function(Data)
                    if Data.HasPlayer == true and Data.TargetPlayer == plr then
                        MarketplaceService:PromptProductPurchase(plr, currentProductId);
                    end
                end)
            end)
        end
    end
end

function ShopCoinsUI:KnitInit()
    
end

return ShopCoinsUI
