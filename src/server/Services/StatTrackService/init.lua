local StatTrackService = {}
local DataService = require(script.Parent.DataService)
local MissionService = require(script.Parent.MissionService)

local SecondsPlayedService = require(script.SecondsPlayedService);
local LogInService = require(script.LogInService);
--local LevelService = require(script.LevelService);

function StatTrackService.GetData(Player)
	local Profile = DataService:GetProfile(Player)
	local Data = Profile.Data
	return Data
end

function StatTrackService:SetStat(Player,StatName,Value)
    MissionService.Check(Player,StatName,Value)--// Checking
end;

function StatTrackService:GetLevel(Player)
    if Player then
        local Profile = DataService:GetProfile(Player);
        if Profile then
            --LevelService:GetLevel(Player,Profile);
        end;
    end;
end;

function StatTrackService:SetLevel(Player, Value)
    if Player then
        local Profile = DataService:GetProfile(Player);
        if Profile then
            --LevelService:SetLevel(Player,Profile, Value);
        end;
    end;
end;

function StatTrackService:GetEXP(Player)
    if Player then
        local Profile = DataService:GetProfile(Player);
        if Profile then
            --LevelService:GetEXP(Player,Profile);
        end;
    end;
end;

function StatTrackService:SetEXP(Player, Value)
    if Player then
        local Profile = DataService:GetProfile(Player);
        if Profile then
            --LevelService:SetEXP(Player,Profile, Value);
        end;
    end;
end;

function StatTrackService:StartCountingSecondsPlayed(Player)
    if Player then
        local Profile = DataService:GetProfile(Player);
        if Profile then
            SecondsPlayedService:StartCountingSecondsPlayed(Player,Profile);
        end;
    end;
end;

function StatTrackService:StopCountingSecondsPlayed(Player)
	SecondsPlayedService:StopCountingSecondsPlayed(Player);
end

function StatTrackService:GetSecondsPlayed(Player)
    if Player then
        local Profile = DataService:GetProfile(Player);
        if Profile then
            SecondsPlayedService:GetSecondsPlayed(Player,Profile);
        end;
    end;
end;

function StatTrackService:StartTracking(Player)
    local Profile = DataService:GetProfile(Player);
    if Profile then
        --print("[StatTrackService]: Tracking all stats for player["..tostring(Player).."]");
        LogInService:Increment(Player,Profile);
        SecondsPlayedService:StartCountingSecondsPlayed(Player,Profile);
    end;
end;

function StatTrackService:StopTracking(Player)
    --print("[StatTrackService]: Stopped tracking all stats for player["..tostring(Player).."]");
	SecondsPlayedService:StopCountingSecondsPlayed(Player);
end;


return StatTrackService;
