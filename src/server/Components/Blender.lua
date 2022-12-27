local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TweenModule = require(Knit.ReplicatedModules.TweenUtil);
local NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

----- Directories -----

local IngredientsAvailable = workspace:WaitForChild("IngredientAvailable");
local FoodAvailable = workspace:WaitForChild("FoodAvailable");

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary");
local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects");

local ServerModules = Knit.Modules;
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"));

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
    self.BlenderEnabled = true;
    self.playersDebounces = {};
    self.ObjectsInBlender = {};
    self.MaxNumOfObjects = 5;
    self.NumOfObjects = {};
    self.NumOfObjectsTextLabel = self.Object.Glass.Glass.NumOfObjects.TextLabel;

    local function PlayerAdded(player)
        self.playersDebounces[player.UserId] = nil;
        self.ObjectsInBlender[player.UserId] = {};
        self.NumOfObjects[player.UserId] = 0

        local CookingService = Knit.GetService("CookingService");
        CookingService.Client.ChangeClientBlender:Fire(player,
            self.Object, -- blender object
            "bladeSpin", -- command
            { -- data
                true -- boolean
            });
    end;
    
    local function PlayerRemoving(player)
        self.playersDebounces[player.UserId] = nil;
        self.ObjectsInBlender[player.UserId] = nil;
        self.NumOfObjects[player.UserId] = nil;
    end;

    local function TemporaryDisableButton(seconds)
        self.Object.Button.ProximityPrompt.RequiresLineOfSight = true;
        self.Object.Button.ProximityPrompt.Enabled = false;
        task.wait(seconds)
        self.Object.Button.ProximityPrompt.Enabled = true;
        self.Object.Button.ProximityPrompt.RequiresLineOfSight = false;
    end

    --[[local function BlenderFluidChange(percentage)
        local blenderFluid = self.Object.Flood;
        local maxSize = 11.47;
        local currentSize = blenderFluid.Size.Y
        local newSize = maxSize * percentage;
        local difference = newSize - currentSize

        difference /= 2

        local endSize = Vector3.new(blenderFluid.Size.X, newSize, blenderFluid.Size.Z)
        local endCFrame = blenderFluid.CFrame * CFrame.new(0, (newSize/2), 0)
        local endPosition = blenderFluid.Position + Vector3.new(0,difference, 0)

        local goal = {
            Size = endSize,
            Position = endPosition,
            --CFrame = endCFrame
        }

        local timeInSeconds = 3

        local tweenInfo = TweenInfo.new(timeInSeconds)
        local powerBlender = TweenService:Create(blenderFluid, tweenInfo, goal)
        powerBlender:Play()
        powerBlender.Completed:Wait();
        blenderFluid.Size = endSize;
        --blenderFluid.CFrame = endCFrame;
    end]]

    local function InsertObjToBlender(Obj)
        local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints");
        if Obj:IsA("Model") and Obj.PrimaryPart then
            Obj.PrimaryPart.ProximityPrompt.Enabled = false;
        else
            Obj.ProximityPrompt.Enabled = false;
        end
        local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)];
        if RandomFoodLocation then
            if Obj:IsA("Model") and Obj.PrimaryPart then
                Obj:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
            else
                Obj.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5));
            end
        end

        task.wait(0.1)

        if Obj:IsA("Model") and Obj.PrimaryPart then
            Obj.PrimaryPart.ProximityPrompt.Enabled = true;
        else
            Obj.ProximityPrompt.Enabled = true;
        end
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

            self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 70;
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
            if hit:GetAttribute("Owner") then
                local player = game.Players:FindFirstChild(hit:GetAttribute("Owner"));
                if not self.ObjectsInBlender[player.UserId] then self.ObjectsInBlender[player.UserId] = {} end
                if not self.NumOfObjects[player.UserId] then self.NumOfObjects[player.UserId] = 0 end
            end
            if hit:GetAttribute("Type") then
                local player = game.Players:FindFirstChild(hit:GetAttribute("Owner"));
                if player then
                    if (self.NumOfObjects[player.UserId] >= 5 and self.playersDebounces[player.UserId] == nil)
                    or CollectionService:HasTag(hit, "IngredientsTable") == true then
                        if hit.Parent:IsA("Model") then
                            hit.Parent:SetPrimaryPartCFrame(CFrame.new(self.Object.ReturnObj.Position + Vector3.new(0,5,0)))
                        else
                            hit.Position = self.Object.ReturnObj.Position + Vector3.new(0,5,0)
                        end
                        return
                    end
                end
                if table.find(self.ObjectsInBlender[player.UserId], hit) == nil then
                    table.insert(self.ObjectsInBlender[player.UserId], hit)
                    self.playersDebounces[player.UserId] = true;
                    InsertObjToBlender(hit)
                    self.NumOfObjects[player.UserId] += 1;
                    --task.spawn(BlenderFluidChange, self.NumOfObjects[player.UserId] / self.MaxNumOfObjects)
                    --self.NumOfObjectsTextLabel.Text = tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects);
                   
                    local CookingService = Knit.GetService("CookingService");
                    CookingService.Client.ChangeClientBlender:Fire(player,
                        self.Object, -- blender object
                        "fluidPercentage", -- command
                        { -- data
                            (self.NumOfObjects[player.UserId] / self.MaxNumOfObjects), -- fluid 
                            tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects) -- blender text
                        });

                    print("BLADE HIT", hit, hit.Parent, self.ObjectsInBlender[player.UserId])
                    self.playersDebounces[player.UserId] = nil;
                end
            elseif hit.Parent:GetAttribute("Type") then
                local player = game.Players:FindFirstChild(hit.Parent:GetAttribute("Owner"));
                if player then
                    if (self.NumOfObjects[player.UserId] >= 5 and self.playersDebounces[player.UserId] == nil)
                    or CollectionService:HasTag(hit, "IngredientsTable") == true then
                        if hit.Parent:IsA("Model") then
                            hit.Parent:SetPrimaryPartCFrame(CFrame.new(self.Object.ReturnObj.Position + Vector3.new(0,5,0)))
                        else
                            hit.Position = self.Object.ReturnObj.Position + Vector3.new(0,5,0)
                        end
                        return
                    end
                end
                if table.find(self.ObjectsInBlender[player.UserId], hit.Parent) == nil then
                    table.insert(self.ObjectsInBlender[player.UserId], hit.Parent)
                    self.playersDebounces[player.UserId] = true;
                    InsertObjToBlender(hit)
                    self.NumOfObjects[player.UserId] += 1;
                    --task.spawn(BlenderFluidChange, self.NumOfObjects[player.UserId] / self.MaxNumOfObjects)
                    --self.NumOfObjectsTextLabel.Text = tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects);
                    
                    local CookingService = Knit.GetService("CookingService");
                    CookingService.Client.ChangeClientBlender:Fire(player,
                        self.Object, -- blender object
                        "fluidPercentage", -- command
                        { -- data
                            (self.NumOfObjects[player.UserId] / self.MaxNumOfObjects), -- fluid 
                            tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects) -- blender text
                        });
                    
                    print("BLADE HIT", hit, hit.Parent, self.ObjectsInBlender[player.UserId])
                    self.playersDebounces[player.UserId] = nil;
                end
            end
        end
    end))

    self._maid:GiveTask(self.Object.Button.ProximityPrompt.Triggered:Connect(function(player)
        --task.spawn(TemporaryDisableButton, 3)
        print("BLENDER", self.BlenderEnabled, self.playersDebounces[player.UserId]);

        if self.playersDebounces[player.UserId] == nil then
            self.playersDebounces[player.UserId] = true;

            --print("NumOfObjects", self.NumOfObjects[player.UserId])
            local NotificationService = Knit.GetService("NotificationService")

            if not self.ObjectsInBlender[player.UserId] then self.ObjectsInBlender[player.UserId] = {} end
            if not self.NumOfObjects[player.UserId] then self.NumOfObjects[player.UserId] = 0 end

            if self.NumOfObjects[player.UserId] == 0 then
                NotificationService:Message(false, player, "Blender is empty!")
            else
                self.NumOfObjects[player.UserId] = 0;

                local blendedFood = SpawnItemsAPI:SpawnBlenderFood(player.UserId, player, self.ObjectsInBlender[player.UserId], IngredientObjects, IngredientsAvailable, self.Object.ReturnObj.Position + Vector3.new(0,5,0));

                NotificationService:Message(false, player, "Blended food is dropped!")
                
                self.ObjectsInBlender[player.UserId] = {};

                local CookingService = Knit.GetService("CookingService");
                CookingService.Client.ChangeClientBlender:Fire(player,
                    self.Object, -- blender object
                    "fluidPercentage", -- command
                    { -- data
                        (self.NumOfObjects[player.UserId] / self.MaxNumOfObjects), -- fluid 
                        tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects) -- blender text
                    });
                
                --task.spawn(BlenderFluidChange, self.NumOfObjects[player.UserId] / self.MaxNumOfObjects)
                --self.NumOfObjectsTextLabel.Text = tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects);
            end

            task.wait(1);
            self.playersDebounces[player.UserId] = nil;
        end

		--[[self.BlenderEnabled = not self.BlenderEnabled;
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
        end]]
	end));

    --// TODO, GET BLENDED FOOD BUTTON, DONT CAHNGE TO CLIENT BESIDES THEEFFECTS AND SPAWN FOOD ON SERVER, REPLICATE TO CLIENT AND DELETE TO OTHER CLIENTS

    --// Initialize Contents
    --BlenderFluidChange(0);
    --self.NumOfObjectsTextLabel.Text = tostring(self.NumOfObjects.."/"..self.MaxNumOfObjects);

    self.BlenderEnabled = true;

    self.Object.Lid.Transparency = 1;
    self.Object.Lid.CanCollide =  false;

    task.spawn(SpinBlade, true);
    PlayEffects(true);
    self.Object.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
    self.Object.Button.ProximityPrompt.ActionText = "Get Blended Food"

    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(PlayerAdded)(player);
    end

    Players.PlayerAdded:Connect(PlayerAdded);
    Players.PlayerRemoving:Connect(PlayerRemoving);

    return self;
end

function Blender:Destroy()
    self._maid:Destroy();
end

return Blender;