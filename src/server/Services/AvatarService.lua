--[[
    Name: Avatar Service [V1]
    By: Real_KingBob
    Date: 10/3/21 (Updated: 4/18/22)
    Description: This module handles all functions that changes the avatar of the duck
]]

----- Private Variables -----

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local AvatarService = Knit.CreateService {
    Name = "AvatarService";
    Client = {};
}

local AvatarServiceLogs = {};

local PlayerService = game:GetService("Players");
local InsertService = game:GetService("InsertService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local DataService = require(script.Parent.DataService);
local InventoryService = require(script.Parent.InventoryService);
local Rarity = Knit.ReplicatedRarities

local DuckModels = ReplicatedStorage:WaitForChild("Assets").DuckModels
local DeathEffects = ReplicatedStorage:WaitForChild("Assets").DeathEffects

local GameLibrary = ReplicatedStorage:WaitForChild("GameLibrary");
local Beams = GameLibrary:WaitForChild("Beams");
local Particles = GameLibrary:WaitForChild("Particles");
local SurfaceAppearances = GameLibrary:WaitForChild("SurfaceAppearances");

----- Public functions -----

-- Getters() --

-- Setters() --

function ChangeText(PLAYER, NEW_UI)
	-- // NAME CHANGE
	if PLAYER.DisplayName == PLAYER.Name then
		NEW_UI.USER.Text = ""
		NEW_UI.NICK.Text = PLAYER.Name
	else
		NEW_UI.NICK.Text = PLAYER.DisplayName
		NEW_UI.USER.Text = "@"..PLAYER.Name
	end
end

function AvatarService:SetNametag(Player)
    if not workspace.Lobby.NameTags:FindFirstChild(Player.UserId) then
		local NEW_UI = game.ReplicatedStorage.Assets.HEAD_UI:Clone()
		NEW_UI.Name = Player.UserId
		NEW_UI.Parent = workspace.Lobby.NameTags
        if Player.Character:FindFirstChild("Head") then
            NEW_UI.Adornee = Player.Character.Head
        end
		ChangeText(Player, NEW_UI)
	else
		local NEW_UI = workspace.Lobby.NameTags:FindFirstChild(Player.UserId)
		if Player.Character:FindFirstChild("Head") then
            NEW_UI.Adornee = Player.Character.Head
        end
		ChangeText(Player, NEW_UI)
	end
end

function AvatarService:HideAvatarAccessory(UserId,Character)
    if UserId and Character then
        for _, obj in pairs(Character:GetChildren()) do
            if obj:IsA("Accessory") then
                obj.Handle.Transparency = 1;
            end;
        end;
    else
        warn(UserId,"[AvatarService]: Missing one of the following: | Character -".. tostring(Character) .." |");
    end;
end;

function AvatarService:UnhideAvatarAccessory(UserId,Character)
    if UserId and Character then
        for _, obj in pairs(Character:GetChildren()) do
            if obj:IsA("Accessory") then
                obj.Handle.Transparency = 0;
            end;
        end;
    else
        warn(UserId,"[AvatarService]: Missing one of the following: | Character -".. tostring(Character) .." |");
    end;
end;

function AvatarService:CheckForHeadless(UserId) -- [UserId : Number]
    local AcceptableIds = {17}; -- Source: https://developer.roblox.com/en-us/api-reference/enum/AssetType
    if UserId then
        warn(UserId,"[AvatarService]: Checking User["..tostring(UserId).."] for headless");--print("[AvatarService]: Checking User[",AvatarId,"] for headless");
        local CharacterInfo;
        local call, err = pcall(function()
            CharacterInfo = PlayerService:GetCharacterAppearanceInfoAsync(UserId);
            return;
        end);
        if call == true then
            for _,asset in pairs(CharacterInfo["assets"]) do
                if table.find(AcceptableIds,asset["assetType"]["id"]) then -- Matches current id with AcceptableIds
                    if asset["id"] == 134082579 then return true end;
                end;
            end;
        else
            warn(UserId,"[AvatarService][ERROR]: ".. tostring(err));
            return false;
        end;
    end;
    return false;
end;

function AvatarService:RefreshAvatar(UserId, Character) -- [Texture : String]
    if Character then
        self:SetAvatarTexture(UserId, Character, "Default");
        self:SetAvatarColor(UserId, Character, self:GetAvatarColor(UserId));
        self:SetAvatarTransparency(UserId, Character, 0)
        self:SetAvatarMaterial(UserId, Character, Enum.Material.Plastic);
        self:SetAvatarBeams(UserId, Character)
        self:SetAvatarParticles(UserId, Character);
        self:SetAvatarFace(UserId, Character, self:GetAvatarFace(UserId), true);
        self:UnhideAvatarAccessory(UserId, Character);
        self:SetNametag(UserId)
        warn(UserId,"[AvatarService]: Refreshed avatar [".. tostring(UserId).."] successfully");
    end;
end;

-- Getters()

function AvatarService:GetAvatarAccessories(UserId) -- [IngredientOjects, IngredientAvailable],[FoodOjects, FoodAvailable]
    local AccessoryIds = {};
    local AcceptableIds = {8,41,42,57,58}; -- Source: https://developer.roblox.com/en-us/api-reference/enum/AssetType
    if UserId then
        warn(UserId,"[AvatarService]: Retrieving User["..tostring(UserId).."] avatar accessories");--print("[AvatarService]: Retrieving User[",AvatarId,"] avatar accessories");
        local CharacterInfo;
        local call, err = pcall(function()
            CharacterInfo = PlayerService:GetCharacterAppearanceInfoAsync(UserId);
            return;
        end);
        if call == true then
            for _,asset in pairs(CharacterInfo["assets"]) do
                if table.find(AcceptableIds,asset["assetType"]["id"]) then -- Matches current id with AcceptableIds
                    warn(UserId,"[AvatarService]: Adding accessory ["..tostring(asset["name"]).."] to array"); --print("[AvatarService]: Adding accessory [", asset["name"],"] to array");
                    table.insert(AccessoryIds,asset["id"]);
                end;
            end;
        else
            warn(UserId,"[AvatarService][ERROR]: ".. tostring(err));
            return {};
        end;
    end;
    return AccessoryIds; -- Returns all accessory ids to load the assets and place on character with other function
end;

function AvatarService:GetAvatarColor(UserId) -- [UserId : Number]
    if UserId then
        warn(UserId,"[AvatarService]: Retrieving User["..tostring(UserId).."] body color");--print("[AvatarService]: Retrieving User[",AvatarId,"] body color");
        local CharacterInfo;
        local call, err = pcall(function()
            CharacterInfo = PlayerService:GetCharacterAppearanceInfoAsync(UserId);
            return;
        end);
        if call == true then
            if CharacterInfo["bodyColors"] then
                return {CharacterInfo["bodyColors"]["headColorId"],CharacterInfo["bodyColors"]["torsoColorId"]};
            end
        else
            warn(UserId,"[AvatarService][ERROR]: ".. tostring(err));
            return nil;
        end;
    end;
end;

function AvatarService:GetAvatarFace(UserId) -- [UserId : Number]
    local AcceptableIds = {18}; -- Source: https://developer.roblox.com/en-us/api-reference/enum/AssetType
    if UserId then
        warn(UserId,"[AvatarService]: Retrieving User["..tostring(UserId).."] face id");--print("[AvatarService]: Retrieving User[",AvatarId,"] face id");
        local CharacterInfo;
        local call, err = pcall(function()
            CharacterInfo = PlayerService:GetCharacterAppearanceInfoAsync(UserId);
            return;
        end);
        if call == true then
            for _,asset in pairs(CharacterInfo["assets"]) do
                if table.find(AcceptableIds,asset["assetType"]["id"]) then -- Matches current id with AcceptableIds
                    warn(UserId,"[AvatarService]: Returning face id ["..asset["name"].."]");
                    return asset["id"];
                end;
            end;
            warn(UserId,"[AvatarService][ERROR]: Did not find User["..tostring(UserId).."] face id, setting default face");--print("[AvatarService]: Retrieving User[",AvatarId,"] face id");
            return 8056256;
        else
            warn(UserId,"[AvatarService][ERROR]: ".. tostring(err));
            return nil;
        end;
    end;
end;

-- Setters()

function AvatarService:SetHeadless(UserId, Character) -- [UserId : Number]
    if Character then
        warn(UserId,"[AvatarService]: Setting User["..tostring(UserId).."] for headless");
        Character.Head.Transparency = 1;
        Character.Head.face.Texture = "";
    end;
end;

function AvatarService:SetAvatarFace(UserId,Character,FaceId,IsCharacterFace) -- [UserId : Number]
    if Character and FaceId then
        local Head = Character:FindFirstChild("Head");
        if (IsCharacterFace and IsCharacterFace == true) then
            local success, asset = pcall(InsertService.LoadAsset, InsertService, FaceId);
            if success and asset and Head then
                --print(asset:GetChildren())
                if asset:FindFirstChildWhichIsA("Decal") then
                    local InsertedFace = asset:FindFirstChildWhichIsA("Decal");
                    warn(UserId,"[AvatarService]: Loaded face ["..FaceId.."] successfully");
                    Head.face.Texture = InsertedFace.Texture;
                end
            else
                warn(UserId,"[AvatarService]: Failed to change avatar face to [".. FaceId .."]");
            end;
        else
            Head.face.Texture = "rbxassetid://".. tostring(FaceId);
            warn(UserId,"[AvatarService]: Loaded face ["..FaceId.."] successfully");
        end;
    else
        warn(UserId,"[AvatarService][ERROR]: Missing one of the following: | Character -".. tostring(Character) .. " FaceId -".. tostring(FaceId) .."|");
    end;
end;

function AvatarService:SetAvatarColor(UserId,Character,BodyColorIds) -- [BodyColorId : Number]
    if Character and BodyColorIds then
        local Head = Character:FindFirstChild("Head");
        local Torso = Character:FindFirstChild("Mouse.001");
        if Head and Torso then
            warn(UserId,"[AvatarService]: Loaded body color ["..tostring(BodyColorIds[1]).."] successfully");
            Head.BrickColor = BrickColor.new(BodyColorIds[1]);
            Torso.BrickColor = BrickColor.new(BodyColorIds[2]);
        else
            warn(UserId,"[AvatarService][ERROR]: Failed to change avatar color to ["..tostring(BodyColorIds[1]).."]");
        end;
    else
        warn(UserId,"[AvatarService][ERROR]: Missing one of the following: | Character -".. tostring(Character) .. " BodyColorId -".. tostring(BodyColorIds) .."|");
    end;
end;

function AvatarService:SetAvatarMaterial(UserId,Character,Material) -- [BodyColorId : Number]
    if Character and Material then
        local Head = Character:FindFirstChild("Head");
        local Torso = Character:FindFirstChild("Mouse.001");
        if Head and Torso then
            warn(UserId,"[AvatarService]: Loaded material ["..tostring(Material).."] successfully");
            Head.Material = Material;
            Torso.Material = Material;
        else
            warn(UserId,"[AvatarService][ERROR]: Failed to change material to ["..tostring(Material).."]");
        end;
    else
        warn(UserId,"[AvatarService][ERROR]: Missing one of the following: | Character -".. tostring(Character) .. " Material -".. tostring(Material) .."|");
    end;
end;

function AvatarService:SetAvatarAccessory(UserId,Humanoid,AccessoryId)
    if Humanoid and AccessoryId then
        local success, asset = pcall(InsertService.LoadAsset, InsertService, AccessoryId);
        if success and asset then
            if asset:FindFirstChildWhichIsA("Accessory") then
                local accessory = asset:FindFirstChildWhichIsA("Accessory");
                warn(UserId,"[AvatarService]: Loaded accessory [".. tostring(accessory).."] successfully");
                --asset.Parent = workspace
                Humanoid:AddAccessory(accessory);
            end
        else
            warn(UserId,"[AvatarService][ERROR]: Failed to load ["..tostring(AccessoryId).."]");
        end;
    else
        warn(UserId,"[AvatarService][ERROR]: Missing one of the following: | Humanoid -".. tostring(Humanoid) .. " AccessoryId -".. tostring(AccessoryId).."|");
    end;
end;

function AvatarService:SetAvatarPoof(UserId, Character,AddPoof) -- [Texture : String]
    if Character and (AddPoof == true) then
        local Head = Character:FindFirstChild("Head");
        local Torso = Character:FindFirstChild("Mouse.001");
        if Head and Torso and Particles:FindFirstChild("PoofParticles") then
            local ClonedTexture1 = Particles:FindFirstChild("PoofParticles"):Clone();
            local ClonedTexture2 = Particles:FindFirstChild("PoofParticles"):Clone();
            ClonedTexture1.Parent = Torso;
            ClonedTexture2.Parent = Head;
            if Head:FindFirstChild("Poof") then
                Head:FindFirstChild("Poof"):Destroy();
            end;
            if Torso:FindFirstChild("Poof") then
                Torso:FindFirstChild("Poof"):Destroy();
            end;
            ClonedTexture1.Name = "Poof";
            ClonedTexture2.Name = "Poof";
            warn(UserId,"[AvatarService]: Added avatar poof particles successfully");
        end;
    elseif Character then
        local Head = Character:FindFirstChild("Head");
        local Torso = Character:FindFirstChild("Mouse.001");
        if Head and Torso and Head:FindFirstChild("Poof") and Torso:FindFirstChild("Poof") then
            task.spawn(function()
                Head:FindFirstChild("Poof").Rate = 0;
                Torso:FindFirstChild("Poof").Rate = 0;
                task.wait(.7);
                if Head:FindFirstChild("Poof") then
                    Head:FindFirstChild("Poof"):Destroy();
                end;
                if Torso:FindFirstChild("Poof") then
                    Torso:FindFirstChild("Poof"):Destroy();
                end
                warn(UserId,"[AvatarService]: Destroyed avatar poof particles successfully");
            end)
        end;
    end;
end;

function AvatarService:SetAvatarParticles(UserId, Character,ParticleName) -- [Texture : String]
    if Character and ParticleName then
        local Torso = Character:FindFirstChild("Mouse.001");
        if Torso and Particles:FindFirstChild(ParticleName) then
            local ClonedTexture = Particles:FindFirstChild(ParticleName):Clone();
            ClonedTexture.Parent = Torso;
            if Torso:FindFirstChild("Particle") then
                Torso:FindFirstChild("Particle"):Destroy();
            end;
            ClonedTexture.Name = "Particle";
            warn(UserId,"[AvatarService]: Added avatar particles [".. tostring(ParticleName).."] successfully");
        end;
    elseif Character then
        local Torso = Character:FindFirstChild("Mouse.001");
        if Torso and Torso:FindFirstChild("Particle")  then
            Torso:FindFirstChild("Particle"):Destroy();
            warn(UserId,"[AvatarService]: Destroyed avatar particles [".. tostring(Character).."] successfully");
        end;
    end;
end;

function AvatarService:SetAvatarTransparency(UserId, Character,Transparency) -- [TextureName : String]
    if Character and Transparency then
        local Head = Character:FindFirstChild("Head");
        local Torso = Character:FindFirstChild("Mouse.001");
        if Head and Torso then
            Head.Transparency = Transparency;
            Torso.Transparency = Transparency;
            warn(UserId,"[AvatarService]: Set transparency [".. tostring(Transparency).."] to avatar successfully");
        end;
    end;
end;

function AvatarService:SetAvatarTexture(UserId, Character,TextureName) -- [TextureName : String]
    if Character and TextureName then
        local Torso = Character:FindFirstChild("Mouse.001");
        if Torso and SurfaceAppearances:FindFirstChild(TextureName) then
            local ClonedTexture = SurfaceAppearances:FindFirstChild(TextureName):Clone();
            ClonedTexture.Parent = Torso;
            if Torso:FindFirstChild("SurfaceAppearance") then
                Torso:FindFirstChild("SurfaceAppearance"):Destroy();
            end;
            ClonedTexture.Name = "SurfaceAppearance";
            warn(UserId,"[AvatarService]: Set texture [".. tostring(TextureName).."] to avatar successfully");
        end;
    elseif Character then
        local Torso = Character:FindFirstChild("Mouse.001");
        if Torso and Torso:FindFirstChild("SurfaceAppearance") then
            Torso:FindFirstChild("SurfaceAppearance"):Destroy();
            warn(UserId,"[AvatarService]: Destroyed texture [".. tostring(Character).."] on avatar successfully");
        end;
    end;
end;

function AvatarService:SetAvatarBeams(UserId, Character, BeamName1, BeamName2, Parent1, Parent2) -- [Texture : String]
    if Character and BeamName1 and BeamName2 and Parent1 and Parent2 then
        local Torso = Character:FindFirstChild("Mouse.001");
        if Torso and Beams:FindFirstChild(BeamName1) and Beams:FindFirstChild(BeamName2) then
            local ClonedBeam1 = Beams:FindFirstChild(BeamName1):Clone();
            local ClonedBeam2 = Beams:FindFirstChild(BeamName2):Clone();
            ClonedBeam1.Attachment0 = Parent1;
            ClonedBeam1.Attachment1 = Parent2;

            ClonedBeam2.Attachment0 = Parent2;
            ClonedBeam2.Attachment1 = Parent1;

            ClonedBeam1.Parent = Torso;
            ClonedBeam2.Parent = Torso;
            if Torso and Torso:FindFirstChild("Beam1") and Torso:FindFirstChild("Beam2") then
                Torso:FindFirstChild("Beam1"):Destroy();
                Torso:FindFirstChild("Beam2"):Destroy();
            end;
            ClonedBeam1.Name = "Beam1";
            ClonedBeam2.Name = "Beam2";
            warn(UserId,"[AvatarService]: Set beams [".. tostring(BeamName1).."] to avatar successfully");
        end;
    elseif Character then
        local Torso = Character:FindFirstChild("Mouse.001");
        if Torso and Torso:FindFirstChild("Beam1") and Torso:FindFirstChild("Beam2") then
            Torso:FindFirstChild("Beam1"):Destroy();
            Torso:FindFirstChild("Beam2"):Destroy();
            warn(UserId,"[AvatarService]: Destroyed beams [".. tostring(Character).."] on avatar successfully");
        end;
    end;
end;

function AvatarService:KnitStart()
    
end


function AvatarService:KnitInit()
    
end

return AvatarService;