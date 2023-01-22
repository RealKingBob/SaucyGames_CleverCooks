local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);
local Players = game:GetService("Players")

local Stoves = {};
Stoves.__index = Stoves;

Stoves.Tag = "Stoves";

function Stoves.new(instance)
    if instance:IsA("Model") then
        return;
    end
    local self = setmetatable({}, Stoves);
    self._maid = Maid.new();

    self.Object = instance;
    self.StoveEnabled = instance:GetAttribute("Enabled");
    self.playersDebounces = {};
    
    self._maid:GiveTask(self.Object:GetAttributeChangedSignal("Enabled"):Connect(function()
        local stoveEnabled = instance:GetAttribute("Enabled")
        --print(stoveEnabled)
        for _,v in pairs(instance:GetChildren()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = stoveEnabled
            end
        end
    end))

    self._maid:GiveTask(self.Object.Touched:Connect(function(hit)
        if self.StoveEnabled == true then
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            local player = game.Players:GetPlayerFromCharacter(hit.Parent);
            if humanoid and player then
                if self.playersDebounces[player.UserId] == nil then
                    self.playersDebounces[player.UserId] = true;
                    humanoid.Health -= 50;
                    task.wait(1);
                    self.playersDebounces[player.UserId] = nil;
                end
            end
        else
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            local player = game.Players:GetPlayerFromCharacter(hit.Parent);
            if humanoid and player then
                if self.playersDebounces[player.UserId] == nil then
                    self.playersDebounces[player.UserId] = true;
                    humanoid.Health -= 5;
                    task.wait(1);
                    self.playersDebounces[player.UserId] = nil;
                end
            end
        end
    end))

    return self;
end

function Stoves:Destroy()
    self._maid:Destroy();
end

return Stoves;