local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopGiftsUI = Knit.CreateController { Name = "ShopGiftsUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Const
local isOpened = false;
local selectedPlayer, selectedButton;
local productId, isGamepass;

local ViewOriginalSizes = {};
local ViewOriginalPositions = {};

local TweenModule = require(Knit.Modules.Tween);
local NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

local PlayerGui = plr:WaitForChild("PlayerGui");
local ShopView = PlayerGui:WaitForChild("Views"):WaitForChild("Shop");
local GiftPanel = ShopView:WaitForChild("GiftPanel");
local PanelMainFrame = GiftPanel:WaitForChild("Inner"):WaitForChild("Main")
local GiftButton = PanelMainFrame:WaitForChild("GiftButton")
local BackButton = PanelMainFrame:WaitForChild("BackButton")
local PlayerListFrame = PanelMainFrame:WaitForChild("CaseContainer"):WaitForChild("Holder"):WaitForChild("Inner"):WaitForChild("ScrollingFrame")

function ShopGiftsUI:IsViewing()
    return isOpened;
end

local function promptPurchase(player, targetPlayer, ProductId)

	local hasPass = false
 
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(targetPlayer.UserId, ProductId)
	end)
 
	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return
	end
 
	if hasPass then
		-- Player already owns the game pass; tell them somehow
        
	else
		-- Player does NOT own the game pass; prompt them to purchase
		MarketplaceService:PromptGamePassPurchase(player, ProductId)
	end
end

function ShopGiftsUI:OpenView(ProductId, IsGamepass)
    if isOpened == true then return end

    isOpened = true;
    productId = ProductId;
    isGamepass = IsGamepass;

	local CurrentView = GiftPanel;
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

    for _, button in pairs(PlayerListFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button:Destroy();
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player == plr then continue end 
        local PlayerButtonPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("PlayerButton");
        local ItemClone = PlayerButtonPrefab:Clone() do
            ItemClone.Name = player.UserId;
            ItemClone.Text = player.Name;

            if player:IsFriendsWith(plr.UserId) then
                ItemClone.LayoutOrder = 0;
            else
                ItemClone.LayoutOrder = 1;
            end

            ItemClone.Parent = PlayerListFrame;

            ItemClone.MouseButton1Click:Connect(function()
                if selectedButton == ItemClone then return end

                if selectedButton then
                    selectedButton.BackgroundColor3 = Color3.fromRGB(146, 108, 71);
                end

                selectedPlayer = player;
                selectedButton = ItemClone;

                ItemClone.BackgroundColor3 = Color3.fromRGB(46, 219, 12);
            end)
        end
    end

    CurrentView.Background.BackgroundTransparency = 1;

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
    
    task.wait(.2)
    local FadeTween = TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);
    local FadeOutTween = TweenModule.new(FadeTween, function(Alpha)
        CurrentView.Background.BackgroundTransparency = NumberUtil.LerpClamp(1, 0.45, Alpha);
    end)

    FadeOutTween:Play();
    FadeOutTween.Completed:Wait();
end

function ShopGiftsUI:CloseView()
    if isOpened == false then return end

    isOpened = false;
    productId = nil;
    isGamepass = nil;

    local TargetView = GiftPanel

    if (TargetView) then

        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end

end


function ShopGiftsUI:KnitStart()

    ViewOriginalSizes[GiftPanel.Name] = GiftPanel.Size;
    ViewOriginalPositions[GiftPanel.Name] = GiftPanel.Position;

    GiftButton:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        if selectedButton then
            print("gifting to:", selectedPlayer)
            local DataService = Knit.GetService("DataService")
            DataService:PurchaseProduct(selectedPlayer):andThen(function(Data)
                if Data.HasPlayer == true and Data.TargetPlayer ~= plr and productId ~= nil then
                    if isGamepass then
                        promptPurchase(plr, Data.TargetPlayer, productId)
                    else
                        MarketplaceService:PromptProductPurchase(plr, productId);
                    end
                end
            end)
        end
    end)

    BackButton:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        selectedPlayer = nil;
        selectedButton = nil;
        self:CloseView();
    end)
end


function ShopGiftsUI:KnitInit()
    
end


return ShopGiftsUI
