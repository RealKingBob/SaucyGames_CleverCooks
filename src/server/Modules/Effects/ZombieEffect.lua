--[[
    Name: Zombie Effect [V1]
    By: Real_KingBob
    Date: 10/18/21
    Description: Transforms the rat avatar into a zombie rat with certain presets
]]

----- Private Variables -----

local ZombieEffect = {};

local ServerScriptService = game:GetService("ServerScriptService");
local ServerModules = ServerScriptService:FindFirstChild("ServerModules");
local PlayerEffects = ServerModules:FindFirstChild("PlayerEffects");
local ModuleServices = ServerModules:FindFirstChild("Services");

local AvatarService = require(ModuleServices:FindFirstChild("AvatarService"));
local PoofEffect = require(PlayerEffects:FindFirstChild("PoofEffect"));

----- Public functions -----

function ZombieEffect:Initialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        AvatarService:SetAvatarTexture(UserId, Character, "Zombify");
        AvatarService:SetAvatarColor(UserId, Character, {318,365});
        AvatarService:SetAvatarParticles(UserId, Character, "ZombieParticles");
        --AvatarService:HideAvatarAccessory(UserId, Character);
        AvatarService:SetAvatarFace(UserId, Character, 174393211);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

function ZombieEffect:Uninitialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

return ZombieEffect;