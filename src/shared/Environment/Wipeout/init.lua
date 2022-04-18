--// Covers clients side of environment
local Wipeout = {};

local CollectionService = game:GetService("CollectionService")
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


function Wipeout:SetClientEnvironment(MapObject)
    if MapObject then
        print("[Client]: Setting Environment")


        if MapObject:GetAttribute("HP") == true then
            local Factor = 0.03
            
            for _, v in pairs(CollectionService:GetTagged("SpinningWheels")) do
                if v:IsA("Model") then
                    task.spawn(function()
                        while v:FindFirstChild("Spinner01") ~= nil do
                            task.wait(0)
                            if v:FindFirstChild("Spinner01") then
                                v.Spinner01.CFrame = v.Spinner01.CFrame * CFrame.new(0, 0, 0) * CFrame.fromEulerAnglesXYZ(0, -Factor, 0)
                                v.Spinner02.CFrame = v.Spinner02.CFrame * CFrame.new(0, 0, 0) * CFrame.fromEulerAnglesXYZ(0, -Factor, 0)
                                v.Spinner02.RotVelocity = Vector3.new(0,-Factor*30,0)
                            end
                        end
                    end)
                end
            end


        end


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

return Wipeout;