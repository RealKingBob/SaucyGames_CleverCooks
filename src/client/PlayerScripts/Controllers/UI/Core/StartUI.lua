local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local StartUI = Knit.CreateController { Name = "StartUI" }

--//Imports
local TweenModule;
local NumberUtil;

--//Services
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")


local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local StartGui = PlayerGui:WaitForChild("Start");
local InviteFriendsGui = PlayerGui:WaitForChild("InviteFriendsGui");
local Background = StartGui:WaitForChild("Background");
local GridBoxHolder = Background:WaitForChild("GridBoxHolder");
local HonkStudiosLogo = Background:WaitForChild("Icon");
local LoadingCircles = Background:WaitForChild("LoadingCircles");
local CircleRound = Background:WaitForChild("CircleRound");

local RiseTween = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);
local FastFadeTween = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);
local BounceFadeTween = TweenInfo.new(.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out);
local FadeTween = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);
local ColorInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut);

--//State
local HasStarted = false;

local function Shuffle(tabl)
    for i=1,#tabl-1 do
        local ran = math.random(i,#tabl)
        tabl[i],tabl[ran] = tabl[ran],tabl[i]
    end
end

--//Public Methods
function StartUI:StartIntro()
    if (HasStarted == true) then return end
    local SettingsUI = Knit.GetController("SettingsUI");
    if SettingsUI:GetSetting("AFK") == "Off" then return end

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false);
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false);

    HasStarted = true;

    
    local GridBoxData = {};

    for _, Frame in pairs(GridBoxHolder:GetChildren()) do
        if Frame:IsA("Frame") then
            table.insert(GridBoxData, Frame)
        end
    end

    Shuffle(GridBoxData)
    Shuffle(GridBoxData)

    for _, Frame in pairs(GridBoxData) do
        if Frame:IsA("Frame") then
            Frame.FrameBox:TweenSize(UDim2.new(1, 0, 1, 0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Quint,
            .01)    
            task.wait(.01)
        end
    end

    for index, _ in pairs(GridBoxHolder:GetChildren()) do
        local Frame = GridBoxHolder:FindFirstChild(tostring(index))
        if Frame then
            local GreyToBlue = TweenModule.new(ColorInfo, function(Alpha)
                local OldColor = Frame.FrameBox.BackgroundColor3
                Frame.FrameBox.BackgroundColor3 = OldColor:Lerp(Color3.fromRGB(16,16,16), Alpha)   
            end)
            GreyToBlue:Play();
            task.wait(0.005);
        end
    end

    local IconTween = TweenModule.new(BounceFadeTween, function(Alpha)
        HonkStudiosLogo.Size = UDim2.fromScale(0,0):Lerp(UDim2.fromScale(0.282, 0.433), Alpha);
    end)

    local IconTextTween = TweenModule.new(BounceFadeTween, function(Alpha)
        HonkStudiosLogo.TopTitle.Size = UDim2.fromScale(0,0):Lerp(UDim2.fromScale(0.957,0.184), Alpha);
        HonkStudiosLogo.BottomTitle.Size = UDim2.fromScale(0,0):Lerp(UDim2.fromScale(0.957, 0.2), Alpha);
    end)

    local ShowLoadingCircles = TweenModule.new(RiseTween, function(Alpha)
        LoadingCircles.Position = UDim2.fromScale(0.5, 1):Lerp(UDim2.fromScale(0.5, 0.915), Alpha);
        task.spawn(function()
            for _, ball : Frame in pairs(LoadingCircles:GetChildren()) do 
                if ball:IsA("Frame") then 
                    ball.Visible = true task.wait(.15) 
                end 
            end
        end)
    end)

    local GreenLoadingCircles = TweenModule.new(RiseTween, function(Alpha)
        local NumOfCircles = 0;
        for _, ball : Frame in pairs(LoadingCircles:GetChildren()) do 
            if ball:IsA("Frame") then 
                NumOfCircles += 1
            end 
            if ball:IsA("Frame") then 
                if ball.Name == "Ball".. tostring(NumOfCircles) then
                    ball.BackgroundColor3 = Color3.fromRGB(0,170,0);
                    ball.Frame.BackgroundColor3 = Color3.fromRGB(1, 228, 1);
                end
            end 
            task.wait(math.random(.5, 1.5));
        end
    end)

    local FadeOutTween = TweenModule.new(FadeTween, function(Alpha)
        task.spawn(function()
            for _, ball : Frame in pairs(LoadingCircles:GetChildren()) do
                 if ball:IsA("Frame") then 
                    ball.BackgroundTransparency = NumberUtil.LerpClamp(0, 1, Alpha); 
                    ball.Frame.BackgroundTransparency = NumberUtil.LerpClamp(0, 1, Alpha); 
                end
            end
        end)
    end)

    local FadeLogoTween = TweenModule.new(FastFadeTween, function(Alpha)
        HonkStudiosLogo.Size = UDim2.fromScale(0.282, 0.433):Lerp(UDim2.fromScale(0,0), Alpha);
    end)

    local FadeLogoTextTween = TweenModule.new(FastFadeTween, function(Alpha)
        HonkStudiosLogo.TopTitle.Size = UDim2.fromScale(0.957,0.184):Lerp(UDim2.fromScale(0,0), Alpha);
        HonkStudiosLogo.BottomTitle.Size = UDim2.fromScale(0.957, 0.2):Lerp(UDim2.fromScale(0,0), Alpha);
    end)

    HonkStudiosLogo.Visible = true;
    IconTween:Play();
    ShowLoadingCircles:Play();
    IconTween.Completed:Wait();
    task.wait(1);

    IconTextTween:Play();

    local instanceIDTable = {
        "rbxassetid://8401434180", -- these are map images
        "rbxassetid://8292083859",
        "rbxassetid://8401434457",
        "rbxassetid://8401434317",
        "rbxassetid://8400801443",
        "rbxassetid://8400521703",

        "rbxassetid://8321764473", -- unboxing crates images
		"rbxassetid://8322575070",
		"rbxassetid://8322574923",
		"rbxassetid://8322574790",
		"rbxassetid://8322574630",
    };

    local instanceTable = {};

    for _, id in pairs(instanceIDTable) do
        local instance = Instance.new("Decal");
        instance.Texture = id;
        table.insert(instanceTable, instance); 
    end

    ContentProvider:PreloadAsync(instanceTable);

    task.wait(1);

    GreenLoadingCircles:Play();
    GreenLoadingCircles.Completed:Wait();

    task.wait(1);

    FadeOutTween:Play();

    for index, _ in pairs(GridBoxHolder:GetChildren()) do
        local Frame = GridBoxHolder:FindFirstChild(tostring(index))
        if Frame then
            local OldColor = Frame.FrameBox.BackgroundColor3
            local GreyToBlue = TweenModule.new(ColorInfo, function(Alpha)
                Frame.FrameBox.BackgroundColor3 = OldColor:Lerp(Color3.fromRGB(11, 11, 11), Alpha)   
            end)
            GreyToBlue:Play();
            task.wait(0.01);
            --GreyToBlue.Completed:Wait();
        end
    end

    for index, _ in pairs(GridBoxHolder:GetChildren()) do
        local Frame = GridBoxHolder:FindFirstChild(tostring(index))
        if Frame then
            Frame.FrameBox:TweenSize(UDim2.new(0, 0, 0, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            .005)
            task.wait(.005)
        end
    end

    for _, Frame in pairs(GridBoxData) do
        if Frame:IsA("Frame") then
            Frame.Visible = false;
        end
    end

    FadeLogoTextTween:Play();
    CircleRound:TweenSize(UDim2.new(6, 0, 6, 0), Enum.EasingDirection.Out,Enum.EasingStyle.Linear,.8,false)
    FadeLogoTextTween.Completed:Wait();
    task.wait(.1);
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true);
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true);
    SettingsUI:SetSetting("AFK", "Off")
    --FadeLogoTween:Play();
    --FadeLogoTween.Completed:Wait();
    CircleRound.Visible = false;
    StartGui.Enabled = false;
end

function StartUI:CanStart()
    return not HasStarted;
end

function StartUI:KnitStart()
    TweenModule = require(Knit.Modules.Tween);
    NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

    task.wait(5)
    self:StartIntro()
end

function StartUI:KnitInit()
    StartGui.Enabled = true
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false);
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false);
    LoadingCircles.Position = UDim2.fromScale(0.5, 1)
    for _, ball : Frame in pairs(LoadingCircles:GetChildren()) do 
        if ball:IsA("Frame") then 
            ball.Visible = false 
        end 
    end
    HonkStudiosLogo.Size = UDim2.fromScale(0,0);
    HonkStudiosLogo.TopTitle.Size = UDim2.fromScale(0,0)
    HonkStudiosLogo.BottomTitle.Size = UDim2.fromScale(0,0)
    HonkStudiosLogo.Visible = false;
    Background.Visible = true;
    InviteFriendsGui.Enabled = true;
end

return StartUI
