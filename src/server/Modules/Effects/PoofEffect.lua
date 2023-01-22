--[[
    Name: Poof Effect [V1]
    By: Real_KingBob
    Date: 10/24/21
    Description: Makes clouds on the rat to tranforms its current avatar to another preset
]]

----- Private Variables -----

local PoofEffect = {};

local ServerScriptService = game:GetService("ServerScriptService");
local ServerModules = ServerScriptService:FindFirstChild("ServerModules");
local ModuleServices = ServerModules:FindFirstChild("Services");

local AvatarService = require(ModuleServices:FindFirstChild("AvatarService"));

----- Public functions -----

function PoofEffect:Initialize(UserId, Character)
    if UserId and Character then
        AvatarService:SetAvatarPoof(UserId, Character, true);
    end;
end;

function PoofEffect:Uninitialize(UserId, Character)
    if UserId and Character then
        AvatarService:SetAvatarPoof(UserId, Character, false);
    end;
end;

return PoofEffect;