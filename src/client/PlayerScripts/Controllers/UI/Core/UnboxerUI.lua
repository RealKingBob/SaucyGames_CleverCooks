local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local UnboxerUI = Knit.CreateController { Name = "UnboxerUI" }

--//Imports
local CameraShaker;
local TweenModule;
local DuckSkins;
local DeathEffects;
local Rarities;
local NumberUtil;
local CommaValue;

--//Services
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")


local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local HatcherGui = PlayerGui:WaitForChild("Hatcher");
local Background = HatcherGui:WaitForChild("Background");
local EggButton = Background:WaitForChild("Egg");
local EggCloneImage = Background:WaitForChild("EggClone");
local BreakText = Background:WaitForChild("BreakText");
local DuplicateText = Background:WaitForChild("Duplicate");

local PetPopUp = Background:WaitForChild("PetPopUp");
local Starburst = Background:WaitForChild("Starburst");
local PetContainer = PetPopUp:WaitForChild("Pet");
local ButtonContainer = PetPopUp:WaitForChild("ButtonContainer");
local PetNameLabel = PetPopUp:WaitForChild("PetName");

local StartInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out);
local ClickInfo = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local ExpansionInfo = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local DisapearInfo = TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local TiltInfo = TweenInfo.new(.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out);
local CollapseInfo = TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.In);
local PetPopUpInfo = TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out);
local PetRise = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true);
local PetPopUpCloseInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local BottomBarInfo = TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out);

--//State
local IsEarned = false;

--//Public Methods
function UnboxerUI:StartHatching(CrateName, DuckEarned, CrateType, DuplicateInfo)
    if (IsHatching) then return; end

    local function getDuckDataFromType(DuckEarned, Type)
        if Type == "Skins" then
			return DuckSkins.SkinsTable[DuckEarned];
        elseif Type == "Effects" then
			return DeathEffects.EffectsTable[DuckEarned];
        elseif Type == "Emotes" then
            return nil;
        else
            return nil;
        end
    end

    local function getCrateDataFromType(CrateName, Type)
        if Type == "Skins" then
            return DuckSkins.CratesTable[CrateName];
        elseif Type == "Effects" then
            return DeathEffects.CratesTable[CrateName];
        elseif Type == "Emotes" then
            return nil;
        else
            return nil;
        end
    end

    local function getRarityDataFromType(Key, Type)
        if Type == "Skins" then
            return Rarities.getRarityDataFromDuckName(Key);
        elseif Type == "Effects" then
            return Rarities.getRarityDataFromEffectsName(Key);
        elseif Type == "Emotes" then
            return nil;
        else
            return nil;
        end
    end
    
    local CrateData = getCrateDataFromType(CrateName, CrateType);
    local DuckData = getDuckDataFromType(DuckEarned, CrateType);
    local RarityData = getRarityDataFromType(DuckData.Key, CrateType);

    IsHatching = true;
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false);
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false);

    DuplicateText.Visible = false;
    PetContainer.Visible = false;
    EggButton.Image = CrateData.UnboxingIcons[1];
    BreakText.Visible = false;
    PetPopUp.Size = UDim2.new();
    Starburst.Size = UDim2.new();
    EggButton.Size = UDim2.fromScale(.2, .4);
    PetContainer.Size = UDim2.fromScale(0.5, 0.5);
    EggButton.Rotation = 0;
    
    local GuiShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(cframe)
        local xPosScale = EggButton.Position.X.Scale;
        local yPosScale = EggButton.Position.X.Scale;
        local xPosOffset = EggButton.Position.X.Offset + cframe.Position.X * 50;
        local yPosOffset =  EggButton.Position.Y.Offset + cframe.Position.Y * 50;
        
        EggButton.Position = UDim2.new(xPosScale, xPosOffset, yPosScale, yPosOffset);
    end)
    
    -- self.PlayerGui.MainGui.Enabled = false;
    --HatcherGui.Enabled = true;
    Background.Visible = true;
    
    local StartTween = TweenModule.new(StartInfo, function(Alpha)
        Background.BackgroundTransparency = NumberUtil.LerpClamp(1, .2, Alpha);
        EggButton.Position = UDim2.fromScale(.5, -.25):Lerp(UDim2.fromScale(.5, .5), Alpha);
    end)
    
    StartTween:Play();
    StartTween.Completed:Wait();

    local Clicks = 0;
    local MouseDownConnection, MouseUpConnection, ClickConnection;
    
    GuiShake:Start();

    for i = 1, 10 do
        Clicks = i
        TweenService:Create(EggButton, ClickInfo, { Size = UDim2.fromScale(.2, .4) }):Play();
        task.wait(0.1)
        TweenService:Create(EggButton, ClickInfo, { Size = UDim2.fromScale(.15, .35) }):Play();
        if (Clicks % 3 == 0) then
            EggButton.Image = CrateData.UnboxingIcons[Clicks/3 + 1] or CrateData.UnboxingIcons[#CrateData.UnboxingIcons];
            
            local Clone = EggCloneImage:Clone() do
                Clone.Image = EggButton.Image;
                Clone.Position = EggButton.Position;
                Clone.Size = EggButton.Size;
                Clone.Visible = true;
                Clone.Parent = Background;
            end
            
            local ExpandTween = TweenService:Create(Clone, ExpansionInfo, { Size = UDim2.fromScale(.3, .5), ImageTransparency = .75 })
            
            ExpandTween.Completed:Connect(function()
                local DisapearTween = TweenService:Create(Clone, DisapearInfo, { Size = UDim2.fromScale(.35, .55), ImageTransparency = 1 });
                DisapearTween:Play();
                DisapearTween.Completed:Wait();
                
                Clone:Destroy();
            end)
            
            -- EggCrackSounds[math.random(1, #EggCrackSounds)]:Play();
            ExpandTween:Play();
            
            GuiShake:Shake(CameraShaker.Presets.Explosion);
        else
            -- EggHitSound:Play();
        end
        task.wait(0.1)
    end
    
    BreakText.Visible = false;
    
    if MouseDownConnection then
        MouseDownConnection:Disconnect();
        MouseUpConnection:Disconnect();
        ClickConnection:Disconnect();
    end
    
    local TiltTween = TweenService:Create(EggButton, TiltInfo, { Rotation = 45 / 2 });
    TiltTween:Play();
    
    -- EggCracked:Play();
    
    GuiShake:Shake(CameraShaker.Presets.Explosion);
    
    TiltTween.Completed:Wait();
    
    local CollapseTween = TweenService:Create(EggButton, CollapseInfo, { Size = UDim2.new() });
    CollapseTween:Play();

    PetContainer:WaitForChild("CaseItem"):WaitForChild("Main"):WaitForChild("ImageLabel").Image = DuckData.DecalId;
    Starburst.ImageColor3 = RarityData.Color;
    PetNameLabel.Text = DuckData.Name;
    PetNameLabel:WaitForChild("RarityText").Text = RarityData.Name;
    PetNameLabel:WaitForChild("RarityText"):WaitForChild("UIGradient").Color = RarityData.Gradient.Color;
    
    PetNameLabel.Visible = false;
    ButtonContainer.Visible = false;
    
    PetContainer.Position = UDim2.fromScale(.5, .49);
    Starburst.Rotation = 0;
    
    
    local PetPopUpTween = TweenService:Create(PetPopUp, PetPopUpInfo, { Size = UDim2.fromScale(0.3, 0.6) });
    TweenService:Create(Starburst, PetPopUpInfo, { Size = UDim2.fromScale(0.3, 0.6) }):Play();
    
    PetContainer.Visible = true;
    PetPopUpTween:Play();
    PetNameLabel.Visible = true;

    local CircleRotation = TweenModule.new(TweenInfo.new(15, Enum.EasingStyle.Linear), function(Alpha)
        Starburst.Rotation = Alpha * 360;
    end)
    
    local CompletedConnection = CircleRotation.Completed:Connect(function()
        task.wait();
        CircleRotation:Play();
    end)
    
    CircleRotation:Play();

    ButtonContainer.OpenContainer.ImageLabel.Image = CrateData.UnboxingIcons[1];

    ButtonContainer.Visible = true;
    ButtonContainer.Size = UDim2.new();
    TweenService:Create(ButtonContainer, BottomBarInfo, { Size = UDim2.fromScale(1, 0.175) }):Play()

    if (DuplicateInfo.IsDuplicate) then
        local Amount = DuplicateInfo.DuplicateAmount;
        DuplicateText.Text = ("Duplicate Item: You get back %s!"):format(CommaValue(Amount));
        DuplicateText.Visible = DuplicateInfo.IsDuplicate;
    end
    
    local PetRiseTween = TweenService:Create(PetContainer, PetRise, { Position = UDim2.fromScale(.5, .51) })
    PetRiseTween:Play();
    
    local ClickedEvent = Instance.new("BindableEvent");

    ButtonContainer.OpenContainer.OpenButton.Button.MouseButton1Click:Connect(function()
        ClickedEvent:Fire(true);
    end)

    ButtonContainer.Close.Button.MouseButton1Click:Connect(function()
        ClickedEvent:Fire(false);
    end)
    
    local IsOpeningEgg = ClickedEvent.Event:Wait();
    
    CompletedConnection:Disconnect();
    PetRiseTween:Cancel();
    CircleRotation:Cancel();
    
    PetNameLabel.Visible = false;
    ButtonContainer.Visible = false;
    DuplicateText.Visible = false;

    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true);
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true);

    local CloseTween = TweenService:Create(Background, PetPopUpCloseInfo, { BackgroundTransparency = 1 });
    local ClosePetTween = TweenService:Create(PetContainer, CollapseInfo, { Size = UDim2.new() });
    local CloseStarTween = TweenService:Create(Starburst, CollapseInfo, { Size = UDim2.new() });
    
    -- self.PlayerGui.MainGui.Enabled = true;
    
    CloseStarTween:Play();
    ClosePetTween:Play();
    CloseTween:Play();
    CloseTween.Completed:Wait();
    
    --HatcherGui.Enabled = false;
    Background.Visible = false;
    
    IsHatching = false;
    GuiShake:Stop();

    if (IsOpeningEgg) then
        local CaseData;
        local SelectedType = CrateType
        if SelectedType == "Skins" then
            CaseData = DuckSkins.CratesTable[CrateName];
        elseif SelectedType == "Effects" then
            CaseData = DeathEffects.CratesTable[CrateName];
        end
        
        local CanAfford, AffordPromise = false, nil;
        local PurchaseInfo, Promise = nil, nil;

        local DataService = Knit.GetService("DataService")
        local CrateService = Knit.GetService("CrateService")

        AffordPromise = DataService:GetCoins():andThen(function(Coins)
            if Coins then
                CanAfford = (Coins >= CaseData.Price);
                return;
            else
                CanAfford = false;
                return;
            end
        end)

        repeat task.wait(0) until AffordPromise:getStatus() ~= "Started" or Players.LocalPlayer == nil

        if (CanAfford) then
            Promise = CrateService:PurchaseCrate(CaseData.CrateId,CaseData.CrateType):andThen(function(CaseInfo)
                PurchaseInfo = CaseInfo;
                return;
            end)

            repeat task.wait(0) until Promise:getStatus() ~= "Started" or Players.LocalPlayer == nil

            if PurchaseInfo then
                if (PurchaseInfo.Status == "Success") then
                    UnboxerUI:StartHatching(DuckSkins.getCrateInfoFromId(PurchaseInfo.ItemInfo.CrateId).Key, PurchaseInfo.ItemInfo.Key, PurchaseInfo.ItemInfo.ItemType, PurchaseInfo.DuplicateInfo)
                end
            end
        else
            Knit.GetController("ShopCoinsUI"):OpenShop();
        end
    end
end

function UnboxerUI:CanOpen()
    return not IsHatching;
end

function UnboxerUI:KnitStart()
    DuckSkins = require(Knit.ReplicatedAssets.DuckSkins);
    DeathEffects = require(Knit.ReplicatedAssets.DeathEffects);
    for _,Data in pairs(DuckSkins.CratesTable) do
        ContentProvider:PreloadAsync(Data.UnboxingIcons)
    end

    for _,Data in pairs(DeathEffects.CratesTable) do
        ContentProvider:PreloadAsync(Data.UnboxingIcons)
    end
    TweenModule = require(Knit.Modules.Tween);
    CameraShaker = require(Knit.Modules.CameraShaker);
    Rarities = require(Knit.ReplicatedAssets.Rarities);
    NumberUtil = require(Knit.ReplicatedModules.NumberUtil);
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
end

function UnboxerUI:KnitInit()
    
end

return UnboxerUI
