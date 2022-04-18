local WinTypeService = require(script.WinTypeService);
local DataService = require(script.Parent.DataService);
local TimeService = require(script.TimeService);

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local GameLibrary = ReplicatedStorage:FindFirstChild("Common");
local ReplicatedModules = GameLibrary:FindFirstChild("Modules");

local Missions = {}; --https://devforum.roblox.com/t/making-a-quests-system/1208204/7
local MissionTypes = {"Cook"};
local PlayerMissions = {};

local DailyMissionHours = 24*60*60; -- hours
local WinMultiplier = 1.2;

Missions.Mission1 = {
	Name = "Win %d matches",
	ID = 1,
	Type = "Win",
	Requirements = {TotalWins = 0},
	Reward = {Coins = 20, EXP = 10},
	Service = WinTypeService("Cook %d foods", 1) -- Name, ID
}

Missions.Mission2 = {
	Name = "Win as a %s",
	ID = 2,
	Type = "Win",
	Requirements = {TotalWins = 0, RecentCharacter = false}, -- {Food, Number of times food was made}
	Reward = {Coins = 25, EXP = 20},
	Service = WinTypeService("Cook %s", 2) -- Name, ID
}

Missions.Mission3 = {
	Name = "Win %d matches as a %s",
	ID = 3,
	Type = "Win",
	Requirements = {TotalWins = false, RecentCharacter = 0}, -- {Food, Number of times food was made}
	Reward = {Coins = 20, EXP = 20},
	Service = WinTypeService("Cook %d %s", 3) -- Name, ID
}


function Missions:GetRandomMissionType()
    local RandomNumber = math.random(1, #MissionTypes)
    local MissionType = MissionTypes[RandomNumber];
	return MissionType;
end;

function Missions:GetMissionIdsFromType(Type)
	local MissionIds = {};
	for _,Mission in pairs(Missions) do
		if type(Mission)== "table" and Mission["Type"] == Type then
			table.insert(MissionIds, tostring(Mission["ID"]))
		end;
	end;
	return MissionIds;
end;

function Missions:GetMissionFromID(ID)
	for _,Mission in pairs(Missions) do
		if type(Mission)== "table" and Mission["ID"] == ID then
			return Mission;
		end;
	end;
end;

function Missions:GetMissionFromName(Name)
	for _,Mission in pairs(Missions) do
		if type(Mission)== "table" and Mission["Name"] == Name then
			return Mission;
		end;
	end;
end;

function Missions:CheckAllProgress(Player)
	if Player then
        local Profile = DataService:GetProfile(Player)
        if Profile then
			print("Checking progress on:",#Profile.Data.Missions)
            if #Profile.Data.Missions > 0 then
				for k, Mission in pairs(Profile.Data.Missions) do
					--print(k,Mission)
					Mission.self:CheckProgress(Player, Profile)
					--Mission:CheckProgress(Player, Profile);
				end;
			end;
        end;
    end;
end;

function Missions:Copy(o)
	local function deepCopy(original)
		local copy = {};
		for k, v in pairs(original) do
			if type(v) == "table" then
				v = deepCopy(v);
			end;
			copy[k] = v;
		end;
		return copy;
	end;
	local copiedModule = deepCopy(o);
	return copiedModule;
end;

function Missions:CheckTime(Player)
	if Player then
		local Profile = DataService:GetProfile(Player);
		if Profile then
			TimeService:CheckTime(Player, Profile, DailyMissionHours);
		end;
	end;
end;

function Missions:ResetMissions(Player)
	if Player then
		local Profile = DataService:GetProfile(Player);
		if Profile then
			Profile.Data.Missions = {};
			PlayerMissions[Player] = {};
		end;
	end;
end;

function Missions:CreateRandomMission(Player, Type)
	local AvailableMissionIds = self:GetMissionIdsFromType((Type or self:GetRandomMissionType()));
	if not PlayerMissions[Player] then
		PlayerMissions[Player] = {};
	end;
	
	--[[for i,MissionId in pairs(AvailableMissionIds) do
		for _,PlayerMissionId in pairs(PlayerMissions[Player]) do
			if tonumber(MissionId) == tonumber(PlayerMissionId) then 
				
				table.remove(AvailableMissionIds, i);
			end;
		end;
	end;]]
	for _,PlayerMissionId in pairs(PlayerMissions[Player]) do
		for i = #AvailableMissionIds, 1, -1 do
			if AvailableMissionIds[i] == PlayerMissionId then
				--print("Removing MissionId",PlayerMissionId,"from array",AvailableMissionIds,PlayerMissions[Player])
				table.remove(AvailableMissionIds, i)
			end
		end
	end;
	local RandomNumber = math.random(1, #AvailableMissionIds);
	local RandomId = AvailableMissionIds[RandomNumber];
	local MissionName = "Mission" .. tostring(RandomId);
	local MissionTemplate = self[MissionName];
	local Mission = MissionTemplate["Service"];
	print("MM: - ",Mission,MissionTemplate)
	table.insert(PlayerMissions[Player], RandomId);

	if MissionTemplate.ID == 1 or MissionTemplate.ID == 2 or MissionTemplate.ID == 3 then
		MissionTemplate = WinTypeService:ConfigureMission(Mission, MissionTemplate, WinMultiplier);
	end;
	
	Mission:SetId(MissionTemplate.ID);
	Mission:SetRequirements(MissionTemplate.Requirements);
	Mission:SetReward(MissionTemplate.Reward);
	print("[MissionService]: Created Mission:","| NAME:", Mission:GetName(),"| ID:", Mission:GetId(),"| REQUIREMENTS:", Mission:GetRequirements(),"| REWARD:", Mission:GetReward());
	--[[Mission:StartMission(Player, Profile);
	if MissionTemplate.ID == 1 then
		Mission:CheckProgress(Player, Profile,"FoodCooked",MissionTemplate.Requirements.FoodCooked)
	elseif MissionTemplate.ID == 2 then
		Mission:CheckProgress(Player, Profile,"RecentFoodMade",MissionTemplate.Requirements.RecentFoodMade)
	end

	Mission:CompleteMission(Player, Profile)]]

	return Mission;
end;

function Missions:Initialize(Player, Profile)
	self:CheckTime(Player);
end;


return Missions;
