--[[
    Name: Crate Service [V2]
    By: Real_KingBob
	
    Methods:
    PlayerProfile = DataService:GetProfile(player).Data

    CrateTypes = "Ducks", "Effects", "Emotes"

    [REMOTE FUNCTION] CrateService.Client:GetDailyItems(player, crateId, crateType)
            -- NOTE: USE THIS FOR PURCHASES ON CRATE SECTIONS OR ITEMS IN CRATES
            -- Example return: {
                    ["DailyShopItems"] =  ▼  {
                       [1] =  ▼  {
                          ["id"] = 1,
                          ["itemInfo"] =  ▼  {
                             ["CrateId"] = 1,
                             ["DecalId"] = "rbxassetid://8249188730",
                             ["IndividualPrice"] = 300,
                             ["Name"] = "Turkey",
                             ["Rarity"] = 2
                          },
                          ["purchased"] = false,
                          ["timestamp"] = 1640136250
                       },
                       [2] =  ▶ {...},
                       [3] =  ▶ {...},
                       [4] =  ▶ {...}
                    },
                    ["TimeLeft"] = "18:41:12"
                }

    [REMOTE FUNCTION] CrateService.Client:PurchaseItem(player, name, crateType)
            -- NOTE: USE THIS FOR PURCHASES ON DAILY SHOP OR INDIVIDUAL ITEMS
            -- Example return: { 
                Player = player, 
                Status = "Success", -- "Success" or "Error"
                StatusString = "Successfully purchased item", -- Gives specific string for error or success
                ItemInfo = {
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
                    ["Model"] = Goose,
                    ["Name"] = "Default Duck",
                    ["Rarity"] = 1
                 } -- calls the getItemFromName method
            }

    [REMOTE FUNCTION] CrateService.Client:PurchaseCrate(player, crateId, crateType)
            -- NOTE: USE THIS FOR PURCHASES ON CRATE SECTIONS OR ITEMS IN CRATES
            -- Example return: { 
                Player = player, 
                Status = "Success", -- "Success" or "Error"
                StatusString = "Successfully purchased item", -- Gives specific string for error or success
                ItemInfo = {
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
                    ["Model"] = Goose,
                    ["Name"] = "Default Duck",
                    ["Rarity"] = 1
                 } -- calls the getItemFromName method
            }

    PlayerProfile.DailyShopItems Returns:
    {
        [1] =  ▼  {
            ["id"] = 1,
            ["itemInfo"] =  ▼  {
                ["CrateId"] = 1,
                ["DecalId"] = 8249188754,
                ["IndividualPrice"] = 300,
                ["Model"] = Pirate Duck,
                ["Name"] = "Pirate Duck",
                ["Rarity"] = 4
            },
            ["purchased"] = false,
            ["timestamp"] = 1639972342
        },
        [2] =  ▼  {
            ["id"] = 2,
            ["itemInfo"] =  ▶ {...},
            ["purchased"] = false,
            ["timestamp"] = 1639972342
        },
        [3] =  ▶ {...},
        [4] =  ▶ {...}
    } -- This is the 4 daily item shops being restarted etc

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableAPI = require(Knit.Modules.Table)

local TableUtil = require(Knit.Util.TableUtil);
local Signal = require(Knit.Util.Signal);
local Synced = require(Knit.ReplicatedModules.Synced);

local ThemeData = workspace:GetAttribute("Theme")

local crateStoreLogs = DataStoreService:GetDataStore("CrateStoreLogs")

local DataService = Knit.DataService;
local InventoryService = Knit.InventoryService;

local HatSkinsData = require(Knit.ReplicatedHatSkins);
local BoosterEffectsData = require(Knit.ReplicatedBoosterEffects);

local Rarities = Knit.ReplicatedRarities;

local CrateService = Knit.CreateService {
    Name = "CrateService";
    Client = {
        SuccessCrateSignal = Knit.CreateSignal(); -- When player successful purchases Item/crate

        InitializeDailyShop = Knit.CreateSignal(); -- request for daily items for player
        InitializeHourlyShop = Knit.CreateSignal(); -- request for hourly items for player

        SendDailyItems = Knit.CreateSignal(); -- updates daily items for player
        SendHourlyItems = Knit.CreateSignal(); -- updates hourly items for player
    };
    SavePlayerLastData = Signal.new();
}

local PlayerDailyProfiles = {};
local PlayerHourlyProfiles = {};
local PlayerLoginTimes = {};
local PlayerDailyItems = {};
local PlayerHourlyItems = {};
local PlayerServerPurchases = {};
local PlayerUpgradeDebounce = {}

local RarityWeights = Rarities.getRarityChances();
RarityWeights.Common = 100;

local ResetDailyShop = Knit.Config.RESET_DAILY_SHOP_DATA;
local DailyShopOffset = (60 * 60 * Knit.Config.DAILY_SHOP_OFFSET); 

local HourlyShopOffset = (60 * 60); 

Synced.init() -- Will make the request to google.com if it hasn't already.

local function GetItemsFromRarity(typeItem, rarityItem)
    local Items;
    if typeItem == "Hats" then
        Items = HatSkinsData.getHatSkinsFromRarity(rarityItem, true)
    elseif typeItem == "Booster Effects" then
        Items = BoosterEffectsData.getBoosterEffectsFromRarity(rarityItem, true)
    else
        Items = HatSkinsData.getHatSkinsFromRarity(5, true)
    end
    return Items
end

function CrateService:ResetShopItems(Player)
	if Player then
		local PlayerProfile = DataService:GetProfile(Player).Data;
		if PlayerProfile then
			PlayerProfile.DailyShopItems = {};
		end
	end
end

function CrateService.Client:PurchaseItem(player, name, crateType, dailyShopId)
    print("PurchaseItem", player, name, crateType, dailyShopId)
    return self.Server:PurchaseItem(player, name, crateType, dailyShopId)
end

function CrateService:ResetHourlyItems(Player)
	if Player then
		local PlayerProfile = DataService:GetProfile(Player).Data;
		if PlayerProfile then
			PlayerProfile.HourlyShopItems = {};
		end
	end
end

function CrateService:PurchaseItem(player, name, crateType, dailyShopId)
    --print(player, name, crateType, dailyShopId)
    if not player or not name or not crateType or not dailyShopId then return end;
    if PlayerUpgradeDebounce[player] or not PlayerDailyItems[player] then 
        return {
            Player = player, 
            Currency = nil,
            DailyData = nil,
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI0] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil
        }
    end

    PlayerUpgradeDebounce[player] = true;
    local PlayerCurrency, PlayerDailyData = nil, nil;
    local PlayerProfile = DataService:GetProfile(player)
    if PlayerProfile then
        PlayerCurrency = PlayerProfile.Data.PlayerInfo.Currency[ThemeData];
        PlayerDailyData = PlayerProfile.Data.DailyShopItems;
        PlayerDailyItems[player].DailyShopItems = PlayerDailyData
    end

    if not PlayerCurrency or not PlayerDailyData then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player,
            Currency = PlayerCurrency,
            DailyData = PlayerDailyItems[player],
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI1] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil;
        }
    end
    local selectedInfo, selectedItem = nil, nil

    if crateType == "Hats" then
        selectedInfo = HatSkinsData
    elseif crateType == "Booster Effects" then
        selectedInfo = BoosterEffectsData
    end

    if not selectedInfo then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player,
            Currency = PlayerCurrency,
            DailyData = PlayerDailyItems[player],
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI2] Failed to find crate type.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil;
        }
    end

    selectedItem = selectedInfo.getItemFromName(name)

    if not selectedItem then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player,
            Currency = PlayerCurrency,
            DailyData = PlayerDailyItems[player],
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI3] Failed to find item.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil;
        }
    end

    if PlayerCurrency < selectedInfo.getItemFromName(name).IndividualPrice then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player, 
            Currency = PlayerCurrency,
            DailyData = PlayerDailyItems[player],
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI4] Insufficient funds!",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil
        }
    end

    local ItemName = selectedItem.Key
    local PlayerInfo = PlayerProfile.Data.PlayerInfo
    local PlayerDailyShopItems = PlayerProfile.Data.DailyShopItems

    if not PlayerInfo or not PlayerDailyShopItems then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player,
            Currency = PlayerCurrency,
            DailyData = PlayerDailyItems[player],
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI5] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil;
        }
    end

    if PlayerDailyShopItems[dailyShopId].purchased == true 
    or InventoryService:HasItem(player, ItemName, crateType) == true then
        PlayerUpgradeDebounce[player] = nil;
        PlayerProfile.Data.DailyShopItems[dailyShopId].purchased = true
        PlayerProfile.Data.DailyShopItems[dailyShopId].hasItem = true
        return {
            Player = player,
            Currency = PlayerCurrency,
            DailyData = PlayerDailyItems[player],
            Status = "Error", 
            StatusString = "[ErrorCode CS-PI6] Item is already purchased.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil;
        }
    end

    if PlayerProfile.Data.PlayerInfo.DailyItemsBought == nil then
        PlayerProfile.Data.PlayerInfo.DailyItemsBought = 1;
    else
        PlayerProfile.Data.PlayerInfo.DailyItemsBought += 1;
    end

    if PlayerServerPurchases[player.UserId] == nil then
        PlayerServerPurchases[player.UserId] = {}
    end
    
    table.insert(PlayerServerPurchases[player.UserId],
        {
            ItemKey = selectedItem.Key, 
            ItemType = "Item",
            Timestamp = os.time(),
            ItemInfo = {
                Key = selectedItem.Key, 
                Name = selectedItem.Name, 
                Rarity = selectedItem.Rarity,
                CrateId = selectedItem.CrateId,
                DecalId = selectedItem.DecalId,
                IndividualPrice = selectedItem.IndividualPrice
            }
        }
    )

    PlayerCurrency = PlayerCurrency - selectedItem.IndividualPrice
    PlayerProfile.Data.PlayerInfo.Currency[ThemeData] = PlayerCurrency;
    DataService.Client.CurrencySignal:Fire(player, PlayerProfile.Data.PlayerInfo.Currency[ThemeData], nil, nil, true)

    InventoryService.AddItem(player, ItemName, crateType)
    PlayerDailyItems[player].DailyShopItems = PlayerProfile.Data.DailyShopItems;
    PlayerUpgradeDebounce[player] = nil;
    return {
        Player = player, 
        Currency = PlayerCurrency,
        DailyData = PlayerDailyItems[player],
        Status = "Success", 
        StatusString = "Purchase Successful",
        StatusEffect = {Effect = false, Color = Color3.fromRGB(40, 255, 21)};
        Data = selectedItem
    }
end

function CrateService.Client:PurchaseCrate(player, crateId, crateType, isHourlyCrate)
    --print(player, crateId, crateType, isHourlyCrate)
    local PlayerProfile = DataService:GetProfile(player).Data;
    if not PlayerProfile then 
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "Failed to load player data",
            ItemInfo = nil
        }
    end
    local selectedInfo
    local selectedItem

    if crateType == "Hats" then
        selectedInfo = HatSkinsData
    elseif crateType == "Booster Effects" then
        selectedInfo = BoosterEffectsData
    else
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "Failed to find crate type",
            ItemInfo = nil
        }
    end

    if isHourlyCrate then
        if PlayerProfile.PlayerInfo.Coins < 1000 then
            return {
                Player = player, 
                Status = "Error", 
                StatusString = "Failed to purchase item",
                ItemInfo = nil
            }
        end
    elseif selectedInfo.getCrateInfoFromId(crateId) then
        if PlayerProfile.PlayerInfo.Coins < selectedInfo.getCrateInfoFromId(crateId).Price then
            return {
                Player = player, 
                Status = "Error", 
                StatusString = "Failed to purchase item",
                ItemInfo = nil
            }
        end
    else
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "Failed to find crate",
            ItemInfo = nil
        }
    end
    
    if isHourlyCrate then
        selectedItem = selectedInfo.selectRandomItemWithContents(PlayerHourlyItems[player])
        --print("selectedItem", selectedItem, PlayerHourlyItems[player])
    else
        --print("is not hourly crate")
        selectedItem = selectedInfo.selectRandomItem(crateId)
    end
    
    if selectedItem then
        local ItemName;

        if isHourlyCrate then
            ItemName = selectedItem.itemKey
        else
            ItemName = selectedItem.Key
        end
        
        if PlayerProfile.CratesOpened == nil then
            PlayerProfile.CratesOpened = {}
        end

        if isHourlyCrate then
            local Day = math.floor((Synced.time() + DailyShopOffset) / (60 * 60 * 24));
            local Hour = math.floor((Synced.time() + HourlyShopOffset) / (60 * 60));
            if PlayerProfile.CratesOpened["HourlyCrate_" .. Day + Hour] then
                PlayerProfile.CratesOpened["HourlyCrate_" .. Day + Hour] += 1;
            else
                PlayerProfile.CratesOpened["HourlyCrate_" .. Day + Hour] = 1;
            end
        else
            if PlayerProfile.CratesOpened[selectedInfo.getCrateInfoFromId(crateId).CrateType .. "_" .. selectedInfo.getCrateInfoFromId(crateId).Key] then
                PlayerProfile.CratesOpened[selectedInfo.getCrateInfoFromId(crateId).CrateType .. "_" .. selectedInfo.getCrateInfoFromId(crateId).Key] += 1;
            else
                PlayerProfile.CratesOpened[selectedInfo.getCrateInfoFromId(crateId).CrateType .. "_" .. selectedInfo.getCrateInfoFromId(crateId).Key] = 1;
            end
        end
        

        if PlayerProfile.PlayerInfo.CratesOpened == nil then
            PlayerProfile.PlayerInfo.CratesOpened = 1;
        else
            PlayerProfile.PlayerInfo.CratesOpened += 1;
        end

        if PlayerServerPurchases[player.UserId] == nil then
            PlayerServerPurchases[player.UserId] = {}
        end

        if isHourlyCrate then
            table.insert(PlayerServerPurchases[player.UserId],
                {
                    ItemKey = selectedItem.Key, 
                    ItemType = "Crate",
                    Timestamp = os.time(),
                    ItemInfo = {
                        Key = selectedItem.itemKey, 
                        Name = selectedItem.itemKey, 
                        Rarity = selectedItem.itemRarity,
                        CrateId = -4,
                        DecalId = selectedItem.itemDecal,
                        IndividualPrice = 1000
                    }
                }
            )
        else
            table.insert(PlayerServerPurchases[player.UserId],
                {
                    ItemKey = selectedItem.Key, 
                    ItemType = "Crate",
                    Timestamp = os.time(),
                    ItemInfo = {
                        Key = selectedItem.Key, 
                        Name = selectedItem.Name, 
                        Rarity = selectedItem.Rarity,
                        CrateId = selectedItem.CrateId,
                        DecalId = selectedItem.DecalId,
                        IndividualPrice = selectedItem.IndividualPrice
                    }
                }
            )
        end

        if isHourlyCrate then
            PlayerProfile.PlayerInfo.Coins = PlayerProfile.PlayerInfo.Coins - 1000;
        else
            PlayerProfile.PlayerInfo.Coins = PlayerProfile.PlayerInfo.Coins - selectedInfo.getCrateInfoFromId(crateId).Price;
        end
        
        DataService.Client.CoinSignal:Fire(player, PlayerProfile.PlayerInfo.Coins, nil, true)
        local ItemDuplicate = InventoryService:IsDuplicate(player, ItemName, crateType);
        InventoryService.AddItem(player, ItemName, crateType)
        return {
            Player = player, 
            Status = "Success", 
            StatusString = "Purchase Successful",
            DuplicateInfo = {
                IsDuplicate = ItemDuplicate.IsDuplicate,
                DuplicateAmount = ItemDuplicate.DuplicateAmount,
            },
            ItemInfo = selectedItem
        }
    end
end

function CrateService.Client:GetDailyItems(player) -- Updates daily shop time and shop data
	--print("[DailyService]: Watching time for ",player,profile, lastLogin,dailyshopTime)
    if PlayerDailyItems[player] == nil then
        repeat
            task.wait(1)
        until PlayerDailyItems[player] or player == nil
    end
    
    if PlayerDailyItems[player] then
        return PlayerDailyItems[player]
    end
end

function CrateService.Client:GetHourlyItems(player) -- Updates hourly shop time and shop data
	--print("[DailyService]: Watching time for ",player,profile, lastLogin,dailyshopTime)
    if PlayerHourlyItems[player] == nil then
        repeat
            task.wait(1)
        until PlayerHourlyItems[player] or player == nil
    end
    
    if PlayerHourlyItems[player] then
        return PlayerHourlyItems[player]
    end
end


-- HOURLY FUNCTIONS

function CrateService:UpdateHourlyShopData(player, profile, lastLogin) -- Updates hourly shop time and shop data
    if player and lastLogin then

        local HourlyTime = (math.floor(Synced.time())) + HourlyShopOffset
        local OriginalHourlyTime = HourlyTime - HourlyShopOffset

        local HourPassed = OriginalHourlyTime % 3600
        local HourlySeconds = 3600 - HourPassed

        --print("UPDATE HOURLY DATA", HourlyTime, OriginalHourlyTime, HourPassed, HourlySeconds)

        --local seconds = dailyshopTime - (os.time() - lastLogin)
        if HourlySeconds <= 0 then
            if PlayerHourlyItems[player] then
                PlayerHourlyItems[player] = nil;
            end
            return self:CheckHourlyShopData(player, profile)
        end

        task.spawn(function()
            if not PlayerHourlyItems[player] then
                task.wait(HourlySeconds)
                if player and PlayerHourlyItems[player] then
                    PlayerHourlyItems[player] = nil;
                    return self:CheckHourlyShopData(player, profile)
                end
            end
        end)

        PlayerHourlyItems[player] = {
            HourlyShopItems = profile.HourlyShopItems, 
            TimeLeft = HourlySeconds
        }

        self.Client.SendHourlyItems:Fire(player, {
            HourlyShopItems = profile.HourlyShopItems, 
            TimeLeft = HourlySeconds
        })

        --print(profile.DailyShopItems, ('Daily Shop Ends: %.2d:%.2d:%.2d'):format(hours, minutes%(60), seconds%(60)))
    end
end

function CrateService:CheckHourlyShopData(player, profile) -- Checks daily shop time to see if needs to be reset
	--print("[DailyService]: Checking time for ",player,profile,dailyshopTime)
	local Day = math.floor((Synced.time() + DailyShopOffset) / (60 * 60 * 24)) -- flooring is EXTREMELY important here, because that means the number won't change unless it becomes an integer higher. This is the seed we're going to supply to our getAvailableItems function. This would output something like 18431. By dividing this by 24 hours and adding our offset, we know that if the number changes, THEN a day has passed since the epoch +  our own offset.
    local Hour = math.floor((Synced.time() + HourlyShopOffset) / (60 * 60)) -- flooring is EXTREMELY important here, because that means the number won't change unless it becomes an integer higher. This is the seed we're going to supply to our getAvailableItems function. This would output something like 18431. By dividing this by 24 hours and adding our offset, we know that if the number changes, THEN a day has passed since the epoch +  our own offset.

    local HourlyTime = (math.floor(Synced.time())) + HourlyShopOffset
    local OriginalHourlyTime = HourlyTime - HourlyShopOffset

    local HourPassed = OriginalHourlyTime % 3600
    local HourlySeconds = 3600 - HourPassed

    local HasHourPassed = HourlySeconds % 3600 -- basically, this would output how far into the day we are in seconds
    
    if player and profile then
        if ResetDailyShop == true then
            profile.PlayerInfo.HourlyShopInfo = false; -- UNCOMMENT RESETS TIME STATS 
        end

		if typeof(profile.PlayerInfo.HourlyShopInfo) ~= "table" then 
			profile.PlayerInfo.HourlyShopInfo = {
                CurrentDay = -1,
                CurrentHour = -1,
                Streak = 0
            };
		end

        if profile.PlayerInfo.HourlyShopInfo.CurrentHour == nil then 
			profile.PlayerInfo.HourlyShopInfo = {
                CurrentDay = -1,
                CurrentHour = -1,
                Streak = 0
            };
		end

		local lastOnlineDate = profile.PlayerInfo.HourlyShopInfo.CurrentHour
		
		if lastOnlineDate == -1 or lastOnlineDate ~= Hour or HasHourPassed == 0 then -- # hours pass aka next day or no data

			local streak = profile.PlayerInfo.HourlyShopInfo.Streak or 0
			
            self:ResetHourlyItems(player);

            self:StartHourlyItems(player, profile, Day+Hour, 8);

			streak = streak + 1
			if lastOnlineDate then
                profile.PlayerInfo.HourlyShopInfo = {
                    CurrentDay = Day,
                    CurrentHour = Hour,
                    Streak = 0
                };
			end
			
			self:UpdateHourlyShopData(player, profile, profile.PlayerInfo.HourlyShopInfo.CurrentHour)
		elseif lastOnlineDate == Hour then -- if data, wait till 24 hours yeps
			self:UpdateHourlyShopData(player, profile, lastOnlineDate)
		end
	end
end

function CrateService:StartHourlyItems(player, profile, CurrentHour, NumOfItems)
    if player and profile then
        --print("[DailyHandler]: "..player.Name .. " is starting daily items");
        local seed = Random.new(CurrentHour);

        --print("Hourly Seed", seed, CurrentHour)
        local crateItems = {};

        local function shallowCopy(original)
            local copy = {}
            for key, value in pairs(original) do
                copy[key] = value
            end
            return copy
        end

        if profile.HourlyShopItems == nil then
            profile.HourlyShopItems = {};
        end

        for Index,HourlyItem in pairs(profile.HourlyShopItems) do
            if HourlyItem and HourlyItem.id == 0 then
                table.remove(profile.HourlyShopItems, Index);
            end;
        end;

        local function GenerateItem(Rarity)
            local returnedItem;
            local returnedRarity;
    
            local function GenerateWeightedItem(rarityName) -- wrap this in a function so that it's easier to use for our duplicate check
                local rarity -- initialize our rarity variable
                local weightNumber -- Use NextNumber instead of NextInteger so that you can use decimals in your weight values. NextNumber is much more precise. We limit it to 100, our max weight value

                if rarityName == "Legendary" then
                    weightNumber = seed:NextNumber(0,1);
                elseif rarityName == "Epic" then
                    weightNumber = seed:NextNumber(1,2);
                elseif rarityName == "Rare" then
                    weightNumber = seed:NextNumber(3, 5);
                elseif rarityName == "Uncommon" then
                    weightNumber = seed:NextNumber(6, 29);
                elseif rarityName == "Common" then
                    weightNumber = seed:NextNumber(60, 100);
                else
                    weightNumber = seed:NextNumber(0, 100);
                end
    
                local weightitem -- initialize a variable for the weighted item

                --print("HOURLY weightnumber", rarityName, weightNumber)
                if weightNumber < RarityWeights.Legendary then 
                    --print("Legendary") 
                    local Items = HatSkinsData.getHatSkinsFromRarity(5, false)
                    --Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                elseif weightNumber < RarityWeights.Epic then 
                    --print("Epic")
                    local Items = HatSkinsData.getHatSkinsFromRarity(4, false)
                    --Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                elseif weightNumber < RarityWeights.Rare then 
                    --print("Rare")
                    local Items = HatSkinsData.getHatSkinsFromRarity(3, false)
                    --Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                elseif weightNumber < RarityWeights.Uncommon then 
                    --print("Uncommon")
                    local Items = HatSkinsData.getHatSkinsFromRarity(2, false)
                    --Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                else
                    --print("Common")
                    local Items = HatSkinsData.getHatSkinsFromRarity(1, false)
                    --Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                end
    
                return weightitem, rarity -- Return both these values so we can use it later. We will need the "rarity" table for duplicate prevention
            end
    
            returnedItem, returnedRarity = GenerateWeightedItem(Rarity) -- Do the function
            --returnedRarity = TableUtil.Shuffle(returnedRarity); -- Shuffles the table
            local itemtablecopy = shallowCopy(returnedRarity) -- Copies the table we returned
    
            --Duplicate check below
            for i, item in pairs(crateItems) do 
                local duplicate = table.find(crateItems, returnedItem) --Finds a duplicate
    
                if duplicate then -- If there is a duplicate and it's not nil...
                    --print("Respinning..")
    
                    for number, v in pairs(itemtablecopy) do 
                        for i = 1, #crateItems do
                            if v == crateItems[i] then
                                table.remove(itemtablecopy, number) -- if an item in the copied table is the same as a value inside of our shop items already, then it removes it
                            end
                        end
                    end
    
                    repeat
                        returnedItem = itemtablecopy[seed:NextInteger(1,#itemtablecopy)] -- keep randomnly generating an item from the items that we have left in the copied table
                    until returnedItem ~= item -- until you get one that the shop table doesn't have yet
                end
            end
    
            table.insert(crateItems, returnedItem) -- Inserts the item inside of the table
        end

        local AmountOfMissions = table.getn(profile.HourlyShopItems) --// Amount of DailyShopItems
        --[[repeat
            GenerateItem()
        until #crateItems >= NumOfItems]] -- Until we get our desired # of items.

        GenerateItem("Common")
        GenerateItem("Common")
        GenerateItem("Common")
        GenerateItem("Uncommon")
        GenerateItem("Uncommon")
        GenerateItem("Rare")
        GenerateItem("Rare")
        GenerateItem("Epic")
        GenerateItem("Epic")
        GenerateItem("Legendary")
       
        --[[bool = not bool
        local itemInfo;
        if bool then
            itemInfo = DuckSkins.selectRandomItem(-2)
        else
            itemInfo = DeathEffect.selectRandomItem(1)
        end]]

        --print("crateItems:", table.getn(crateItems))

        for _, itemInfo in pairs(crateItems) do
            
            local HourlyItem = {
                id = AmountOfMissions + 1,
                purchased = false,
                hasItem = InventoryService:HasItem(player, itemInfo.Key, itemInfo.ItemType),
                itemType = itemInfo.ItemType,
                itemRarity = itemInfo.Rarity,
                itemKey = itemInfo.Key,
                itemDecal = itemInfo.DecalId,
                timestamp = os.time();
            };

            --print("Hourly Item:", itemInfo.Name, itemInfo.Rarity)
            
            table.insert(profile.HourlyShopItems, AmountOfMissions + 1, HourlyItem);
        end
    end;
end;

-- DAILY FUNCTIONS

function CrateService:UpdateDailyShopData(player, profile, lastLogin, dailyshopTime) -- Updates daily shop time and shop data
    if player and lastLogin and dailyshopTime then

        local DailyTime = (math.floor(Synced.time())) + DailyShopOffset
        local OriginalTime = DailyTime - DailyShopOffset
    
        local DayPassed = OriginalTime % 86400
        local DailySeconds = 86400 - DayPassed

        --print("UPDATE DAILY DATA", DailyTime, OriginalTime, DayPassed, DailySeconds)

        --local seconds = dailyshopTime - (os.time() - lastLogin)
        if DailySeconds <= 0 then
            if PlayerDailyItems[player] then
                PlayerDailyItems[player] = nil;
            end
            return self:CheckDailyShopData(player, profile, dailyshopTime)
        end

        task.spawn(function()
            if not PlayerDailyItems[player] then
                task.wait(DailySeconds)
                if player and PlayerDailyItems[player] then
                    PlayerDailyItems[player] = nil;
                    return self:CheckDailyShopData(player, profile, dailyshopTime)
                end
            end
        end)

        PlayerDailyItems[player] = {
            DailyShopItems = profile.DailyShopItems, 
            TimeLeft = DailySeconds
        }

        self.Client.SendDailyItems:Fire(player, {
            DailyShopItems = profile.DailyShopItems, 
            TimeLeft = DailySeconds
        })

        --print(profile.DailyShopItems, ('Daily Shop Ends: %.2d:%.2d:%.2d'):format(hours, minutes%(60), seconds%(60)))
    end
end

function CrateService:CheckDailyShopData(player, profile, dailyshopTime) -- Checks daily shop time to see if needs to be reset
	--print("[DailyService]: Checking time for ",player,profile,dailyshopTime)
	local Day = math.floor((Synced.time() + DailyShopOffset) / (60 * 60 * 24)) -- flooring is EXTREMELY important here, because that means the number won't change unless it becomes an integer higher. This is the seed we're going to supply to our getAvailableItems function. This would output something like 18431. By dividing this by 24 hours and adding our offset, we know that if the number changes, THEN a day has passed since the epoch +  our own offset.
    local Time = (math.floor(Synced.time())) + DailyShopOffset -- Sets the date to Thursday 7 PM EST
    local OriginalTime = Time - DailyShopOffset

    local HasDayPassed = OriginalTime % 86400 -- basically, this would output how far into the day we are in seconds
    
    if player and profile and dailyshopTime then
        if ResetDailyShop == true then
            profile.PlayerInfo.DailyShopInfo = false; -- UNCOMMENT RESETS TIME STATS 
        end

		if typeof(profile.PlayerInfo.DailyShopInfo) ~= "table" then 
			profile.PlayerInfo.DailyShopInfo = {
                CurrentDay = -1,
                Streak = 0
            };
		end

        if profile.PlayerInfo.DailyShopInfo.CurrentDay == nil then 
			profile.PlayerInfo.DailyShopInfo = {
                CurrentDay = -1,
                Streak = 0
            };
		end

		local lastOnlineDate = profile.PlayerInfo.DailyShopInfo.CurrentDay
		
		if lastOnlineDate == -1 or lastOnlineDate ~= Day or HasDayPassed == 0 then -- # hours pass aka next day or no data

			local streak = profile.PlayerInfo.DailyShopInfo.Streak or 0
			
            self:ResetShopItems(player);

            self:StartDailyItems(player, profile, Day, 4);

			streak = streak + 1
			if lastOnlineDate then
				profile.PlayerInfo.DailyShopInfo = {
                    CurrentDay = Day,
                    Streak = streak
                };
			end
			
			self:UpdateDailyShopData(player, profile, profile.PlayerInfo.DailyShopInfo.CurrentDay, dailyshopTime)
		elseif lastOnlineDate == Day then -- if data, wait till 24 hours yeps
			self:UpdateDailyShopData(player, profile, lastOnlineDate, dailyshopTime)
		end
	end
end

function CrateService:StartDailyItems(player, profile, CurrentDay, NumOfItems)
    if player and profile then
        --print("[DailyHandler]: "..player.Name .. " is starting daily items");
        local seed = Random.new(CurrentDay);

        --print("Daily Seed:", seed, CurrentDay)
        local shopItems = {};

        local function shallowCopy(original)
            local copy = {}
            for key, value in pairs(original) do
                copy[key] = value
            end
            return copy
        end

        for Index,DailyItem in pairs(profile.DailyShopItems) do
            if DailyItem and DailyItem.id == 0 then
                table.remove(profile.DailyShopItems, Index);
            end;
        end;

        local function GenerateItem(itemType : string)
            local returnedItem;
            local returnedRarity;
    
            local function GenerateWeightedItem() -- wrap this in a function so that it's easier to use for our duplicate check
                local rarity -- initialize our rarity variable
                local weightNumber -- Use NextNumber instead of NextInteger so that you can use decimals in your weight values. NextNumber is much more precise. We limit it to 100, our max weight value

                weightNumber = seed:NextNumber(0, 100);
    
                local weightitem, Items -- initialize a variable for the weighted item

                --print("DAILY weightnumber", weightNumber)

                if weightNumber < RarityWeights.Legendary then 
                    Items = GetItemsFromRarity(itemType, 5); -- Legendary
                    --Items = TableUtil.Shuffle(Items); // THIS RANDOMIZES THE ITEM RATHER THAN HAVING SAME ONE
                elseif weightNumber < RarityWeights.Epic then 
                    Items = GetItemsFromRarity(itemType, 4); -- Epic
                elseif weightNumber < RarityWeights.Rare then 
                    Items = GetItemsFromRarity(itemType, 3); -- Rare
                elseif weightNumber < RarityWeights.Uncommon then 
                    Items = GetItemsFromRarity(itemType, 2); -- Uncommon
                else
                    Items = GetItemsFromRarity(itemType, 1); -- Common
                end

                weightitem = Items[seed:NextInteger(1,#Items)];
                rarity = Items
    
                return weightitem, rarity -- Return both these values so we can use it later. We will need the "rarity" table for duplicate prevention
            end
    
            returnedItem, returnedRarity = GenerateWeightedItem() -- Do the function, and now we have both the item and the returned rarity table
            --returnedRarity = TableUtil.Shuffle(returnedRarity); -- Shuffles the table
            local itemtablecopy = shallowCopy(returnedRarity) -- Copies the table we returned
    
            --print("shopItems:", shopItems)
            --Duplicate check below
            for _, item in pairs(shopItems) do 
                local duplicate = table.find(shopItems, returnedItem) --Finds a duplicate
    
                if duplicate then -- If there is a duplicate and it's not nil...
                    --print("Respinning..")
    
                    for number, v in pairs(itemtablecopy) do 
                        for itemNum = 1, #shopItems do
                            if v == shopItems[itemNum] then
                                table.remove(itemtablecopy, number) -- if an item in the copied table is the same as a value inside of our shop items already, then it removes it
                            end
                        end
                    end
    
                    repeat
                        returnedItem = itemtablecopy[seed:NextInteger(1,#itemtablecopy)] -- keep randomnly generating an item from the items that we have left in the copied table
                    until returnedItem ~= item -- until you get one that the shop table doesn't have yet
                end
            end
    
            table.insert(shopItems, returnedItem) -- Inserts the item inside of the table
        end

        local AmountOfMissions = table.getn(profile.DailyShopItems) --// Amount of DailyShopItems
        --[[repeat
            GenerateItem()
        until #shopItems >= NumOfItems -- Until we get our desired # of items.]]

        GenerateItem("Hats")
        GenerateItem("Booster Effects")
        GenerateItem("Hats")
        GenerateItem("Booster Effects")
       
        --[[bool = not bool
        local itemInfo;
        if bool then
            itemInfo = DuckSkins.selectRandomItem(-2)
        else
            itemInfo = DeathEffect.selectRandomItem(1)
        end]]

        for _, itemInfo in pairs(shopItems) do
            local DailyItem = {
                id = AmountOfMissions + 1,
                purchased = false,
                hasItem = InventoryService:HasItem(player, itemInfo.Key, itemInfo.ItemType),
                itemType = itemInfo.ItemType,
                itemKey = itemInfo.Key,
                timestamp = os.time();
            };     
            
            table.insert(profile.DailyShopItems, AmountOfMissions + 1, DailyItem);
            print("Daily Item:", profile.DailyShopItems)
        end
    end;
end;

function CrateService:RemoveDailyItem(player, profile)
    if player and profile then
        --print("[DailyHandler]: "..player.Name .. " is removing a mission");
        local CurrentMission = nil;

        for _,Mission in pairs(profile.DailyShopItems) do
            if Mission and Mission.id == self:GetId() then
                CurrentMission = Mission;
                break;
            end;
        end;
        
        if CurrentMission then
            table.remove(profile.DailyShopItems, TableAPI.Find(profile.DailyShopItems,CurrentMission));
        end;
    end;
end;

function CrateService:PurchasedItem(player, profile)
	--print(player,profile)
    if player and profile then
        --print("[DailyHandler]: "..player.Name .. " is purchase a item",profile.DailyShopItems);

        for _,ShopItem in pairs(profile.DailyShopItems) do
            --print(ShopItem,ShopItem.id,ShopItem.purchased ~= true)
            if ShopItem and ShopItem.id and ShopItem.purchased ~= true then
                ShopItem.purchased = true;
            end;
        end;
    end;
end;

function CrateService:InitializeShops(Player)
    --print("InitializeShops", Player)
	if Player then
        local success, playerPurchases = pcall(function()
            return crateStoreLogs:GetAsync("User_"..Player.UserId)
        end)
        if success then
            --print(playerPurchases)
            PlayerServerPurchases[Player.UserId] = playerPurchases;
        end
        repeat task.wait(0.001) until DataService:GetProfile(Player) ~= nil
        if DataService:GetProfile(Player) then
            local PlayerProfile = DataService:GetProfile(Player).Data;
            if not PlayerDailyProfiles[Player] and PlayerProfile then
                PlayerDailyProfiles[Player] = PlayerProfile --TableUtil.Copy(PlayerProfile.Data, true)
                if PlayerDailyProfiles[Player] then
                    self:CheckDailyShopData(Player,PlayerDailyProfiles[Player], 24 * 60 * 60)
                    --self:CheckHourlyShopData(Player, PlayerDailyProfiles[Player], 60 * 60)
                end
            end
        end
	end
end

function CrateService:GetDailyProfile(Player)
    if PlayerDailyProfiles[Player] then
        return PlayerDailyProfiles[Player]
    end
end

function CrateService:CleanUp(Player)
    if PlayerDailyProfiles[Player] then
        PlayerDailyProfiles[Player] = nil
    end
    if PlayerDailyItems[Player] then
        PlayerDailyItems[Player] = nil
    end
    if PlayerHourlyItems[Player] then
        PlayerHourlyItems[Player] = nil
    end
    if PlayerServerPurchases[Player.UserId] then
        --print(PlayerServerPurchases[Player.UserId])
        local success, errorMessage = pcall(function()
            crateStoreLogs:SetAsync("User_"..Player.UserId, PlayerServerPurchases[Player.UserId])
        end)
        if not success then
            print(errorMessage)
        end
        PlayerServerPurchases[Player.UserId] = nil
    end
end

function CrateService:KnitStart()
    local function onPlayerAdded(player)
        self:InitializeShops(player);
    end

    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(onPlayerAdded)(player);
    end

    Players.PlayerAdded:Connect(onPlayerAdded);
end

function CrateService:KnitInit()
    print("[SERVICE]: Crate Service Initialized")
end


return CrateService;
