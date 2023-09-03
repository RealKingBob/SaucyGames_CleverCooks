----- Services -----
local Players = game:GetService("Players") 
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(script.Parent.ProfileService)

--local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")
--local giftHistoryStore = DataStoreService:GetDataStore("GiftHistory")
local ThemeData = workspace:GetAttribute("Theme")

local SETTINGS = {
    StatsTemplate = {	
        Tutorial = false,
		PlayerInfo = {
			Currency = {
                French = 0
            }, -- User current currency
			Level = 0, -- User current level
			EXP = 0, -- User experience to level up

			TotalWins = 0, -- Num of wins a user has
            TotalLosses = 0, -- Num of losses a user has
            TotalKills = 0, -- Total kills that the hunter has killed

            DailyItemsBought = 0, -- Num of daily items bought in daily store
			CurrencyBought = 0, -- Coin amount a user has bought
            LifeTimeCurrency = 0, -- counts how many Currency a user has had overall

            MostDays = 0, -- Most days the user survived for
            LatestDays = 0, -- Most recent days the user survived for

			Wins = 0, -- Num of wins a user has a duck
			WinStreak = 0, -- Win streak a user has

			CratesOpened = 0, -- Num of crates a user has opened

            FoodCooked = 0,
            FoodsPickedUp = 0,
            IngredientsPickedUp = 0,

            RecentFoodMade = false,
            RecentFoodPickUp = false,
            RecentIngredientPickUp = false,

			LogInTimes = 0, -- Num of times a player has logged on this game
			SecondsPlayed = 0, -- Num of seconds a user has played the game
            
			MissionInfo = false, -- {lastOnline, streak}
			DailyShopInfo = false, -- {lastOnline, streak}
		}, -- All player info stored here
		DailyShopItems = {}, -- Specific daily shop items a user has ingame
		Missions = {
            Daily = {},
            Weekly = {},
            Event = {
                French = {},
            }
        }, -- Specific missions a user has ingame
        Boosts = {}, -- Specific boosts a user owns
        GamepassOwned = {}, -- Specific gamepasses a user owns
        CratesOpened = {}, -- Specific crates opened by a user
        RecipesCooked = {}, -- Specific foods cooked and delivered by a user
        Battlepasses = {}, -- Battlepasses the user participated / completed
		Inventory = {
            CurrentDeathEffect = "Default",
			CurrentBoosterEffect = "Default Boost",
			CurrentHat = "Default Hat",
			CurrentEmote = "Default",
			Boosters = {},
			Hats = {
                ["Default Hat"] = {
                    Quantity = 1,
                    Rarity = 1,
                }
            },
            BoosterEffects = {
                ["Default Boost"] = {
                    Quantity = 1,
                    Rarity = 1,
                }
            },
			Emotes = {
                Default = {
                    Quantity = 1,
                    Rarity = 1,
                }
            },
			Effects = {
                Default = {
                    Quantity = 1,
                    Rarity = 1,
                }
            },
            DeathEffects = {
                Default = {
                    Quantity = 1,
                    Rarity = 1,
                }
            },
		}, -- Inventory of the user
        SkillUpgrades = {
            French = { -- French Kitchen
                ["Jump Amount"] = 1, -- 1x jump boost
                ["Cook Speed"] = 1, -- 1x speed
                ["Boost Stamina"] = 1, -- 100%
                ["Recipe Luck"] = 1, -- Stages to increasing chances on getting hard recipes
                ["Extra Health"] = 1, -- 100 health
                ["Multitasking"] = 1, -- Cook multiple foods
                ["Cooking Perfection"] = 1, -- automatically cooks your food to perfection
            },
		}, -- Player Skill Upgrades
	},

    Products = { -- developer_product_id = function(profile)
		-- COIN PURCHASES --
		[00000000000] = function(ownerprofile, profile) -- 99
            profile.Data.PlayerInfo.Currency[ThemeData] += 1000
            if ownerprofile.Data.PlayerInfo.CurrencyBought == nil then ownerprofile.Data.PlayerInfo.CurrencyBought = 0 end
            ownerprofile.Data.PlayerInfo.CurrencyBought += 1000
            updateClientCurrency(profile, 1000, ThemeData)
            updateClientDonations(ownerprofile)
        end,
        [00000000000] = function(ownerprofile, profile) -- 199
            profile.Data.PlayerInfo.Currency[ThemeData] += 2400
            if ownerprofile.Data.PlayerInfo.CurrencyBought == nil then ownerprofile.Data.PlayerInfo.CurrencyBought = 0 end
            ownerprofile.Data.PlayerInfo.CurrencyBought += 2400
            updateClientCurrency(profile, 2400, ThemeData)
            updateClientDonations(ownerprofile)
        end,
        [00000000000] = function(ownerprofile, profile) -- 499
            profile.Data.PlayerInfo.Currency[ThemeData] += 6500
            if ownerprofile.Data.PlayerInfo.CurrencyBought == nil then ownerprofile.Data.PlayerInfo.CurrencyBought = 0 end
            ownerprofile.Data.PlayerInfo.CurrencyBought += 6500
            updateClientCurrency(profile, 6500, ThemeData)
            updateClientDonations(ownerprofile)
        end,
        [00000000000] = function(ownerprofile, profile) -- 999
            profile.Data.PlayerInfo.Currency[ThemeData] += 14000
            if ownerprofile.Data.PlayerInfo.CurrencyBought == nil then ownerprofile.Data.PlayerInfo.CurrencyBought = 0 end
            ownerprofile.Data.PlayerInfo.CurrencyBought += 14000
            updateClientCurrency(profile, 14000, ThemeData)
            updateClientDonations(ownerprofile)
        end,
    },

    Gamepasses = { -- developer_product_id = function(profile)
		-- VIP --
        [00000000] = function(ownerprofile, profile)
            if profile.Data.GamepassOwned == nil then profile.Data.GamepassOwned = {} end
            profile.Data.GamepassOwned["VIP"] = true
            updateClientGamepasses(profile)

            if profile.Data.Inventory.DuckSkins["VIP Duck"] == nil then
                AddItem(profile, "VIP Duck", "Skins")
                profile.Data.PlayerInfo.Currency[ThemeData] += 1000
                updateClientCurrency(profile, 1000, ThemeData)
            end
        end,
    },

    PurchaseIdLog = 30, -- Store this amount of purchase id's in MetaTags
        -- This value must be reasonably big enough so the player would not be able
        -- to purchase products faster than individual purchases can be confirmed.
        -- Anything beyond 30 should be good enough.
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData_2",
	SETTINGS.StatsTemplate
)

local StatsProfiles = {}
local RecentGifts = {}
local PlayerServerGifts = {}

local DataService = Knit.CreateService {
	Name = "DataService",
	Client = {
		LevelSignal = Knit.CreateSignal(),
		CurrencySignal = Knit.CreateSignal(),
        DonationSignal = Knit.CreateSignal(),
        GamepassSignal = Knit.CreateSignal(),
        RequestCurrencyignal = Knit.CreateSignal(),

        GiveCurrency = Knit.CreateSignal(),

        ServerMessage = Knit.CreateSignal(),
        WelcomeMessage = Knit.CreateSignal(),
	}
}

local Signal = require(Knit.Util.Signal)
DataService.RequestDailyShop = Signal.new()

----- Private Functions -----

function updateClientCurrency(profile, coinAmount, theme)
    local Player = DataService:GetPlayer(profile)
    if Player then
        DataService.Client.Currencyignal:Fire(Player, profile.Data.PlayerInfo.Currency[theme], coinAmount)
    end
end

function updateClientDonations(profile)
    local Player = DataService:GetPlayer(profile)
    if Player then
        DataService.Client.DonationSignal:Fire(Player, profile.Data.PlayerInfo.CurrencyBought)
    end
end

function updateClientGamepasses(profile)
    local Player = DataService:GetPlayer(profile)
    if Player then
        DataService.Client.GamepassSignal:Fire(Player, profile.Data.GamepassOwned)
    end
end

function AddItem(profile, itemName, crateType)
    local Player = DataService:GetPlayer(profile)
    if Player then
        local InventoryService = Knit.GetService("InventoryService")
        InventoryService.AddItem(Player, itemName, crateType)
        InventoryService.InventoryChanged(Player)
    end
end

function AddItemPlayer(Player, itemName, crateType)
    if Player then
        local InventoryService = Knit.GetService("InventoryService")
        InventoryService.AddItem(Player, itemName, crateType)
        InventoryService.InventoryChanged(Player)
    end
end

local function PreloadData(Player, Profile, ProfileData)
	--DataService.RequestDailyShop:Fire(Player)
    local TEST_VOICE_CHAT_PLACE_ID = 8792750286
    local TEST_BIG_SERVER_PLACE_ID = 8793381822
    local TEST_SERVER_PLACE_ID = 8303278706

    --[[if game.PlaceId == TEST_VOICE_CHAT_PLACE_ID or 
	game.PlaceId == TEST_BIG_SERVER_PLACE_ID or 
	game.PlaceId == TEST_SERVER_PLACE_ID then
		if Config.WHITELIST == true and Player:IsInGroup(13585944) then
			Profile.Data.PlayerInfo.Currency[ThemeData] = 1000000
		end
	end]]
    print(Profile.Data.PlayerInfo.Currency[ThemeData])
    Profile.Data.PlayerInfo.Currency[ThemeData] = 1000000
    if Player then
        DataService.Client.CurrencySignal:Fire(Player, Profile.Data.PlayerInfo.Currency[ThemeData], nil, nil, true)
    end

    if Profile.Data.PlayerInfo.SecondsPlayed < 30 then
        DataService.Client.WelcomeMessage:Fire(Player)
    end

    local success, playerGifts = pcall(function()
        return false --giftHistoryStore:GetAsync("User_"..Player.UserId)
    end)

    if success then
        --print("playerGifts", playerGifts)
        PlayerServerGifts[Player.UserId] = playerGifts
    end
end

local function OnPlayerAdded(Player)
	local PlayerProfile = ProfileStore:LoadProfileAsync(
		"Player_".. Player.UserId
	)

	if PlayerProfile then
        PlayerProfile:AddUserId(Player.UserId) -- GDPR compliance
        --PlayerProfile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
        PlayerProfile:ListenToRelease(function()
            StatsProfiles[Player] = nil
            -- The profile could've been loaded on another Roblox server:
            Player:Kick()
        end)
	
	    if Player:IsDescendantOf(Players) then
			StatsProfiles[Player] = PlayerProfile
			PreloadData(Player, StatsProfiles[Player], StatsProfiles[Player].Data)
		else
			print(Player.Name .. "'s profile has been released!")
            PlayerProfile:Release()
		end
	else
		Player:Kick("Kicked to prevent data corruption... | Unable to retieve data for "..Player.Name.." | Please rejoin")
	end
end

local function GetPlayerProfileAsync(player) --> [Profile] / nil
    -- Yields until a Profile linked to a player is loaded or the player leaves
    local profile = StatsProfiles[player]
    while profile == nil and player:IsDescendantOf(Players) == true do
        task.wait()
        profile = StatsProfiles[player]
    end
    return profile
end

local function GrantProduct(player, targetPlayer, product_id)
    -- We shouldn't yield during the product granting process!
    local playerprofile, targetprofile = StatsProfiles[player], StatsProfiles[targetPlayer]
    local product_function = SETTINGS.Products[product_id]
    if product_function ~= nil then
        if player ~= targetPlayer and targetPlayer ~= nil then
            if PlayerServerGifts[player.UserId] == nil then
                PlayerServerGifts[player.UserId] = {}
            end

            product_function(playerprofile, targetprofile)
    
            table.insert(PlayerServerGifts[player.UserId],
                {
                    Player = player.UserId, 
                    TargetPlayer = targetPlayer.UserId,
                    Timestamp = os.time(),
                    ItemId = product_id,
                    IsGamepass = false,
                }
            )
            Knit.GetService("NotificationService").Client.ServerMessage:FireAll("[SERVER]: ".. player.Name .." gifted ".. targetPlayer.Name .." an item!")
        else
            product_function(playerprofile, playerprofile)
        end
        Knit.GetService("NotificationService").Client.Notification:Fire(player, "Notice!", "Purchase successful! Thanks for buying! :]", "OK")
        return true
    else
        warn("ProductId " .. tostring(product_id) .. " has not been defined in Products table")
        return nil
    end
end

local function GrantGamepass(player, targetPlayer, gamepass_id)
    -- We shouldn't yield during the product granting process!
    local playerprofile, targetprofile = StatsProfiles[player], StatsProfiles[targetPlayer]
    local gamepass_function = SETTINGS.Gamepasses[gamepass_id]
    if gamepass_function ~= nil then
        if player ~= targetPlayer and targetPlayer ~= nil then
            gamepass_function(playerprofile, targetprofile)

            if PlayerServerGifts[player.UserId] == nil then
                PlayerServerGifts[player.UserId] = {}
            end
    
            table.insert(PlayerServerGifts[player.UserId],
                {
                    Player = player.UserId, 
                    TargetPlayer = targetPlayer.UserId,
                    Timestamp = os.time(),
                    ItemId = gamepass_id,
                    IsGamepass = true,
                }
            )
            DataService.Client.ServerMessage:FireAll("[SERVER]: ".. player.Name .." gifted ".. targetPlayer.Name .." an item!")
        else
            gamepass_function(playerprofile, playerprofile)
        end
        DataService.Client.Notification:Fire(player, "Notice!", "Purchase successful! Thanks for buying! :]", "OK")
        return true
    else
        warn("GamepassId " .. tostring(gamepass_id) .. " has not been defined in Gamepass table")
        return nil
    end
end

function PurchaseIdCheckAsync(profile, profile_id, product_id,  purchase_id, grant_product_callback) --> Enum.ProductPurchaseDecision
    -- Yields until the purchase_id is confirmed to be saved to the profile or the profile is released

    if profile:IsActive() ~= true then

        return Enum.ProductPurchaseDecision.NotProcessedYet

    else
        --- Loloris code
        local meta_data = profile.MetaData

        local local_purchase_ids = meta_data.MetaTags.ProfilePurchaseIds
        if local_purchase_ids == nil then
            local_purchase_ids = {}
            meta_data.MetaTags.ProfilePurchaseIds = local_purchase_ids
        end

        -- Granting product if not received:

        if table.find(local_purchase_ids, purchase_id) == nil then
            while #local_purchase_ids >= SETTINGS.PurchaseIdLog do
                table.remove(local_purchase_ids, 1)
            end
            table.insert(local_purchase_ids, purchase_id)
            task.spawn(grant_product_callback)
        end

        -- Waiting until the purchase is confirmed to be saved:

        local result = nil

        local function check_latest_meta_tags()
            local saved_purchase_ids = meta_data.MetaTagsLatest.ProfilePurchaseIds
            if saved_purchase_ids ~= nil and table.find(saved_purchase_ids, purchase_id) ~= nil then
                result = Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end

        check_latest_meta_tags()

        local meta_tags_connection = profile.MetaTagsUpdated:Connect(function()
            check_latest_meta_tags()
            -- When MetaTagsUpdated fires after profile release:
            if profile:IsActive() == false and result == nil then
                result = Enum.ProductPurchaseDecision.NotProcessedYet
            end
        end)

        while result == nil do
            task.wait()
        end

        meta_tags_connection:Disconnect()

        return result

    end

end

local function ProcessReceipt(receipt_info)

    local player = Players:GetPlayerByUserId(receipt_info.PlayerId)

    if player == nil then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local profile = GetPlayerProfileAsync(player)

    if profile ~= nil then

        return PurchaseIdCheckAsync(
            profile,
            receipt_info.PlayerId,
            receipt_info.ProductId,
            receipt_info.PurchaseId,
            function()
                GrantProduct(player, RecentGifts[player], receipt_info.ProductId)
            end
        )
    else
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

-- Function to handle a completed prompt and purchase
local function onPromptGamePassPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess == true and SETTINGS.Gamepasses[purchasedPassID] ~= nil then
		print(player.Name .. " purchased the game pass with ID " .. purchasedPassID)
		GrantGamepass(player, RecentGifts[player], purchasedPassID)
	end
end

-- Function to handle a completed prompt and purchase
local function onPromptPurchaseFinished(player, purchasedProductID, purchaseSuccess)
		--print("NOTIFICATION", purchaseSuccess, SETTINGS.Gamepasses[purchasedProductID], SETTINGS.Products[purchasedProductID])
	if purchaseSuccess == true and (SETTINGS.Gamepasses[purchasedProductID] ~= nil or SETTINGS.Products[purchasedProductID] ~= nil)  then
		print(player.Name .. " purchased the product with ID " .. purchasedProductID)
		--print("NOTIFICATION")
	end
end

----- Initialize -----

function DataService:GetCurrency(player, theme)
    local Profile = self:GetProfile(player)
    local tries = 0

    if not Profile then
        repeat
            task.wait(0.001)
            tries += 1
        until Profile or tries == 20000
    end

    if Profile then
		return Profile.Data.PlayerInfo.Currency[theme], Profile.Data.SkillUpgrades[theme]
	end
    return 0
end

local reset = {}

function DataService:GiveCurrency(player, Amount, disableEffect, Percentage)

    --print("give", player, Amount)

    local profile = StatsProfiles[player]

	if not profile then
		return
	end

    --[[if not reset[player] then
        reset[player] = true
        profile.Data.PlayerInfo.Currency[ThemeData] = 0
    end]]

    if profile.Data.PlayerInfo.Currency[ThemeData] == nil then
        profile.Data.PlayerInfo.Currency[ThemeData] = 0
    end

    profile.Data.PlayerInfo.Currency[ThemeData] = profile.Data.PlayerInfo.Currency[ThemeData] + Amount

    if player then
        if disableEffect == nil then
            DataService.Client.CurrencySignal:Fire(player, profile.Data.PlayerInfo.Currency[ThemeData], Amount, Percentage, true)
        else
            DataService.Client.CurrencySignal:Fire(player, profile.Data.PlayerInfo.Currency[ThemeData], Amount, Percentage, disableEffect)
        end
    end

end

function DataService:PurchaseProduct(player, targetPlayer)
    --RecentGifts[player] = targetPlayer
    if RecentGifts[player] ~= nil then
        return true
    end
    return false
end

function DataService.Client:GetCurrency(Player, Theme)
	-- We can just call our other method from here:
    return self.Server:GetCurrency(Player, Theme)
end

function DataService.Client:PurchaseProduct(Player, TargetPlayer)
    RecentGifts[Player] = TargetPlayer
    if RecentGifts[Player] ~= nil then
        return {
            TargetPlayer = RecentGifts[Player],
            HasPlayer = true,
        }
    end
    return {
        TargetPlayer = nil,
        HasPlayer = false,
    }
end

function DataService.Client:GetCurrencyBought(Player)
	local StatsProfile = StatsProfiles[Player]

	if StatsProfile then
		return StatsProfile.Data.PlayerInfo.CurrencyBought
	end
end

function DataService.Client:GetGamepass(Player)
	local StatsProfile = StatsProfiles[Player]

	if StatsProfile then
		return StatsProfile.Data.GamepassOwned
	end
end


function DataService.Client:GetProfile(Player)
    local profile = GetPlayerProfileAsync(Player)
    return profile.Data
    --return self.Server:GetProfile(Player).Data
end

function DataService:GetProfile(Player)
    if not Player then return nil end
	local Profile = StatsProfiles[Player] or GetPlayerProfileAsync(Player)

	if Profile then
		return Profile
	end
end

function DataService:GetPlayer(Profile)
	for Player, _profile in next, StatsProfiles do
		if _profile == Profile then
			return Player
		end
	end
end

function DataService:KnitStart()
	
end

function DataService:KnitInit()
    print("[SERVICE]: DataService Initialized")
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(OnPlayerAdded)(player)
    end
    
    MarketplaceService.ProcessReceipt = ProcessReceipt
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPromptGamePassPurchaseFinished)
    MarketplaceService.PromptPurchaseFinished:Connect(onPromptPurchaseFinished)
    
    --[[self.Client.GiveCurrency:Connect(function(player, amount)
        self:GiveCurrency(player, amount)
    end)]]

	Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(function(Player)
        local PlayerProfile = StatsProfiles[Player]

        if PlayerProfile ~= nil then
            PlayerProfile:Release()
            print(Player.Name .. "'s profile has been released!")
        end
        --Knit.StatTrackService:StopTracking(Player)
        
        if PlayerServerGifts[Player.UserId] then
            print(PlayerServerGifts[Player.UserId])
            local success, errorMessage = pcall(function()
                --giftHistoryStore:SetAsync("User_"..Player.UserId, PlayerServerGifts[Player.UserId])
            end)
            if not success then
                print(errorMessage)
            end
            PlayerServerGifts[Player.UserId] = nil
        end
    end)
end


return DataService