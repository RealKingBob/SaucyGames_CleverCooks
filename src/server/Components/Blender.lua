local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TweenModule = require(Knit.ReplicatedModules.TweenUtil);
local NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

local Blender = {};
Blender.__index = Blender;

Blender.Tag = "Blender";

function Blender.new(instance)
    if instance:IsA("Part") then
        return;
    end
    local self = setmetatable({}, Blender);
    self._maid = Maid.new();

    self.Object = instance
    self.BlenderEnabled = false;
    self.playersDebounces = {};
    self.ObjectsInBlender = {};
    self.MaxNumOfObjects = 5;
    self.NumOfObjects = 0;
    self.NumOfObjectsTextLabel = self.Object.Glass.NumOfObjects.TextLabel;

    local function TemporaryDisableButton(seconds)
        self.Object.Button.ProximityPrompt.RequiresLineOfSight = true;
        self.Object.Button.ProximityPrompt.Enabled = false;
        task.wait(seconds)
        self.Object.Button.ProximityPrompt.Enabled = true;
        self.Object.Button.ProximityPrompt.RequiresLineOfSight = false;
    end

    local function BlenderFluidChange(percentage)
        local blenderFluid = self.Object.BlenderLiquid;
        local maxSize = 11.635;
        local newSize = maxSize * percentage;

        local endSize = Vector3.new(newSize, blenderFluid.Size.Y, blenderFluid.Size.Z)
        local endPosition = blenderFluid.Position + Vector3.new(0,(blenderFluid.Size.Y/2) - (newSize/2), 0)

        local goal = {
            Size = endSize,
            Position = endPosition
        }

        local timeInSeconds = 3

        local tweenInfo = TweenInfo.new(timeInSeconds)
        local powerBlender = TweenService:Create(blenderFluid, tweenInfo, goal)
        powerBlender:Play()
    end

    local function SpinBlade(enabled)
        if enabled == true then
            print('huh')
            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

            -- create two conflicting tweens (both trying to animate part.Position)
            local SpinTween = TweenService:Create(self.Object.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 100 });

            --[[local SpinTween = TweenModule.new(FadeTween, function(Alpha)
                print(Alpha)
                self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = NumberUtil.LerpClamp(0, 100, Alpha); 
            end)]]

            SpinTween:Play();
            SpinTween.Completed:Wait();



            self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 100;
        else

            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

            local SpinTween = TweenService:Create(self.Object.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 0 });

            --[[local SpinTween = TweenModule.new(FadeTween, function(Alpha)
                print(Alpha)
                self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = NumberUtil.LerpClamp(100, 0, Alpha); 
            end)]]

            SpinTween:Play();
            SpinTween.Completed:Wait();

            self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 0;
        end
    end

    local function PlayEffects(enabled)
        for _, particle in pairs(self.Object.ParticleHolder:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = enabled;
            end
        end

        task.spawn(function()
            task.wait(3)
            for _, particle in pairs(self.Object.ParticleHolder:GetDescendants()) do
                if particle:IsA("ParticleEmitter") then
                    particle:Clear();
                end
            end
        end)
    end

    self._maid:GiveTask(self.Object.Blade.Blade.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        local player = game.Players:GetPlayerFromCharacter(hit.Parent);
        if self.BlenderEnabled == false then
            if humanoid and player then
                if self.playersDebounces[player.UserId] == nil then
                    self.playersDebounces[player.UserId] = true;
                    humanoid.Health -= 10;
                    task.wait(1);
                    self.playersDebounces[player.UserId] = nil;
                end
            end
        else
            if humanoid and player then
                humanoid.BreakJointsOnDeath = true
                humanoid.Health = -1;
            end
            local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end
            if hit:GetAttribute("Type") then
                
                if table.find(self.ObjectsInBlender, hit) == nil then
                    table.insert(self.ObjectsInBlender, hit)
                    self.NumOfObjects += 1;
                    BlenderFluidChange(self.NumOfObjects / self.MaxNumOfObjects)
                end
            elseif hit.Parent:GetAttribute("Type") then
                if table.find(self.ObjectsInBlender, hit.Parent) == nil then
                    table.insert(self.ObjectsInBlender, hit.Parent)
                    self.NumOfObjects += 1;
                    BlenderFluidChange(self.NumOfObjects / self.MaxNumOfObjects)
                end
            end
            --print("BLADE HIT", hit, hit.Parent, self.ObjectsInBlender)
        end
    end))

    self._maid:GiveTask(self.Object.Button.ProximityPrompt.Triggered:Connect(function(plr)
        task.spawn(TemporaryDisableButton, 5)
        print("BLENDER", self.BlenderEnabled)
		self.BlenderEnabled = not self.BlenderEnabled;
        self.Object.Button:SetAttribute("Enabled", self.BlenderEnabled)

        if self.BlenderEnabled == true then
            self.Object.Lid.Transparency = 0;
            self.Object.Lid.CanCollide =  true;

            task.spawn(SpinBlade, true);
            PlayEffects(true);
            self.Object.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
            self.Object.Button.ProximityPrompt.ActionText = "Turn Off"
        else
            self.Object.Lid.Transparency = 1;
            self.Object.Lid.CanCollide =  false;
            task.spawn(SpinBlade, false);
            PlayEffects(false);
            self.Object.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(166, 0, 0)
            self.Object.Button.ProximityPrompt.ActionText = "Turn On"
        end
	end));

    --// Initialize Contents
    --BlenderFluidChange(0);
    self.NumOfObjectsTextLabel.Text = tostring(self.NumOfObjects.."/"..self.MaxNumOfObjects);

    return self;
end

function Blender:Destroy()
    self._maid:Destroy();
end

return Blender;