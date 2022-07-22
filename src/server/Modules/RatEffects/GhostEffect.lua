--[[
    Name: Ghost Effect [V1]
    By: Real_KingBob
    Date: 10/18/21
    Description: Transforms the rat avatar into a ghost rat with certain presets
]]

----- Private Variables -----

local GhostEffect = {};

local ServerScriptService = game:GetService("ServerScriptService");
local ServerModules = ServerScriptService:FindFirstChild("ServerModules");
local PlayerEffects = ServerModules:FindFirstChild("PlayerEffects");
local ModuleServices = ServerModules:FindFirstChild("Services");

local AvatarService = require(ModuleServices:FindFirstChild("AvatarService"));
local PoofEffect = require(PlayerEffects:FindFirstChild("PoofEffect"));

----- Public functions -----

function GhostEffect:Initialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        AvatarService:SetAvatarTexture(UserId, Character);
        AvatarService:SetAvatarColor(UserId, Character, {1,1});
        AvatarService:SetAvatarTransparency(UserId, Character, .4)
        AvatarService:SetAvatarBeams(UserId, Character, "Chain1", "Chain2", 
        Character:FindFirstChild("Mouse.001").Root.HumanoidRootNode.UpperTorso.LowerTorso.Tail1,
        Character:FindFirstChild("Mouse.001").Root.HumanoidRootNode.UpperTorso)
        AvatarService:SetAvatarParticles(UserId, Character, "GhostParticles");
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

function GhostEffect:Uninitialize(UserId, Character)
    if UserId and Character then
        PoofEffect:Initialize(UserId, Character);
        AvatarService:RefreshAvatar(UserId, Character);
        PoofEffect:Uninitialize(UserId, Character);
    end;
end;

return GhostEffect;