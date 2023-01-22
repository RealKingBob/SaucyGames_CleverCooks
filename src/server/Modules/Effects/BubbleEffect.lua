--[[
    Name: Bubble Effect [V1]
    By: Real_KingBob
    Date: 10/18/21
    Description: Transforms the rat avatar into a bubble rat with certain presets
]]

----- Private Variables -----

local BubbleEffect = {};

local ServerScriptService = game:GetService("ServerScriptService");
local ServerModules = ServerScriptService:FindFirstChild("ServerModules");
local PlayerEffects = ServerModules:FindFirstChild("PlayerEffects");
local ModuleServices = ServerModules:FindFirstChild("Services");

local AvatarService = require(ModuleServices:FindFirstChild("AvatarService"));
local PoofEffect = require(PlayerEffects:FindFirstChild("PoofEffect"));

----- Public functions -----

function BubbleEffect:Initialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        AvatarService:SetAvatarTexture(UserId, Character);
        AvatarService:SetAvatarMaterial(UserId, Character, Enum.Material.ForceField);
        AvatarService:SetAvatarColor(UserId, Character, {1027,1027});
        AvatarService:SetAvatarParticles(UserId, Character, "BubbleParticles");
        --AvatarService:HideAvatarAccessory(UserId, Character);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

function BubbleEffect:Uninitialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

return BubbleEffect;