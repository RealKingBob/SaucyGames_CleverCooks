local LevelService = {};
--[[
local MathAPI = require(script.Parent.Parent.Parent.APIs.MathAPI);

function LevelService:GetLevel(Player,Profile)
	if Player then
		if Profile then
			local profileData = Profile.Data;
            return profileData.PlayerInfo.Level;
		end;
	end;
end;

function LevelService:SetLevel(Player,Profile, Value)
	if Player then
		if Profile then
			local profileData = Profile.Data;
            profileData.PlayerInfo.Level = Value;
            print("[LevelHandler]: "..Player.Name .. " is level " .. tostring(profileData.PlayerInfo.Level) .. " now!");
		end;
	end;
end;

function LevelService:LevelProgress(Player, Profile)
    if Player then
        if Profile then
			local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
            local profileData = Profile.Data;
            local maxEXP = MathAPI:getSum(profileData.PlayerInfo.Level);
			local DataService = Knit.GetService("DataService")
    
            if profileData.PlayerInfo.EXP >= maxEXP then
				self:SetLevel(Player, Profile, self:GetLevel() + 1)
				self:SetEXP(Player, Profile, - maxEXP)
				local Payload = {Profile.Data.PlayerInfo.Level, (Profile.Data.PlayerInfo.EXP / MathAPI:getSum(Profile.Data.PlayerInfo.Level))}
				DataService.Client.LevelSignal:Fire(Knit.DataService.GetPlayer(Profile), Payload)
                return self:LevelProgress(Player, Profile)
            else
				local Payload = {Profile.Data.PlayerInfo.Level, (Profile.Data.PlayerInfo.EXP / MathAPI:getSum(Profile.Data.PlayerInfo.Level))}
				DataService.Client.LevelSignal:Fire(Knit.DataService.GetPlayer(Profile), Payload)
                return profileData.PlayerInfo.Level;
            end
        end;
    end;
end;

function LevelService:GetEXP(Player,Profile)
	if Player then
		if Profile then
			local profileData = Profile.Data;
            return profileData.PlayerInfo.EXP;
		end;
	end;
end;

function LevelService:SetEXP(Player,Profile,Value)
	if Player then
		if Profile then
			local profileData = Profile.Data;
            profileData.PlayerInfo.EXP = Value;
			self:LevelProgress(Player,Profile)
			print("[LevelHandler]: "..Player.Name .. " EXP is " .. tostring(profileData.PlayerInfo.EXP) .. " now!");
		end;
	end;
end;]]


return LevelService;