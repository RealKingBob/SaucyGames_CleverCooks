--[[
    Name: Duck Death Effects [V1]
    By: Real_KingBob
	
	--// Rarite Types: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary, 5 = Mythic
    Methods:

	DeathEffects.getItemFromName(Name) -- returns duck skin data from name
		Name   [string]
		-- Example return: "{
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
                    ["Model"] = Goose,
                    ["Name"] = "Default Duck",
                    ["Rarity"] = 1
                 }"
	

	DeathEffects.getItemFromKey(Key) -- returns duck skin data from key
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

	DeathEffects.getCrateInfoFromId(ID) -- returns crate info from crate ID
		ID   [number]
		-- Example return: "["Crate1"] = {
						["Name"] = "Crate 1",
						["CrateId"] = 1, -- In no crates
						["DecalId"] = 8247203005,
						["Price"] = 100,
					},""

	DeathEffects.getCrateContentsFromId(ID) -- returns crate items from crate ID
		ID   [number]
		-- Example return: "[1] =  ▼  {
                       ["CrateId"] = 1,
                       ["DecalId"] = 8249188754,
                       ["IndividualPrice"] = 300,
                       ["Model"] = Royal Duck,
                       ["Name"] = "Turkey",
                       ["Rarity"] = 2
                    },
                    [2] =  ▶ {...},
                    [3] =  ▶ {...},
                    [4] =  ▶ {...},
                    [5] =  ▶ {...},
                    [6] =  ▶ {...},
                    [7] =  ▶ {...},
                    [8] =  ▶ {...},
                    [9] =  ▶ {...},
                    [10] =  ▶ {...}"

	DeathEffects.selectRandomKey(crateId) -- returns random duck data based off rarity chance
		ID   [number] [OPTIONAL]
		-- Example return: "Burning"

	DeathEffects.selectRandomItem(crateId) -- returns random duck data based off rarity chance
		ID   [number] [OPTIONAL]
		-- Example return: "{
					["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
                    ["Model"] = Flamingo,
                    ["Name"] = "Flamingo",
                    ["Rarity"] = 1
				}"
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuckEffects = ReplicatedStorage.Assets.DeathEffects
local Rarities = require(script.Parent.Rarities)

--// Rarite Types: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary, 5 = Mythic

local DeathEffects = {};

DeathEffects.CratesTable = {
	["Crate1"] = {
		Name = "Effects Crate",
		Key = "Crate1",
		CrateId = 1, -- In no crates
		CrateType = "Effects",
		DecalId = "rbxassetid://8321764473",
		UnboxingIcons = {
			[1] = "rbxassetid://8322575070",
			[2] = "rbxassetid://8322574923",
			[3] = "rbxassetid://8322574790",
			[4] = "rbxassetid://8322574630",
		},
		Price = 600,
	},
};

DeathEffects.EffectsTable = {
    ["Default"] = {
		Name = "Default",
		Key = "Default",
		ItemType = "Effects",
		Rarity = 1, -- Not obtainable
		CrateId = -1, -- In no crates
		DecalId = "rbxassetid://8305495719",
		IndividualPrice = 0, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Default"),
		Tradeable = false
	},

    ["Burning"] = {
		Name = "Burning",
		Key = "Burning",
		ItemType = "Effects",
		Rarity = 1, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305495972",
		IndividualPrice = 600, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Burning"),
	},
    ["Dust"] = {
		Name = "Dust",
		Key = "Dust",
		ItemType = "Effects",
		Rarity = 1, 
		CrateId = 1,
		DecalId = "rbxassetid://8305495551",
		IndividualPrice = 600, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Dust"),
	},
	["Slime"] = {
		Name = "Slime",
		Key = "Slime",
		ItemType = "Effects",
		Rarity = 1, 
		CrateId = 1,
		DecalId = "rbxassetid://8509497276",
		IndividualPrice = 600, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Slime"),
	},
    ["Confetti"] = {
		Name = "Confetti",
		Key = "Confetti",
		ItemType = "Effects",
		Rarity = 2, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305495847",
		IndividualPrice = 1200, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Confetti"),
	},
    ["Fireworks"] = {
		Name = "Fireworks",
		Key = "Fireworks",
		ItemType = "Effects",
		Rarity = 2, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305495293",
		IndividualPrice = 1200, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Fireworks"),
	},
    ["Ghost"] = {
		Name = "Ghost",
		Key = "Ghost",
		ItemType = "Effects",
		Rarity = 3, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305495139",
		IndividualPrice = 1800, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Ghost"),
	},
    ["Bubble"] = {
		Name = "Bubble",
		Key = "Bubble",
		ItemType = "Effects",
		Rarity = 3, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305496152",
		IndividualPrice = 1800, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Bubble"),
	},
    ["Explosion"] = {
		Name = "Explosion",
		Key = "Explosion",
		ItemType = "Effects",
		Rarity = 4, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305495393",
		IndividualPrice = 2400, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Explosion"),
	},
	["Sun"] = {
		Name = "Sun",
		Key = "Sun",
		ItemType = "Effects",
		Rarity = 4, 
		CrateId = 1, 
		DecalId = "rbxassetid://8509497109",
		IndividualPrice = 2400, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Sun"),
	},
    ["Black Hole"] = {
		Name = "Black Hole",
		Key = "Black Hole",
		ItemType = "Effects",
		Rarity = 5, 
		CrateId = 1, 
		DecalId = "rbxassetid://8305496299",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckEffects:WaitForChild("Explosion"),
	},
};

function DeathEffects.getCrateInfoFromId(ID)
    for _,crateData in next, DeathEffects.CratesTable do
        if crateData.CrateId == ID then
            return crateData;
        end
    end
	return nil;
end

function DeathEffects.getCrateContentsFromId(ID)
	local crateData = {};
    for _,skinsData in next, DeathEffects.EffectsTable do
        if skinsData.CrateId == ID then
            table.insert(crateData,skinsData);
        end
    end
	return crateData;
end

function DeathEffects.getTable()
	return DeathEffects.EffectsTable;
end

function DeathEffects.getItemFromName(Name)
    for skinsTitle,skinsData in next, DeathEffects.EffectsTable do
        if skinsTitle == Name then
            return skinsData;
        end
    end
	return nil;
end

function DeathEffects.getItemFromKey(Key)
    for skinsTitle,skinsData in next, DeathEffects.EffectsTable do
        if skinsData.Key == Key then
            return skinsData;
        end
    end
	return nil;
end

function DeathEffects.selectRandomKey(crateId)
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
				for _, data in pairs(DeathEffects.EffectsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			else
				for _, data in pairs(DeathEffects.EffectsTable) do
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

function DeathEffects.selectRandomItem(crateId)
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
				for _, data in pairs(DeathEffects.EffectsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			else
				for _, data in pairs(DeathEffects.EffectsTable) do
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

return DeathEffects;