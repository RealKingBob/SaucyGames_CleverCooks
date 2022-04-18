local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopBundlesUI = Knit.CreateController { Name = "ShopBundlesUI" }

--//Service
local MarketplaceService = game:GetService("MarketplaceService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

local BundleData = {
    {
        ["Name"] = "Karl Bundle",
        ["Description"] = "- Contains one duck: Karl\n- Extra 1200 bread",
        ["Image"] = "rbxassetid://8523423060",
        ["Limited"] = true,
        ["ProductId"] = 27310378,
        ["GiftProductId"] = 1245274024,
        ["Amount"] = 199
    },
    {
        ["Name"] = "VIP Bundle",
        ["Description"] = "- Contains one duck: VIP Duck\n- Extra 1000 bread\n- 1.5x coin boost",
        ["Image"] = "rbxassetid://8523422860",
        ["Limited"] = false,
        ["ProductId"] = 26228902,
        ["GiftProductId"] = 1245274104,
        ["Amount"] = 499
    },
}

local function promptPurchase(button, ProductId)

	local hasPass = false
 
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, ProductId)
	end)
 
	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return
	end
 
	if hasPass then
		-- Player already owns the game pass; tell them somehow
        button:WaitForChild("BuyButton"):WaitForChild("ImageButton").ImageTransparency = hasPass and 1 or 0
        button.BuyButton.ImageButton:WaitForChild("TextLabel").Text = hasPass and "OWNED" or "BUY"

        if (hasPass) then
            CollectionService:RemoveTag(button.BuyButton.ImageButton, "ButtonStyle");
        else
            CollectionService:AddTag(button.BuyButton.ImageButton, "ButtonStyle");
        end
	else
		-- Player does NOT own the game pass; prompt them to purchase
		MarketplaceService:PromptGamePassPurchase(plr, ProductId)
	end
end

function ShopBundlesUI:OpenShop()
    self.ViewsUI:OpenView("Shop");
    self.ShopUI:GoToPage("Bundles");
end

function ShopBundlesUI:KnitStart()
    self.ShopUI = Knit.GetController("ShopUI");
    self.ShopGiftsUI = Knit.GetController("ShopGiftsUI");
    self.ViewsUI = Knit.GetController("ViewsUI");
    local BundlesPage = self.ShopUI:GetPage("Bundles");
    local CommaValue = require(Knit.ReplicatedModules.CommaValue);

    local currentProductId;

    for _,ItemData in pairs(BundleData) do
        local BundleItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("BundleItem");
        local ItemClone = BundleItemPrefab:Clone() do
            local ItemClonePass = false;
            ItemClone.Name = ItemData.Name;
            ItemClone:WaitForChild("ImageInfo"):WaitForChild("Inner"):WaitForChild("ImageLabel").Image = ItemData.Image;
            ItemClone:WaitForChild("ItemName").Text = ItemData.Name;
            ItemClone:WaitForChild("ItemDesc").Text = ItemData.Description;
            ItemClone:WaitForChild("LimitedTime").Visible = ItemData.Limited;
            ItemClone:WaitForChild("Amount").Text = ("%s ROBUX"):format(CommaValue(ItemData.Amount));
            ItemClone.Parent = BundlesPage:WaitForChild("ScrollingFrame");

            local success, message = pcall(function()
                ItemClonePass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, ItemData.ProductId)
            end)
         
            if not success then
                warn("Error while checking if player has pass: " .. tostring(message))
                return
            end
         
            if ItemClonePass then
                -- Player already owns the game pass; tell them somehow
                ItemClone:WaitForChild("BuyButton"):WaitForChild("ImageButton").ImageTransparency = ItemClonePass and 1 or 0
                ItemClone.BuyButton.ImageButton:WaitForChild("TextLabel").Text = ItemClonePass and "OWNED" or "BUY"
        
                if (ItemClonePass) then
                    CollectionService:RemoveTag(ItemClone.BuyButton.ImageButton, "ButtonStyle");
                else
                    CollectionService:AddTag(ItemClone.BuyButton.ImageButton, "ButtonStyle");
                end
            end

            ItemClone:WaitForChild("GiftButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.GiftProductId;
                self.ShopGiftsUI:OpenView(currentProductId, false);
            end)

            ItemClone:WaitForChild("BuyButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
                if self.ShopGiftsUI:IsViewing() == true then return end
                currentProductId = ItemData.ProductId;
                local DataService = Knit.GetService("DataService")
                DataService:PurchaseProduct(plr):andThen(function(Data)
                    if Data.HasPlayer == true and Data.TargetPlayer == plr then
                        promptPurchase(ItemClone, currentProductId)
                    end
                end)
            end)
        end
    end
end

function ShopBundlesUI:KnitInit()
    
end

return ShopBundlesUI
