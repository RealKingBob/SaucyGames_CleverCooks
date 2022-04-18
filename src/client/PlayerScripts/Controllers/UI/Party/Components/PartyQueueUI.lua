local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Knit = require(ReplicatedStorage.Packages.Knit)

local PartyQueueUI = Knit.CreateController { Name = "PartyQueueUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Const
local isOpened = false;
local partyQueueType = nil;

local debounce = false;
local con = nil;

local ViewOriginalSizes = {};
local ViewOriginalPositions = {};

local TweenModule = require(Knit.Modules.Tween);
local NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

local PlayerGui = plr:WaitForChild("PlayerGui");
local QueueView = PlayerGui:WaitForChild("Views"):WaitForChild("Queue");
local QueueInfo = PlayerGui:WaitForChild("GameplayFrame"):WaitForChild("QueueInfo");
local CancelButton = QueueInfo:WaitForChild("Close")
local QueueButton = QueueView:WaitForChild("Main"):WaitForChild("Button");

local SizeTween = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);
local ColorInfo = TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut);

function PartyQueueUI:IsViewing()
    return isOpened;
end

function PartyQueueUI:UpdateText(Type : string)
    local TitleText = QueueView:WaitForChild("Main"):WaitForChild("Title")

    if Type == "TournamentQueue" then
        partyQueueType = "Normal"
        TitleText.Text = "Tournament (Normal)"
    elseif Type == "VCTournamentQueue" then
        partyQueueType = "Voicechat"
        TitleText.Text = "Tournament (Voicechat)"
    end
end

function PartyQueueUI:OpenView(Status : string, Type : string)
    if isOpened == true then return end

    if con ~= nil then con:Disconnect() end

    isOpened = true;

	local CurrentView = QueueInfo;
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

    CancelButton.Visible = true;

    QueueInfo.BackgroundColor3 = Color3.fromRGB(170, 133, 90);
    QueueInfo.BG.BackgroundColor3 = Color3.fromRGB(84, 65, 44);

    QueueInfo:WaitForChild("Title").Text = "Queueing for match";
    QueueInfo:WaitForChild("Mode").Text = "Tournament ("..Type..")";

    local startTime = os.clock()

    local TimerLabel = QueueInfo:WaitForChild("Timer")

    local function sToHMS(s)
        local h = math.floor(s/3600)
        s = s % 3600
        local m = math.floor(s/60)
        s = s % 60
        return string.format("%02i:%02i", m, s)
    end

    con = game:GetService("RunService").RenderStepped:Connect(function()
        TimerLabel.Text = sToHMS(os.clock() - startTime)
    end)

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
end

function PartyQueueUI:CloseView()
    if isOpened == false then return end

    isOpened = false;

    local TargetView = QueueInfo;

    if (TargetView) then

        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end
end

function PartyQueueUI:FoundMatch()
    CancelButton.Visible = false;

    QueueInfo:WaitForChild("Title").Text = "Teleporting to match"

    local OldMainColor = QueueInfo.BackgroundColor3;
    local OldSecondaryColor = QueueInfo.BG.BackgroundColor3

    local QueueSizeTween = TweenModule.new(SizeTween, function(Alpha)
        QueueInfo.Size = UDim2.fromScale(0.24, 0.09):Lerp(UDim2.fromScale(0.25, 0.09), Alpha);
    end)

    local MainToGreen = TweenModule.new(ColorInfo, function(Alpha)
        QueueInfo.BackgroundColor3 = OldMainColor:Lerp(Color3.fromRGB(20, 170, 20), Alpha)
    end)

    local SecondaryToGreen = TweenModule.new(ColorInfo, function(Alpha)
        QueueInfo.BG.BackgroundColor3 = OldSecondaryColor:Lerp(Color3.fromRGB(2, 84, 9), Alpha)
    end)

    QueueSizeTween:Play();
    MainToGreen:Play();
    SecondaryToGreen:Play();
    --MainToGreen.Completed:Wait();
end

function PartyQueueUI:QueueMatch(Type : string)
    local PartyService = Knit.GetService("PartyService");

    if Type == "Normal" then
        PartyService.PartyStatus:Fire("RegularQueueStart");
    elseif Type == "Voicechat" then
        PartyService.PartyStatus:Fire("VCQueueStart");
    end
end

function PartyQueueUI:UnqueueMatch()
    local PartyService = Knit.GetService("PartyService");
    
    PartyService.PartyStatus:Fire("QueueCancel");
end

function PartyQueueUI:KnitStart()

    self.ViewsUI = Knit.GetController("ViewsUI");

    ViewOriginalSizes[QueueInfo.Name] = QueueInfo.Size;
    ViewOriginalPositions[QueueInfo.Name] = QueueInfo.Position;

    CancelButton.MouseButton1Click:Connect(function()
        if self:IsViewing() == false then return end

        self:UnqueueMatch()

        self:CloseView();
    end)

    QueueButton.MouseButton1Click:Connect(function()
        self.ViewsUI:CloseView()
        self:QueueMatch(partyQueueType)
    end)

    local TournamentService  = Knit.GetService("TournamentService");

    TournamentService.QueueStatus:Connect(function(Status : string, Type : string)
        print("QUEUE STATUS:", Status, Type);

        if Status == "FoundMatch" then
            self:FoundMatch()
        elseif Status == "QueueCancel" or Type == nil then
            -- queue no bueno yep
        else
            self:OpenView(Status, Type)
        end
    end)
end


function PartyQueueUI:KnitInit()
    
end


return PartyQueueUI
