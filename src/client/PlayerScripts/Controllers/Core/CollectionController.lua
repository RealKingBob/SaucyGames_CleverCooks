--[[
    Name: Collection Controller [V1]
    By: Real_KingBob
    Updated: 2/17/23
    Description: Handles client-sided effects on collecting items that the server-sided scripts send
    Example: Cheese!
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local TweenService = game:GetService("TweenService")

local CollectionController = Knit.CreateController { Name = "CollectionController" }

local localPlayer = Players.LocalPlayer;

local debounces = {};
local cancelDebris = {}

local TweenModule = require(game.ReplicatedStorage.Common.Modules.TweenUtil);
local NumberSuffix = require(game.ReplicatedStorage.Common.Modules.NumberSuffix);
local NumberUtil = require(game.ReplicatedStorage.Common.Modules.NumberUtil);

local Sfx = game.SoundService.Sfx;

local CurrencyCollected;

-- Checks if an object has been destroyed or not.
-- Returns true if the object has been destroyed, false otherwise.
local function Destroyed(x)
	if x.Parent then
		return false
	end
	local _, result = pcall(function()
		x.Parent = x
	end)
	return result:match("locked") and true or false
end

-- Creates a bouncing animation for a part.
-- The part will move up and then back down to its original position.
local function bounce(part)
    if not part then return end
    if part.AssemblyLinearVelocity ~= Vector3.new(0, 0, 0) then return end

    local tweenInfo = TweenInfo.new(
        0.1, -- Time
        Enum.EasingStyle.Linear , -- EasingStyle
        Enum.EasingDirection.Out, -- EasingDirection
        0, -- RepeatCount (when less than zero the tween will loop indefinitely)
        true, -- Reverses (tween will reverse once reaching it's goal)
        0 -- DelayTime
    )

    local NewPosition = part.Position + Vector3.new(0, .3, 0)
    local tween = TweenService:Create(part, tweenInfo, {Position = NewPosition})
    tween:Play()
end

-- Creates a fading animation for a UI instance.
-- The instance will fade out and move up slightly before being destroyed.
local function customDebris(instance, lifetime)
	local continueDebris = true

    local FadeOut = TweenModule.new(TweenInfo.new(.75, Enum.EasingStyle.Back, Enum.EasingDirection.In), function(Alpha)
        local tweenUI = instance.UI
        tweenUI.ExtentsOffsetWorldSpace = Vector3.new(0,NumberUtil.LerpClamp(1, 5, Alpha),0)
        
        tweenUI.Amount.TextTransparency = NumberUtil.LerpClamp(0, 1, Alpha);
        tweenUI.Amount.UIStroke.Transparency = NumberUtil.LerpClamp(0, 1, Alpha);
        tweenUI.Icon.ImageTransparency = NumberUtil.LerpClamp(0, 1, Alpha);
    end)

	coroutine.wrap(function()
		task.wait(lifetime)
		local isDestroyedAlready = Destroyed(instance)
		if continueDebris and instance and not isDestroyedAlready then
            instance.Name = "_oldCurrency"
            CurrencyCollected = nil;
            task.wait(.5)
            FadeOut:Play();
            FadeOut.Completed:Wait();
			instance:Destroy()
		end
	end)()

	return function()
		continueDebris = false
	end
end

-- Clones the objects from a given table, modifies their attributes, and drops them into the game world with a sound effect and a bouncing animation.
function CollectionController:DropItem(type, tableOfObjs)
    for objIndex, objData in pairs(tableOfObjs) do
        local cloneObject = objData.Object:Clone()
        cloneObject.Name = "Cheese"..objIndex
        cloneObject:SetAttribute("ObjectId", objData.ObjectId)
        cloneObject:SetAttribute("Type", objData.Type)

        cloneObject.CFrame = objData.OriginalCFrame
        cloneObject.Parent = workspace.Spawnables:FindFirstChild(type)
        cloneObject.AssemblyLinearVelocity = objData.InitialVelocity;

        task.spawn(function()
            local random = Random.new()

            task.wait(random:NextNumber(0, .4))
            local CheeseDrop = Sfx:WaitForChild("Small Pop"):Clone() do
                CheeseDrop.Volume = NumberUtil.Lerp(.1, .4, math.random());
                CheeseDrop.Parent = cloneObject;
                
                CheeseDrop.Ended:Connect(function()
                    CheeseDrop:Destroy();
                end)
    
                CheeseDrop:Play();
            end

            task.wait(3)

            repeat
                task.wait(random:NextNumber(1,3))
                bounce(cloneObject);
            until cloneObject == nil
        end)
    end
end

-- Drops currency and creates a UI pop-up indicating the amount, and can stack multiple instances for a single user.
function CollectionController:DropCurrencyText(oCFrame, amount, userId)

    local function fadeInObj(instance)
        local PopUpTweenInfo = TweenInfo.new(.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    
        local FadeIn = TweenModule.new(PopUpTweenInfo, function(Alpha)
            local tweenUI = instance.UI
            tweenUI.ExtentsOffsetWorldSpace = Vector3.new(0,NumberUtil.LerpClamp(0, 1, Alpha),0)
            tweenUI.Amount.TextColor3 = Color3.fromRGB(255, 238, 110):Lerp(Color3.fromRGB(255, 207, 19), Alpha)
        end)

        FadeIn:Play()
    end

    local prevObj = workspace.Spawnables.CurrencyText:FindFirstChild("Currency_"..userId)
    if prevObj then
        cancelDebris[userId]()
        local prevAmount = prevObj:GetAttribute("Amount");
        local newAmount = prevAmount + amount;
        prevObj:SetAttribute("Amount", newAmount)
        prevObj.UI.Amount.Text = NumberSuffix(newAmount);
        prevObj.CFrame = oCFrame;

        if CurrencyCollected then
            CurrencyCollected.Volume = NumberUtil.Lerp(.1, .4, math.random());
            CurrencyCollected:Play();
        end

        fadeInObj(prevObj)
        cancelDebris[userId] = customDebris(prevObj, 1.25)
        return;
    end

    local obj = game.ReplicatedStorage.Spawnables.CurrencyDrop;
    local cloneObject = obj:Clone();
    cloneObject.Name = "Currency_"..userId;
    cloneObject:SetAttribute("userId", userId)
    cloneObject:SetAttribute("Amount", amount)
    cloneObject.UI.Amount.Text = NumberSuffix(amount);
    cloneObject.CFrame = oCFrame;
    cloneObject.Parent = workspace.Spawnables.CurrencyText;

    CurrencyCollected = Sfx:WaitForChild("CheesePop"):Clone() do
        CurrencyCollected.Volume = NumberUtil.Lerp(.1, .4, math.random());
        CurrencyCollected.Parent = cloneObject;
        
        CurrencyCollected:Play();
    end

    fadeInObj(cloneObject)

    cancelDebris[userId] = customDebris(cloneObject, 1.25)
end

function CollectionController:KnitStart()
    local CurrencySessionService = Knit.GetService("CurrencySessionService");

    CurrencySessionService.DropCurrency:Connect(function(type, objectData)
        if type == "Cheese" then
            self:DropItem(type, objectData)
        end
    end)

    CurrencySessionService.CurrencyCollected:Connect(function(RootCFrame, DropAmount)
        --print("CurrencyCollected", RootCFrame, DropAmount)
        self:DropCurrencyText(RootCFrame, DropAmount, localPlayer.UserId)
    end)
    
    while true do
        local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait();
        if Character then
            local Root = Character:FindFirstChild("HumanoidRootPart")
            if Root then
                for _, dropable in pairs(workspace.Spawnables.Cheese:GetChildren()) do
                    if dropable:IsA("Part") 
                    and CollectionService:HasTag(dropable, "Dropable") then
                        local magnitude = (Root.Position - dropable.Position).Magnitude;

                        if magnitude < 10 then
                            dropable.CanCollide = false;
                            dropable.Anchored = true;
                            dropable.CFrame = dropable.CFrame:Lerp(Root.CFrame, 0.26)

                            task.spawn(function()
                                if magnitude <= 2 then
                                    if not debounces[dropable] then
                                        debounces[dropable] = true
                                        TweenService:Create(dropable.Cheese, TweenInfo.new(0.1), {Size = UDim2.fromScale(0,0)}):Play()
                                        task.wait(0.1)
                                        CurrencySessionService.CurrencyCollected:Fire(
                                            dropable:GetAttribute("ObjectId"), 
                                            dropable:GetAttribute("Type"),
                                            Root.CFrame
                                        )
                                        dropable:Destroy()
                                        debounces[dropable] = nil
                                    end
                                end
                            end)

                        end
                    end
                end
            end
        end
        task.wait()
    end
end


function CollectionController:KnitInit()
    
end


return CollectionController
