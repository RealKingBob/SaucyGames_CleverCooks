--[[
    Name: Duck Weapons [V1]
    By: Real_KingBob
	
	--// Rarite Types: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary
    Methods:

	DucksSkins.getItemFromName(Name) -- returns duck skin data from name
		Name   [string]
		-- Example return: "{
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
					["Key"] = "Goose",
                    ["Model"] = Goose,
                    ["Name"] = "Default Duck",
                    ["Rarity"] = 1
                 }"

	DucksSkins.getItemFromKey(Key) -- returns duck skin data from key
		Name   [string]
		-- Example return: "{
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
					["Key"] = "Goose",
                    ["Model"] = Goose,
                    ["Name"] = "Default Duck",
                    ["Rarity"] = 1
                 }"

	DucksSkins.getCrateInfoFromId(ID) -- returns crate info from crate ID
		ID   [number]
		-- Example return: "["Crate1"] = {
						["Name"] = "Crate 1",
						["CrateId"] = 1, -- In no crates
						["DecalId"] = 8247203005,
						["Price"] = 100,
					},""

	DucksSkins.getCrateContentsFromId(ID) -- returns crate items from crate ID
		ID   [number]
		-- Example return: "["Default"] =  ▼  {
                       ["CrateId"] = 1,
                       ["DecalId"] = 8249188754,
                       ["IndividualPrice"] = 300,
					   ["Key"] = "Turkey",
                       ["Model"] = Royal Duck,
                       ["Name"] = "Turkey",
                       ["Rarity"] = 2
                    },
                    ["QA Duck"] =  ▶ {...},
                    ["Turkey"] =  ▶ {...},
                    [4] =  ▶ {...},
                    [5] =  ▶ {...},
                    [6] =  ▶ {...},
                    [7] =  ▶ {...},
                    [8] =  ▶ {...},
                    [9] =  ▶ {...},
                    [10] =  ▶ {...}"

	DucksSkins.selectRandomKey(crateId) -- returns random duck data based off rarity chance
		ID   [number] [OPTIONAL]
		-- Example return: "QA Duck"

	DucksSkins.selectRandomItem(crateId) -- returns random duck data based off rarity chance
		ID   [number] [OPTIONAL]
		-- Example return: "{
					["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
					["Key"] = "Flamingo",
                    ["Model"] = Flamingo,
                    ["Name"] = "Flamingo",
                    ["Rarity"] = 1
				}"
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuckModels = ReplicatedStorage.Assets.DuckModels
local Rarities = require(script.Parent.Rarities)

local DucksWeapons = {};

DucksWeapons.CratesTable = {
	--[[["Crate1"] = {
		Name = "Animal Crate",
		Key = "Crate1",
		CrateId = 1, -- In no crates
		CrateType = "Skins",
		DecalId = "rbxassetid://8321764473",
		UnboxingIcons = {
			[1] = "rbxassetid://8322575070",
			[2] = "rbxassetid://8322574923",
			[3] = "rbxassetid://8322574790",
			[4] = "rbxassetid://8322574630",
		},
		Price = 1000,
	},
	["Crate2"] = {
		Name = "Costume Crate",
		Key = "Crate2",
		CrateId = 2, -- In no crates
		CrateType = "Skins",
		DecalId = "rbxassetid://8321764473",
		UnboxingIcons = {
			[1] = "rbxassetid://8322575070",
			[2] = "rbxassetid://8322574923",
			[3] = "rbxassetid://8322574790",
			[4] = "rbxassetid://8322574630",
		},
		Price = 1000,
	},
	["Crate3"] = {
		Name = "Anime Crate",
		Key = "Crate3",
		CrateId = 3, -- In no crates
		CrateType = "Skins",
		DecalId = "rbxassetid://8321764473",
		UnboxingIcons = {
			[1] = "rbxassetid://8322575070",
			[2] = "rbxassetid://8322574923",
			[3] = "rbxassetid://8322574790",
			[4] = "rbxassetid://8322574630",
		},
		Price = 1000,
	},]]
};

DucksWeapons.SkinsTable = {
	--// EXCLUSIVE
	["Default"] = {
		Name = "Baguette",
		Key = "Default Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1, -- Not obtainable
		CrateId = -1, -- In no crates
		DecalId = "rbxassetid://8247202970",
		IndividualPrice = 0, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Default Duck"),
		Tradeable = false
	},
	["QA Duck"] = {
		Name = "QA Duck",
		Key = "QA Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = -1,
		CrateId = -1,
		DecalId = "rbxassetid://8751478305",
		IndividualPrice = 0, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("QA Duck"),
		Tradeable = false
	},
	["VIP Duck"] = {
		Name = "VIP Duck",
		Key = "VIP Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = -1,
		CrateId = -1,
		DecalId = "rbxassetid://8249195091",
		IndividualPrice = 0, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("VIP Duck"),
		Tradeable = false
	},
	["Karl"] = {
		Name = "Karl",
		Key = "Karl",
		ItemType = "Skins",
		Visible = true;
		Rarity = -1,
		CrateId = -1,
		DecalId = "rbxassetid://8476224280",
		IndividualPrice = 0, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Karl"),
		Tradeable = false
	},
};

function DucksWeapons.getCrateInfoFromId(ID)
    for _,crateData in next, DucksWeapons.CratesTable do
        if crateData.CrateId == ID then
            return crateData;
        end
    end
	return nil;
end

function DucksWeapons.getCrateContentsFromId(ID)
	local crateData = {};
    for skinsName,skinsData in next, DucksWeapons.SkinsTable do
        if skinsData.CrateId == ID then
			crateData[skinsName] = skinsData
        end
    end
	return crateData;
end

function DucksWeapons.getItemFromName(Name)
    for skinsTitle,skinsData in next, DucksWeapons.SkinsTable do
        if skinsTitle == Name then
            return skinsData;
        end
    end
	return nil;
end

function DucksWeapons.getItemFromKey(Key)
    for skinsTitle,skinsData in next, DucksWeapons.SkinsTable do
        if skinsData.Key == Key then
            return skinsData;
        end
    end
	return nil;
end

function DucksWeapons.getTable()
	return DucksWeapons.SkinsTable;
end

function DucksWeapons.getDuckSkinsFromRarity(rarity, dailyShop)
	local duckSkins = {};
	if dailyShop == true then
		for _, data in pairs(DucksWeapons.SkinsTable) do
			-- @todo: CHANGE THIS TO data.CrateId == -2 AFTER NEW SKINS
			if data.Rarity == rarity and data.CrateId ~= -1 and data.Visible == true then 
				table.insert(duckSkins, data);
			end
		end
	else
		for _, data in pairs(DucksWeapons.SkinsTable) do
			if data.Rarity == rarity and data.CrateId > 0 and data.Visible == true then
				table.insert(duckSkins, data);
			end
		end
	end
	return duckSkins;
end

function DucksWeapons.selectRandomKey(crateId)
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		if rarityData.ID == -1 then
			continue;
		end
		chanceCounter = chanceCounter + rarityData.Chance;
		if generatedNumber <= chanceCounter then
			local duckRarityTable = {};

			if crateId then
				for _, data in pairs(DucksWeapons.SkinsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			else
				for _, data in pairs(DucksWeapons.SkinsTable) do
					if data.Rarity == rarityData.ID then
						table.insert(duckRarityTable, data);
					end
				end
			end
			local chosenDuckData = duckRarityTable[math.random(1, #duckRarityTable)];
			return chosenDuckData.Key;
		end
	end
end

function DucksWeapons.selectRandomItem(crateId)
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		if rarityData.ID == -1 then
			continue;
		elseif crateId == -2 then
			local duckRarityTable = {};
			if crateId then
				for _, data in pairs(DucksWeapons.SkinsTable) do
					if data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			end
			local chosenDuckData = duckRarityTable[math.random(1, #duckRarityTable)];
			return chosenDuckData;
		end
		chanceCounter = chanceCounter + rarityData.Chance;
		if generatedNumber <= chanceCounter then
			local duckRarityTable = {};

			if crateId then
				for _, data in pairs(DucksWeapons.SkinsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			else
				for _, data in pairs(DucksWeapons.SkinsTable) do
					if data.Rarity == rarityData.ID then
						table.insert(duckRarityTable, data);
					end
				end
			end
			local chosenDuckData = duckRarityTable[math.random(1, #duckRarityTable)];
			return chosenDuckData;
		end
	end
end


return DucksWeapons;