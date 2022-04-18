local RewardService = {};

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
--local LevelService = require(script.Parent.StatTrackService.LevelService);
--local MathAPI = require(Knit.APIs.MathAPI);

function RewardService:GiveReward(profile, reward)
    local DataService = Knit.GetService("DataService");
    for rewardType, rewardValue in pairs(reward) do
        if tostring(rewardType) == "Coins" then
            if profile.Data.PlayerInfo.Coins == nil then
                profile.Data.PlayerInfo.Coins = 0;
            end;
            
            profile.Data.PlayerInfo.Coins = profile.Data.PlayerInfo.Coins + rewardValue;
            local Player = DataService:GetPlayer(profile)
            if Player then
                DataService.Client.CoinSignal:Fire(Player, profile.Data.PlayerInfo.Coins, rewardValue)
            end
			--DataService.Client.RequestCoinSignal:Fire(Knit.DataService:GetPlayer(profile))
        --[[elseif tostring(rewardType) == "EXP" then
            if profile.Data.PlayerInfo.EXP == nil then
                profile.Data.PlayerInfo.EXP = 0;
            end;

            LevelService:SetEXP(Knit.DataService:GetPlayer(profile), profile, profile.Data.PlayerInfo.EXP + rewardValue)
        ]]
        end;
    end;
end;

return RewardService;