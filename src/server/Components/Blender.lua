local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TweenModule = require(Knit.Shared.Modules.TweenUtil)
local NumberUtil = require(Knit.Shared.Modules.NumberUtil)

local Component = require(game:GetService("ReplicatedStorage").Packages.Component)

----- Directories -----

local IngredientsAvailable = workspace:WaitForChild("IngredientAvailable")
local FoodAvailable = workspace:WaitForChild("FoodAvailable")

local GameLibrary = ReplicatedStorage:FindFirstChild("GameLibrary")
local IngredientObjects = GameLibrary:FindFirstChild("IngredientObjects")

local ServerModules = Knit.Modules
local SpawnItemsAPI = require(ServerModules:FindFirstChild("SpawnItems"))

local MyComponent = Component.new({
	Tag = "Blender",
	Ancestors = {workspace}, -- Optional array of ancestors in which components will be started
	Extensions = {}, -- See Logger example above with the example for the Extension type
})

-- Optional if UpdateRenderStepped should use BindToRenderStep:
MyComponent.RenderPriority = Enum.RenderPriority.Camera.Value

function MyComponent:Construct()
end

function MyComponent:Start()
end

function MyComponent:Stop()
end

function MyComponent:HeartbeatUpdate(dt)
end

function MyComponent:SteppedUpdate(dt)
end

function MyComponent:RenderSteppedUpdate(dt)
end

MyComponent.Started:Connect(function(component)
	local robloxInstance: Instance = component.Instance
	print("Component is bound to " .. robloxInstance:GetFullName())

    local Object = robloxInstance
    local BlenderEnabled = true
    local playersDebounces = {}
    local ObjectsInBlender = {}
    local BlenderColors = {}
    local colorOfFood = {}
    local MaxNumOfObjects = 5
    local NumOfObjects = {}
    local NumOfObjectsTextLabel = Object.Glass.Glass.NumOfObjects.TextLabel

    component._maid = Maid.new()

    local function PlayerAdded(player)
        playersDebounces[player.UserId] = nil
        ObjectsInBlender[player.UserId] = {}
        BlenderColors[player.UserId] = Color3.fromRGB(255,255,255)
        NumOfObjects[player.UserId] = 0
    end
    
    local function PlayerRemoving(player)
        playersDebounces[player.UserId] = nil
        ObjectsInBlender[player.UserId] = nil
        BlenderColors[player.UserId] = nil
        NumOfObjects[player.UserId] = nil
    end

    local function InsertObjToBlender(player, Obj)
        local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints")
        if Obj:IsA("Model") and Obj.PrimaryPart then
            Obj.PrimaryPart.ProximityPrompt.Enabled = false
        else
            Obj.ProximityPrompt.Enabled = false
        end

        local objItem = (Obj:IsA("Model") and Obj.PrimaryPart ~= nil and Obj.PrimaryPart or Obj)

        print(objItem)

        local CookingService = Knit.GetService("CookingService")
        CookingService.Client.ChangeClientBlender:Fire(player,
            Object, -- blender object
            "itemPoof", -- command
            { -- data
                Position = objItem.Position + Vector3.new(0,-7,0),
                Color = objItem.Color, 
            }
        )

        local RandomFoodLocation = FoodSpawnPoints[math.random(1, #FoodSpawnPoints)]
        if RandomFoodLocation then
            if Obj:IsA("Model") and Obj.PrimaryPart then
                Obj:SetPrimaryPartCFrame(CFrame.new(RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))))
            else
                Obj.Position = RandomFoodLocation.Position + Vector3.new(math.random(-5,5) ,5, math.random(-5,5))
            end
        end

        task.wait(0.1)

        if Obj:IsA("Model") and Obj.PrimaryPart then
            Obj.PrimaryPart.ProximityPrompt.Enabled = true
        else
            Obj.ProximityPrompt.Enabled = true
        end
    end

    local function SpinBlade(enabled)
        if enabled == true then
            print('huh')
            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

            local SpinTween = TweenService:Create(Object.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 100 })

            SpinTween:Play()
            SpinTween.Completed:Wait()

            Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 70
        else

            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

            local SpinTween = TweenService:Create(Object.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 0 })

            SpinTween:Play()
            SpinTween.Completed:Wait()

            Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 0
        end
    end

    local function PlayEffects(enabled)
        for _, particle in pairs(Object.ParticleHolder:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = enabled
            end
        end

        task.spawn(function()
            task.wait(3)
            for _, particle in pairs(Object.ParticleHolder:GetDescendants()) do
                if particle:IsA("ParticleEmitter") then
                    particle:Clear()
                end
            end
        end)
    end

    component._maid:GiveTask(Object.Blade.Blade.Touched:Connect(function(hit)
        if BlenderEnabled == false then return end
        if CollectionService:HasTag(hit, "CC_Food") then return end
        --print(hit)
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if BlenderEnabled == false then
            if humanoid and player then
                if playersDebounces[player.UserId] == nil then
                    playersDebounces[player.UserId] = true
                    humanoid.Health -= 10
                    task.wait(1)
                    playersDebounces[player.UserId] = nil
                end
            end
        else
            if humanoid and player then
                humanoid.BreakJointsOnDeath = true
                humanoid.Health = -1
            end
            local function tablefind(tab,el) for index, value in pairs(tab) do if value == el then	return index end end end
            if hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner") then
                local player = game.Players:FindFirstChild(hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner"))
                if not player then return end
                if not ObjectsInBlender[player.UserId] then ObjectsInBlender[player.UserId] = {} end
                if not NumOfObjects[player.UserId] then NumOfObjects[player.UserId] = 0 end
                if not BlenderColors[player.UserId] then BlenderColors[player.UserId] = Color3.fromRGB(255,255,255) end
            end

            if hit:GetAttribute("Type") or hit.Parent:GetAttribute("Type") then
                
                local isAModel = (hit.Parent:IsA("Model") 
                and hit.Parent.PrimaryPart ~= nil 
                and hit.Parent.PrimaryPart:GetAttribute("Owner") ~= nil) and true or false
                
                print(hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner"), "isAModel:", isAModel)
                local player = game.Players:FindFirstChild(hit:GetAttribute("Owner") or hit.Parent:GetAttribute("Owner"))
                if not player then return end
                
                if (NumOfObjects[player.UserId] >= 5 and playersDebounces[player.UserId] == nil)
                or CollectionService:HasTag(hit, "IngredientsTable") == true then
                    local obj = (isAModel == true and hit.Parent) or hit
                    if isAModel == true then
                        obj:SetPrimaryPartCFrame(CFrame.new(Object.ReturnObj.Position + Vector3.new(0,5,0)))
                    else
                        obj.Position = Object.ReturnObj.Position + Vector3.new(0,5,0)
                    end

                    local NotificationService = Knit.GetService("NotificationService")
                    NotificationService:Message(false, player, "Blender is full!")
                    return
                end

                local objToInsert = (isAModel == true and hit.Parent) or hit
                if table.find(ObjectsInBlender[player.UserId], objToInsert) == nil then
                    table.insert(ObjectsInBlender[player.UserId], objToInsert)
                    playersDebounces[player.UserId] = true
                    InsertObjToBlender(player, hit)
                    NumOfObjects[player.UserId] += 1

                    local obj = (isAModel == true and hit.Parent) or hit
                    if isAModel == true then
                        colorOfFood[player.UserId] = obj.PrimaryPart.Color
                    else
                        colorOfFood[player.UserId] = obj.Color
                    end 

                    if NumOfObjects[player.UserId] then
                        if NumOfObjects[player.UserId] > 1 then
                            local oColor = BlenderColors[player.UserId]
                            print("oColor", oColor)
                            BlenderColors[player.UserId] = oColor:Lerp(colorOfFood[player.UserId], 0.5)
                        else
                            BlenderColors[player.UserId] = colorOfFood[player.UserId]
                        end
                    end

                    local CookingService = Knit.GetService("CookingService")
                    CookingService.Client.ChangeClientBlender:Fire(player,
                        Object, -- blender object
                        "fluidPercentage", -- command
                        { -- data
                        FluidPercentage = (NumOfObjects[player.UserId] / MaxNumOfObjects), -- fluid 
                        FluidText = tostring(NumOfObjects[player.UserId].."/"..MaxNumOfObjects), -- blender text
                        FluidColor = BlenderColors[player.UserId], -- color of food
                        })

                    print("BLADE HIT", hit, hit.Parent, ObjectsInBlender[player.UserId])
                    playersDebounces[player.UserId] = nil
                end
            end
        end
    end))

    component._maid:GiveTask(Object.Button.ProximityPrompt.TriggerEnded:Connect(function(player)
        --task.spawn(TemporaryDisableButton, 3)
        if BlenderEnabled == false then 
            local NotificationService = Knit.GetService("NotificationService")
            NotificationService:Message(false, player, "Blender is off!")
            return 
        end

        print("BLENDER", BlenderEnabled, playersDebounces[player.UserId])

        if playersDebounces[player.UserId] == nil then
            playersDebounces[player.UserId] = true

            --print("NumOfObjects", NumOfObjects[player.UserId])
            local NotificationService = Knit.GetService("NotificationService")

            if not ObjectsInBlender[player.UserId] then ObjectsInBlender[player.UserId] = {} end
            if not NumOfObjects[player.UserId] then NumOfObjects[player.UserId] = 0 end

            if NumOfObjects[player.UserId] == 0 then
                NotificationService:Message(false, player, "Blender is empty!")
            else
                NumOfObjects[player.UserId] = 0

                local blendedFood = SpawnItemsAPI:SpawnBlenderFood(
                    player.UserId, 
                    player, 
                    ObjectsInBlender[player.UserId], 
                    IngredientObjects, 
                    IngredientsAvailable, 
                    (Object.ReturnObj.Position + Vector3.new(0,5,0)),
                    BlenderColors[player.UserId]
                )

                NotificationService:Message(false, player, "Blended food is dropped!")
                
                ObjectsInBlender[player.UserId] = {}

                local CookingService = Knit.GetService("CookingService")
                CookingService.Client.ChangeClientBlender:Fire(player,
                    Object, -- blender object
                    "fluidPercentage", -- command
                    { -- data
                        FluidPercentage = (NumOfObjects[player.UserId] / MaxNumOfObjects), -- fluid 
                        FluidText = tostring(NumOfObjects[player.UserId].."/"..MaxNumOfObjects), -- blender text
                        FluidColor = Color3.fromRGB(66, 123, 255), -- color of food
                    })
            end

            task.wait(1)
            playersDebounces[player.UserId] = nil
        end
	end))

    component._maid:GiveTask(Object:GetAttributeChangedSignal("Enabled"):Connect(function(player)
        local Enabled = Object:GetAttribute("Enabled")

        if Enabled then
            BlenderEnabled = true

            Object.Lid.Transparency = 1
            Object.Lid.CanCollide =  false
        
            task.spawn(SpinBlade, true)
            PlayEffects(true)
            Object.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
            Object.Button.ProximityPrompt.ActionText = "Get Blended Food"
        else
            BlenderEnabled = false

            Object.Lid.Transparency = 0
            Object.Lid.CanCollide = true
        
            task.spawn(SpinBlade, false)
            PlayEffects(false)
            Object.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(166, 0, 0)
            Object.Button.ProximityPrompt.ActionText = "Disabled"

            playersDebounces = {}
            ObjectsInBlender = {}
            BlenderColors = {}
            colorOfFood = {}
            MaxNumOfObjects = 5
            NumOfObjects = {}
            local CookingService = Knit.GetService("CookingService")
            CookingService.Client.ChangeClientBlender:FireAll(
                Object, -- blender object
                "fluidPercentage", -- command
                { -- data
                    FluidPercentage = (0 / MaxNumOfObjects), -- fluid 
                    FluidText = tostring("..."), -- blender text
                    FluidColor = Color3.fromRGB(66, 123, 255), -- color of food
                })
        end
	end))

    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(PlayerAdded)(player)
    end

    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(PlayerRemoving)
end)

MyComponent.Stopped:Connect(function(component) 
    local robloxInstance: Instance = component.Instance
	print("Component is not bound to " .. robloxInstance:GetFullName() .. " anymore")
    if component._maid then component._maid:Destroy() end
end)

return {}