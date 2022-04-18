local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local GamepassUI = Knit.CreateController { Name = "GamepassUI" }

--//Services
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Imports
local CommaValue;
local NumberUtil;
local TweenModule;
local YouDonated;

--//Const
local plr = game.Players.LocalPlayer;
local PlayerGui = plr:WaitForChild("PlayerGui");
local GamepassPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("Gamepassboard");
local GamepassContainer = PlayerGui

local ChangeInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);

local BundleData = {
    ["Karl"] = {
        ["Name"] = "Karl Bundle",
        ["Description"] = "- Contains one duck: Karl\n- Extra 1200 bread",
        ["Image"] = "rbxassetid://8523423060",
        ["Limited"] = true,
        ["ProductId"] = 27310378,
        ["Amount"] = 199
    },
    ["VIP"] = {
        ["Name"] = "VIP Bundle",
        ["Description"] = "- Contains one duck: VIP Duck\n- Extra 1000 bread\n- 1.5x coin boost",
        ["Image"] = "rbxassetid://8523422860",
        ["Limited"] = false,
        ["ProductId"] = 26228902,
        ["Amount"] = 499
    },
}

--//Public Methods
function GamepassUI:UpdateGamepass()
    --print("Updated Gamepasss")
end

function GamepassUI:Update(currentGamepasss)
	--local TargetCoins = LastGamepasss;
	
	if currentGamepasss ~= nil then
		--[[local Tween = TweenModule.new(ChangeInfo, function(Alpha)
			--local CurrentCoins = math.floor(NumberUtil.Lerp(TargetCoins, currentGamepasss, Alpha));
			
			--LastGamepasss = CurrentCoins;
			
			--YouDonated.Text = ("You Donated: %s"):format(CommaValue(CurrentCoins));
		end)]]
		
		--Tween:Play();
	end
end

local function promptPurchase(ProductId)

	local hasPass = false
 
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, ProductId)
	end)
 
	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return
	end
 
	if hasPass then
        print("Owns")
		-- Player already owns the game pass; tell them somehow
	else
		-- Player does NOT own the game pass; prompt them to purchase
		MarketplaceService:PromptGamePassPurchase(plr, ProductId)
	end
end

function GamepassUI:SetupGamepass(Obj)
    local GamepassClone = GamepassPrefab:Clone() do
        GamepassClone.Adornee = Obj;
        GamepassClone.Name = "Gamepassboard";
        local ItemData = BundleData[Obj:GetAttribute("Type")]
        GamepassClone.Name = ItemData.Name;
        GamepassClone:WaitForChild("InfoSection"):WaitForChild("ImageInfo"):WaitForChild("Inner"):WaitForChild("ImageLabel").Image = ItemData.Image;
        GamepassClone:WaitForChild("InfoSection"):WaitForChild("ItemName").Text = ItemData.Name;
        GamepassClone:WaitForChild("InfoSection"):WaitForChild("ItemDesc").Text = ItemData.Description;
        GamepassClone:WaitForChild("BuySection"):WaitForChild("LimitedTime").Visible = ItemData.Limited;
        GamepassClone:WaitForChild("BuySection"):WaitForChild("Amount").Text = ("%s ROBUX"):format(CommaValue(ItemData.Amount));
        GamepassClone:WaitForChild("BuySection"):WaitForChild("BuyButton"):WaitForChild("ImageButton").Activated:Connect(function(InputType)
            if InputType.UserInputType == Enum.UserInputType.MouseButton1 or InputType.UserInputType == Enum.UserInputType.Touch then
                --print('CLICK')
                --MarketplaceService:PromptProductPurchase(plr, ItemData.ProductId);
                promptPurchase(ItemData.ProductId)
            end
        end)
        GamepassClone.Parent = GamepassContainer;
    end
end

function GamepassUI:KnitStart()
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
    NumberUtil = require(Knit.ReplicatedModules.NumberUtil);
    TweenModule = require(Knit.Modules.Tween);

    CollectionService:GetInstanceAddedSignal("Gamepass"):Connect(function(v)
        self:SetupGamepass(v);
    end)

    for _, v in pairs(CollectionService:GetTagged("Gamepass")) do
        self:SetupGamepass(v);
    end

    local DataService = Knit.GetService("DataService")

    DataService:GetGamepass():andThen(function(Gamepasss) -- REMOTE FUNCTION
        --self:Update(Gamepasss);
    end)

    DataService.GamepassSignal:Connect(function(amount)
        --self:Update(amount);
    end)
end

function GamepassUI:KnitInit()
    
end

return GamepassUI

