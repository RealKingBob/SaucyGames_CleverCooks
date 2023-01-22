local PlayerService = game:GetService("Players");
local InsertService = game:GetService("InsertService");

local ApplyAppearance = {};

ApplyAppearance._chefShirt = "http://www.roblox.com/asset/?id=6602162098";
ApplyAppearance._chefPants = "http://www.roblox.com/asset/?id=6602166189";

ApplyAppearance._waiterShirt = "http://www.roblox.com/asset/?id=6522258077";
ApplyAppearance._waiterPants = "http://www.roblox.com/asset/?id=6522262611";

function ApplyAppearance:GetShirtAndPants(JobType) -- [JobType : String]
	if JobType then
		if JobType == "Chef" then
			return {Shirt = self._chefShirt, Pants = self._chefPants}
		elseif JobType == "Waiter" then 
			return {Shirt = self._waiterShirt, Pants = self._waiterPants}
		end
	end;
end;

function ApplyAppearance:SetShirtAndPants(Character,Package) -- [UserId : Number]
	if Character and Package then
		Character.Shirt.ShirtTemplate = Package.Shirt;
		Character.Pants.PantsTemplate = Package.Pants;
		--warn("[AvatarService]: Loaded shirts and pants ["..tostring(Package).."] successfully");
	else
		warn("[AvatarService][ERROR]: Missing one of the following: | Character -".. tostring(Character) .. " Shirt and Pants -".. tostring(Package) .."|");
	end;
end;

function ApplyAppearance:GetAvatarColor(UserId) -- [UserId : Number]
	if UserId then
		--warn(UserId,"[AvatarService]: Retrieving User["..tostring(UserId).."] body color");--print("[AvatarService]: Retrieving User[",AvatarId,"] body color");
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


function ApplyAppearance:GetAvatarFace(UserId) -- [UserId : Number]
	local AcceptableIds = {18}; -- Source: https://developer.roblox.com/en-us/api-reference/enum/AssetType
	if UserId then
		--warn(UserId,"[AvatarService]: Retrieving User["..tostring(UserId).."] face id");--print("[AvatarService]: Retrieving User[",AvatarId,"] face id");
		local CharacterInfo;
		local call, err = pcall(function()
			CharacterInfo = PlayerService:GetCharacterAppearanceInfoAsync(UserId);
			return;
		end);
		if call == true then
			for _,asset in pairs(CharacterInfo["assets"]) do
				if table.find(AcceptableIds,tonumber(asset["assetType"]["id"])) then -- Matches current id with AcceptableIds
					--warn(UserId,"[AvatarService]: Returning face id ["..asset["name"].."]");
					local assetId = asset["id"] --Replace the emote ID with another ID that you want the animation of
					
					--print(InsertService:LoadAsset(assetId):FindFirstChildOfClass'Decal'.Texture) --> http://www.roblox.com/asset/?id=3344650532
					
					local textureId = InsertService:LoadAsset(assetId):FindFirstChildOfClass'Decal'.Texture;
					return textureId;
				end;
			end;
			warn(UserId,"[AvatarService][ERROR]: Did not find User["..tostring(UserId).."] face id, setting default face");--print("[AvatarService]: Retrieving User[",AvatarId,"] face id");
			return "rbxassetid://8056256";
		else
			warn(UserId,"[AvatarService][ERROR]: ".. tostring(err));
			return nil;
		end;
	end;
end;

function ApplyAppearance:SetAvatarFace(Character,FaceId,IsCharacterFace) -- [UserId : Number]
	if Character and FaceId then
		local Head = Character:FindFirstChild("Head");
		if not Head then return end
		if (IsCharacterFace and IsCharacterFace == true) then
			local success, asset = pcall(InsertService.LoadAsset, InsertService, FaceId);
			if success and asset and Head then
				--print(asset:GetChildren())
				if asset:FindFirstChildWhichIsA("Decal") then
					local InsertedFace = asset:FindFirstChildWhichIsA("Decal");
					--warn(UserId,"[AvatarService]: Loaded face ["..FaceId.."] successfully");
					Head.face.Texture = InsertedFace.Texture;
				end
			else
				--warn("[AvatarService]: Failed to change avatar face to [".. FaceId .."]");
			end;
		else
			Head.face.Texture = tostring(FaceId);
			--warn("[AvatarService]: Loaded face ["..FaceId.."] successfully");
		end;
	else
		warn("[AvatarService][ERROR]: Missing one of the following: | Character -".. tostring(Character) .. " FaceId -".. tostring(FaceId) .."|");
	end;
end;

function ApplyAppearance:SetAvatarColor(Character,BodyColorIds) -- [BodyColorId : Number]
	if Character and BodyColorIds then
		local Head = Character:FindFirstChild("Head");
		local UpperTorso = Character:FindFirstChild("UpperTorso");
		local LowerTorso = Character:FindFirstChild("LowerTorso");
		if Head and UpperTorso then
			---warn(UserId,"[AvatarService]: Loaded body color ["..tostring(BodyColorIds[1]).."] successfully");
			
			for _, bodyPart in pairs(Character:GetChildren()) do
				if bodyPart:IsA("MeshPart") then
					bodyPart.BrickColor = BrickColor.new(BodyColorIds[1]);
				end
			end
			
			Head.BrickColor = BrickColor.new(BodyColorIds[1]);
			
		else
			warn("[AvatarService][ERROR]: Failed to change avatar color to ["..tostring(BodyColorIds[1]).."]");
		end;
	else
		warn("[AvatarService][ERROR]: Missing one of the following: | Character -".. tostring(Character) .. " BodyColorId -".. tostring(BodyColorIds) .."|");
	end;
end;

function ApplyAppearance:GetAvatarAccessories(UserId, isChef) -- [IngredientOjects, IngredientAvailable],[FoodOjects, FoodAvailable]
	local AccessoryIds = {};
	local AcceptableIds = {41,42,57,58}; -- 8 Source: https://developer.roblox.com/en-us/api-reference/enum/AssetType
	if UserId then
		--warn(UserId,"[AvatarService]: Retrieving User["..tostring(UserId).."] avatar accessories");--print("[AvatarService]: Retrieving User[",AvatarId,"] avatar accessories");
		local CharacterInfo;
		local call, err = pcall(function()
			CharacterInfo = PlayerService:GetCharacterAppearanceInfoAsync(UserId);
			return;
		end);
		if call == true then
			for _,asset in pairs(CharacterInfo["assets"]) do
				if table.find(AcceptableIds,asset["assetType"]["id"]) then -- Matches current id with AcceptableIds
					--warn(UserId,"[AvatarService]: Adding accessory ["..tostring(asset["name"]).."] to array"); --print("[AvatarService]: Adding accessory [", asset["name"],"] to array");
					table.insert(AccessoryIds,asset["id"]);
				end;
			end;
		else
			warn(UserId,"[AvatarService][ERROR]: ".. tostring(err));
			return {};
		end;
	end;
	
	if isChef == true then
		table.insert(AccessoryIds, 9936355807);
	end
	return AccessoryIds; -- Returns all accessory ids to load the assets and place on character with other function
end;

return ApplyAppearance;
