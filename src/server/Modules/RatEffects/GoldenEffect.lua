--[[
    Name: Golden Effect [V1]
    By: Real_KingBob
    Date: 10/18/21
    Description: Transforms the rat avatar into a golden rat with certain presets
]]

----- Private Variables -----

local GoldenEffect = {};

local ServerScriptService = game:GetService("ServerScriptService");
local ServerModules = ServerScriptService:FindFirstChild("ServerModules");
local PlayerEffects = ServerModules:FindFirstChild("PlayerEffects");
local ModuleServices = ServerModules:FindFirstChild("Services");

local AvatarService = require(ModuleServices:FindFirstChild("AvatarService"));
local PoofEffect = require(PlayerEffects:FindFirstChild("PoofEffect"));

----- Public functions -----

function GoldenEffect:Initialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        AvatarService:SetAvatarTexture(UserId, Character, "Goldify");
        AvatarService:SetAvatarColor(UserId, Character, {24,24});
        AvatarService:SetAvatarBeams(UserId, Character);
        AvatarService:SetAvatarTransparency(UserId, Character,0);
        AvatarService:SetAvatarParticles(UserId, Character, "GoldParticles");
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

function GoldenEffect:Uninitialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

return GoldenEffect;