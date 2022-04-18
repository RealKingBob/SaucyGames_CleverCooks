--// Covers clients side of environment
local Candyland = {};

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local WIND_DIRECTION = Vector3.new(-1,0,0);
local WIND_SPEED = 15;
local WIND_POWER = 0.2;

local Common = ReplicatedStorage.Common;
local Services = Common.Services;
local Environment = Common.Environment;

local WindShake = require(Services.WindShake);
local WindLines = require(Services.WindLines);

local MovableObjects = require(script.MoveableObjects)


function Candyland:SetClientEnvironment(MapObject)
    if MapObject then
        print("[Client]: Setting Environment")
        --[[for _,tree in pairs(MapObject.MovableObjects.Trees:GetChildren()) do
            CollectionService:AddTag(tree.Leaves, "WindShake")
        end]]

        WindLines:Init({
            Direction = WIND_DIRECTION;
            Speed = WIND_SPEED;
            Lifetime = 1.5;
            SpawnRate = 7;
        })

        WindShake:SetDefaultSettings({
            WindSpeed = WIND_SPEED;
            WindDirection = WIND_DIRECTION;
            WindPower = WIND_POWER;
        })

        WindShake:Init() -- Anything with the WindShake tag will now shake
        MovableObjects:Init(MapObject)
    end
end

return Candyland;