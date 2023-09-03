local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local OrderUI = Knit.CreateController { Name = "OrderUI" }

--//Service
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Const
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local dingSound = "rbxassetid://9068539820"
local swooshSound = "rbxassetid://9119737641"
local itemClickSound = "rbxassetid://552900451"
local itemCompleteSound = "rbxassetid://3241682089"

local ReplicatedModules = Knit.Shared.Modules
local GuiParticleEmitterModule = ReplicatedModules:FindFirstChild("GuiParticleEmitter")

local MainGui = PlayerGui:WaitForChild("Main")
local OrderFrame = MainGui:WaitForChild("TopFrame"):WaitForChild("Bottom")


local function playLocalSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    SoundService:PlayLocalSound(sound)
    sound.Ended:Wait()
    sound:Destroy()
end

function OrderUI:AddOrder(orderData)
    local name, id, image, timer, description = orderData.name, orderData.id, orderData.image, orderData.timer, orderData.name

    local StickyNotePrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("StickyNote")
    local ItemClone = StickyNotePrefab:Clone() do
        local MainFrame = ItemClone:WaitForChild("MainFrame")
        ItemClone.Name = "OrderItem_"..tostring(name)
        local IconFrame = MainFrame:WaitForChild("Icon")
        IconFrame.Name = "View"
        IconFrame.InspectRecipe.Image = image
        ItemClone.LayoutOrder = #OrderFrame:GetChildren() - 1
        ItemClone:SetAttribute("orderId", id)
        ItemClone:SetAttribute("maxTimer", timer)
        ItemClone:SetAttribute("timer", timer)
        MainFrame.Position = UDim2.new(10, 0, 0, 0)
        ItemClone.Parent = OrderFrame

        self:AnimateEnterOrder(ItemClone)

        local TimerFrame = MainFrame:WaitForChild("Timer")
        local leftFrame = TimerFrame:WaitForChild("LeftBG"):WaitForChild("LeftFrame")
        local rightFrame = TimerFrame:WaitForChild("RightBG"):WaitForChild("RightFrame")

        local numValue = Instance.new("NumberValue")

        local colorGreen = Color3.fromRGB(80, 255, 86)
        local colorRed = Color3.fromRGB(255, 41, 41)

        numValue.Changed:Connect(function()
            local rightRot = math.clamp(numValue.Value - 180, -180, 0)
            rightFrame.Rotation = rightRot
            
            if numValue.Value <= 180 then
                leftFrame.Visible = false
            else
                local leftRot = math.clamp(numValue.Value - 360, -180, 0)
                leftFrame.Rotation = leftRot
                leftFrame.Visible = true
            end

            if not leftFrame or not rightFrame then return end
            if not leftFrame:FindFirstChild("LeftBG") then return end
            if not rightFrame:FindFirstChild("RightBG") then return end
            leftFrame.LeftBG.ImageColor3 = colorRed:Lerp(colorGreen, numValue.Value / 360)
            rightFrame.RightBG.ImageColor3 = colorRed:Lerp(colorGreen, numValue.Value / 360)
        end)

        local function progressBar(tweenSpeed, finalNum, initialNum)

            if initialNum then
                numValue.Value = initialNum
            end
            
            local tweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

            local progressTween = TweenService:Create(numValue, tweenInfo, {Value = finalNum})
            progressTween:Play()
        end

        local function pulseTimer(pulseSpeed)
            local tweenInfo = TweenInfo.new(pulseSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            if TimerFrame and TimerFrame:FindFirstChild("ImageLabel") then
                local tween = TweenService:Create(TimerFrame:FindFirstChild("ImageLabel"), tweenInfo, {ImageColor3 = Color3.fromRGB(236, 52, 52)})
                tween:Play()
                tween.Completed:Wait()
            end
            if TimerFrame and TimerFrame:FindFirstChild("ImageLabel") then
                local tween2 = TweenService:Create(TimerFrame:FindFirstChild("ImageLabel"), tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
                tween2:Play()
                tween2.Completed:Wait()
            end 
        end

        progressBar(0,360,0)

        local startPercent, endPercent, startCircle, endCircle = 0, 1, 0, 360 -- 0 -> 360 degrees
        local function percentageInCircle(percentage)
            return (startCircle + (percentage / endPercent) * (endCircle - startCircle))
        end

        task.spawn(function()
            repeat
                ItemClone:SetAttribute("timer", ItemClone:GetAttribute("timer") - 1)
                --print(i-1, percentageInCircle((i-1)/timer))
                task.spawn(progressBar, 1, percentageInCircle((ItemClone:GetAttribute("timer")-1)/ItemClone:GetAttribute("maxTimer")))
                if ItemClone:GetAttribute("maxTimer")/2.7 > ItemClone:GetAttribute("timer") then
                    if MainFrame and MainFrame:FindFirstChild("Timer") then
                        MainFrame:FindFirstChild("Timer").AddTimeLabel.Visible = true
                        MainFrame:FindFirstChild("Timer").AddTime.Visible = true
                    end

                    task.spawn(pulseTimer, .5)
                end
                task.wait(1)
            until ItemClone:GetAttribute("timer") <= 0
        end)

        --task.spawn(progressBar, .4, 360, 0)

        local debounceOrder = false

        MainFrame:FindFirstChild("Timer").AddTime.MouseButton1Click:Connect(function()
            if debounceOrder == false then
                debounceOrder = true
                task.spawn(playLocalSound, itemClickSound, 0.2)
                Knit.GetService("OrderService").ResetTimePurchase:Fire(ItemClone:GetAttribute("orderId"))
                task.wait(.5)
                debounceOrder = false
            end
        end)

        IconFrame.InspectRecipe.MouseButton1Click:Connect(function()
            --print('inspecting recipe')
            if debounceOrder == false then
                debounceOrder = true
                task.spawn(playLocalSound, itemClickSound, 0.2)
                Knit.GetController("RecipesView"):GetRecipeIngredients(name)
                task.wait(.5)
                debounceOrder = false
            end
        end)
    end 
end

function OrderUI:CompleteOrder(orderId)
    for index, frame in pairs(OrderFrame:GetChildren()) do
        if frame:IsA("ImageLabel") then
            if frame:GetAttribute("orderId") == orderId then
                if frame:FindFirstChild("MainFrame") then
                    if frame:FindFirstChild("MainFrame"):FindFirstChild("Completed") then
                        frame:FindFirstChild("MainFrame"):FindFirstChild("Completed").Visible = true
                    end
                    task.spawn(playLocalSound, itemCompleteSound, 0.2)
                end
                task.wait(1)
                self:RemoveOrder(orderId)
            end
        end
    end
end

function OrderUI:ChangeTime(orderId, newTime)
    for index, frame in pairs(OrderFrame:GetChildren()) do
        if frame:IsA("ImageLabel") then
            --print(frame:GetAttribute("orderId"), orderId )
            if frame:GetAttribute("orderId") == orderId then
                if frame:FindFirstChild("MainFrame") then
                    if frame:FindFirstChild("MainFrame"):FindFirstChild("Timer") then
                        frame:WaitForChild("MainFrame"):FindFirstChild("Timer").AddTimeLabel.Visible = false
                        frame:WaitForChild("MainFrame"):FindFirstChild("Timer").AddTime.Visible = false
                    end

                    frame:SetAttribute("timer", newTime)
                end
            end
        end
    end
end

function OrderUI:RemoveOrder(orderId)
    --print('ORDER REMOVED')
    for index, frame in pairs(OrderFrame:GetChildren()) do
        if frame:IsA("ImageLabel") then
            --print(frame:GetAttribute("orderId"), orderId )
            if frame:GetAttribute("orderId") == orderId then
                self:AnimateExitOrder(frame)
                task.wait(0.4)
                frame:Destroy()
            end
        end
    end
end

function OrderUI:RemoveAllOrders()
    --print('ORDER REMOVED')
    for index, frame in pairs(OrderFrame:GetChildren()) do
        if frame:IsA("ImageLabel") then
            self:AnimateExitOrder(frame)
            task.wait(0.4)
            frame:Destroy()
        end
    end
end

function OrderUI:AnimateEnterOrder(orderFrame)

    local MainFrame = orderFrame:FindFirstChild("MainFrame")
    if MainFrame then
        MainFrame.Position = UDim2.new(10, 0, 0, 0)

        local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
        TweenService:Create(MainFrame, tweenInfo, {Position = UDim2.new(0,0,0,0)}):Play()
    end
    task.spawn(playLocalSound, dingSound, 0.03)
    task.spawn(playLocalSound, swooshSound, 0.2)
end

function OrderUI:AnimateExitOrder(orderFrame)

    local MainFrame = orderFrame:FindFirstChild("MainFrame")
    if MainFrame then
        MainFrame.Position = UDim2.new(0, 0, 0, 0)

        local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
        TweenService:Create(MainFrame, tweenInfo, {Position = UDim2.new(-10,0,0,0)}):Play()
    end
    task.spawn(playLocalSound, swooshSound, 0.2)
end

function OrderUI:KnitStart()
    local OrderService = Knit.GetService("OrderService")

    OrderService.AddOrder:Connect(function(orderData)
        self:AddOrder(orderData)
    end)

    OrderService.RemoveOrder:Connect(function(orderId)
        self:RemoveOrder(orderId)
    end)

    OrderService.RemoveAllOrders:Connect(function()
        self:RemoveAllOrders()
    end)

    OrderService.CompleteOrder:Connect(function(orderId)
        self:CompleteOrder(orderId)
    end)

    OrderService.ResetTimePurchase:Connect(function(orderId, newTime)
        self:ChangeTime(orderId, newTime)
    end)

end


function OrderUI:KnitInit()
    
end


return OrderUI
