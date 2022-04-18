--[[
	Name: Time Service [V1]
	Creator: Real_KingBob
	Made in: 11/8/21
	Description: Handles time for missions to expire, plain and simple
]]

local TimeService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameLibrary = ReplicatedStorage:WaitForChild("Common")
--local RemoteEvents = GameLibrary:WaitForChild("RemoteEvents")
--local SendMissionsEvent = RemoteEvents:WaitForChild("SendMissions")

function TimeService:WatchTime(player,profile, lastLogin, missionTime)
	print("[TimeService]: Watching time for ",player,lastLogin,missionTime)
	task.spawn(function()
		while task.wait(1) do
			if player and lastLogin and missionTime then
				local seconds = missionTime - (os.time() - lastLogin)
				if seconds <= 0 then
					break;
				end
				local minutes = seconds/60
				local hours = minutes/60  
				--SendMissionsEvent:FireClient(player, {profile.Data.Missions, tostring('%.2d:%.2d:%.2d'):format(hours, minutes%(60), seconds%(60))})
				--print(('Daily Mission: %.2d:%.2d:%.2d'):format(hours, minutes%(60), seconds%(60)))
			end
		end

		return self:CheckTime(player, profile, missionTime)
	end)
end

function TimeService:CheckTime(player, profile, missionTime)
	print("[TimeService]: Checking time for ",player,profile,missionTime)
	if player and profile and missionTime then
		--profile.Data.PlayerInfo.MissionInfo = false; -- RESETS TIME STATS
		if type(profile.Data.PlayerInfo.MissionInfo) ~= "table" then 
			profile.Data.PlayerInfo.MissionInfo = {nil, nil};
		end
		
		local lastOnline = profile.Data.PlayerInfo.MissionInfo[1]
		local currentTime = os.time()

		local timeDifference

		if lastOnline then
			timeDifference = currentTime - lastOnline
		end
		
		if not timeDifference or timeDifference >= missionTime then -- # hours pass aka next day or no data

			local streak = profile.Data.PlayerInfo.MissionInfo[2] or 0
			local timeAfterDifference
			
			print("Give missions here");
            local MissionService = require(script.Parent);
            MissionService:ResetMissions(player);
            
            local Mission1 = MissionService:CreateRandomMission(player);
            task.wait(.05)
            local Mission2 = MissionService:CreateRandomMission(player);
            task.wait(.05)
            local Mission3 = MissionService:CreateRandomMission(player);

            Mission1:StartMission(player, profile);
            Mission2:StartMission(player, profile);
            Mission3:StartMission(player, profile);

			streak = streak + 1
			if timeDifference then
				timeAfterDifference = timeDifference - (missionTime)
				if timeAfterDifference >= missionTime then
					profile.Data.PlayerInfo.MissionInfo = {os.time(), 0}
				else
					profile.Data.PlayerInfo.MissionInfo = {os.time() - timeAfterDifference, streak}
				end
			else
				profile.Data.PlayerInfo.MissionInfo = {os.time(), streak}
			end
			
			return self:WatchTime(player, profile, profile.Data.PlayerInfo.MissionInfo[1], missionTime)
		elseif timeDifference then -- if data, wait till 24 hours yeps
			return self:WatchTime(player, profile, lastOnline, missionTime)
		end
	end
end

return TimeService;