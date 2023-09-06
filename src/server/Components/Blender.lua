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

MyComponent.Started:Connect(function(component)
	local robloxInstance: Instance = component.Instance
	print("Component is bound to " .. robloxInstance:GetFullName())

    local BlenderEnabled = true
    local playersDebounces = {}
    local ObjectsInBlender = {}
    local BlenderColors = Color3.fromRGB(255,255,255)
    local colorOfFood = Color3.fromRGB(255,255,255)
    local MaxNumOfObjects = 5
    local NumOfObjects = 0

    component._maid = Maid.new()

    robloxInstance.Button.ProximityPrompt.Enabled = true

    local function InsertObjToBlender(Obj)
        local FoodSpawnPoints = CollectionService:GetTagged("FoodSpawnPoints")
        if Obj:IsA("Model") and Obj.PrimaryPart then
            Obj.PrimaryPart.ProximityPrompt.Enabled = false
        else
            Obj.ProximityPrompt.Enabled = false
        end

        local objItem = (Obj:IsA("Model") and Obj.PrimaryPart ~= nil and Obj.PrimaryPart or Obj)

        local CookingService = Knit.GetService("CookingService")
        CookingService.Client.ChangeClientBlender:FireAll(
            robloxInstance, -- blender object
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
            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

            local SpinTween = TweenService:Create(robloxInstance.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 100 })

            SpinTween:Play()
            SpinTween.Completed:Wait()

            robloxInstance.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 70
        else

            local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

            local SpinTween = TweenService:Create(robloxInstance.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 0 })

            SpinTween:Play()
            SpinTween.Completed:Wait()

            robloxInstance.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 0
        end
    end

    local function PlayEffects(enabled)
        for _, particle in pairs(robloxInstance.ParticleHolder:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = enabled
            end
        end

        task.spawn(function()
            task.wait(3)
            for _, particle in pairs(robloxInstance.ParticleHolder:GetDescendants()) do
                if particle:IsA("ParticleEmitter") then
                    particle:Clear()
                end
            end
        end)
    end

    component._maid:GiveTask(robloxInstance.Blade.Blade.Touched:Connect(function(hit)
        if CollectionService:HasTag(hit, "CC_Food") then return end
        
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)

        if BlenderEnabled then
            if humanoid and player then
                humanoid.BreakJointsOnDeath = true
                humanoid.Health = -1
            end


            if not ObjectsInBlender then ObjectsInBlender = {} end
            if not NumOfObjects then NumOfObjects = 0 end
            if not BlenderColors then BlenderColors = Color3.fromRGB(255,255,255) end

            if hit:GetAttribute("Type") or hit.Parent:GetAttribute("Type") then
                
                local isAModel = (hit.Parent:IsA("Model") 
                and hit.Parent.PrimaryPart ~= nil) and true or false
                
                if NumOfObjects >= 5 or CollectionService:HasTag(hit, "IngredientsTable") == true then
                    local obj = (isAModel == true and hit.Parent) or hit
                    if isAModel == true then
                        obj:SetPrimaryPartCFrame(CFrame.new(robloxInstance.ReturnObj.Position + Vector3.new(0,5,0)))
                    else
                        obj.Position = robloxInstance.ReturnObj.Position + Vector3.new(0,5,0)
                    end

                    local NotificationService = Knit.GetService("NotificationService")
                    NotificationService:Message(false, player, "Blender is full!")
                    return
                end

                local objToInsert = (isAModel == true and hit.Parent) or hit
                if table.find(ObjectsInBlender, objToInsert) == nil then
                    table.insert(ObjectsInBlender, objToInsert)
                    InsertObjToBlender(hit)
                    NumOfObjects += 1

                    local obj = (isAModel == true and hit.Parent) or hit
                    if isAModel == true then
                        colorOfFood = obj.PrimaryPart.Color
                    else
                        colorOfFood = obj.Color
                    end 

                    if NumOfObjects then
                        if NumOfObjects > 1 then
                            local oColor = BlenderColors
                            print("oColor", oColor)
                            BlenderColors = oColor:Lerp(colorOfFood, 0.5)
                        else
                            BlenderColors = colorOfFood
                        end
                    end

                    local CookingService = Knit.GetService("CookingService")
                    CookingService.Client.ChangeClientBlender:FireAll(
                        robloxInstance, -- blender object
                        "fluidPercentage", -- command
                        { -- data
                        FluidPercentage = (NumOfObjects / MaxNumOfObjects), -- fluid 
                        FluidText = tostring(NumOfObjects.."/"..MaxNumOfObjects), -- blender text
                        FluidColor = BlenderColors, -- color of food
                        })

                    print("BLADE HIT", hit, hit.Parent, ObjectsInBlender)
                end
            end
        else
            if humanoid and player then
                if not playersDebounces[player] then
                    playersDebounces[player] = true
                    humanoid.Health -= 10
                    task.wait(1)
                    playersDebounces[player] = nil
                end
            end
        end
    end))

    component._maid:GiveTask(robloxInstance.Button.ProximityPrompt.TriggerEnded:Connect(function(player)
        --task.spawn(TemporaryDisableButton, 3)
        if BlenderEnabled == false then 
            local NotificationService = Knit.GetService("NotificationService")
            NotificationService:Message(false, player, "Blender is off!")
            return 
        end

        print("BLENDER", BlenderEnabled, playersDebounces)

        if not playersDebounces[player] then
            playersDebounces[player] = true

            --print("NumOfObjects", NumOfObjects)
            local NotificationService = Knit.GetService("NotificationService")

            if not ObjectsInBlender then ObjectsInBlender = {} end
            if not NumOfObjects then NumOfObjects = 0 end

            if NumOfObjects == 0 then
                NotificationService:Message(false, player, "Blender is empty!")
            else
                NumOfObjects = 0

                local blendedFood = SpawnItemsAPI:SpawnBlenderFood(
                    player.UserId, 
                    player, 
                    ObjectsInBlender, 
                    IngredientObjects, 
                    IngredientsAvailable, 
                    (robloxInstance.ReturnObj.Position + Vector3.new(0,5,0)),
                    BlenderColors
                )

                NotificationService:Message(false, player, "Blended food is dropped!")
                
                ObjectsInBlender = {}

                local CookingService = Knit.GetService("CookingService")
                CookingService.Client.ChangeClientBlender:FireAll(
                    robloxInstance, -- blender object
                    "fluidPercentage", -- command
                    { -- data
                        FluidPercentage = (NumOfObjects / MaxNumOfObjects), -- fluid 
                        FluidText = tostring(NumOfObjects.."/"..MaxNumOfObjects), -- blender text
                        FluidColor = Color3.fromRGB(66, 123, 255), -- color of food
                    })
            end

            task.wait(1)
            playersDebounces[player] = nil
        end
	end))

    component._maid:GiveTask(robloxInstance:GetAttributeChangedSignal("Enabled"):Connect(function(player)
        local Enabled = robloxInstance:GetAttribute("Enabled")

        if Enabled then
            BlenderEnabled = true

            robloxInstance.Lid.Transparency = 1
            robloxInstance.Lid.CanCollide =  false
        
            task.spawn(SpinBlade, true)
            PlayEffects(true)
            robloxInstance.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
            robloxInstance.Button.ProximityPrompt.ActionText = "Get Blended Food"
        else
            BlenderEnabled = false

            robloxInstance.Lid.Transparency = 0
            robloxInstance.Lid.CanCollide = true
        
            task.spawn(SpinBlade, false)
            PlayEffects(false)
            robloxInstance.Button.SurfaceGui.Frame.BackgroundColor3 = Color3.fromRGB(166, 0, 0)
            robloxInstance.Button.ProximityPrompt.ActionText = "Disabled"

            playersDebounces = {}
            ObjectsInBlender = {}
            BlenderColors = Color3.fromRGB(255,255,255)
            colorOfFood = Color3.fromRGB(255,255,255)
            MaxNumOfObjects = 5
            NumOfObjects = 0
            local CookingService = Knit.GetService("CookingService")
            CookingService.Client.ChangeClientBlender:FireAll(
                robloxInstance, -- blender object
                "fluidPercentage", -- command
                { -- data
                    FluidPercentage = (0 / MaxNumOfObjects), -- fluid 
                    FluidText = tostring("..."), -- blender text
                    FluidColor = Color3.fromRGB(66, 123, 255), -- color of food
                })
        end
	end))
end)

MyComponent.Stopped:Connect(function(component) 
    local robloxInstance: Instance = component.Instance
	print("Component is not bound to " .. robloxInstance:GetFullName() .. " anymore")
    if component._maid then component._maid:Destroy() end
end)

return {}