--[[
    Name: Hat Skins [V1]
    By: Real_KingBob
	
	--// Rarite Types: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary
    Methods:

	HatsSkins.getItemFromName(Name) -- returns Hat skin data from name
		Name   [string]
		-- Example return: "{
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
					["Key"] = "Goose",
                    ["Model"] = Goose,
                    ["Name"] = "Default Hat",
                    ["Rarity"] = 1
                 }"

	HatsSkins.getItemFromKey(Key) -- returns Hat skin data from key
		Name   [string]
		-- Example return: "{
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
					["Key"] = "Goose",
                    ["Model"] = Goose,
                    ["Name"] = "Default Hat",
                    ["Rarity"] = 1
                 }"

	HatsSkins.getCrateInfoFromId(ID) -- returns crate info from crate ID
		ID   [number]
		-- Example return: "["Crate1"] = {
						["Name"] = "Crate 1",
						["CrateId"] = 1, -- In no crates
						["DecalId"] = 8247203005,
						["Price"] = 100,
					},""

	HatsSkins.getCrateContentsFromId(ID) -- returns crate items from crate ID
		ID   [number]
		-- Example return: "["Default"] =  ▼  {
                       ["CrateId"] = 1,
                       ["DecalId"] = 8249188754,
                       ["IndividualPrice"] = 300,
					   ["Key"] = "Turkey",
                       ["Model"] = Royal Hat,
                       ["Name"] = "Turkey",
                       ["Rarity"] = 2
                    },
                    ["QA Hat"] =  ▶ {...},
                    ["Turkey"] =  ▶ {...},
                    [4] =  ▶ {...},
                    [5] =  ▶ {...},
                    [6] =  ▶ {...},
                    [7] =  ▶ {...},
                    [8] =  ▶ {...},
                    [9] =  ▶ {...},
                    [10] =  ▶ {...}"

	HatsSkins.selectRandomKey(crateId) -- returns random Hat data based off rarity chance
		ID   [number] [OPTIONAL]
		-- Example return: "QA Hat"

	HatsSkins.selectRandomItem(crateId) -- returns random Hat data based off rarity chance
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
local Rarities = require(script.Parent.Rarities)

local HatsSkins = {};

HatsSkins.CratesTable = {
	["HourlyCrate"] = {
		Name = "Hourly Crate",
		Key = "HourlyCrate",
		CrateId = 0, -- In no crates
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
	["Crate1"] = {
		Name = "Hat Crate 1",
		Key = "Crate1",
		CrateId = 1, -- In no crates
		CrateType = "Hats",
		DecalId = "rbxassetid://8321764473",
		UnboxingIcons = {
			[1] = "rbxassetid://8322575070",
			[2] = "rbxassetid://8322574923",
			[3] = "rbxassetid://8322574790",
			[4] = "rbxassetid://8322574630",
		},
		Price = 1000,
	},
};

HatsSkins.ItemsTable = {
--// EXCLUSIVE
	["Default Hat"] = {
		Name = "Default Hat",
		Key = "Default Hat",
		ItemType = "Hats",
		Visible = true;
		Rarity = 1, -- Not obtainable
		CrateId = -1, -- In no crates
		DecalId = "rbxassetid://11262933534",
		IndividualPrice = 0, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},

--// CRATE 1
	["Cooking Cap"] = {
		Name = "Cooking Cap",
		Key = "Cooking Cap",
		ItemType = "Hats",
		Visible = true;
		Rarity = 1,
		CrateId = 1,
		DecalId = "rbxassetid://11213708955",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["French Beret"] = {
		Name = "French Beret",
		Key = "French Beret",
		ItemType = "Hats",
		Visible = true;
		Rarity = 1,
		CrateId = 1,
		DecalId = "rbxassetid://11213708534",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["Colander"] = {
		Name = "Colander",
		Key = "Colander",
		ItemType = "Hats",
		Visible = true;
		Rarity = 1,
		CrateId = 1,
		DecalId = "rbxassetid://11213709286",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["Clever Top Chef Hat"] = {
		Name = "Clever Top Chef Hat",
		Key = "Clever Top Chef Hat",
		ItemType = "Hats",
		Visible = true;
		Rarity = 2,
		CrateId = 1,
		DecalId = "rbxassetid://11213709698",
		IndividualPrice = 2520, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["Olive Chef Hat"] = {
		Name = "Olive Chef Hat",
		Key = "Olive Chef Hat",
		ItemType = "Hats",
		Visible = true;
		Rarity = 2,
		CrateId = 1,
		DecalId = "rbxassetid://11213707122",
		IndividualPrice = 2520, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["Tomato Hat"] = {
		Name = "Tomato Hat",
		Key = "Tomato Hat",
		ItemType = "Hats",
		Visible = true;
		Rarity = 3,
		CrateId = 1,
		DecalId = "rbxassetid://11213706618",
		IndividualPrice = 3150, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["Mushroom Hat"] = {
		Name = "Mushroom Hat",
		Key = "Mushroom Hat",
		ItemType = "Hats",
		Visible = true;
		Rarity = 4,
		CrateId = 1,
		DecalId = "rbxassetid://11213707684",
		IndividualPrice = 4500, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},
	["Golden Chef Hat"] = {
		Name = "Golden Chef Hat",
		Key = "Golden Chef Hat",
		ItemType = "Hats",
		Visible = true;
		Rarity = 5,
		CrateId = 1,
		DecalId = "rbxassetid://11213708138",
		IndividualPrice = 7500, -- If it were to go on daily shop, this would be displayed
		Tradeable = false
	},


};

function HatsSkins.getCrateInfoFromId(ID)
    for _,crateData in next, HatsSkins.CratesTable do
        if crateData.CrateId == ID then
            return crateData;
        end
    end
	return nil;
end

function HatsSkins.getCrateContentsFromId(ID)
	local crateData = {};
    for skinsName,skinsData in next, HatsSkins.ItemsTable do
        if skinsData.CrateId == ID then
			crateData[skinsName] = skinsData
        end
    end
	return crateData;
end

function HatsSkins.getItemFromName(Name)
    for skinsTitle,skinsData in next, HatsSkins.ItemsTable do
        if skinsTitle == Name then
            return skinsData;
        end
    end
	return nil;
end

function HatsSkins.getItemFromKey(Key)
    for skinsTitle,skinsData in next, HatsSkins.ItemsTable do
        if skinsData.Key == Key then
            return skinsData;
        end
    end
	return nil;
end

function HatsSkins.getTable()
	return HatsSkins.ItemsTable;
end

function HatsSkins.getHatSkinsFromRarity(rarity, dailyShop)
	local HatSkins = {};
	if dailyShop == true then
		for _, data in pairs(HatsSkins.ItemsTable) do
			if data.Rarity == rarity and data.CrateId ~= -1 and data.CrateId ~= -3 and data.Visible == true then 
				table.insert(HatSkins, data);
			end
		end
	else
		for _, data in pairs(HatsSkins.ItemsTable) do
			if data.Rarity == rarity and data.CrateId > 0 and data.Visible == true then
				table.insert(HatSkins, data);
			end
		end
	end
	return HatSkins;
end

function HatsSkins.selectRandomKey(crateId)
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		if rarityData.ID == -1 then
			continue;
		end
		chanceCounter = chanceCounter + rarityData.Chance;
		if generatedNumber <= chanceCounter then
			local HatRarityTable = {};

			if crateId then
				for _, data in pairs(HatsSkins.ItemsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(HatRarityTable, data);
					end
				end
			else
				for _, data in pairs(HatsSkins.ItemsTable) do
					if data.Rarity == rarityData.ID then
						table.insert(HatRarityTable, data);
					end
				end
			end
			local chosenHatData = HatRarityTable[math.random(1, #HatRarityTable)];
			return chosenHatData.Key;
		end
	end
end

function HatsSkins.selectRandomItem(crateId)
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		if rarityData.ID == -1 then
			continue;
		elseif crateId == -2 then
			local HatRarityTable = {};
			if crateId then
				for _, data in pairs(HatsSkins.ItemsTable) do
					if data.CrateId == crateId then
						table.insert(HatRarityTable, data);
					end
				end
			end
			local chosenHatData = HatRarityTable[math.random(1, #HatRarityTable)];
			return chosenHatData;
		end
		chanceCounter = chanceCounter + rarityData.Chance;
		if generatedNumber <= chanceCounter then
			local HatRarityTable = {};

			if crateId then
				for _, data in pairs(HatsSkins.ItemsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(HatRarityTable, data);
					end
				end
			else
				for _, data in pairs(HatsSkins.ItemsTable) do
					if data.Rarity == rarityData.ID then
						table.insert(HatRarityTable, data);
					end
				end
			end
			local chosenHatData = HatRarityTable[math.random(1, #HatRarityTable)];
			return chosenHatData;
		end
	end
end


function HatsSkins.selectRandomItemWithContents(crateTable)
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		chanceCounter = chanceCounter + rarityData.Chance;
		if generatedNumber <= chanceCounter then
			local HatRarityTable = {};

			if crateTable then
				print(crateTable)
				for _, data in pairs(crateTable.HourlyShopItems) do
					if data.itemRarity == rarityData.ID then
						table.insert(HatRarityTable, data);
					end
				end
			end
			local chosenHatData = HatRarityTable[math.random(1, #HatRarityTable)];
			return chosenHatData;
		end
	end
end


return HatsSkins;