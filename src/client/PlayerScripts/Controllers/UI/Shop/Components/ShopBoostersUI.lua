local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopBoostersUI = Knit.CreateController { Name = "ShopBoostersUI" };

--//Service
local MarketplaceService = game:GetService("MarketplaceService");

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

local ProductData = {
    {
        ["Name"] = "2x Bread",
        ["Image"] = "",
        ["ProductId"] = 0,
        ["Amount"] = "+30 Minutes"
    },
    {
        ["Name"] = "2x Bread",
        ["Image"] = "",
        ["ProductId"] = 0,
        ["Amount"] = "+1 Hour"
    },
    {
        ["Name"] = "2x Bread",
        ["Image"] = "",
        ["ProductId"] = 0,
        ["Amount"] = "+3 Hours"
    },
    {
        ["Name"] = "2x EXP",
        ["Image"] = "",
        ["ProductId"] = 0,
        ["Amount"] = "+30 Minutes"
    },
    {
        ["Name"] = "2x EXP",
        ["Image"] = "",
        ["ProductId"] = 0,
        ["Amount"] = "+1 Hour"
    },
    {
        ["Name"] = "2x EXP",
        ["Image"] = "",
        ["ProductId"] = 0,
        ["Amount"] = "+3 Hours"
    }
}



function ShopBoostersUI:KnitStart()
    self.ShopUI = Knit.GetController("ShopUI");
    self.ShopGiftsUI = Knit.GetController("ShopGiftsUI");
    self.ViewsUI = Knit.GetController("ViewsUI");
    local BoostersPage = self.ShopUI:GetPage("Boosters");
    local CommaValue = require(Knit.ReplicatedModules.CommaValue);
    local currentProductId;

    for _,ItemData in pairs(ProductData) do
        local BoostItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("BoostItem");
        local ItemClone = BoostItemPrefab:Clone() do
            ItemClone.Name = ItemData.Name;
            ItemClone:WaitForChild("ImageLabel").Image = ItemData.Image;
            ItemClone:WaitForChild("ItemName").Text = ItemData.Name;
            ItemClone:WaitForChild("Amount").Text = ItemData.Amount;
            ItemClone.Parent = BoostersPage:WaitForChild("ScrollingFrame");

            ItemClone:WaitForChild("GiftButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                --[[if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                self.ShopGiftsUI:OpenView(currentProductId, false);]]
            end)

            ItemClone:WaitForChild("BuyButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                --[[if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                local DataService = Knit.GetService("DataService")
                DataService:PurchaseProduct(plr):andThen(function(Data)
                    if Data.HasPlayer == true and Data.TargetPlayer == plr then
                        MarketplaceService:PromptProductPurchase(plr, currentProductId);
                    end
                end)]]
            end)
        end
    end
end


function ShopBoostersUI:KnitInit()
    
end


return ShopBoostersUI
