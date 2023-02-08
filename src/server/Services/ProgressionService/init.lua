local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ProgressionService = Knit.CreateService {
    Name = "ProgressionService";
    Client = {};
}

local PlayerUpgradeDebounce = {}

local FrenchProgressionData = require(script.KitchenUpgrades.French);

function ProgressionService.Client:GetProgressionData(player, theme, category)
    print("GetProgressionData", player, theme, category)
    return self.Server:GetProgressionData(player, theme, category)
end

function ProgressionService.Client:PurchaseUpgrade(player, theme, category)
    print("PurchaseUpgrade", player, theme, category)
    return self.Server:PurchaseUpgrade(player, theme, category)
end

function ProgressionService:GetPlayerProgressionData(theme, category)
    if theme == "French" then
        if category then
            return FrenchProgressionData[category]
        else
            return FrenchProgressionData:Copy()
        end
    end
end

function ProgressionService:PurchaseUpgrade(player, theme, category)
    if not player or not theme or not category then return end;
    if PlayerUpgradeDebounce[player] then 
        return {
            Player = player, 
            Status = "Error", 
            StatusString = "[ErrorCode PS-PU0] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            ItemInfo = nil
        }
    end

    PlayerUpgradeDebounce[player] = true;
    local DataService = Knit.GetService("DataService");
    local PlayerCurrency, PlayerProgressionData = nil, nil;
    local PlayerProfile = DataService:GetProfile(player)
    if PlayerProfile then
        PlayerCurrency = PlayerProfile.Data.PlayerInfo.Currency[theme];
        PlayerProgressionData = PlayerProfile.Data.SkillUpgrades[theme];
    end

    if not PlayerCurrency or not PlayerProgressionData then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player,
            Currency = PlayerCurrency,
            ProgressionData = PlayerProgressionData,
            Status = "Error", 
            StatusString = "[ErrorCode PS-PU1] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            ItemInfo = nil;
        }
    end

    local CategoryData

    if theme == "French" then
        if category then CategoryData = FrenchProgressionData[category] end
    end

    if not CategoryData then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player,
            Currency = PlayerCurrency,
            ProgressionData = PlayerProgressionData,
            Status = "Error", 
            StatusString = "[ErrorCode PS-PU2] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            ItemInfo = nil;
        }
    end

    local PlayerDataIndex = PlayerProgressionData[category]

    if (PlayerDataIndex + 1) > CategoryData.Max then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player, 
            Currency = PlayerCurrency,
            ProgressionData = PlayerProgressionData,
            Status = "Error", 
            StatusString = "[ErrorCode PS-PU3] Already at max upgrade!",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            ItemInfo = nil
        }
    end

    if PlayerCurrency < CategoryData.Data[PlayerDataIndex + 1].Price then
        PlayerUpgradeDebounce[player] = nil;
        return {
            Player = player, 
            Currency = PlayerCurrency,
            ProgressionData = PlayerProgressionData,
            Status = "Error", 
            StatusString = "[ErrorCode PS-PU4] Insufficient funds!",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            ItemInfo = nil
        }
    end

    warn('1', PlayerProfile.Data.PlayerInfo.Currency[theme], PlayerProfile.Data.SkillUpgrades[theme])

    PlayerCurrency = PlayerCurrency - CategoryData.Data[PlayerDataIndex + 1].Price
    PlayerProfile.Data.PlayerInfo.Currency[theme] = PlayerCurrency;
    DataService.Client.CurrencySignal:Fire(player, PlayerProfile.Data.PlayerInfo.Currency[theme], nil, nil, true)
    PlayerProgressionData[category] = PlayerProgressionData[category] + 1;
    PlayerProfile.Data.SkillUpgrades[theme] = PlayerProgressionData

    warn(PlayerProfile.Data.PlayerInfo.Currency[theme], PlayerProfile.Data.SkillUpgrades[theme])
    PlayerUpgradeDebounce[player] = nil;
    return {
        Player = player, 
        Currency = PlayerCurrency,
        ProgressionData = PlayerProgressionData,
        Status = "Success", 
        StatusString = "Purchase Successful",
        StatusEffect = {Effect = false, Color = Color3.fromRGB(40, 255, 21)};
        ItemInfo = nil
    }
end

function ProgressionService:GetProgressionData(player, theme, category)
    local DataService = Knit.GetService("DataService");
    local PlayerCurrency, PlayerProgressionData = nil, nil;
    local PlayerProfile = DataService:GetProfile(player)
    if PlayerProfile then
        PlayerCurrency = PlayerProfile.Data.PlayerInfo.Currency[theme];
        PlayerProgressionData = PlayerProfile.Data.SkillUpgrades[theme];
    end
    if theme == "French" then
        if category then
            return PlayerCurrency, PlayerProgressionData, FrenchProgressionData[category]
        else
            return PlayerCurrency, PlayerProgressionData, FrenchProgressionData:Copy()
        end
    end
end

function ProgressionService:KnitStart()
    
end


function ProgressionService:KnitInit()
    
end

return ProgressionService
