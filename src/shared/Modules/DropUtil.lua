-- Drop Util
-- Real_KingBob
-- July 25, 2022

local DropUtil = {};

local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TweenModule = require(game.ReplicatedStorage.Common.Modules.TweenUtil);
local NumberSuffix = require(game.ReplicatedStorage.Common.Modules.NumberSuffix);
local NumberUtil = require(game.ReplicatedStorage.Common.Modules.NumberUtil);

local Sfx = game.SoundService.Sfx;

local cancelDebris = {}

local function Destroyed(x)
	if x.Parent then
		return false
	end
	local _, result = pcall(function()
		x.Parent = x
	end)
	return result:match("locked") and true or false
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

function DropUtil.DropCheese(oCFrame, obj, amount, value)

    for i= 0, amount do
        local cloneObject = obj:Clone()
        cloneObject.Name = "Cheese"..i
        cloneObject:SetAttribute("Amount", value)
        cloneObject.CFrame = oCFrame
        game:GetService("Debris"):AddItem(cloneObject, 10)
        cloneObject.Parent = workspace.Spawnables.Cheese

        local randomX = {math.random(-10, -4), math.random(4,10)}
        local randomZ = {math.random(-10, -4), math.random(4,10)}

        local velocity = Vector3.new(randomX[math.random(1,2)], math.random(60,70), randomZ[math.random(1,2)])

        cloneObject.AssemblyLinearVelocity = velocity;

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
        end)

        --[[task.spawn(function()
            task.delay(10, function()
                if cloneObject and cloneObject.Parent then
                    cloneObject:Destroy()
                end
            end)
        end)]]
    end
end

function DropUtil.DropCurrencyText(oCFrame, amount, userId)

    local DataService = Knit.GetService("DataService")

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

        local CurrencyCollected = Sfx:WaitForChild("CheesePop"):Clone() do
            CurrencyCollected.Volume = NumberUtil.Lerp(.1, .4, math.random());
            CurrencyCollected.Parent = prevObj;
            
            CurrencyCollected.Ended:Connect(function()
                CurrencyCollected:Destroy();
            end)
    
            CurrencyCollected:Play();
        end

        local player = Players:GetPlayerByUserId(userId)

        DataService.GiveCurrency:Fire(tonumber(amount))

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

    local CurrencyCollected = Sfx:WaitForChild("CheesePop"):Clone() do
        CurrencyCollected.Volume = NumberUtil.Lerp(.1, .4, math.random());
        CurrencyCollected.Parent = cloneObject;
        
        CurrencyCollected.Ended:Connect(function()
            CurrencyCollected:Destroy();
        end)

        CurrencyCollected:Play();
    end

    DataService.GiveCurrency:Fire(tonumber(amount))

    fadeInObj(cloneObject)

    cancelDebris[userId] = customDebris(cloneObject, 1.25)
end

return DropUtil