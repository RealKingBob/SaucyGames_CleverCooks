--[[
    Name: Duck Skins [V1]
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

local DucksSkins = {};

DucksSkins.CratesTable = {
	["Crate1"] = {
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
	},
};

DucksSkins.SkinsTable = {
	--// EXCLUSIVE
	["Default Duck"] = {
		Name = "Default Duck",
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

	--// BATTLEPASS
	["Mushroom Duck"] = {
		Name = "Mushroom Duck",
		Key = "Mushroom Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 1,
		CrateId = -3,
		DecalId = "rbxassetid://9283319033",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Mushroom Duck"),
		Tradeable = false,
	},
	["Cow Duck"] = {
		Name = "Cow Duck",
		Key = "Cow Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 1,
		CrateId = -3,
		DecalId = "rbxassetid://9283318865",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Cow Duck"),
		Tradeable = false,
	},
	["Snowman"] = {
		Name = "Snowman",
		Key = "Snowman",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = -3,
		DecalId = "rbxassetid://9283319653",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Snowman"),
		Tradeable = false,
	},
	["Rock Duck"] = {
		Name = "Rock Duck",
		Key = "Rock Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = -3,
		DecalId = "rbxassetid://9283319548",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Rock Duck"),
		Tradeable = false,
	},
	["Pig Skin"] = {
		Name = "Pig Duck",
		Key = "Pig Skin",
		ItemType = "Skins",
		Visible = false;
		Rarity = 2,
		CrateId = -3,
		DecalId = "rbxassetid://9283319257",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Pig Skin"),
		Tradeable = false,
	},
	["Bee"] = {
		Name = "Bee Duck",
		Key = "Bee",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = -3,
		DecalId = "rbxassetid://9283318749",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Bee"),
		Tradeable = false,
	},
	["Wizard"] = {
		Name = "Wizard",
		Key = "Wizard",
		ItemType = "Skins",
		Visible = false;
		Rarity = 2,
		CrateId = -3,
		DecalId = "rbxassetid://9283326512",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Wizard"),
		Tradeable = false,
	},
	["Pizza Man Skin"] = {
		Name = "Pizza Delivery Duck",
		Key = "Pizza Man Skin",
		ItemType = "Skins",
		Visible = false;
		Rarity = 3,
		CrateId = -3,
		DecalId = "rbxassetid://9283319397",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Pizza Man Skin"),
		Tradeable = false,
	},
	["Princess Duck"] = {
		Name = "Princess Duck",
		Key = "Princess Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 3,
		CrateId = -3,
		DecalId = "rbxassetid://9283319457",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Princess Duck"),
		Tradeable = false,
	},
	["Grassblock Duck"] = {
		Name = "Grassblock Duck",
		Key = "Grassblock Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = -3,
		DecalId = "rbxassetid://9283318963",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Grassblock Duck"),
		Tradeable = false,
	},


	--// DAILY ITEMS
	["Graduat Duck"] = {
		Name = "Graduat Duck",
		Key = "Graduat Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 1,
		CrateId = -2,
		DecalId = "rbxassetid://8905095669",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Graduat Duck")
	},
	["Toucan Duck"] = {
		Name = "Toucan Duck",
		Key = "Toucan Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 1,
		CrateId = -2,
		DecalId = "rbxassetid://8905096111",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Toucan Duck")
	},
	["Zombie"] = {
		Name = "Zombie",
		Key = "Zombie",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = -2,
		DecalId = "rbxassetid://8337107439",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Zombie")
	},
	["Shinigami Duck"] = {
		Name = "Shinigami Duck",
		Key = "Shinigami Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = -2,
		DecalId = "rbxassetid://8860988507",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Shinigami Duck")
	},
	["Robo Duck"] = {
		Name = "Robo Duck",
		Key = "Robo Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = -2,
		DecalId = "rbxassetid://8337101906",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Robo Duck")
	},
	["Alien Duck"] = {
		Name = "Alien Duck",
		Key = "Alien Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 2,
		CrateId = -2,
		DecalId = "rbxassetid://8905097645",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Alien Duck")
	},
	["Skeleton Duck"] = {
		Name = "Skeleton Duck",
		Key = "Skeleton Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = -2,
		DecalId = "rbxassetid://8370143969",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Skeleton Duck")
	},
	["Super Duck"] = {
		Name = "Super Duck",
		Key = "Super Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 2,
		CrateId = -2,
		DecalId = "rbxassetid://8905096922",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Super Duck")
	},
	["Bear Onesie Duck"] = {
		Name = "Bear Onesie Duck",
		Key = "Bear Onesie Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 3,
		CrateId = -2,
		DecalId = "rbxassetid://8905095304",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Bear Onesie Duck")
	},
	["Chef Duck"] = {
		Name = "Chef Duck",
		Key = "Chef Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 3,
		CrateId = -2,
		DecalId = "rbxassetid://8905097979",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Chef Duck")
	},
	["Elf"] = {
		Name = "Elf",
		Key = "Elf",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = -2,
		DecalId = "rbxassetid://8370142842",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Elf")
	},
	["Police Duck"] = {
		Name = "Police Duck",
		Key = "Police Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 4,
		CrateId = -2,
		DecalId = "rbxassetid://8905098329",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Police Duck")
	},
	["Squid Duck"] = {
		Name = "Squid Duck",
		Key = "Squid Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = -2,
		DecalId = "rbxassetid://8249192688",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Squid Duck")
	},
	["Shuba Duck"] = {
		Name = "Shuba Duck",
		Key = "Shuba Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 4,
		CrateId = -2,
		DecalId = "rbxassetid://8905097318",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Shuba Duck")
	},
	["Vampire"] = {
		Name = "Vampire",
		Key = "Vampire",
		ItemType = "Skins",
		Visible = true;
		Rarity = 5,
		CrateId = -2,
		DecalId = "rbxassetid://8337105297",
		IndividualPrice = 5000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Vampire")
	},
	["Crusader Duck"] = {
		Name = "Crusader Duck",
		Key = "Crusader Duck",
		ItemType = "Skins",
		Visible = false;
		Rarity = 5,
		CrateId = -2,
		DecalId = "rbxassetid://8905096517",
		IndividualPrice = 5000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Crusader Duck")
	},


	--// CRATE 1
	["Chicken"] = {
		Name = "Chicken",
		Key = "Chicken",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 1,
		DecalId = "rbxassetid://8337108702",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Chicken")
	},
	["Goose"] = {
		Name = "Goose",
		Key = "Goose",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 1,
		DecalId = "rbxassetid://8249191283",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Goose")
	},
	["Turkey"] = {
		Name = "Turkey",
		Key = "Turkey",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 1,
		DecalId = "rbxassetid://8249188730",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Turkey")
	},
	["Flamingo"] = {
		Name = "Flamingo",
		Key = "Flamingo",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = 1,
		DecalId = "rbxassetid://8303655303",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Flamingo")
	},
	["Penguin"] = {
		Name = "Penguin",
		Key = "Penguin",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = 1,
		DecalId = "rbxassetid://8303586110",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Penguin")
	},
	["Panda"] = {
		Name = "Panda",
		Key = "Panda",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = 1,
		DecalId = "rbxassetid://8337109791",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Panda")
	},
	["Rubber Duck"] = {
		Name = "Rubber Duck",
		Key = "Rubber Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = 1,
		DecalId = "rbxassetid://8249192138",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Rubber Duck")
	},
	["Shark"] = {
		Name = "Shark",
		Key = "Shark",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = 1,
		DecalId = "rbxassetid://8337103443",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Shark")
	},
	["Wyduck"] = {
		Name = "Wyduck",
		Key = "Wyduck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = 1,
		DecalId = "rbxassetid://8249189533",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Wyduck")
	},
	["Phoenix"] = {
		Name = "Phoenix",
		Key = "Phoenix",
		ItemType = "Skins",
		Visible = true;
		Rarity = 5,
		CrateId = 1,
		DecalId = "rbxassetid://8370143329",
		IndividualPrice = 5000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Phoenix")
	},

	--// CRATE 2
	["Agent Duck"] = {
		Name = "Agent Duck",
		Key = "Agent Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 2,
		DecalId = "rbxassetid://8370142009",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Agent Duck")
	},
	["Crook"] = {
		Name = "Crook",
		Key = "Crook",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 2,
		DecalId = "rbxassetid://8370142510",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Crook")
	},
	["Nerd Duck"] = {
		Name = "Nerd Duck",
		Key = "Nerd Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 2,
		DecalId = "rbxassetid://8370143090",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Nerd Duck")
	},
	["Cowboy"] = {
		Name = "Cowboy",
		Key = "Cowboy",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = 2,
		DecalId = "rbxassetid://8370142292",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Cowboy")
	},
	["Pirate Duck"] = {
		Name = "Pirate Duck",
		Key = "Pirate Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = 2,
		DecalId = "rbxassetid://8303655498",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Pirate Duck")
	},
	["Rich Duck"] = {
		Name = "Rich Duck",
		Key = "Rich Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = 2,
		DecalId = "rbxassetid://8370143535",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Rich Duck")
	},
	["Gladiator"] = {
		Name = "Gladiator",
		Key = "Gladiator",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = 2,
		DecalId = "rbxassetid://8642593978",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Gladiator")
	},
	["Astronaut"] = {
		Name = "Astronaut",
		Key = "Astronaut",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = 2,
		DecalId = "rbxassetid://8370141756",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Astronaut")
	},
	["Royal Duck"] = {
		Name = "Royal Duck",
		Key = "Royal Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = 2,
		DecalId = "rbxassetid://8249195710",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Royal Duck")
	},
	["Golden Duck"] = {
		Name = "Golden Duck",
		Key = "Golden Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 5,
		CrateId = 2,
		DecalId = "rbxassetid://8249190595",
		IndividualPrice = 5000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Golden Duck")
	},

	--// CRATE 3 [ANIME CRATE]
	["Gi Duck"] = {
		Name = "Gi Duck",
		Key = "Gi Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 3,
		DecalId = "rbxassetid://8697241837",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Gi Duck")
	},
	["Rookie Hunter Duck"] = {
		Name = "Rookie Hunter",
		Key = "Rookie Hunter Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 3,
		DecalId = "rbxassetid://8697240797",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Rookie Hunter Duck")
	},
	["Straw Hat Duck"] = {
		Name = "Straw Hat Duck",
		Key = "Straw Hat Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 1,
		CrateId = 3,
		DecalId = "rbxassetid://8697240416",
		IndividualPrice = 1000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Straw Hat Duck")
	},
	["One Punch Duck"] = {
		Name = "One Punch Duck",
		Key = "One Punch Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = 3,
		DecalId = "rbxassetid://8697241143",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("One Punch Duck")
	},
	["Titan Duck"] = {
		Name = "Titan Duck",
		Key = "Titan Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 2,
		CrateId = 3,
		DecalId = "rbxassetid://8697240245",
		IndividualPrice = 2000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Titan Duck")
	},
	["Honk Might"] = {
		Name = "Honk Might",
		Key = "Honk Might",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = 3,
		DecalId = "rbxassetid://8697241714",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Honk Might")
	},
	["Menacing Duck"] = {
		Name = "Menacing Duck",
		Key = "Menacing Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 3,
		CrateId = 3,
		DecalId = "rbxassetid://8697241346",
		IndividualPrice = 3000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Menacing Duck")
	},
	["Revenger Duck"] = {
		Name = "Revenger Duck",
		Key = "Revenger Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = 3,
		DecalId = "rbxassetid://8697240975",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Revenger Duck")
	},
	["Slayer Duck"] = {
		Name = "Slayer Duck",
		Key = "Slayer Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 4,
		CrateId = 3,
		DecalId = "rbxassetid://8697240552",
		IndividualPrice = 4000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Slayer Duck")
	},
	["Jujutsu Sorcerer Duck"] = {
		Name = "Jujutsu Sorcerer",
		Key = "Jujutsu Sorcerer Duck",
		ItemType = "Skins",
		Visible = true;
		Rarity = 5,
		CrateId = 3,
		DecalId = "rbxassetid://8697241551",
		IndividualPrice = 5000, -- If it were to go on daily shop, this would be displayed
		Model = DuckModels:WaitForChild("Jujutsu Sorcerer Duck")
	},
};

function DucksSkins.getCrateInfoFromId(ID)
    for _,crateData in next, DucksSkins.CratesTable do
        if crateData.CrateId == ID then
            return crateData;
        end
    end
	return nil;
end

function DucksSkins.getCrateContentsFromId(ID)
	local crateData = {};
    for skinsName,skinsData in next, DucksSkins.SkinsTable do
        if skinsData.CrateId == ID then
			crateData[skinsName] = skinsData
        end
    end
	return crateData;
end

function DucksSkins.getItemFromName(Name)
    for skinsTitle,skinsData in next, DucksSkins.SkinsTable do
        if skinsTitle == Name then
            return skinsData;
        end
    end
	return nil;
end

function DucksSkins.getItemFromKey(Key)
    for skinsTitle,skinsData in next, DucksSkins.SkinsTable do
        if skinsData.Key == Key then
            return skinsData;
        end
    end
	return nil;
end

function DucksSkins.getTable()
	return DucksSkins.SkinsTable;
end

function DucksSkins.getDuckSkinsFromRarity(rarity, dailyShop)
	local duckSkins = {};
	if dailyShop == true then
		for _, data in pairs(DucksSkins.SkinsTable) do
			-- @todo: CHANGE THIS TO data.CrateId == -2 AFTER NEW SKINS
			if data.Rarity == rarity and data.CrateId ~= -1 and data.Visible == true then 
				table.insert(duckSkins, data);
			end
		end
	else
		for _, data in pairs(DucksSkins.SkinsTable) do
			if data.Rarity == rarity and data.CrateId > 0 and data.Visible == true then
				table.insert(duckSkins, data);
			end
		end
	end
	return duckSkins;
end

function DucksSkins.selectRandomKey(crateId)
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
				for _, data in pairs(DucksSkins.SkinsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			else
				for _, data in pairs(DucksSkins.SkinsTable) do
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

function DucksSkins.selectRandomItem(crateId)
	local generatedNumber = math.random(1,100)
	local chanceCounter = 0
	for rarityTitle, rarityData in pairs(Rarities.RarityTable) do
		if rarityData.ID == -1 then
			continue;
		elseif crateId == -2 then
			local duckRarityTable = {};
			if crateId then
				for _, data in pairs(DucksSkins.SkinsTable) do
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
				for _, data in pairs(DucksSkins.SkinsTable) do
					if data.Rarity == rarityData.ID and data.CrateId == crateId then
						table.insert(duckRarityTable, data);
					end
				end
			else
				for _, data in pairs(DucksSkins.SkinsTable) do
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


return DucksSkins;