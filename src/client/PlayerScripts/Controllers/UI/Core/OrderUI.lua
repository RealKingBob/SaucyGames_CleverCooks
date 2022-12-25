local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local OrderUI = Knit.CreateController { Name = "OrderUI" }

--//Service
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Const
local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MainGui = PlayerGui:WaitForChild("Main")
local OrderFrame = MainGui:WaitForChild("TopFrame"):WaitForChild("Bottom")

function OrderUI:AddOrder(orderData)
    local name, id, image, timer, description = orderData.name, orderData.id, orderData.image, orderData.timer, orderData.name

    local StickyNotePrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("StickyNote");
    local ItemClone = StickyNotePrefab:Clone() do
        ItemClone.Name = "OrderItem_"..tostring(name);
        ItemClone:WaitForChild("Icon").Image = image;
        ItemClone.LayoutOrder = #OrderFrame:GetChildren() - 1;
        ItemClone:SetAttribute("orderId", id)
        ItemClone.Parent = OrderFrame;

        local TimerFrame = ItemClone:WaitForChild("Timer")
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

        progressBar(0,360,0)

        local startPercent, endPercent, startCircle, endCircle = 0, 1, 0, 360; -- 0 -> 360 degrees
        local function percentageInCircle(percentage)
            return (startCircle + (percentage / endPercent) * (endCircle - startCircle));
        end

        task.spawn(function()
            for i = timer, 0, -1 do
                --print(i-1, percentageInCircle((i-1)/timer))
                task.spawn(progressBar, 1, percentageInCircle((i-1)/timer))
                task.wait(1)
            end
        end)

        --task.spawn(progressBar, .4, 360, 0)

        ItemClone:FindFirstChild("Timer").AddTime.MouseButton1Click:Connect(function()
            print('add time')
            
        end)

        ItemClone:FindFirstChild("Icon").InspectRecipe.MouseButton1Click:Connect(function()
            print('inspecting recipe')
            Knit.GetController("RecipesView"):GetRecipeIngredients(name)
        end)
    end 
end

function OrderUI:RemoveOrder(orderId)
    print('ORDER REMOVED')
    for index, frame in pairs(OrderFrame:GetChildren()) do
        if frame:IsA("ImageLabel") then
            print(frame:GetAttribute("orderId"), orderId )
            if frame:GetAttribute("orderId") == orderId then
                frame:Destroy();
            end
        end
    end
end

function OrderUI:AnimateOrder(orderFrame)
    -- makes a big notepad and display in midle and tween to the order position and make original notepad visible

end

function OrderUI:KnitStart()
    local OrderService = Knit.GetService("OrderService");

    OrderService.AddOrder:Connect(function(orderData)
        self:AddOrder(orderData);
    end)

    OrderService.RemoveOrder:Connect(function(orderId)
        self:RemoveOrder(orderId);
    end)

end


function OrderUI:KnitInit()
    
end


return OrderUI
