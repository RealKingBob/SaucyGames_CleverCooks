local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local UniverseId = 3152539461;
local LikeCheckpoints = 5000; --Every 5000 likes
local BigLikeCheckpoints = 100000; --Every 100,000 likes

local LikeCounterService = Knit.CreateService {
    Name = "LikeCounterService";
    Client = {
        CounterSignal = Knit.CreateSignal();
    };
}

LikeCounterService.bigLikeGoal = 100000;
LikeCounterService.prevBigLikeGoal = 0;

LikeCounterService.likeGoal = 5000;
LikeCounterService.prevLikeGoal = 1000;

LikeCounterService.currentLikes = 0;
LikeCounterService.reload = 30;

LikeCounterService.coinsGivenPerGoal = 500;
LikeCounterService.coinsGivenPerBigGoal = 5000;

local function adjust(min, max, alpha)
    return min + (max - min) * alpha;
end

local function RoundToMult(num, mult)
    return math.floor(num / mult + 0.5) * mult
end

local function RoundToNextMult(num, mult)
    return math.ceil(num / mult + 0.5) * mult
end

function LikeCounterService:GetLikes(player)
    local profile = Knit.DataService:GetProfile(player);
    
    if not profile then
        local check = 0;
        repeat
            task.wait(.1)
            check += 1;
        until profile or check >= 200;
    end

    if profile then
        if profile.Data.LikeGoals == nil then
            profile.Data.LikeGoals = {};
        end
        
        return {
            CurrentLikes = self.currentLikes,
            PrevLikeGoal = self.prevLikeGoal,
            Claimed = profile.Data.LikeGoals[tostring(self.prevLikeGoal).."Likes"] == true,
            LikeGoal = self.likeGoal,
            Alpha = (adjust(
                0,
                1,
                self.currentLikes / self.likeGoal
            ));
        };
    end
    return {
        CurrentLikes = self.currentLikes,
        PrevLikeGoal = self.prevLikeGoal,
        Claimed = false,
        LikeGoal = self.likeGoal,
        Alpha = (adjust(
            0,
            1,
            self.currentLikes / self.likeGoal
        ));
    };
end

function LikeCounterService.Client:GetLikes(Player)
	-- We can just call our other method from here:
    return self.Server:GetLikes(Player)
end;

function LikeCounterService:SetupCounters()
    print("Setting up like counter")
    
    self.Client.CounterSignal:Connect(function(player)
        local profile = Knit.DataService:GetProfile(player);
        if profile then
            if profile.Data.LikeGoals == nil then
                profile.Data.LikeGoals = {};
            end

            if profile.Data.LikeGoals[tostring(self.prevLikeGoal).."Likes"] == nil then
                profile.Data.LikeGoals[tostring(self.prevLikeGoal).."Likes"] = true;

                if profile.Data.BigLikeGoals == nil then
                    profile.Data.BigLikeGoals = {};
                end

                if self.prevBigLikeGoal ~= 0 and profile.Data.BigLikeGoals[tostring(self.prevBigLikeGoal).."Likes"] == nil then
                    profile.Data.BigLikeGoals[tostring(self.prevBigLikeGoal).."Likes"] = true;
                    profile.Data.PlayerInfo.Coins += self.coinsGivenPerBigGoal
                    Knit.DataService.Client.Notification:Fire(player, "Notice!", "Hey! You just received the MILESTONE coins from the likes! :]", "OK");
                    Knit.DataService.Client.CoinSignal:Fire(player, profile.Data.PlayerInfo.Coins, self.coinsGivenPerBigGoal)
                else
                    profile.Data.PlayerInfo.Coins += self.coinsGivenPerGoal
                    Knit.DataService.Client.Notification:Fire(player, "Notice!", "Hey! You just received the coins from the likes! :]", "OK");
                    Knit.DataService.Client.CoinSignal:Fire(player, profile.Data.PlayerInfo.Coins, self.coinsGivenPerGoal)
                end

                self.Client.CounterSignal:Fire(player, {
                    CurrentLikes = self.currentLikes,
                    PrevLikeGoal = self.prevLikeGoal,
                    Claimed = profile.Data.LikeGoals[tostring(self.prevLikeGoal).."Likes"] == true,
                    LikeGoal = self.likeGoal,
                    Alpha = (adjust(
                        0,
                        1,
                        self.currentLikes / self.likeGoal
                    ));
                });
            end
        end
    end)

    task.spawn(function()
        task.wait(5)
        while true do

            local response = HttpService:RequestAsync({
                Url = "https://games.roproxy.com/v1/games/votes?universeIds="..UniverseId,
                Method = "GET"
            })

            if response.Success then
                local votes = HttpService:JSONDecode(response.Body)
                --print("Like counter upVotes:", votes.data[1].upVotes)

                self.currentLikes = votes.data[1].upVotes

                if self.currentLikes >= RoundToMult(self.currentLikes, BigLikeCheckpoints) then
                    self.bigLikeGoal = RoundToNextMult(self.currentLikes, BigLikeCheckpoints);
                else
                    self.bigLikeGoal = RoundToMult(self.currentLikes, BigLikeCheckpoints);
                end

                if self.currentLikes >= RoundToMult(self.currentLikes, LikeCheckpoints) then
                    self.likeGoal = RoundToNextMult(self.currentLikes, LikeCheckpoints);
                else
                    self.likeGoal = RoundToMult(self.currentLikes, LikeCheckpoints);
                end

                self.prevBigLikeGoal = (RoundToNextMult(self.currentLikes, BigLikeCheckpoints) - BigLikeCheckpoints);
                self.prevLikeGoal = (self.likeGoal - LikeCheckpoints) == 0 and 1000 or (RoundToMult(self.currentLikes, LikeCheckpoints) - LikeCheckpoints);
            end

            if self.currentLikes > 0 then
                for _, player in pairs(Players:GetPlayers()) do
                    task.spawn(function()
                        local profile = Knit.DataService:GetProfile(player);

                        if not profile then
                            local check = 0;
                            repeat
                                task.wait(.1)
                                check += 1; 
                            until profile or check >= 200;
                        end
                        
                        if profile then
                            if profile.Data.LikeGoals == nil then
                                profile.Data.LikeGoals = {};
                            end

                            self.Client.CounterSignal:Fire(player, {
                                CurrentLikes = self.currentLikes,
                                PrevLikeGoal = self.prevLikeGoal,
                                Claimed = profile.Data.LikeGoals[tostring(self.prevLikeGoal).."Likes"] == true,
                                LikeGoal = self.likeGoal,
                                Alpha = (adjust(
                                    0,
                                    1,
                                    self.currentLikes / self.likeGoal
                                ));
                            });
                        end
                    end)
                end
            end

            task.wait(self.reload);
        end
    end)
end


function LikeCounterService:KnitStart()
    
end


function LikeCounterService:KnitInit()
    self:SetupCounters()
end


return LikeCounterService
