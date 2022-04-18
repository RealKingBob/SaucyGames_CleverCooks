local BaseClass = require(script.Parent.BaseClass);
local TableAPI = require(script.Parent.Parent.Parent.APIs.TableAPI);
local MathAPI = require(script.Parent.Parent.Parent.APIs.MathAPI);
local RewardService = require(script.Parent.Parent.RewardService);

local WinTypeService = BaseClass.class{};

function WinTypeService:__init(name, id)
    self.name = name;
    self.id = id;
    self.reward = {};
    self.requirements = {};
end;

function WinTypeService:GetName()
    return self.name;
end;

function WinTypeService:GetId()
    return self.id;
end;

function WinTypeService:GetReward()
    return self.reward;
end;

function WinTypeService:GetRequirements()
    return self.requirements;
end;

function WinTypeService:SetName(name)
    self.name = name;
end;

function WinTypeService:SetId(id)
    self.id = id;
end;

function WinTypeService:SetReward(reward)
    self.reward = reward;
end;

function WinTypeService:SetRequirements(requirements)
    self.requirements = requirements;
end;

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

function WinTypeService:ConfigureMission(Mission, MissionTemplate, WinMultiplier, RecipeModule)
	print("MissionTemplate", Mission, MissionTemplate)
	local MissionTemplate = deepCopy(MissionTemplate)
	if MissionTemplate.ID == 1 then
        local AmountOfFood = math.random(1,1);
		local nameString = ('Cook %d '):format(AmountOfFood)..(AmountOfFood > 1 and "Foods" or "Food");
		--print(nameString)
		Mission:SetName(nameString);
        local RawCalculatedCoins = (MissionTemplate.Reward.Coins * (AmountOfFood or 1));
        local RawCalculatedEXP = (MissionTemplate.Reward.EXP * (AmountOfFood or 1));
		MissionTemplate.Reward.Coins = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedCoins, 2);
        MissionTemplate.Reward.EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2);
        MissionTemplate.Requirements.FoodCooked = AmountOfFood;
	elseif MissionTemplate.ID == 2 then
		local RandomFood = RecipeModule:GetRandomRecipe();
		--print(RandomFood)
		local nameString = ('Cook %s'):format(RandomFood.Name);
		--print(nameString)
		Mission:SetName(nameString);
        local RawCalculatedCoins = math.floor((MissionTemplate.Reward.Coins * (#(RandomFood.Ingredients) * WinMultiplier)));
		local RawCalculatedEXP = (RawCalculatedCoins / (WinMultiplier / (WinMultiplier / RawCalculatedCoins)));
		MissionTemplate.Reward.Coins = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedCoins, 2);
        MissionTemplate.Reward.EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2);
		MissionTemplate.Requirements.RecentFoodMade = RandomFood.Name;
        MissionTemplate.Requirements.FoodCooked = 1;
    elseif MissionTemplate.ID == 3 then
        local AmountOfFood = math.random(1,2);
        local RandomFood = RecipeModule:GetRandomRecipe();
        --print(RandomFood)
        local nameString = ('Cook %d %s'):format(AmountOfFood, RandomFood.Name);
		--print(nameString)
		Mission:SetName(nameString);
        local RawCalculatedCoins = math.floor((MissionTemplate.Reward.Coins * 
            ((#(RandomFood.Ingredients) + (MissionTemplate.Requirements.FoodCooked or 1)) * 
            (1 + (WinMultiplier/1.2)))));
        local RawCalculatedEXP = math.floor(RawCalculatedCoins / (WinMultiplier / (WinMultiplier / RawCalculatedCoins)));
		MissionTemplate.Reward.Coins = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedCoins, 2);
        MissionTemplate.Reward.EXP = MathAPI:Find_Closest_Divisible_Integer(RawCalculatedEXP, 2);
        MissionTemplate.Requirements.RecentFoodMade = RandomFood.Name;
        MissionTemplate.Requirements.FoodCooked = AmountOfFood;
	end;
    return MissionTemplate;
end;

function WinTypeService:StartMission(player, profile)
    if player and profile then
        print("[MissionHandler]: "..player.Name .. " is starting a mission");
        --print("ModuleResponse: ",PlayerMissions)

        for MissionIndex,Mission in pairs(profile.Data.Missions) do
            if Mission and Mission.id == 0 then
                table.remove(profile.Data.Missions, MissionIndex);
            end;
        end;

        for _,Mission in pairs(profile.Data.Missions) do
            --print(Mission)
            if Mission and Mission.id == self:GetId() then
                print("[MissionHandler]: "..player.Name .. " already has this mission, rerolling mission");
                local MissionService = require(script.Parent);
                MissionService:CreateRandomMission(player, "Cook")
                return;
            end;
        end;

        local AmountOfMissions = table.getn(profile.Data.Missions) --// Amount of Missions
        local Mission = {};
        Mission.id = self:GetId();
		Mission.progress = {};
		Mission.requirements = self:GetRequirements();
        Mission.reward = self:GetReward();
        Mission.timestamp = os.time();
        Mission.self = self;
        --rint("before",PlayerMissions)
        table.insert(profile.Data.Missions,AmountOfMissions + 1,Mission);
        --print("after",PlayerMissions)
    end;
end;

function WinTypeService:RemoveMission(player, profile)
    if player and profile then
        print("[MissionHandler]: "..player.Name .. " is removing a mission");
        local CurrentMission = nil;

        for _,Mission in pairs(profile.Data.Missions) do
            if Mission and Mission.id == self:GetId() then
                CurrentMission = Mission;
                break;
            end;
        end;
        
        if CurrentMission then
            table.remove(profile.Data.Missions, TableAPI.Find(profile.Data.Missions,CurrentMission));
        end;
    end;
end;

function WinTypeService:CompleteMission(player, profile)
	print(player,profile)
    if player and profile then
        print("[MissionHandler]: "..player.Name .. " is clearing a mission",profile.Data.Missions,self:GetId());

        for _,Mission in pairs(profile.Data.Missions) do
            print(Mission,Mission.id == self:GetId(),Mission.progress ~= true)
            if Mission and Mission.id == self:GetId() and Mission.progress ~= true then
                Mission.progress = true;
                RewardService:GiveReward(profile, Mission.reward)
                print("[MissionHandler]: "..player.Name .. " has completed this mission");
                --self:RemoveMission(player, profile)
            end;
        end;
    end;
end;

function WinTypeService:CheckProgress(player, profile)
    --print('TEST',player, profile)
    if player and profile then
        print("[MissionHandler][CHECKING]: "..player.Name .. "'s progress on mission");

        if #profile.Data.Missions == 0 then
            print(player.Name .. " has no missions");
        else
            for _,Mission in pairs(profile.Data.Missions) do
                local CheckIfAllTrue = true;
                if Mission and Mission.progress ~= true then
                    for K, V in pairs(Mission.progress) do
                        --print(K,V)
                        if V ~= true then
                            CheckIfAllTrue = false
                        end;
                    end;
                elseif Mission and Mission.progress == true then
                    CheckIfAllTrue = false;
				end;
				--print("CheckIfAllTrue", CheckIfAllTrue)
                if CheckIfAllTrue == true then
                    Mission.self:CompleteMission(player,profile);
                end;
            end;
        end;
    end;
end;



return WinTypeService;