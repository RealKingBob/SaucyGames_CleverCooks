--[[
    Name: Death Effects [V1]
    By: Real_KingBob
    Methods:

	DuckEmotes.getDuckSkinFromName(Name) -- returns duck emotes data from name
		Name   [string]
		-- Example return: "{
                    ["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
                    ["Name"] = "Default Duck",
                    ["Rarity"] = 1
                 }"
	
	DuckEmotes.getCrateItemsFromId(ID) -- returns crate items from crate ID
		ID   [number]
		-- Example return: "[1] =  ▼  {
                       ["CrateId"] = 1,
                       ["DecalId"] = 8249188754,
                       ["IndividualPrice"] = 300,
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

	DuckEmotes.selectRandomDuck() -- returns random duck emotes data based off rarity chance
		-- Example return: "{
					["CrateId"] = 1,
                    ["DecalId"] = 8247203005,
                    ["IndividualPrice"] = 100,
                    ["Name"] = "Flamingo",
                    ["Rarity"] = 1
				}"
]]
local Rarities = require(script.Parent.Rarities)

--// Rarite Types: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary, 5 = Mythic

local DuckEmotes = {};

DuckEmotes.EmotesTable = {};

function DuckEmotes.getCrateItemsFromId(ID)
	local crateData = {};
    for _,skinsData in next, DuckEmotes.EmotesTable do
        if skinsData.CrateId == ID then
            table.insert(crateData,skinsData);
        end
    end
	return crateData;
end

function DuckEmotes.getDuckSkinFromName(Name)
    for skinsTitle,skinsData in next, DuckEmotes.EmotesTable do
        if skinsTitle == Name then
            return skinsData;
        end
    end
	return nil;
end

function DuckEmotes.selectRandomDuck()
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		if rarityData.ID == -1 then
			continue;
		end
		chanceCounter = chanceCounter + rarityData.Chance;
		if generatedNumber <= chanceCounter then
			local duckRarityTable = {};

			for _, data in pairs(DuckEmotes.SkinsTable) do
				if data.Rarity == rarityData.ID then
					table.insert(duckRarityTable, data);
				end
			end
			local chosenDuckData = duckRarityTable[math.random(1,#duckRarityTable)];
			return chosenDuckData;
		end
	end
end


return DuckEmotes;