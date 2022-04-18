local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CoinsUI = Knit.CreateController { Name = "CoinsUI" }

--//Services
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Imports
local CommaValue;
local NumberUtil;
local TweenModule;
local YouPurchased;

--//Const
local plr = game.Players.LocalPlayer;
local PlayerGui = plr:WaitForChild("PlayerGui");
local CoinPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("Coinboard");
local CoinContainer = PlayerGui

local ChangeInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);

local LastCoins = -1;

local ProductData = {
    {
        ["Name"] = "1K",
        ["Image"] = "rbxassetid://8475059273",
        ["ProductId"] = 1229503030,
        ["Amount"] = 1000,
        ["Color"] = Color3.fromRGB(197, 158, 0),
    },
    {
        ["Name"] = "3K",
        ["Image"] = "rbxassetid://8475059142",
        ["ProductId"] = 1229503040,
        ["Amount"] = 3000,
        ["Color"] = Color3.fromRGB(197, 158, 0),
    },
    {
        ["Name"] = "5K",
        ["Image"] = "rbxassetid://8475058995",
        ["ProductId"] = 1229502993,
        ["Amount"] = 5000,
        ["Color"] = Color3.fromRGB(197, 158, 0),
    },
    {
        ["Name"] = "10K",
        ["Image"] = "rbxassetid://8475058841",
        ["ProductId"] = 1229503096,
        ["Amount"] = 10000,
        ["Color"] = Color3.fromRGB(197, 158, 0),
    },
    {
        ["Name"] = "20K",
        ["Image"] = "rbxassetid://8475058704",
        ["ProductId"] = 1229503007,
        ["Amount"] = 20000,
        ["Color"] = Color3.fromRGB(197, 158, 0),
    }
}

--//Public Methods
function CoinsUI:UpdateCoin()
    --print("Updated Coins")
end

function CoinsUI:Update(currentCoins)
	local TargetCoins = LastCoins;
	
	if currentCoins ~= nil then
		local Tween = TweenModule.new(ChangeInfo, function(Alpha)
			local CurrentCoins = math.floor(NumberUtil.Lerp(TargetCoins, currentCoins, Alpha));
			
			LastCoins = CurrentCoins;
			YouPurchased.Text = ("You Purchased: %s"):format(CommaValue(CurrentCoins));
		end)
		
		Tween:Play();
    else
        YouPurchased.Text = ("You Purchased: 0");
	end
end

function CoinsUI:SetupCoin(Obj)
    local CoinClone = CoinPrefab:Clone() do
        local TargetClone = CoinClone:WaitForChild("UIListLayout"):WaitForChild("ItemPrefab");
        local Buttons = CoinClone:WaitForChild("Buttons")
        YouPurchased = CoinClone:WaitForChild("YouPurchased"):WaitForChild("TextLabel")
        CoinClone.Adornee = Obj;
        CoinClone.Name = "Coinboard";

        for _, ItemData in pairs(ProductData) do
            local ItemClone = TargetClone:Clone() do
                ItemClone.Name = ItemData.Name;
                ItemClone:WaitForChild("ImageButton"):WaitForChild("TextLabel").Text = ItemData.Name;
                ItemClone:WaitForChild("ImageButton").ImageColor3 = ItemData.Color
                ItemClone:WaitForChild("ImageButton").Activated:Connect(function(InputType)
                    if InputType.UserInputType == Enum.UserInputType.MouseButton1 or InputType.UserInputType == Enum.UserInputType.Touch then
                        MarketplaceService:PromptProductPurchase(plr, ItemData.ProductId);
                    end
                end)
                ItemClone.Parent = Buttons;

                --self:UpdateCoin()
            end
        end
        CoinClone.Parent = CoinContainer;
    end
end

function CoinsUI:KnitStart()
    
end

function CoinsUI:KnitInit()
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
    NumberUtil = require(Knit.ReplicatedModules.NumberUtil);
    TweenModule = require(Knit.Modules.Tween);

    CollectionService:GetInstanceAddedSignal("Donation"):Connect(function(v)
        self:SetupCoin(v);
    end)

    for _, v in pairs(CollectionService:GetTagged("Donation")) do
        self:SetupCoin(v);
    end
end

return CoinsUI

