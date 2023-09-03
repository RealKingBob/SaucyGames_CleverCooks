local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local TweenService = game:GetService("TweenService")

local NotificationUI = Knit.CreateController { Name = "NotificationUI" }

--//Const
local isOpened = false
local isWelcome = false
local selectedPlayer, selectedButton
local productId, isGamepass

local ViewOriginalSizes = {}
local ViewOriginalPositions = {}
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local SoundService = game:GetService("SoundService")
local indexNum = 0

local typeWriterEffectSound = "rbxassetid://9120410355"

local NotificationFrame = PlayerGui:WaitForChild("Notification"):WaitForChild("Notification")
local Button = NotificationFrame:WaitForChild("Button")
local Title = NotificationFrame:WaitForChild("Title")
local Desc = NotificationFrame:WaitForChild("Desc")

local function playLocalSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    SoundService:PlayLocalSound(sound)
    sound.Ended:Wait()
    sound:Destroy()
end

function NotificationUI:IsViewing()
    return isOpened
end

function NotificationUI:LargeMessage(text, typeWriterEffect)
    local notificationUI = PlayerGui:WaitForChild("Notification")
    local CenterFrame = notificationUI:WaitForChild("Frame"):WaitForChild("CenterFrame")
    local notificationItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("NotificationLargeMessage")
    local messageClone = notificationItemPrefab:Clone() do
        indexNum += 1
        messageClone.Name = "Notification"..indexNum
        messageClone.LayoutOrder = indexNum
        if typeWriterEffect == nil then
            messageClone.Text = text
        else
            messageClone.Text = ""
        end
        messageClone.TextTransparency = 0
        messageClone.Parent = CenterFrame
        
        local paramCheck = (typeof(typeWriterEffect) == "table" and typeWriterEffect ~= nil and typeWriterEffect.Effect) or false
        if paramCheck == true then
            local delay = 0.03  -- delay between each character being displayed, in seconds
            for i = 1, #text do
                local character = string.sub(text, i, i)
                if character == "," then
                    delay = 0.2
                elseif character == "." then
                    delay = 0.1
                else
                    delay = 0.03
                end
                messageClone.TextColor3 = typeWriterEffect.Color
                messageClone.Text = string.sub(text, 1, i)
                task.spawn(playLocalSound, typeWriterEffectSound, 0.15)
                task.wait(delay)
            end
        end
            
        task.delay(5, function()
            TweenService:Create(messageClone, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            task.wait(.4)
            messageClone:Destroy()
        end)
    end
end

function NotificationUI:Message(text, typeWriterEffect)
    local notificationUI = PlayerGui:WaitForChild("Notification")
    local CenterFrame = notificationUI:WaitForChild("Frame"):WaitForChild("CenterFrame")
    local notificationItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("NotificationMessage")
    local messageClone = notificationItemPrefab:Clone() do
        indexNum += 1
        messageClone.Name = "Notification"..indexNum
        messageClone.LayoutOrder = indexNum
        if (typeof(typeWriterEffect) == "table" and typeWriterEffect ~= nil and typeWriterEffect.Effect == false) or typeWriterEffect == nil then
            messageClone.Text = text
            if (typeof(typeWriterEffect) == "table" and typeWriterEffect ~= nil and typeWriterEffect.Color ~= nil) then
                messageClone.TextColor3 = typeWriterEffect.Color
            end
        else
            messageClone.Text = ""
        end
        messageClone.TextTransparency = 0
        messageClone.Parent = CenterFrame
        
        local paramCheck = (typeof(typeWriterEffect) == "table" and typeWriterEffect ~= nil and typeWriterEffect.Effect) or false
        if paramCheck == true then
            local delay = 0.03  -- delay between each character being displayed, in seconds
            for i = 1, #text do
                local character = string.sub(text, i, i)
                if character == "," then
                    delay = 0.2
                elseif character == "." then
                    delay = 0.1
                else
                    delay = 0.03
                end
                messageClone.TextColor3 = typeWriterEffect.Color
                messageClone.Text = string.sub(text, 1, i)
                task.spawn(playLocalSound, typeWriterEffectSound, 0.15)
                task.wait(delay)
            end
        end
            
        task.delay(5, function()
            TweenService:Create(messageClone, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            task.wait(.4)
            messageClone:Destroy()
        end)
    end
end

function NotificationUI:OpenView(TitleText, DescriptionText, ButtonName)
    --if isOpened == true then return end
    --local ShopGiftsUI = Knit.GetController("ShopGiftsUI")
    --ShopGiftsUI:CloseView()

    isOpened = true

    if TitleText and DescriptionText and ButtonName then
        Title.Text = TitleText
        Desc.Text = DescriptionText
        Button:WaitForChild("Title").Text = ButtonName
    end
    
	local CurrentView = NotificationFrame
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name]

	CurrentView.Visible = true
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6)
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5)
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true)
end

function NotificationUI:CloseView()
    if isOpened == false then return end

    isOpened = false

    local TargetView = NotificationFrame

    if (TargetView) then

        local OriginalPosition = ViewOriginalPositions[TargetView.Name]
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true)
    end

end

function NotificationUI:KnitStart()

    ViewOriginalSizes[NotificationFrame.Name] = NotificationFrame.Size
    ViewOriginalPositions[NotificationFrame.Name] = NotificationFrame.Position

    Button.MouseButton1Click:Connect(function()
        self:CloseView()
    end)
end


function NotificationUI:KnitInit()
    
end


return NotificationUI
