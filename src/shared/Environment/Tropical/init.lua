--// Covers clients side of environment
local Tropical = {};

local CollectionService = game:GetService("CollectionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

local WIND_DIRECTION = Vector3.new(-1,0,0);
local WIND_SPEED = 15;
local WIND_POWER = 0.2;

local Common = ReplicatedStorage.Common
local Services = Common.Services;
local Environment = Common.Environment;

local Seagulls = require(Environment.Tropical.SeagullAnims);
local Sharks = require(Environment.Tropical.SharkAnims);
local Ships = require(Environment.Tropical.ShipAnims);

local WindShake = require(Services.WindShake);
local WindLines = require(Services.WindLines);


function Tropical:SetClientEnvironment(MapObject)
    if MapObject then
        print("[Client]: Setting Environment")
        for _,model in pairs(MapObject.Map:GetDescendants()) do
            if model.Name == "Volcano Island" then
                for _,lava in pairs(model.Volcano:GetDescendants()) do
                    if lava.Name == "Movable" and lava:IsA("Texture") then
                        task.spawn(function()
                            while true do
                                lava.OffsetStudsV += .09
                                task.wait(0.01)
                            end
                        end)
                    elseif lava.Name == "RMovable" and lava:IsA("Texture") then
                        task.spawn(function()
                            while true do
                                lava.OffsetStudsV -= .09
                                task.wait(0.01)
                            end
                        end)
                    end
                end
            end
        end

        if MapObject:FindFirstChild("MovablePlain"):FindFirstChild("Water") then
            for _,water in pairs(MapObject.MovablePlain.Water["Water CENTRE"]:GetChildren()) do
                if water.Name ~= "Darker Water (KILL BLOCK)" then
                    TweenService:Create(water, TweenInfo.new(7,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,-1,true, 0), {Position = water.Position + Vector3.new(0, -.4, 0)}):Play()
                end
            end
        end

        if MapObject:FindFirstChild("MovableObjects"):FindFirstChild("Trees") then
            for _,tree in pairs(MapObject.MovableObjects.Trees:GetChildren()) do
                CollectionService:AddTag(tree.Leaves, "WindShake")
            end
        end

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
        Seagulls:Init(MapObject)
        Sharks:Init(MapObject)
        Ships:Init(MapObject)
    end
end

return Tropical;