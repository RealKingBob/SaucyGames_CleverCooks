local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopView = Knit.CreateController { Name = "ShopView" }

--//Service
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Const
local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local viewsUI = PlayerGui:WaitForChild("Views")

local ShopGui = viewsUI:WaitForChild("Shop")
local ScrollingFrame = ShopGui:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ScrollingFrame")

local ShopAreas = {
    ["Bundle"] = 0;
    ["Gamepass"] = 0.212;
    ["Currency"] = 0.617;
}

local CheeseData = {
    {
        ["Name"] = "1,000",
        ["Image"] = "rbxassetid://10353892480",
        ["ProductId"] = 1229503030,
        ["Amount"] = 99,
        ["Extra"] = nil,
    },
    {
        ["Name"] = "2,400",
        ["Image"] = "rbxassetid://10353892480",
        ["ProductId"] = 1229503040,
        ["Amount"] = 199,
        ["Extra"] = 20,
    },
    {
        ["Name"] = "6,500",
        ["Image"] = "rbxassetid://10353892480",
        ["ProductId"] = 1229502993,
        ["Amount"] = 499,
        ["Extra"] = 30,
    },
    {
        ["Name"] = "14,000",
        ["Image"] = "rbxassetid://10353892480",
        ["ProductId"] = 1229503096,
        ["Amount"] = 999,
        ["Extra"] = 40,
    }
}

function ShopView:GoToArea(AreaName)
    if AreaName and ShopAreas[AreaName] then
        TweenService:Create(ScrollingFrame, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, ScrollingFrame.CanvasSize.Y.Offset * ShopAreas[AreaName])}):Play()
    end
end

function ShopView:SetupCheeseProducts()
    local CommaValue = require(Knit.ReplicatedModules.CommaValue);
    local CheesePage = ScrollingFrame:WaitForChild("CheesePage")
    local currentProductId;

    for i,ItemData in pairs(CheeseData) do
        local CheeseItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("CheeseItem");
        local ItemClone = CheeseItemPrefab:Clone() do
            ItemClone.Name = "CheeseProduct"..tostring(i);
            ItemClone:WaitForChild("Icon").Image = ItemData.Image;
            ItemClone:WaitForChild("Cheese").Text = ItemData.Name;
            ItemClone:WaitForChild("BuyButton"):WaitForChild("Title").Text =ItemData.Amount;
            if ItemData.Extra ~= nil then
                ItemClone:WaitForChild("Extra").Text = ("+"..tostring(ItemData.Extra).."% EXTRA");
            end
            ItemClone.Parent = CheesePage:WaitForChild("MainFrame"):WaitForChild("Frame");

            --[[ItemClone:WaitForChild("GiftButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                self.ShopGiftsUI:OpenView(currentProductId, false);
            end)]]

            ItemClone:WaitForChild("BuyButton").MouseButton1Click:Connect(function()
                --[[if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                local DataService = Knit.GetService("DataService")
                DataService:PurchaseProduct(LocalPlayer):andThen(function(Data)
                    if Data.HasPlayer == true and Data.TargetPlayer == LocalPlayer then
                        MarketplaceService:PromptProductPurchase(LocalPlayer, currentProductId);
                    end
                end)]]
            end)
        end
    end
end

function ShopView:KnitStart()
    --self.ShopGiftsUI = Knit.GetController("ShopGiftsUI");
    self.ViewsUI = Knit.GetController("ViewsUI");

    self:SetupCheeseProducts()
end


function ShopView:KnitInit()
    
end


return ShopView
