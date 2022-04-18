local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService");

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);
local Signal = require(Knit.Util.Signal);

local ServerAssets = Knit.ReplicatedMaps;

local Trap_Bullseye = {};
Trap_Bullseye.__index = Trap_Bullseye;

Trap_Bullseye.Tag = "Target";

local hitSoundId = "rbxassetid://8618186140"

function Trap_Bullseye.new(instance)
    local GameService = Knit.GetService("GameService")
    if GameService:GetPreviousMode() == "INFECTION MODE" or GameService:GetPreviousMode() == "HOT POTATO" then
        instance.Color = Color3.fromRGB(51,51,51)
        if instance:FindFirstChild("Beams") then
            for _, v in pairs(instance:FindFirstChild("Beams"):GetChildren()) do
                if v:IsA("Beam") then
                    v.Enabled = false
                end
            end
            if instance:FindFirstChild("Centre") then
                instance:FindFirstChild("Centre").ParticleEmitter.Enabled = false
            end
        end
        return;
    end
    local self = setmetatable({}, Trap_Bullseye);
    local maid = Maid.new();
    self._maid = maid;

    self.InitiateTrap = Signal.Wrap(CollectionService:GetInstanceAddedSignal("InitiateTrap"));
    self._maid:GiveTask(self.InitiateTrap);

    self.Object = instance
    self.Trap = instance:GetAttribute("Trap");
    self.Map = instance:GetAttribute("Map");
    instance:SetAttribute("Cooldown", -1);
    self.hasStarted = false;

    if not ServerAssets:FindFirstChild(self.Map) or not ServerAssets:FindFirstChild(self.Map):FindFirstChild("Traps") then
        instance.Color = Color3.fromRGB(51,51,51)
        if instance:FindFirstChild("Beams") then
            for _, v in pairs(instance:FindFirstChild("Beams"):GetChildren()) do
                if v:IsA("Beam") then
                    v.Enabled = false
                end
            end
            if instance:FindFirstChild("Centre") then
                instance:FindFirstChild("Centre").ParticleEmitter.Enabled = false
            end
        end
        return;
    end

    local TrapsFolder = ServerAssets:FindFirstChild(self.Map).Traps;
    if TrapsFolder:FindFirstChild(self.Trap) then
        local TrapModule = require(TrapsFolder:FindFirstChild(self.Trap));

        --TrapModule:OnStart()
        GameService:TrapControl(self.Map, self.Trap, "OnStart")
    
        self.InitiateTrap:Connect(function(Object)
            if Object == self.Object then
                if ServerAssets:FindFirstChild(self.Map) then
                    CollectionService:RemoveTag(Object, "InitiateTrap")
                    TrapModule:Activate(self.Object);
                    GameService:TrapControl(self.Map, self.Trap, "Activate", self.Object)
                    if TrapModule.Activated == true and self.hasStarted == false and instance:GetAttribute("Enabled") == true then
                        --print("[".. tostring(self.Trap) .."]: Activated")
                        --[[task.spawn(function()
                            local newHitSound = Instance.new("Sound")
                            newHitSound.SoundId = hitSoundId;
                            newHitSound.PlayOnRemove = true;
                            newHitSound.Parent = workspace;
                            newHitSound:Destroy();
                        end)]]
                        self.hasStarted = true;
                        instance:SetAttribute("Enabled", false)
                        --[[if instance:FindFirstChild("Impact") then
                            instance:FindFirstChild("Impact"):FindFirstChild("Shockwave"):Emit(5)
                            instance:FindFirstChild("Impact"):FindFirstChild("Sparks"):Emit(45)
                        end]]
                        if instance:FindFirstChild("Beams") then
                            for _, v in pairs(instance:FindFirstChild("Beams"):GetChildren()) do
                                if v:IsA("Beam") then
                                    v.Enabled = false
                                end
                            end
                            if instance:FindFirstChild("Centre") then
                                instance:FindFirstChild("Centre").ParticleEmitter.Enabled = false
                            end
                        end
                        task.spawn(function()
                            for count = (TrapModule.Cooldown - 1), 0, -1 do
                                instance:SetAttribute("Cooldown", count);
                                task.wait(1);
                            end
                            instance:SetAttribute("Cooldown", -1);
                        end)
                        task.delay(TrapModule.Cooldown, function()
                            TrapModule.Activated = false
                            instance:SetAttribute("Enabled", true)
                            self.hasStarted = false;
                        end)
                        --[[instance.Material = Enum.Material.Neon
                        task.wait(.1)
                        TweenService:Create(instance,TweenInfo.new(.2),{
                            Color = Color3.fromRGB(50, 50, 50),
                        }):Play()
                        task.wait(.2)
                        instance.Material = Enum.Material.Plastic
                        instance.Color = Color3.fromRGB(50, 50, 50)]]
                    end
                end
            end
        end)
    end

    return self;
end

function Trap_Bullseye:Destroy()
    self._maid:Destroy();
end

return Trap_Bullseye;