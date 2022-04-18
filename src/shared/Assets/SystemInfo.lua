--[[
    Name: Maps Information [V1]
    By: Real_KingBob
]]

local SystemInfo = {};

SystemInfo.Maps = {
	["Tropical"] = {
		Name = "Captain's Cove",
		DecalId = "rbxassetid://8401434180",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Candyland"] = {
		Name = "Sugar Summit",
		DecalId = "rbxassetid://8599834597",
		TitleColor = Color3.fromRGB(255, 170, 255),
		StrokeColor = Color3.fromRGB(124, 82, 124),
	},
	["Wipeout"] = {
		Name = "Duckout",
		DecalId = "rbxassetid://8400801443",
		TitleColor = Color3.fromRGB(85, 255, 255),
		StrokeColor = Color3.fromRGB(63, 48, 12),
	},
	["Winterland"] = {
		Name = "Frosty Fortress",
		DecalId = "rbxassetid://8401434317",
		TitleColor = Color3.fromRGB(12, 138, 255),
		StrokeColor = Color3.fromRGB(0, 51, 94),
	},
	["Jungle"] = {
		Name = "Jumbled Jungle",
		DecalId = "rbxassetid://8400521703",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Cave"] = {
		Name = "Melty Caverns",
		DecalId = "rbxassetid://8629244140",
		TitleColor = Color3.fromRGB(255, 60, 0),
		StrokeColor = Color3.fromRGB(125, 25, 0),
	},
	["Desert"] = {
		Name = "Dusty Dunes",
		DecalId = "rbxassetid://8629245385",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Kingdom"] = {
		Name = "Kingdom",
		DecalId = "rbxassetid://8637332948",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Hexagon"] = {
		Name = "Hexagon Stadium",
		DecalId = "rbxassetid://9254925392",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["N/A"] = {
		Name = "N/A",
		DecalId = "",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
};

SystemInfo.HotPotatoMaps = {
	["Tropical"] = {
		Key = "TropicalPotato",
		Name = "Captain's Cove",
		DecalId = "rbxassetid://8401434180",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Candyland"] = {
		Key = "CandyPotato",
		Name = "Sugar Summit",
		DecalId = "rbxassetid://8599834597",
		TitleColor = Color3.fromRGB(255, 170, 255),
		StrokeColor = Color3.fromRGB(124, 82, 124),
	},
	["Wipeout"] = {
		Key = "WipePotato",
		Name = "Duckout",
		DecalId = "rbxassetid://8400801443",
		TitleColor = Color3.fromRGB(85, 255, 255),
		StrokeColor = Color3.fromRGB(63, 48, 12),
	},
	["Winterland"] = {
		Key = "WinterPotato",
		Name = "Frosty Fortress",
		DecalId = "rbxassetid://8401434317",
		TitleColor = Color3.fromRGB(12, 138, 255),
		StrokeColor = Color3.fromRGB(0, 51, 94),
	},
	["Jungle"] = {
		Key = "JunglePotato",
		Name = "Jumbled Jungle",
		DecalId = "rbxassetid://8400521703",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Cave"] = {
		Key = "CavePotato",
		Name = "Melty Caverns",
		DecalId = "rbxassetid://8629244140",
		TitleColor = Color3.fromRGB(255, 60, 0),
		StrokeColor = Color3.fromRGB(125, 25, 0),
	},
	["Desert"] = {
		Key = "DesertPotato",
		Name = "Dusty Dunes",
		DecalId = "rbxassetid://8629245385",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["Kingdom"] = {
		Key = "KingdomPotato",
		Name = "Kingdom",
		DecalId = "rbxassetid://8637332948",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["N/A"] = {
		Key = "N/A",
		Name = "N/A",
		DecalId = "",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
};

SystemInfo.Stadiums = {
	["Hexagon"] = {
		Key = "HexagonStadium",
		Name = "Hexagon Stadium",
		DecalId = "rbxassetid://9254925392",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
	["N/A"] = {
		Key = "N/A",
		Name = "N/A",
		DecalId = "",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
};

SystemInfo.GameModes = {
	["HOT POTATO"] = {
		Name = "HOT POTATO",
		GameModeColor = Color3.fromRGB(221, 30, 30),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Traps are disabled on the map\n- Don't get the potato!\n- Last player alive wins!",
	},
	["RACE MODE"] = {
		Name = "RACE MODE",
		GameModeColor = Color3.fromRGB(5, 138, 247),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Traps are automatic\n- Reach the end within the time limit first to win!",
	},
	["INFECTION MODE"] = {
		Name = "INFECTION",
		GameModeColor = Color3.fromRGB(5, 219, 5),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Traps are disabled on the map\n- You have ONE life!\n- Last player alive wins!",
	},
	["DOMINATION"] = {
		Name = "DOMINATION",
		GameModeColor = Color3.fromRGB(5, 138, 247),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Stay in the hill circle to get points!\n- Team with most points win!",
	},
	["DUCK OF THE HILL"] = {
		Name = "DUCK OF THE HILL",
		GameModeColor = Color3.fromRGB(255, 204, 0),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Stay in the hill circle to get points!\n- Duck with most points win!",
	},
	["CLASSIC MODE"] = {
		Name = "DUCK HUNT",
		GameModeColor = Color3.fromRGB(253, 255, 253),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Traps are disabled on the map\n- Don't get the potato!\n- Last player alive wins!",
	},

	["TILE FALLING"] = {
		Name = "TILE FALLING",
		GameModeColor = Color3.fromRGB(186, 19, 236),
		CharacterColor = Color3.fromRGB(0, 170, 255),
		CharacterText = "YOU ARE A DUCK",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
		HunterDescV = false,
		DuckDescV = false,
		RaceDescV = true,
		RaceDescText = "- Weapons are enabled!\n- Don't fall off the tiles!\n- Last player alive wins!",
	},

	["N/A"] = {
		Name = "N/A",
		DecalId = "",
		TitleColor = Color3.fromRGB(255, 204, 0),
		StrokeColor = Color3.fromRGB(125, 87, 0),
	},
};

function SystemInfo.getStadiumKeyFromName(Name)
	for mapTitle, mapData in next, SystemInfo.Stadiums do
        if mapTitle == Name then
            return mapData.Key;
        end
    end
	return nil;
end

function SystemInfo.getHotPotatoKeyFromName(Name)
	for mapTitle, mapData in next, SystemInfo.HotPotatoMaps do
        if mapTitle == Name then
            return mapData.Key;
        end
    end
	return nil;
end

function SystemInfo.getMapTitleFromName(Name)
    for mapTitle, mapData in next, SystemInfo.Maps do
        if mapData.Name == Name then
            return mapTitle;
        end
    end
	return nil;
end

return SystemInfo;