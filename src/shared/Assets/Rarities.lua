local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Name: Rarities [V1]
    By: Real_KingBob
    Desc: ID: Id for the rarity type, Chance: % of getting the item per rarity
    Methods:

    Rarities.getRarityDataFromDuckName(Name)
        Name   [string]
		-- Example return: "{
                       ["Name"] = "Common",
                       ["ID"] = 1,
                       ["Chance"] = 60,
                    }"

    Rarities.getRarityDataFromEffectsName(Name)
        Name   [string]
		-- Example return: "{
                       ["Name"] = "Common",
                       ["ID"] = 1,
                       ["Chance"] = 60,
                    }"

    Rarities.getRarityDataFromEmotesName(Name)
        Name   [string]
		-- Example return: "{
                       ["Name"] = "Common",
                       ["ID"] = 1,
                       ["Chance"] = 60,
                    }"

	Rarities.getIdFromRarityName(Name) -- returns Rarity ID from name
		Name   [string]
		-- Example return: "1"
	
	Rarities.getRarityDataFromId(ID) -- returns rarity data from rarity ID
		ID   [number]
		-- Example return: "{
                       ["Name"] = "Mythic",
                       ["ID"] = 5,
                       ["Chance"] = 1,
                    }"

	Rarities.getRarityDataFromRarityName(Name) -- returns random duck data based off rarity chance
		Name   [string]
		-- Example return: "{
                       ["Name"] = "Common",
                       ["ID"] = 1,
                       ["Chance"] = 60,
                    }"
    
    DuckSkin
]]
local Rarities = {}
local UiAssets = script.Parent.Parent.Parent:WaitForChild("UiAssets")

Rarities.RarityTable = {
    ["Exclusive"] = {
        Name = "Exclusive",
        ID = -1,
        Chance = -1,
        Gradient = UiAssets.RarityGradients:WaitForChild("Exclusive"),
        Color = Color3.fromRGB(255, 219, 16)
    };
    ["Legendary"] = {
        Name = "Legendary",
        ID = 5,
        Chance = 1,
        Gradient = UiAssets.RarityGradients:WaitForChild("Legendary"),
        Color = Color3.fromRGB(255, 31, 31)
    };
    ["Epic"] = {
        Name = "Epic",
        ID = 4,
        Chance = 3,
        Gradient = UiAssets.RarityGradients:WaitForChild("Epic"),
        Color = Color3.fromRGB(190, 24, 255)
    };
    ["Rare"] = {
        Name = "Rare",
        ID = 3,
        Chance = 6,
        Gradient = UiAssets.RarityGradients:WaitForChild("Rare"),
        Color = Color3.fromRGB(0, 132, 255)
    };
    ["Uncommon"] = {
        Name = "Uncommon",
        ID = 2,
        Chance = 30,
        Gradient = UiAssets.RarityGradients:WaitForChild("Uncommon"),
        Color = Color3.fromRGB(2, 241, 54)
    };
    ["Common"] = {
        Name = "Common",
        ID = 1,
        Chance = 60,
        Gradient = UiAssets.RarityGradients:WaitForChild("Common"),
        Color = Color3.fromRGB(187, 187, 187)
    };
}

function Rarities.getRarityChances()
    local Weights = {};
    for _,rarityData in next, Rarities.RarityTable do
        Weights[rarityData.Name] = rarityData.Chance
    end
	return Weights;
end

function Rarities.getRarityDataFromId(ID)
    for _,rarityData in next, Rarities.RarityTable do
        if rarityData.ID == ID then
            return rarityData;
        end
    end
	return nil;
end

function Rarities.getIdFromRarityName(Name)
    for rarityTitle,rarityData in next, Rarities.RarityTable do
        if rarityTitle == Name then
            return rarityData.ID;
        end
    end
	return nil;
end

function Rarities.getRarityDataFromRarityName(Name)
    for rarityTitle,rarityData in next, Rarities.RarityTable do
        if rarityTitle == Name then
            return rarityData;
        end
    end
	return nil;
end

function Rarities.getRarityDataFromItemName(Name)
    --[[local DucksSkins = require(ReplicatedStorage.Common.Assets.DuckSkins)
    for duckTitle,duckData in next, DucksSkins.SkinsTable do
        if duckTitle == Name then
            return Rarities.getRarityDataFromId(duckData.Rarity);
        end
    end]]
	return nil;
end

return Rarities;