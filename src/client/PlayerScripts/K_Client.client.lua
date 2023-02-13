--[[
	Name: Knit Client [V1]
	Creator: Real_KingBob
	Made in: 12/16/21
	Description: Handles all the knit client initialization
]]

----- Services -----
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ChatService = game:GetService("Chat")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Loaded Modules -----
local CollectionService = game:GetService("CollectionService")
local ThemeData = workspace:GetAttribute("Theme")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

----- Knit -----
Knit.PlayerScripts = Knit.Player:WaitForChild("PlayerScripts")

Knit.Modules = Knit.PlayerScripts:WaitForChild("Modules");
Knit.Controllers = Knit.PlayerScripts:WaitForChild("Controllers")

Knit.Shared = ReplicatedStorage.Common;
Knit.ReplicatedAssets = Knit.Shared.Assets;
Knit.ReplicatedModules = Knit.Shared.Modules;
Knit.GamePlayers = ReplicatedStorage.Players;
Knit.GameLibrary = ReplicatedStorage.GameLibrary;
Knit.Spawnables = ReplicatedStorage.Spawnables;

Knit.ReplicatedHatSkins = Knit.ReplicatedAssets.HatSkins;
Knit.ReplicatedBoosterEffects = Knit.ReplicatedAssets.BoosterEffects;

Knit.Config = require(Knit.ReplicatedModules.Config);

----- Loaded Modules -----

Knit.AddControllersDeep(Knit.Controllers)
local UIStrokeAdjuster = require(Knit.Modules.UIStrokeStyle)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)

local KnitClient = Knit.CreateController { Name = "KnitClient" }

function KnitClient:KnitInit()

end

Knit.Start():andThen(function()
	print("Client started");	
end):catch(warn)

task.spawn(function()
	Players.LocalPlayer.PlayerGui:WaitForChild("KCoreUI").Enabled = false;
end)

local DataService = Knit.GetService("DataService")
local CurrencyCounterUI = Knit.GetController("CurrencyCounterUI")

task.spawn(function()
	task.wait(5)
	DataService:GetCurrency(ThemeData):andThen(function(Coins)
		--print("AAAAA", Coins)
		CurrencyCounterUI:Update(Coins);
	end)
end)

DataService.CurrencySignal:Connect(function(Coins, amount, percentage, disableEffect)
	if disableEffect then
		--print('UPDATED COINS', Coins)
		CurrencyCounterUI:Update(Coins);
	else
		CurrencyCounterUI:CollectCheese(Coins, amount, percentage);
	end;
end)

local CookingService = Knit.GetService("CookingService");
local CookingUI = Knit.GetController("CookingUI");

CookingService.Cook:Connect(function(Status, RecipeName, Pan, CookingPercentages)
	--print("CLIENT COOK", Status, RecipeName, Pan, CookingPercentages)
	if Status == "Initialize" then
		CookingUI:StartCooking(RecipeName, Pan)
	elseif Status == "CookUpdate" then
		CookingUI:UpdatePanCook(Pan, CookingPercentages)
	elseif Status == "Destroy" then
		CookingUI:DestroyUI(Pan)
	end
end)

CookingService.Deliver:Connect(function(RecipeName, DeliveryZone, DeliverTime)
	--print("CLIENT DELIVER", RecipeName, DeliveryZone, DeliverTime)
	CookingUI:StartDelivering(RecipeName, DeliveryZone, DeliverTime)
end)

CookingService.PickUp:Connect(function(foodInfo)
	--print("FOOOD",food)
	if foodInfo.Type == "DestroyFood" then
		if foodInfo.Data then foodInfo.Data:Destroy() end;
	end
end)

CookingService.ParticlesSpawn:Connect(function(food, particleName)

	if particleName == "CookedParticle" then
		CookingUI:SpawnCookedParticles(food)
	end
	
end)

local NotificationService = Knit.GetService("NotificationService");
local NotificationUI = Knit.GetController("NotificationUI");
local PlayerController = Knit.GetController("PlayerController");

NotificationService.NotifyMessage:Connect(function(messageText, typeWriterEffect)
	--print("BOROSADA", messageText, typeWriterEffect)
	NotificationUI:Message(messageText, typeWriterEffect);
end)

NotificationService.NotifyLargeMessage:Connect(function(messageText, typeWriterEffect)
	NotificationUI:LargeMessage(messageText, typeWriterEffect);
end)

NotificationService.Alert:Connect(function()
	PlayerController:WarnExclaim();
end)

DataService.Notification:Connect(function(title, desc, buttonName)
	NotificationUI:OpenView(title, desc, buttonName)
end)

local DeathEffectService = Knit.GetService("DeathEffectService");

DeathEffectService.ClientDeath:Connect(function(Character)
	PlayerController:DeathEffect(Character);
end)

--[[local DataService = Knit.GetService("DataService")
local CoinCounterUI = Knit.GetController("CoinCounterUI")
local CoinsUI = Knit.GetController("CoinsUI")

task.spawn(function()
	task.wait(5)
	DataService:GetCoins():andThen(function(Coins)
		CoinCounterUI:Update(Coins);
	end)
	
	DataService:GetCoinsBought():andThen(function(Coins) -- REMOTE FUNCTION
		CoinsUI:Update(Coins);
	end)
end)

DataService.DonationSignal:Connect(function(amount)
	CoinsUI:Update(amount);
end)

DataService.CoinSignal:Connect(function(Coins, amount, disableEffect)
	if disableEffect then
		CoinCounterUI:Update(Coins);
	else
		CoinCounterUI:CollectCoins(Coins, amount);
	end;
end)

DataService.ServerMessage:Connect(function(message)
	game.StarterGui:SetCore("ChatMakeSystemMessage", 
		{
			Text = message, 
			Color = Color3.fromRGB(241, 199, 8),
			Font = Enum.Font.SourceSansBold,
			TextSize = 18,
		}
	)
end)]]
