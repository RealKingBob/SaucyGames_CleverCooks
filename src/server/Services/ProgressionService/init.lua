local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Signal = require(Knit.Util.Signal)

local ProgressionService = Knit.CreateService {
    Name = "ProgressionService";
    UpdateJumpAmount = Signal.new(),
    Client = {
        Update = Knit.CreateSignal();
    };
}

local PlayerUpgradeDebounce = {}

local ThemeData = workspace:GetAttribute("Theme")

local FrenchProgressionData = require(script.KitchenUpgrades.French);

function ProgressionService.Client:GetProgressionData(player, theme, category)
    print("GetProgressionData", player, ThemeData, category)
    return self.Server:GetProgressionData(player, theme, category)
end

function ProgressionService.Client:PurchaseUpgrade(player, theme, category)
    print("PurchaseUpgrade", player, theme, category)
    return self.Server:PurchaseUpgrade(player, theme, category)
end

function ProgressionService.Client:ResetProgressionData(player, theme, category)
    print("ResetProgressionData", player, theme, category)
    return self.Server:ResetProgressionData(player, theme, category)
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

function ProgressionService:UpdatePlayerStats(player, categoryName, categoryValue)
    if not player or not categoryName or not categoryValue then return end;
    if categoryName == "Extra Health" then
        local Character = player.Character or player.CharacterAdded:Wait()
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid then return end
        Humanoid.MaxHealth = categoryValue;
        Humanoid.Health = categoryValue;
    elseif categoryName == "Jump Amount" then
        self.UpdateJumpAmount:Fire(player, categoryValue)
    else

    end
    self.Client.Update:Fire(player, categoryName, categoryValue)
end

function ProgressionService:PurchaseUpgrade(player, theme, category)
    if not player or not theme or not category then return end;
    if PlayerUpgradeDebounce[player] then 
        return {
            Player = player, 
            Currency = nil,
            ProgressionData = nil,
            Status = "Error", 
            StatusString = "[ErrorCode PS-PU0] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil
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
            Data = nil;
        }
    end

    local ThemeData, CategoryData

    if theme == "French" then
        ThemeData = FrenchProgressionData
        if category then 
            CategoryData = FrenchProgressionData[category] 
        end
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
            Data = nil;
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
            Data = nil
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
            Data = nil
        }
    end

    local MaxCookSpeed = (ThemeData["Cook Speed"].Max == PlayerProgressionData["Cook Speed"] and true) or false

    if category == "Cooking Perfection" then
        if MaxCookSpeed == false then
            PlayerUpgradeDebounce[player] = nil;
            return {
                Player = player, 
                Currency = PlayerCurrency,
                ProgressionData = PlayerProgressionData,
                Status = "Error", 
                StatusString = "[ErrorCode PS-PU5] Must max cook speed stats first!",
                StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
                Data = nil
            }
        end
    end

    --warn('1', PlayerProfile.Data.PlayerInfo.Currency[theme], PlayerProfile.Data.SkillUpgrades[theme])

    PlayerCurrency = PlayerCurrency - CategoryData.Data[PlayerDataIndex + 1].Price
    PlayerProfile.Data.PlayerInfo.Currency[theme] = PlayerCurrency;
    DataService.Client.CurrencySignal:Fire(player, PlayerProfile.Data.PlayerInfo.Currency[theme], nil, nil, true)
    PlayerProgressionData[category] = PlayerProgressionData[category] + 1;
    PlayerProfile.Data.SkillUpgrades[theme] = PlayerProgressionData

    --warn(PlayerProfile.Data.PlayerInfo.Currency[theme], PlayerProfile.Data.SkillUpgrades[theme])
    self:UpdatePlayerStats(player, category, CategoryData.Data[PlayerDataIndex + 1].Value)
    PlayerUpgradeDebounce[player] = nil;
    return {
        Player = player, 
        Currency = PlayerCurrency,
        ProgressionData = PlayerProgressionData,
        Status = "Success", 
        StatusString = "Purchase Successful",
        StatusEffect = {Effect = false, Color = Color3.fromRGB(40, 255, 21)};
        Data = nil
    }
end

function ProgressionService:ResetProgressionData(player, theme, category)
    if not player or not theme then return end;
    if PlayerUpgradeDebounce[player] then 
        return {
            Player = player, 
            Currency = nil,
            ProgressionData = nil,
            Status = "Error", 
            StatusString = "[ErrorCode PS-RP0] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil
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
            StatusString = "[ErrorCode PS-RP1] Error occurred, please try again.",
            StatusEffect = {Effect = false, Color = Color3.fromRGB(255, 21, 21)};
            Data = nil;
        }
    end

    if theme == "French" then
        if category then
            PlayerProgressionData[category] = 1;
            local _, _, progData = self:GetProgressionData(player, theme, category)
            self:UpdatePlayerStats(player, category, progData.Data[1].Value)
        else
            for progressionName, progressionData in next, PlayerProgressionData do
                PlayerProgressionData[progressionName] = 1;
                local _, _, progData = self:GetProgressionData(player, theme, progressionName)
                self:UpdatePlayerStats(player, progressionName, progData.Data[1].Value)
            end
        end
        PlayerProfile.Data.SkillUpgrades[theme] = PlayerProgressionData
    end
    PlayerUpgradeDebounce[player] = nil;
    return {
        Player = player, 
        Currency = PlayerCurrency,
        ProgressionData = PlayerProgressionData,
        Status = "Success", 
        StatusString = "All upgrades reset",
        StatusEffect = {Effect = false, Color = Color3.fromRGB(40, 255, 21)};
        Data = nil
    }
end

function ProgressionService:GetProgressionData(player, theme, category)
    print(player, theme, category)
    local DataService = Knit.GetService("DataService");
    local PlayerCurrency, PlayerProgressionData = nil, nil;
    local PlayerProfile = DataService:GetProfile(player)
    --print("PlayerProfile", PlayerProfile)
    if PlayerProfile then
        PlayerCurrency = PlayerProfile.Data.PlayerInfo.Currency[theme];
        PlayerProgressionData = PlayerProfile.Data.SkillUpgrades[theme];
    else
        task.wait(2)
        return self:GetProgressionData(player, theme, category)
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
