local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local TweenService = game:GetService("TweenService")

local CollectionController = Knit.CreateController { Name = "CollectionController" }

local LocalPlayer = Players.LocalPlayer;

local Debounces = {};
local cancelDebris = {}

local TweenModule = require(game.ReplicatedStorage.Common.Modules.TweenUtil);
local NumberSuffix = require(game.ReplicatedStorage.Common.Modules.NumberSuffix);
local NumberUtil = require(game.ReplicatedStorage.Common.Modules.NumberUtil);

local Sfx = game.SoundService.Sfx;

local CurrencyCollected;

local function Destroyed(x)
	if x.Parent then
		return false
	end
	local _, result = pcall(function()
		x.Parent = x
	end)
	return result:match("locked") and true or false
end

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

local function customDebris(instance, lifetime)
	local continueDebris = true

    local DisapearInfo = TweenInfo.new(.75, Enum.EasingStyle.Back, Enum.EasingDirection.In);

    local FadeOut = TweenModule.new(DisapearInfo, function(Alpha)
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

function CollectionController:DropCheese(tableOfObjs)
    for objIndex, objData in pairs(tableOfObjs) do
        local cloneObject = objData.Object:Clone()
        cloneObject.Name = "Cheese"..objIndex
        cloneObject:SetAttribute("ObjectId", objData.ObjectId)
        cloneObject:SetAttribute("Type", objData.Type)
        --if not player then player = { Name = nil; UserId = 0; } end
        --cloneObject:SetAttribute("OwnerName", player.Name)
        --cloneObject:SetAttribute("OwnerId", player.UserId)

        cloneObject.CFrame = objData.OriginalCFrame
        --game:GetService("Debris"):AddItem(cloneObject, 120)
        cloneObject.Parent = workspace.Spawnables.Cheese
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
            local random = Random.new()

            repeat
                task.wait(random:NextNumber(1,3))
                bounce(cloneObject);
            until cloneObject == nil
        end)
    end
end

function CollectionController:DropCurrencyText(oCFrame, amount, userId)
    --print("DropCurrencyText", amount, userId)

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

        --[[CurrencyCollected = Sfx:WaitForChild("CheesePop"):Clone() do
            CurrencyCollected.Volume = NumberUtil.Lerp(.1, .4, math.random());
            CurrencyCollected.Parent = prevObj;
            
            CurrencyCollected.Ended:Connect(function()
                CurrencyCollected:Destroy();
            end)
    
            CurrencyCollected:Play();
        end]]

        local player = Players:GetPlayerByUserId(userId)

        --DataService:GiveCurrency(player, tonumber(amount))

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
        
        --[[CurrencyCollected.Ended:Connect(function()
            CurrencyCollected:Destroy();
        end)]]

        CurrencyCollected:Play();
    end

    local player = Players:GetPlayerByUserId(userId)

    --DataService:GiveCurrency(player, tonumber(amount))

    fadeInObj(cloneObject)

    cancelDebris[userId] = customDebris(cloneObject, 1.25)
end

function CollectionController:KnitStart()
    local CurrencySessionService = Knit.GetService("CurrencySessionService");

    CurrencySessionService.DropCurrency:Connect(function(type, objectData)
        if type == "Cheese" then
            self:DropCheese(objectData)
        end
    end)

    CurrencySessionService.CurrencyCollected:Connect(function(RootCFrame, DropAmount)
        --print("CurrencyCollected", RootCFrame, DropAmount)
        self:DropCurrencyText(RootCFrame, DropAmount, LocalPlayer.UserId)
    end)
    
    while true do
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
        if Character then
            local Root = Character:FindFirstChild("HumanoidRootPart")
            if Root then
                for _, dropable in pairs(workspace.Spawnables.Cheese:GetChildren()) do
                    --[[if dropable:GetAttribute("OwnerId") ~= LocalPlayer.UserId then
                        --print("dropable destroyed")
                        dropable:Destroy()
                        continue;
                    end]]
                    if dropable:IsA("Part") 
                    and CollectionService:HasTag(dropable, "Dropable") then
                        local magnitude = (Root.Position - dropable.Position).Magnitude;

                        if magnitude < 10 then
                            dropable.CanCollide = false;
                            dropable.Anchored = true;
                            dropable.CFrame = dropable.CFrame:Lerp(Root.CFrame, 0.26)--dropable.CFrame:Lerp(Root.CFrame, 0.15)

                            --print("magnitude: ".. magnitude)

                            task.spawn(function()
                                if magnitude <= 2 then
                                    if not Debounces[dropable] then
                                        Debounces[dropable] = true
                                        TweenService:Create(dropable.Cheese, TweenInfo.new(0.1), {Size = UDim2.fromScale(0,0)}):Play()
                                        task.wait(0.1)
                                        CurrencySessionService.CurrencyCollected:Fire(
                                            dropable:GetAttribute("ObjectId"), 
                                            dropable:GetAttribute("Type"),
                                            Root.CFrame
                                        )
                                        dropable:Destroy()
                                        Debounces[dropable] = nil
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
