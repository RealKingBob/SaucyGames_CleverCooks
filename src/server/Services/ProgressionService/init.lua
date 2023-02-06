local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ProgressionService = Knit.CreateService {
    Name = "ProgressionService";
    Client = {};
}

local FrenchProgressionData = require(script.KitchenUpgrades.French);

function ProgressionService.Client:GetProgressionData(player, theme, category)
    print("GetProgressionData", player, theme, category)
    return self.Server:GetProgressionData(player, theme, category)
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
