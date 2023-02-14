--[[
    Name: Inventory Service [V1]
    By: Real_KingBob
	
    Methods:
    PlayerProfile = DataService:GetProfile(player).Data

    [REMOTE FUNCTION] InventoryService.Client:RequestInventory(player)
            -- Example return: { 
                    Inventory = {
                    CurrentDeathEffect = "Default",
                    CurrentHat = "Default",
                    CurrentDuckEmote = "Default",
                    Boosters = {},
                    Hats = {},
                    DuckEmotes = {},
                    DuckEffects = {},
                }, -- Inventory of the user
            }

    FOR CLIENT: AddItem(player, item, type), RemoveItem(player, item, type), EquipItem(player, item, type)

    InventoryTypes = "Ducks", "Effects", "Emotes"

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
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Signal = require(Knit.Util.Signal);

local InventoryService = Knit.CreateService {
    Name = "InventoryService";

    ItemChanged = Knit.CreateSignal();
    Client = {
        InitializeInventory = Knit.CreateSignal(); -- Initialize player inventory
        EquipItem = Knit.CreateSignal(); -- equips item from player inventoryUi

        AddItem = Knit.CreateSignal();
        RemoveItem = Knit.CreateSignal();
        ItemChanged = Knit.CreateSignal();
    };
    SavePlayersLastInventory = Signal.new();
}

local PlayerInventoryProfiles = {};
local DataService = Knit.DataService;
local Config = require(ReplicatedStorage.Common.Modules.Config);
local TableUtil = require(Knit.Util.TableUtil);

local HatSkins = require(Knit.ReplicatedHatSkins);
local BoosterEffects = require(Knit.ReplicatedBoosterEffects);

function InventoryService.PrintItems(player, Type)
	
end

function InventoryService.Client:RequestInventory(player)
    return self.Server:RequestInventory(player)
end

function InventoryService:RequestInventory(player)
    --print(player, "REQUEST")
    local Profile = DataService:GetProfile(player)

    if not Profile then
        local check = 0;
        repeat
            task.wait(.1)
            check += 1;
            Profile = DataService:GetProfile(player)
        until Profile ~= nil or check >= 200;
    end

    Profile = DataService:GetProfile(player)

    if Profile then
        local PlayerProfile = PlayerInventoryProfiles[player] or DataService:GetProfile(player).Data;
        if PlayerProfile then
            if PlayerProfile then
                return self:GetInventoryData(player,PlayerInventoryProfiles[player])
            end
        end
    end
    return nil
end

function InventoryService:HasItem(player, itemName, itemType)
    local Profile = DataService:GetProfile(player)
    if Profile then
        local PlayerProfile = PlayerInventoryProfiles[player] or DataService:GetProfile(player).Data;
        if PlayerProfile then
            if itemType == "Hats" then
                if PlayerProfile.Inventory.Hats[tostring(itemName)] then
                    return true;
                else
                    return false;
                end
            elseif itemType == "Booster Effects" then 
                if PlayerProfile.Inventory.BoosterEffects[tostring(itemName)] then
                    return true;
                else
                    return false;
                end
            end
        end
    end
    return false;
end

function InventoryService:IsDuplicate(player, itemName, itemType)
    local Profile = DataService:GetProfile(player)
    if Profile then
        local PlayerProfile = PlayerInventoryProfiles[player] or DataService:GetProfile(player).Data;
        if PlayerProfile then
            if itemType == "Hats" then
                if PlayerProfile.Inventory.Hats[tostring(itemName)] then
                    task.spawn(function()
                        task.wait(3);
                        PlayerProfile.PlayerInfo.Coins += 350
                        if player then
                            DataService.Client.CoinSignal:Fire(player, PlayerProfile.PlayerInfo.Coins, 350)
                        end
                    end)
                    return {
                        IsDuplicate = true,
                        DuplicateAmount = 350,
                    };
                end
            elseif itemType == "Booster Effects" then 
                if PlayerProfile.Inventory.BoosterEffects[tostring(itemName)] then
                    task.spawn(function()
                        task.wait(3);
                        PlayerProfile.PlayerInfo.Coins += 200
                        if player then
                            DataService.Client.CoinSignal:Fire(player, PlayerProfile.PlayerInfo.Coins, 200)
                        end
                    end)
                    return {
                        IsDuplicate = true,
                        DuplicateAmount = 200,
                    };
                end
            end
        end
    end
    return {
        IsDuplicate = false,
        DuplicateAmount = 0,
    };
end

function InventoryService:InventoryChanged(player)
    local PlayerProfile = DataService:GetProfile(player);
    if PlayerProfile then
        PlayerInventoryProfiles[player] = PlayerProfile.Data
        if PlayerProfile then
            --print(PlayerInventoryProfiles[player].Inventory, InventoryService:GetInventoryData(player,PlayerInventoryProfiles[player]))
            InventoryService.Client.ItemChanged:Fire(player, InventoryService:GetInventoryData(player,PlayerInventoryProfiles[player]))
        end
    end
end

function InventoryService:GetInventoryData(player, profile)
    if not profile then
        local PlayerProfile = DataService:GetProfile(player);
        if PlayerProfile then
            PlayerInventoryProfiles[player] = TableUtil.Copy(PlayerProfile.Data, true)
            return PlayerInventoryProfiles[player].Inventory
        end
    end
    return profile.Inventory
end

function InventoryService.ResetInventory(player, type)
    if not PlayerInventoryProfiles[player] then
        PlayerInventoryProfiles[player] = DataService:GetProfile(player).Data
    end

    if PlayerInventoryProfiles[player] then
        if typeof(PlayerInventoryProfiles[player].Inventory) == "string" then
            local decodedInventory = HttpService:JSONDecode(PlayerInventoryProfiles[player].Inventory)
            PlayerInventoryProfiles[player].Inventory = decodedInventory
        end

        if type == "Hats" then
            PlayerInventoryProfiles[player].Inventory.Hats = {}
            PlayerInventoryProfiles[player].Inventory.Hats["Default Hat"] = {
                Quantity = 1; -- DataInventory[ItemName].Quantity + 
                Rarity = "Common"
            }
        elseif type == "Booster Effects" then
            PlayerInventoryProfiles[player].Inventory.BoosterEffects = {}
            PlayerInventoryProfiles[player].Inventory.BoosterEffects["Default Boost"] = {
                Quantity = 1; -- DataInventory[ItemName].Quantity + 
                Rarity = "Common"
            }
        else
            PlayerInventoryProfiles[player].Inventory.Hats = {}
            PlayerInventoryProfiles[player].Inventory.BoosterEffects = {}

            PlayerInventoryProfiles[player].Inventory.Hats["Default Hat"] = {
                Quantity = 1; -- DataInventory[ItemName].Quantity + 
                Rarity = "Common"
            }
            PlayerInventoryProfiles[player].Inventory.BoosterEffects["Default Boost"] = {
                Quantity = 1; -- DataInventory[ItemName].Quantity + 
                Rarity = "Common"
            }
        end

        DataService:GetProfile(player).Data.Inventory = PlayerInventoryProfiles[player].Inventory
        InventoryService:InventoryChanged(player)
    end
end

function InventoryService.AddAllItem(player, type)
    --print(player, item, type)
    if not PlayerInventoryProfiles[player] then
        PlayerInventoryProfiles[player] = DataService:GetProfile(player).Data
    end
    if PlayerInventoryProfiles[player] then
        if typeof(PlayerInventoryProfiles[player].Inventory) == "string" then
            local decodedInventory = HttpService:JSONDecode(PlayerInventoryProfiles[player].Inventory)
            PlayerInventoryProfiles[player].Inventory = decodedInventory
        end
        local selectedInfo
        local selectedItem
        local DataInventory

        if type == "Hats" then
            selectedInfo = HatSkins
            DataInventory = PlayerInventoryProfiles[player].Inventory.Hats
        elseif type == "Booster Effects" then
            selectedInfo = BoosterEffects
            DataInventory = PlayerInventoryProfiles[player].Inventory.BoosterEffects
        --[[elseif type == "Emotes" then
            selectedInfo = DuckEmotes
            DataInventory = PlayerInventoryProfiles[player].Inventory.DuckEmotes]]
        else
            return
        end

        for _, item in next, selectedInfo.getTable() do
            selectedItem = item
            if selectedItem then
                local ItemName = selectedItem.Key
                if DataInventory[ItemName] ~= nil then
                    DataInventory[ItemName] = {
                        Quantity = 1; -- DataInventory[ItemName].Quantity + 
                        Rarity = selectedItem.Rarity
                    }
                else
                    DataInventory[ItemName] = {
                        Quantity = 1;
                        Rarity = selectedItem.Rarity
                    }
                end
            end
        end

        DataService:GetProfile(player).Data.Inventory = PlayerInventoryProfiles[player].Inventory
        InventoryService:InventoryChanged(player)
    end
end

function InventoryService.AddItem(player, item, type)
    --print(player, item, type)
    if not PlayerInventoryProfiles[player] then
        PlayerInventoryProfiles[player] = DataService:GetProfile(player).Data
    end
    if PlayerInventoryProfiles[player] then
        if typeof(PlayerInventoryProfiles[player].Inventory) == "string" then
            local decodedInventory = HttpService:JSONDecode(PlayerInventoryProfiles[player].Inventory)
            PlayerInventoryProfiles[player].Inventory = decodedInventory
        end
        local selectedInfo
        local selectedItem
        local DataInventory

        if type == "Hats" then
            selectedInfo = HatSkins
            DataInventory = PlayerInventoryProfiles[player].Inventory.Hats
        elseif type == "Booster Effects" then
            selectedInfo = BoosterEffects
            DataInventory = PlayerInventoryProfiles[player].Inventory.BoosterEffects
        --[[elseif type == "Emotes" then
            selectedInfo = DuckEmotes
            DataInventory = PlayerInventoryProfiles[player].Inventory.DuckEmotes]]
        else
            return
        end

        selectedItem = selectedInfo.getItemFromKey(item)
        
        --print(selectedItem,ItemName)
        if selectedItem then
            local ItemName = selectedItem.Key
            if DataInventory[ItemName] ~= nil then
                DataInventory[ItemName] = {
                    Quantity = 1; -- DataInventory[ItemName].Quantity + 
                    Rarity = selectedInfo.getItemFromKey(ItemName).Rarity
                }
            else
                DataInventory[ItemName] = {
                    Quantity = 1;
                    Rarity = selectedInfo.getItemFromKey(ItemName).Rarity
                }
            end
        end
        DataService:GetProfile(player).Data.Inventory = PlayerInventoryProfiles[player].Inventory
        InventoryService:InventoryChanged(player)
    end
end

function InventoryService.RemoveItem(player, item, type)
    if not PlayerInventoryProfiles[player] then
        PlayerInventoryProfiles[player] = DataService:GetProfile(player).Data
    end
    if PlayerInventoryProfiles[player] then
        if typeof(PlayerInventoryProfiles[player].Inventory) == "string" then
            local decodedInventory = HttpService:JSONDecode(PlayerInventoryProfiles[player].Inventory)
            PlayerInventoryProfiles[player].Inventory = decodedInventory
        end

        local DataInventory

        if type == "Hats" then
            DataInventory = PlayerInventoryProfiles[player].Inventory.Hats
        elseif type == "Booster Effects" then
            DataInventory = PlayerInventoryProfiles[player].Inventory.BoosterEffects
        --[[elseif type == "Emotes" then
            DataInventory = PlayerInventoryProfiles[player].Inventory.DuckEmotes]]
        else
            return
        end

        if DataInventory then
            if DataInventory[tostring(item)] then
                DataInventory[tostring(item)] = nil
            end
        end
        DataService:GetProfile(player).Data.Inventory = PlayerInventoryProfiles[player].Inventory
        InventoryService:InventoryChanged(player)
    end
end

function InventoryService.EquipItem(player, item, type)
    if PlayerInventoryProfiles[player] then
        if typeof(PlayerInventoryProfiles[player].Inventory) == "string" then
            local decodedInventory = HttpService:JSONDecode(PlayerInventoryProfiles[player].Inventory)
            PlayerInventoryProfiles[player].Inventory = decodedInventory
        end
        if type == "Hats" then
            if PlayerInventoryProfiles[player].Inventory.Hats[tostring(item)] or Config.GIVE_ALL_INVENTORY == true then
                PlayerInventoryProfiles[player].Inventory.CurrentHat = tostring(item)
                local AvatarService = require(script.Parent.AvatarService);
                    
                print("Set avatar skin")
                
                AvatarService:SetAvatarHat(player, tostring(item));
            end
        elseif type == "Booster Effects" then
            PlayerInventoryProfiles[player].Inventory.CurrentBoosterEffect = tostring(item)
            if PlayerInventoryProfiles[player].Inventory.BoosterEffects[tostring(item)] or Config.GIVE_ALL_INVENTORY == true then
                local AvatarService = require(script.Parent.AvatarService);
                AvatarService:SetBoosterEffect(player, tostring(item));
            end
        --[[elseif type == "Emotes" then
            PlayerInventoryProfiles[player].Inventory.CurrentDuckEmote = tostring(item)]]
        else
            return
        end
    end
end

function InventoryService:InitializeInventory(player)
	if player then
        repeat task.wait(0.001) until DataService:GetProfile(player) ~= nil
		local PlayerProfile = DataService:GetProfile(player);
        if PlayerProfile then
            if player.UserId == 21831137 -- bob
            or player.UserId == 1464956079 then -- sen
                --print("PASSED")
                --self.AddAllItem(player, "Hats")
                --self.AddAllItem(player, "Effects")
            end
            PlayerInventoryProfiles[player] = TableUtil.Copy(PlayerProfile.Data, true)
            if PlayerInventoryProfiles[player] then
                --print("PlayerInventoryProfiles[player] ",PlayerInventoryProfiles[player] )
                return self:GetInventoryData(player,PlayerInventoryProfiles[player])
            end
        end
	end
end

function InventoryService:KnitStart()
end


function InventoryService:KnitInit()
    print("[SERVICE]: InventoryService Initialized")

    local function onPlayerAdded(player)
        self:InitializeInventory(player)
    end

    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(onPlayerAdded)(player);
    end

    Players.PlayerAdded:Connect(onPlayerAdded);

    self.Client.AddItem:Connect(function(player, item, type)
        self.AddItem(player, item, type)
    end)

    self.Client.RemoveItem:Connect(function(player, item, type)
        self.RemoveItem(player, item, type)
    end)

    self.Client.EquipItem:Connect(function(player, item, type)
        self.EquipItem(player, item, type)
    end)
end


return InventoryService
