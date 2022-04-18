--[[
    Name: Crate Service [V1]
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

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableAPI = require(script.Parent.Parent.APIs.TableAPI)

local TableUtil = require(Knit.Util.TableUtil);
local Signal = require(Knit.Util.Signal);
local Synced = require(Knit.ReplicatedModules.Synced);

local crateStoreLogs = DataStoreService:GetDataStore("CrateStoreLogs")

local DataService = Knit.DataService;
local InventoryService = Knit.InventoryService;

local DuckSkins = Knit.ReplicatedDuckSkins;
local DuckEmotes = Knit.ReplicatedDuckEmotes;
local DeathEffect = Knit.ReplicatedDuckEffects;
local Rarities = Knit.ReplicatedRarities;

local CrateService = Knit.CreateService {
    Name = "CrateService";
    Client = {
        SuccessCrateSignal = Knit.CreateSignal(); -- When player successful purchases Item/crate

        InitializeDailyShop = Knit.CreateSignal(); -- request for daily items for player
        UpdateDailyShop = Knit.CreateSignal(); -- updates daily items for player

        SendDailyItems = Knit.CreateSignal(); -- updates daily items for player
    };
    SavePlayerLastData = Signal.new();
}

local PlayerDailyProfiles = {};
local PlayerLoginTimes = {};
local PlayerDailyItems = {};
local PlayerServerPurchases = {};

local RarityWeights = Rarities.getRarityChances();
RarityWeights.Common = 100;

local ResetDailyShop = Knit.Config.RESET_DAILY_SHOP_DATA;
local DailyShopOffset = (60 * 60 * Knit.Config.DAILY_SHOP_OFFSET); 

Synced.init() -- Will make the request to google.com if it hasn't already.

function CrateService:ResetShopItems(Player)
	if Player then
		local PlayerProfile = DataService:GetProfile(Player).Data;
		if PlayerProfile then
			PlayerProfile.DailyShopItems = {};
		end
	end
end

function CrateService.Client:PurchaseItem(player, name, crateType, dailyShopId)
    --print(player, name, crateType, dailyShopId)
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

    if crateType == "Skins" then
        selectedInfo = DuckSkins
    elseif crateType == "Effects" then
        selectedInfo = DeathEffect
    elseif crateType == "Emotes" then
        selectedInfo = DuckEmotes
    else
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "Failed to find crate type",
            ItemInfo = nil
        }
    end

    if selectedInfo.getItemFromName(name) then
        if PlayerProfile.PlayerInfo.Coins < selectedInfo.getItemFromName(name).IndividualPrice then
            return {
                Player = player, 
                Status = "Error", 
                StatusString = "Not enough coins to purchase item",
                ItemInfo = nil
            }
        end
    else
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "Failed to find item",
            ItemInfo = nil
        }
    end
    
    selectedItem = selectedInfo.getItemFromName(name)
    local ItemName = selectedItem.Key
    if selectedItem then
        if PlayerProfile.DailyShopItems then
            if typeof(PlayerProfile.DailyShopItems) == "string" then
                local decodedDailyItems = HttpService:JSONDecode(PlayerProfile.DailyShopItems)
                if decodedDailyItems[dailyShopId].purchased == true
                or InventoryService:HasItem(player, ItemName,crateType) == true  then
                    return {
                        Player = player, 
                        Status = "Error", 
                        StatusString = "Item is already purchased",
                        ItemInfo = nil
                    }
                end
            else
                if PlayerProfile.DailyShopItems[dailyShopId].purchased == true 
                or InventoryService:HasItem(player, ItemName,crateType) == true then
                    return {
                        Player = player, 
                        Status = "Error", 
                        StatusString = "Item is already purchased",
                        ItemInfo = nil
                    }
                end
            end
            PlayerProfile.DailyShopItems[dailyShopId].purchased = true
        end

        if PlayerProfile.PlayerInfo.DailyItemsBought == nil then
            PlayerProfile.PlayerInfo.DailyItemsBought = 1;
        else
            PlayerProfile.PlayerInfo.DailyItemsBought += 1;
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

        PlayerProfile.PlayerInfo.Coins = PlayerProfile.PlayerInfo.Coins - selectedItem.IndividualPrice
        DataService.Client.CoinSignal:Fire(player, PlayerProfile.PlayerInfo.Coins, nil, true)
        InventoryService.AddItem(player, ItemName,crateType)
        return {
            Player = player, 
            Status = "Success", 
            StatusString = "Purchase Successful",
            ItemInfo = selectedItem
        }
    end
end

function CrateService.Client:PurchaseCrate(player, crateId, crateType)
    --print(player, crateId, crateType)
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

    if crateType == "Skins" then
        selectedInfo = DuckSkins
    elseif crateType == "Effects" then
        selectedInfo = DeathEffect
    elseif crateType == "Emotes" then
        selectedInfo = DuckEmotes
    else
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "Failed to find crate type",
            ItemInfo = nil
        }
    end

    if selectedInfo.getCrateInfoFromId(crateId) then
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
    
    selectedItem = selectedInfo.selectRandomItem(crateId)
    if selectedItem then
        local ItemName = selectedItem.Key
        
        if PlayerProfile.CratesOpened == nil then
            PlayerProfile.CratesOpened = {}
        end


        if PlayerProfile.CratesOpened[selectedInfo.getCrateInfoFromId(crateId).CrateType .. "_" .. selectedInfo.getCrateInfoFromId(crateId).Key] then
            PlayerProfile.CratesOpened[selectedInfo.getCrateInfoFromId(crateId).CrateType .. "_" .. selectedInfo.getCrateInfoFromId(crateId).Key] += 1;
        else
            PlayerProfile.CratesOpened[selectedInfo.getCrateInfoFromId(crateId).CrateType .. "_" .. selectedInfo.getCrateInfoFromId(crateId).Key] = 1;
        end

        if PlayerProfile.PlayerInfo.CratesOpened == nil then
            PlayerProfile.PlayerInfo.CratesOpened = 1;
        else
            PlayerProfile.PlayerInfo.CratesOpened += 1;
        end

        if PlayerServerPurchases[player.UserId] == nil then
            PlayerServerPurchases[player.UserId] = {}
        end

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

        PlayerProfile.PlayerInfo.Coins = PlayerProfile.PlayerInfo.Coins - selectedInfo.getCrateInfoFromId(crateId).Price
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

function CrateService:UpdateShopData(player, profile, lastLogin, dailyshopTime) -- Updates daily shop time and shop data
    if player and lastLogin and dailyshopTime then

        local Time = (math.floor(Synced.time())) + DailyShopOffset
        local OriginalTime = Time - DailyShopOffset
    
        local DayPassed = OriginalTime % 86400
        local seconds = 86400 - DayPassed

        --local seconds = dailyshopTime - (os.time() - lastLogin)
        if seconds <= 0 then
            if PlayerDailyItems[player] then
                PlayerDailyItems[player] = nil;
            end
            return self:CheckShopData(player, profile, dailyshopTime)
        end
        
        if typeof(profile.DailyShopItems) == "string" then
            local decodedDailyItems = HttpService:JSONDecode(profile.DailyShopItems)
            profile.DailyShopItems = decodedDailyItems
        end

        task.spawn(function()
            if not PlayerDailyItems[player] then
                task.wait(seconds)
                if player and PlayerDailyItems[player] then
                    PlayerDailyItems[player] = nil;
                    return self:CheckShopData(player, profile, dailyshopTime)
                end
            end
        end)

        PlayerDailyItems[player] = {
            DailyShopItems = profile.DailyShopItems, 
            TimeLeft = seconds
        }

        self.Client.SendDailyItems:Fire(player, {
            DailyShopItems = profile.DailyShopItems, 
            TimeLeft = seconds
        })

        --print(profile.DailyShopItems, ('Daily Shop Ends: %.2d:%.2d:%.2d'):format(hours, minutes%(60), seconds%(60)))
    end
end

function CrateService:CheckShopData(player, profile, dailyshopTime) -- Checks daily shop time to see if needs to be reset
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
			
			self:UpdateShopData(player, profile, profile.PlayerInfo.DailyShopInfo.CurrentDay, dailyshopTime)
		elseif lastOnlineDate == Day then -- if data, wait till 24 hours yeps
			self:UpdateShopData(player, profile, lastOnlineDate, dailyshopTime)
		end
	end
end

function CrateService:StartDailyItems(player, profile, CurrentDay, NumOfItems)
    if player and profile then
        --print("[DailyHandler]: "..player.Name .. " is starting daily items");
        local seed = Random.new(CurrentDay);
        local shopItems = {};

        local function shallowCopy(original)
            local copy = {}
            for key, value in pairs(original) do
                copy[key] = value
            end
            return copy
        end
        
        if typeof(profile.DailyShopItems) == "string" then
            local decodedDailyItems = HttpService:JSONDecode(profile.DailyShopItems)
            profile.DailyShopItems = decodedDailyItems
        end

        for Index,DailyItem in pairs(profile.DailyShopItems) do
            if DailyItem and DailyItem.id == 0 then
                table.remove(profile.DailyShopItems, Index);
            end;
        end;

        local function GenerateItem()
            local returnedItem;
            local returnedRarity;
    
            local function GenerateWeightedItem() -- wrap this in a function so that it's easier to use for our duplicate check
                local rarity -- initialize our rarity variable
                local weightNumber = seed:NextNumber(0, 100) -- Use NextNumber instead of NextInteger so that you can use decimals in your weight values. NextNumber is much more precise. We limit it to 100, our max weight value
    
                local weightitem -- initialize a variable for the weighted item

                if weightNumber < RarityWeights.Legendary then 
                    --print("Legendary") 
                    local Items = DuckSkins.getDuckSkinsFromRarity(5, true)
                    Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                elseif weightNumber < RarityWeights.Epic then 
                    --print("Epic")
                    local Items = DuckSkins.getDuckSkinsFromRarity(4, true)
                    Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                elseif weightNumber < RarityWeights.Rare then 
                    --print("Rare")
                    local Items = DuckSkins.getDuckSkinsFromRarity(3, true)
                    Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                elseif weightNumber < RarityWeights.Uncommon then 
                    --print("Uncommon")
                    local Items = DuckSkins.getDuckSkinsFromRarity(2, true)
                    Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                else
                    --print("Common")
                    local Items = DuckSkins.getDuckSkinsFromRarity(1, true)
                    Items = TableUtil.Shuffle(Items);
                    weightitem = Items[seed:NextInteger(1,#Items)];
                    rarity = Items
                end
    
                return weightitem, rarity -- Return both these values so we can use it later. We will need the "rarity" table for duplicate prevention
            end
    
            returnedItem, returnedRarity = GenerateWeightedItem() -- Do the function, and now we have both the item and the returned rarity table
            returnedRarity = TableUtil.Shuffle(returnedRarity); -- Shuffles the table
            local itemtablecopy = shallowCopy(returnedRarity) -- Copies the table we returned
    
            --Duplicate check below
            for i, item in pairs(shopItems) do 
                local duplicate = table.find(shopItems, returnedItem) --Finds a duplicate
    
                if duplicate then -- If there is a duplicate and it's not nil...
                    --("Respinning..")
    
                    for number, v in pairs(itemtablecopy) do 
                        for i = 1, #shopItems do
                            if v == shopItems[i] then
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
        repeat
            GenerateItem()
        until #shopItems >= NumOfItems -- Until we get our desired # of items.
       
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


function CrateService:InitializeDailyStore(Player)
    --print("InitializeDailyStore", Player)
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
                    self:CheckShopData(Player,PlayerDailyProfiles[Player],24*60*60)
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
        self:InitializeDailyStore(player);
    end

    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(onPlayerAdded)(player);
    end

    Players.PlayerAdded:Connect(onPlayerAdded);
end

function CrateService:KnitInit()
    print("[SERVICE]: Crate Service Initialized")

    self.Client.UpdateDailyShop:Connect(function(player)
        local PlayerProfile = PlayerDailyProfiles[player];
        if PlayerProfile and PlayerLoginTimes[player] then
            self:UpdateShopData(player, PlayerProfile, PlayerLoginTimes[player].LastLogin, PlayerLoginTimes[player].DailyShopTime)
        end
    end)

end


return CrateService;
