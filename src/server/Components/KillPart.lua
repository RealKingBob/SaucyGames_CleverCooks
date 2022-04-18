local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);
local Players = game:GetService("Players")

local KillPart = {};
KillPart.__index = KillPart;

KillPart.Tag = "KillPart";

function KillPart.new(instance)
    if instance:IsA("Model") then
        return;
    end
    local self = setmetatable({}, KillPart);
    self._maid = Maid.new();

    self.Object = instance
    self.Trap = instance:GetAttribute("Trap");
    self.Map = instance:GetAttribute("Map");

    --self.Object.CanCollide = false;

    self._maid:GiveTask(self.Object.Touched:Connect(function(hit)
        if hit.Name ~= "BHitbox" then
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = -1
            end
        end
    end))

    return self;
end

function KillPart:Destroy()
    self._maid:Destroy();
end

return KillPart;