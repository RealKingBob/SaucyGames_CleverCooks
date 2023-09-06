local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CurrencyCounterUI = Knit.CreateController { Name = "CurrencyCounterUI" }

--//Services
local TweenService = game:GetService("TweenService")

local plr = game.Players.LocalPlayer

--//Imports
local NumberSuffix
local NumberUtil
local TweenModule

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui")
local CheeseContainer = PlayerGui:WaitForChild("CurrencyCollectorGui")
local CheesePrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("CheeseImage")

local CurrencyUI = PlayerGui:WaitForChild("Currency")
local MainFrame =  CurrencyUI:WaitForChild("Frame")
local CheeseLabel = MainFrame:WaitForChild("TextLabel")
local AmountLabel = MainFrame:WaitForChild("Amount")
local AddButton = MainFrame:WaitForChild("Add")

local PopUpTweenInfo = TweenInfo.new(.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DisapearInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local ChangeInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local ExpandInfo = TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CloseInfo = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local CollectTextInfo = TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local Sfx = game.SoundService.Sfx

--//State
local LastCheese = -1

function CurrencyCounterUI:CollectCheese(Amount, AmountAdded, Percentage)
	--print(Amount)
    local CoinDrop = Sfx:WaitForChild("CheesePop"):Clone() do
		CoinDrop.Parent = game.SoundService
	
		CoinDrop.Ended:Connect(function()
			CoinDrop:Destroy()
		end)
	
		CoinDrop:Play()
	end

	if (AmountAdded) then		
		AmountLabel.Position = UDim2.fromScale(-0.15, -0.55)
		local amountString = "+"..AmountAdded
		if AmountAdded >= 10000 then
			amountString = "+"..NumberSuffix(AmountAdded)
		end
		if Percentage then
			AmountLabel.Text = Percentage
		else
			AmountLabel.Text = amountString
		end
		
		AmountLabel.Visible = true
	end

	local TargetCoins = math.random(8, 15)

    for i = 1, TargetCoins do
		task.delay(.5 * math.random(), function()
            if (i == TargetCoins) then
                self:SpawnDrop(function()
					if (AmountAdded) then
						local Tween = TweenService:Create(AmountLabel, CollectTextInfo, { Position = UDim2.fromScale(-0.15, 0.25) })
						Tween:Play()
						Tween.Completed:Wait()
						AmountLabel.Visible = false
					end
					
                    self:Update(Amount)
                end)
            else
                self:SpawnDrop()
            end
		end)
	end
end

function CurrencyCounterUI:SpawnDrop(DropCb)
	local DropEnded = Instance.new("BindableEvent")
	local ScreenSize = CheeseContainer.AbsoluteSize
	local xRand, yRand = math.random(-ScreenSize.X/4, ScreenSize.X/4), math.random(-ScreenSize.Y/4, ScreenSize.Y/4)
	local Middle = UDim2.new(0, ScreenSize.X / 2, 0, ScreenSize.Y / 2)

    local Clone = CheesePrefab:Clone()
    local OriginalSize = Clone.Size
	
	Clone.Position = Middle
	Clone.Size = UDim2.fromScale(0, 0)
	Clone.Visible = true
    Clone.Parent = CheeseContainer
    
    local TargetRotation = math.random(-45, 45)
    
    local FadeIn = TweenModule.new(PopUpTweenInfo, function(Alpha)
		Clone.ImageTransparency = 1 - Alpha
		Clone.Rotation = TargetRotation * Alpha
		Clone.Position = Middle:Lerp(Middle + UDim2.fromOffset(xRand, yRand), Alpha)
		Clone.Size = UDim2.fromScale(0, 0):Lerp(OriginalSize, Alpha)
    end)
    
	FadeIn:Play()

	FadeIn.Completed:Connect(function()
		task.wait(.1)

		local CurrentPos = Clone.Position
		local CurrentSize = Clone.Size
		local TargetVector2 = MainFrame.AbsolutePosition + (MainFrame.AbsoluteSize / 2)
		local TargetPos = UDim2.fromOffset(TargetVector2.X, TargetVector2.Y)

		local FadeOut = TweenModule.new(DisapearInfo, function(Alpha)
			Clone.Size = CurrentSize:Lerp(UDim2.fromOffset(0, 0), Alpha)
			Clone.Position = CurrentPos:Lerp(TargetPos, Alpha)
			Clone.ImageTransparency = Alpha
		end)

		FadeOut:Play()
		FadeOut.Completed:Wait()
		
        self:Expand()
        
        if (DropCb) then
            DropCb()
        end

		Clone:Destroy()
		
		local CoinCollected = Sfx:WaitForChild("Pop"):Clone() do
			CoinCollected.Volume = NumberUtil.Lerp(.1, .4, math.random())
			CoinCollected.Parent = game.SoundService
			
			CoinCollected.Ended:Connect(function()
				DropEnded:Fire()
				CoinCollected:Destroy()
			end)

			CoinCollected:Play()
		end
	end)

	DropEnded.Event:Wait()
end

function CurrencyCounterUI:Expand()
    local Container = MainFrame
	local OriginalSize = Container:GetAttribute("OriginalSize") or Container.Size
	local ExpandTween = TweenService:Create(Container, ExpandInfo, { Size = OriginalSize + UDim2.fromScale(.25, .25) })
	
	ExpandTween.Completed:Connect(function()
		TweenService:Create(Container, CloseInfo, { Size = OriginalSize }):Play()
	end)

	ExpandTween:Play()
end

function CurrencyCounterUI:Update(currentCoins)
	--print("WEEEE" , LastCheese, currentCoins)
	local TargetCoins = LastCheese
	
	if currentCoins ~= nil then
		local Tween = TweenModule.new(ChangeInfo, function(Alpha)
			local CurrentCoins = math.floor(NumberUtil.Lerp(TargetCoins, currentCoins, Alpha))
			
			LastCheese = CurrentCoins
			
			CheeseLabel.Text = NumberSuffix(CurrentCoins)
		end)
		
		Tween:Play()
	end
end

function CurrencyCounterUI:KnitStart()
    AddButton.MouseButton1Click:Connect(function()
        local ShopView = Knit.GetController("ShopView")

        Knit.GetController("ViewsUI"):OpenView("Shop")
		task.wait(0.3)
        ShopView:GoToArea("Currency")
    end)
end

function CurrencyCounterUI:KnitInit()
    math.randomseed(tick())

	NumberSuffix = require(Knit.Shared.Modules.NumberSuffix)
    NumberUtil = require(Knit.Shared.Modules.NumberUtil)
    TweenModule = require(Knit.Modules.Tween)
	
	local DataService = Knit.GetService("DataService")
	local CurrencyCounterUI = Knit.GetController("CurrencyCounterUI")

	task.spawn(function()
		task.wait(5)
		local Coins = DataService:GetCurrency(workspace:GetAttribute("Theme"))
		CurrencyCounterUI:Update(Coins)
	end)

	DataService.CurrencySignal:Connect(function(Coins, amount, percentage, disableEffect)
		if disableEffect then
			--print('UPDATED COINS', Coins)
			CurrencyCounterUI:Update(Coins)
		else
			CurrencyCounterUI:CollectCheese(Coins, amount, percentage)
		end
	end)

end

return CurrencyCounterUI
