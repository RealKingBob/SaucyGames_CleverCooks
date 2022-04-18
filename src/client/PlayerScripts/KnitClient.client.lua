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

Knit.Shared = ReplicatedStorage.Common
Knit.ReplicatedModules = Knit.Shared.Modules;

Knit.Config = require(Knit.ReplicatedModules.Config);

Knit.ReplicatedAssets = Knit.Shared.Assets;
Knit.ReplicatedMaps = Knit.Shared.Maps;
Knit.ReplicatedEnvironment = Knit.Shared.Environment;
Knit.ReplicatedServices = Knit.Shared.Services;

----- Loaded Modules -----
local Tropical = require(Knit.ReplicatedEnvironment.Tropical)
local Candyland = require(Knit.ReplicatedEnvironment.Candyland)
local Winterland = require(Knit.ReplicatedEnvironment.Winterland)
local Wipeout = require(Knit.ReplicatedEnvironment.Wipeout)
local Lobby = require(Knit.ReplicatedEnvironment.Lobby)

local hitSoundId = "rbxassetid://8618186140"

require(Knit.Controllers.Core.CameraController)

Knit.AddControllersDeep(Knit.Controllers)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local KnitClient = Knit.CreateController { Name = "KnitClient" }

function KnitClient:KnitInit()
	local bubbleChatSettings = {
		AdorneeName = "PHAttachment",
		LocalPlayerStudsOffset = Vector3.new(0,1,2);
	}

	ChatService:SetBubbleChatSettings(bubbleChatSettings)
end

task.spawn(function()
	local c local player = Players.LocalPlayer local MIT = 5 local function oS(dT) if dT > MIT then if not CollectionService:HasTag(player, "Alive") then return end local Character = player.Character or player.CharacterAdded:Wait() if Character then local Humanoid = Character:WaitForChild("Humanoid"); Humanoid.Health = -1; end end end c = RunService.RenderStepped:Connect(oS)
end)

Knit.Start():andThen(function()
	print("Client started");	
end):catch(warn)

local GameService = Knit.GetService("GameService")
local ResultsUI = Knit.GetController("ResultsUI")
local LightingController = Knit.GetController("LightingController")

GameService.SetLighting:Connect(function(lightingData)
	LightingController:SetLighting(lightingData)
end)

GameService.ResultSignal:Connect(function(resultsData)
	GameService:GetPreviousMode():andThen(function(gameMode) -- When initialized complete, request inventory data
		ResultsUI:UpdateResults(resultsData, gameMode);
	end)
	ResultsUI:OpenView("Results");
end)

GameService.SetEnvironmentSignal:Connect(function(MapObject)
	if tostring(MapObject) == "Lobby" then
		Lobby:SetClientEnvironment(MapObject)
	elseif tostring(MapObject) == "Tropical" then
		Tropical:SetClientEnvironment(MapObject)
	elseif tostring(MapObject) == "Candyland" then
		Candyland:SetClientEnvironment(MapObject)
	elseif tostring(MapObject) == "Winterland" then
		Winterland:SetClientEnvironment(MapObject)
	elseif tostring(MapObject) == "Wipeout" then
		Wipeout:SetClientEnvironment(MapObject)
	end
end)

GameService.TrapControl:Connect(function(Map, Trap, Command, targetObject)
	local MapFolder = Knit.ReplicatedMaps:FindFirstChild(tostring(Map));
	if MapFolder then
		local TrapModule = MapFolder.Traps:FindFirstChild(tostring(Trap));
		print("TC", TrapModule, Map, Trap, Command, targetObject)
		if TrapModule then
			local RTrapModule = require(TrapModule)
			if Command == "OnStart" then
				RTrapModule:OnStart()
			elseif Command == "Activate" then
				RTrapModule:Activate(targetObject)
				local instance = targetObject
				--and self.hasStarted == false
				if RTrapModule.Activated == true and instance:GetAttribute("Enabled") == true then
					--print("[".. tostring(self.Trap) .."]: Activated")
					task.spawn(function()
						local newHitSound = Instance.new("Sound")
						newHitSound.SoundId = hitSoundId;
						newHitSound.PlayOnRemove = true;
						newHitSound.Parent = workspace;
						newHitSound:Destroy();
					end)
					--self.hasStarted = true;
					instance:SetAttribute("Enabled", false)
					if instance:FindFirstChild("Impact") then
						instance:FindFirstChild("Impact"):FindFirstChild("Shockwave"):Emit(5)
						instance:FindFirstChild("Impact"):FindFirstChild("Sparks"):Emit(45)
					end
					if instance:FindFirstChild("Beams") then
						for _, v in pairs(instance:FindFirstChild("Beams"):GetChildren()) do
							if v:IsA("Beam") then
								v.Enabled = false
							end
						end
						if instance:FindFirstChild("Centre") then
							instance:FindFirstChild("Centre").ParticleEmitter.Enabled = false
						end
					end
					task.delay(RTrapModule.Cooldown, function()
						instance.Color = Color3.fromRGB(161, 160, 162)
						if instance:FindFirstChild("Beams") then
							for _, v in pairs(instance:FindFirstChild("Beams"):GetChildren()) do
								if v:IsA("Beam") then
									v.Enabled = true
								end
							end
							if instance:FindFirstChild("Centre") then
								instance:FindFirstChild("Centre").ParticleEmitter.Enabled = true
							end
						end
					end)
					instance.Material = Enum.Material.Neon
					task.wait(.1)
					TweenService:Create(instance,TweenInfo.new(.2),{
						Color = Color3.fromRGB(50, 50, 50),
					}):Play()
					task.wait(.2)
					instance.Material = Enum.Material.Plastic
					instance.Color = Color3.fromRGB(50, 50, 50)
				end
			end
		end
	end
end)

local CrateService = Knit.GetService("CrateService");
local ShopDailyUI = Knit.GetController("ShopDailyUI")

CrateService.SendDailyItems:Connect(function(Data)
	ShopDailyUI:Update(Data);
end)

local DataService = Knit.GetService("DataService")
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
end)

local PartyService = Knit.GetService("PartyService")
local PartyUI = Knit.GetController("PartyUI")

PartyService.SendInvite:Connect(function(InviteOwner)
	print(InviteOwner)
	PartyUI:PendInvite(InviteOwner);
end)

PartyService.JoinParty:Connect(function(PartyInfo)
	PartyUI:UpdateMemberList(PartyInfo);
	PartyUI:RefreshPartyMembers();
end)

PartyService.LeaveParty:Connect(function(PartyInfo)
	PartyUI:UpdateMemberList(PartyInfo);
	PartyUI:RefreshPartyMembers();
end)

local NotificationUI = Knit.GetController("NotificationUI")

DataService.Notification:Connect(function(title, desc, buttonName)
	NotificationUI:OpenView(title, desc, buttonName)
end)

DataService.WelcomeMessage:Connect(function()
	NotificationUI:DisplayWelcome()
end)

local LikeCounterService = Knit.GetService("LikeCounterService")
local LikeCounterController = Knit.GetController("LikeCounterController")

LikeCounterService:GetLikes():andThen(function(Payload)
	LikeCounterController:Update(Payload);
end)

LikeCounterService.CounterSignal:Connect(function(Payload)
	LikeCounterController:Update(Payload);
end)