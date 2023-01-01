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
    self.BlenderColors = {};
    self.colorOfFood = {};
    self.MaxNumOfObjects = 5;
    self.NumOfObjects = {};
    self.NumOfObjectsTextLabel = self.Object.Glass.Glass.NumOfObjects.TextLabel;

    local function PlayerAdded(player)
        self.playersDebounces[player.UserId] = nil;
        self.ObjectsInBlender[player.UserId] = {};
        self.BlenderColors[player.UserId] = Color3.fromRGB(255,255,255);
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
        self.BlenderColors[player.UserId] = nil;
        self.NumOfObjects[player.UserId] = nil;
    end;

    local function TemporaryDisableButton(seconds)
        self.Object.Button.ProximityPrompt.RequiresLineOfSight = true;
        self.Object.Button.ProximityPrompt.Enabled = false;
        task.wait(seconds)
        self.Object.Button.ProximityPrompt.Enabled = true;
        self.Object.Button.ProximityPrompt.RequiresLineOfSight = false;
    end

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

            local SpinTween = TweenService:Create(self.Object.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 100 });

            SpinTween:Play();
            SpinTween.Completed:Wait();

            self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 70;
        else

            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

            local SpinTween = TweenService:Create(self.Object.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 0 });

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
            if hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner") then
                local player = game.Players:FindFirstChild(hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner"));
                if not player then return end
                if not self.ObjectsInBlender[player.UserId] then self.ObjectsInBlender[player.UserId] = {} end
                if not self.NumOfObjects[player.UserId] then self.NumOfObjects[player.UserId] = 0 end
                if not self.BlenderColors[player.UserId] then self.BlenderColors[player.UserId] = Color3.fromRGB(255,255,255) end
            end

            if hit:GetAttribute("Type") or hit.Parent:GetAttribute("Type") then
                
                local isAModel = (hit.Parent:IsA("Model") 
                and hit.Parent.PrimaryPart ~= nil 
                and hit.Parent.PrimaryPart:GetAttribute("Owner") ~= nil) and true or false;
                
                print(hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner"), "isAModel:", isAModel)
                local player = game.Players:FindFirstChild(hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner"));
                if not player then return end
                
                if (self.NumOfObjects[player.UserId] >= 5 and self.playersDebounces[player.UserId] == nil)
                or CollectionService:HasTag(hit, "IngredientsTable") == true then
                    local obj = (isAModel == true and hit.Parent) or hit;
                    if isAModel == true then
                        obj:SetPrimaryPartCFrame(CFrame.new(self.Object.ReturnObj.Position + Vector3.new(0,5,0)))
                    else
                        obj.Position = self.Object.ReturnObj.Position + Vector3.new(0,5,0);
                    end

                    local NotificationService = Knit.GetService("NotificationService")
                    NotificationService:Message(false, player, "Blender is full!")
                    return
                end

                local objToInsert = (isAModel == true and hit.Parent) or hit;
                if table.find(self.ObjectsInBlender[player.UserId], objToInsert) == nil then
                    table.insert(self.ObjectsInBlender[player.UserId], objToInsert)
                    self.playersDebounces[player.UserId] = true;
                    InsertObjToBlender(hit)
                    self.NumOfObjects[player.UserId] += 1;

                    local obj = (isAModel == true and hit.Parent) or hit;
                    if isAModel == true then
                        self.colorOfFood[player.UserId] = obj.PrimaryPart.Color
                    else
                        self.colorOfFood[player.UserId] = obj.Color
                    end 

                    if self.NumOfObjects[player.UserId] then
                        if self.NumOfObjects[player.UserId] > 1 then
                            local oColor = self.BlenderColors[player.UserId];
                            print("oColor", oColor)
                            self.BlenderColors[player.UserId] = oColor:Lerp(self.colorOfFood[player.UserId], 0.5)
                        else
                            self.BlenderColors[player.UserId] = self.colorOfFood[player.UserId];
                        end
                    end

                    local CookingService = Knit.GetService("CookingService");
                    CookingService.Client.ChangeClientBlender:Fire(player,
                        self.Object, -- blender object
                        "fluidPercentage", -- command
                        { -- data
                        FluidPercentage = (self.NumOfObjects[player.UserId] / self.MaxNumOfObjects), -- fluid 
                        FluidText = tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects), -- blender text
                        FluidColor = self.BlenderColors[player.UserId], -- color of food
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

                local blendedFood = SpawnItemsAPI:SpawnBlenderFood(
                    player.UserId, 
                    player, 
                    self.ObjectsInBlender[player.UserId], 
                    IngredientObjects, 
                    IngredientsAvailable, 
                    (self.Object.ReturnObj.Position + Vector3.new(0,5,0)),
                    self.BlenderColors[player.UserId]
                );

                NotificationService:Message(false, player, "Blended food is dropped!")
                
                self.ObjectsInBlender[player.UserId] = {};

                local CookingService = Knit.GetService("CookingService");
                CookingService.Client.ChangeClientBlender:Fire(player,
                    self.Object, -- blender object
                    "fluidPercentage", -- command
                    { -- data
                        FluidPercentage = (self.NumOfObjects[player.UserId] / self.MaxNumOfObjects), -- fluid 
                        FluidText = tostring(self.NumOfObjects[player.UserId].."/"..self.MaxNumOfObjects), -- blender text
                        FluidColor = Color3.fromRGB(66, 123, 255), -- color of food
                    });
            end

            task.wait(1);
            self.playersDebounces[player.UserId] = nil;
        end
	end));

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