local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NotificationUI = Knit.CreateController { Name = "NotificationUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Const
local isOpened = false;
local isWelcome = false;
local selectedPlayer, selectedButton;
local productId, isGamepass;

local ViewOriginalSizes = {};
local ViewOriginalPositions = {};

local TweenModule = require(Knit.Modules.Tween);
local NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

local PlayerGui = plr:WaitForChild("PlayerGui");

local WelcomeFrame = PlayerGui:WaitForChild("Notifications"):WaitForChild("Welcome");
local WButton = WelcomeFrame:WaitForChild("Button")


local NotificationFrame = PlayerGui:WaitForChild("Notifications"):WaitForChild("Notification");
local Button = NotificationFrame:WaitForChild("Button")
local Title = NotificationFrame:WaitForChild("Title")
local Desc = NotificationFrame:WaitForChild("Desc")

function NotificationUI:IsViewing()
    return isOpened;
end

function NotificationUI:DisplayWelcome()
    --if isOpened == true then return end

    isWelcome = true;
    
	local CurrentView = WelcomeFrame;
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
end

function NotificationUI:CloseWelcome()
    if isWelcome == false then return end

    isWelcome = false;

    local TargetView = WelcomeFrame

    if (TargetView) then

        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end
end

function NotificationUI:OpenView(TitleText, DescriptionText, ButtonName)
    --if isOpened == true then return end
    local ShopGiftsUI = Knit.GetController("ShopGiftsUI")
    ShopGiftsUI:CloseView();

    isOpened = true;

    if TitleText and DescriptionText and ButtonName then
        Title.Text = TitleText;
        Desc.Text = DescriptionText;
        Button:WaitForChild("ImageButton"):WaitForChild("TextLabel").Text = ButtonName;
    end
    
	local CurrentView = NotificationFrame;
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
end

function NotificationUI:CloseView()
    if isOpened == false then return end

    isOpened = false;

    local TargetView = NotificationFrame

    if (TargetView) then

        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end

end

function NotificationUI:KnitStart()

    ViewOriginalSizes[WelcomeFrame.Name] = WelcomeFrame.Size;
    ViewOriginalPositions[WelcomeFrame.Name] = WelcomeFrame.Position;

    ViewOriginalSizes[NotificationFrame.Name] = NotificationFrame.Size;
    ViewOriginalPositions[NotificationFrame.Name] = NotificationFrame.Position;

    WButton:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        self:CloseWelcome();
    end)

    Button:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        self:CloseView();
    end)
end


function NotificationUI:KnitInit()
    
end


return NotificationUI
