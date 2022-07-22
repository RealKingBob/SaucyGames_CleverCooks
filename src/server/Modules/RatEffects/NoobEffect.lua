--[[
    Name: Noob Effect [V1]
    By: Real_KingBob
    Date: 10/18/21
    Description: Transforms the rat avatar into a noob rat with certain presets
]]

----- Private Variables -----

local NoobEffect = {};

local ServerScriptService = game:GetService("ServerScriptService");
local ServerModules = ServerScriptService:FindFirstChild("ServerModules");
local PlayerEffects = ServerModules:FindFirstChild("PlayerEffects");
local ModuleServices = ServerModules:FindFirstChild("Services");

local AvatarService = require(ModuleServices:FindFirstChild("AvatarService"));
local PoofEffect = require(PlayerEffects:FindFirstChild("PoofEffect"));

----- Public functions -----

function NoobEffect:Initialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        AvatarService:SetAvatarTexture(UserId, Character, "Noobify");
        AvatarService:SetAvatarColor(UserId, Character, {24,23});
        AvatarService:SetAvatarParticles(UserId, Character, "RobloxParticles");
        AvatarService:HideAvatarAccessory(UserId, Character);
        AvatarService:SetAvatarFace(UserId, Character, 8056256);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

function NoobEffect:Uninitialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

return NoobEffect;