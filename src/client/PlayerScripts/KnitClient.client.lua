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
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

----- Knit -----
Knit.PlayerScripts = Knit.Player:WaitForChild("PlayerScripts")

Knit.Modules = Knit.PlayerScripts:WaitForChild("Modules");
Knit.Controllers = Knit.PlayerScripts:WaitForChild("Controllers")

Knit.Shared = ReplicatedStorage.Common;
Knit.ReplicatedAssets = Knit.Shared.Assets;
Knit.ReplicatedModules = Knit.Shared.Modules;
Knit.GameLibrary = ReplicatedStorage.GameLibrary;
Knit.Spawnables = ReplicatedStorage.Spawnables;

Knit.ReplicatedHatSkins = Knit.ReplicatedAssets.HatSkins;

Knit.Config = require(Knit.ReplicatedModules.Config);

----- Loaded Modules -----

Knit.AddControllersDeep(Knit.Controllers)
local UIStrokeAdjuster = require(Knit.Modules.UIStrokeStyle)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local KnitClient = Knit.CreateController { Name = "KnitClient" }

function KnitClient:KnitInit()

end

Knit.Start():andThen(function()
	print("Client started");	
end):catch(warn)

local DataService = Knit.GetService("DataService")
local CurrencyCounterUI = Knit.GetController("CurrencyCounterUI")

task.spawn(function()
	task.wait(5)
	DataService:GetCurrency():andThen(function(Coins)
		CurrencyCounterUI:Update(Coins);
	end)
end)

DataService.CurrencySignal:Connect(function(Coins, amount, disableEffect)
	if disableEffect then
		CurrencyCounterUI:Update(Coins);
	else
		CurrencyCounterUI:CollectCheese(Coins, amount);
	end;
end)

local CookingService = Knit.GetService("CookingService");
local CookingUI = Knit.GetController("CookingUI");

CookingService.Cook:Connect(function(RecipeName, Pan, CookingTime)
	print("CLIENT COOK",RecipeName,Pan, CookingTime)
	CookingUI:StartCooking(RecipeName,Pan, CookingTime)
end)

CookingService.ParticlesSpawn:Connect(function(food, particleName)

	if particleName == "CookedParticle" then
		CookingUI:SpawnCookedParticles(food)
	end
	
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
