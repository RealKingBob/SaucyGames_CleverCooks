local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);
local Players = game:GetService("Players")

local Pipes = {};
Pipes.__index = Pipes;

Pipes.Tag = "Pipes";

function Pipes.new(instance)
    if instance:IsA("Model") then
        return;
    end
    local self = setmetatable({}, Pipes);
    self._maid = Maid.new();

    self.Object = instance;
    self.StoveEnabled = instance:GetAttribute("Enabled");
    self.playersDebounces = {};

    self._maid:GiveTask(self.Object.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        local player = game.Players:GetPlayerFromCharacter(hit.Parent);
        if humanoid and player then
            if self.playersDebounces[player.UserId] == nil then
                self.playersDebounces[player.UserId] = true;
                local NotificationService = Knit.GetService("NotificationService")
                NotificationService:Message(false, player, "Coming soon...", {Effect = true, Color = Color3.fromRGB(255,255,255)})
                task.wait(5);
                self.playersDebounces[player.UserId] = nil;
            end
        end
    end))

    return self;
end

function Pipes:Destroy()
    self._maid:Destroy();
end

return Pipes;