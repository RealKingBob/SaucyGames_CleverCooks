local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local UpgradeView = Knit.CreateController { Name = "UpgradeView" }

local UpgradesTab = {}

--//Service
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Const
local CommaValue;
local PlayerProgressionData;
local ProgressionStorage;
local PlayerCurrency;

local buttonDebounce = false;

local ThemeData = workspace:GetAttribute("Theme")

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local viewsUI = PlayerGui:WaitForChild("Main"):WaitForChild("Views")

local UpgradesGui = viewsUI:WaitForChild("Upgrades")
local ScrollingFrame = UpgradesGui:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("ScrollingFrame")
local ResetButton = UpgradesGui:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("Reset")

function UpgradeView:Update()
    for progressionName, progressionData in next, ProgressionStorage do
        local PlayerDataIndex = PlayerProgressionData[progressionName]
        local ItemClone = ScrollingFrame:FindFirstChild(progressionName)
        local dataValue = progressionData.Data[PlayerDataIndex].Value
        if dataValue == true then dataValue = "On" elseif dataValue == false then dataValue = "Off" end
        ItemClone:WaitForChild("Title").Text = progressionName.." [".. (tostring(dataValue)..progressionData.Type) .."]";
        ItemClone:WaitForChild("ImageLabel").Image = progressionData.Image;

        if PlayerDataIndex >= progressionData.Max then
            ItemClone:WaitForChild("Price").TextLabel.Text = "MAX";
        else
            ItemClone:WaitForChild("Price").TextLabel.Text = CommaValue(progressionData.Data[PlayerDataIndex + 1].Price);
        end

        if PlayerDataIndex >= progressionData.Max then
            ItemClone:WaitForChild("Button").Title.Text = "MAX"
            ItemClone:WaitForChild("Button").BackgroundColor3 = Color3.fromRGB(107, 107, 107)
            ItemClone:WaitForChild("Button").UIStroke.Color = Color3.fromRGB(61, 61, 61)
        else
            ItemClone:WaitForChild("Button").Title.Text = "Upgrade"
            if PlayerCurrency >= progressionData.Data[PlayerDataIndex + 1].Price then
                ItemClone:WaitForChild("Button").BackgroundColor3 = Color3.fromRGB(255, 184, 5)
                ItemClone:WaitForChild("Button").UIStroke.Color = Color3.fromRGB(117, 78, 0)
            else

                ItemClone:WaitForChild("Button").BackgroundColor3 = Color3.fromRGB(107, 107, 107)
                ItemClone:WaitForChild("Button").UIStroke.Color = Color3.fromRGB(61, 61, 61)
            end
        end
        
        for _, bar in pairs(ItemClone:WaitForChild("Bars"):GetChildren()) do
            if bar:IsA("Frame") then
                if bar.LayoutOrder > progressionData.Max then
                    bar.Visible = false;
                else
                    bar.Visible = true
                    dataValue = progressionData.Data[bar.LayoutOrder].Value
                    if dataValue == true then dataValue = "On" elseif dataValue == false then dataValue = "Off" end
                    bar.DataValue.Text = tostring(dataValue)
                    if PlayerDataIndex >= bar.LayoutOrder then
                        bar.BackgroundColor3 = Color3.fromRGB(7, 156, 255)
                    else
                        bar.BackgroundColor3 = Color3.fromRGB(107, 107, 107)
                    end
                end
            end
        end
    end;
end

function UpgradeView:SetupUpgradeTabs()
    local DataService = Knit.GetService("DataService")
    local ProgressionService = Knit.GetService("ProgressionService")
    local NotificationUI = Knit.GetController("NotificationUI");

    for _, Frame in pairs(ScrollingFrame:GetChildren()) do
        if Frame:IsA("Frame") then
            Frame:Destroy();
        end
    end

    ResetButton.MouseButton1Click:Connect(function()
        if buttonDebounce then return end
        buttonDebounce = true;
        local Promise = nil;

        Promise = ProgressionService:ResetProgressionData(ThemeData):andThen(function(ResultInfo)
            print(ResultInfo)
            if ResultInfo.Currency ~= nil then
                PlayerCurrency = ResultInfo.Currency
            end
            if ResultInfo.ProgressionData ~= nil then
                PlayerProgressionData = ResultInfo.ProgressionData
            end
            NotificationUI:Message(ResultInfo.StatusString, ResultInfo.StatusEffect);
            self:Update()
            buttonDebounce = false;
            return;
        end);
        repeat task.wait(0) until Promise:getStatus() ~= "Started" or Players.LocalPlayer == nil
        warn("Reset Complete!")
        buttonDebounce = false;
    end)

    ProgressionService:GetProgressionData(ThemeData):andThen(function(playerCurrency, playerStorage, progressionStorage)
        print("PlayerCurrency", playerCurrency, "PlayerStorage:", playerStorage, "ProgressionStorage:", progressionStorage)
        PlayerCurrency = playerCurrency;
        PlayerProgressionData = playerStorage;
        ProgressionStorage = progressionStorage;

        local Skills = {}

        for progressionName, progressionData in next, ProgressionStorage do
            table.insert(Skills, {Name = progressionName, Data = progressionData})
            local ProgressItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("ProgressionTemplate");
            local PlayerDataIndex = PlayerProgressionData[progressionName]
            local ItemClone = ProgressItemPrefab:Clone() do
                ItemClone.Name = progressionName;
                local dataValue = progressionData.Data[PlayerDataIndex].Value
                if dataValue == true then dataValue = "On" elseif dataValue == false then dataValue = "Off" end
                ItemClone:WaitForChild("Title").Text = progressionName.." [".. (tostring(dataValue)..progressionData.Type) .."]";
                ItemClone:WaitForChild("ImageLabel").Image = progressionData.Image;

                if PlayerDataIndex >= progressionData.Max then
                    ItemClone:WaitForChild("Price").TextLabel.Text = "MAX";
                else
                    ItemClone:WaitForChild("Price").TextLabel.Text = CommaValue(progressionData.Data[PlayerDataIndex + 1].Price);
                end

                if PlayerDataIndex >= progressionData.Max then
                    ItemClone:WaitForChild("Button").Title.Text = "MAX"
                    ItemClone:WaitForChild("Button").BackgroundColor3 = Color3.fromRGB(107, 107, 107)
                    ItemClone:WaitForChild("Button").UIStroke.Color = Color3.fromRGB(61, 61, 61)
                else
                    ItemClone:WaitForChild("Button").Title.Text = "Upgrade"
                    if PlayerCurrency >= progressionData.Data[PlayerDataIndex + 1].Price then
                        ItemClone:WaitForChild("Button").BackgroundColor3 = Color3.fromRGB(255, 184, 5)
                        ItemClone:WaitForChild("Button").UIStroke.Color = Color3.fromRGB(117, 78, 0)
                    else

                        ItemClone:WaitForChild("Button").BackgroundColor3 = Color3.fromRGB(107, 107, 107)
                        ItemClone:WaitForChild("Button").UIStroke.Color = Color3.fromRGB(61, 61, 61)
                    end
                end
                
                for _, bar in pairs(ItemClone:WaitForChild("Bars"):GetChildren()) do
                    if bar:IsA("Frame") then
                        if bar.LayoutOrder > progressionData.Max then
                            bar.Visible = false;
                        else
                            bar.Visible = true
                            dataValue = progressionData.Data[bar.LayoutOrder].Value
                            if dataValue == true then dataValue = "On" elseif dataValue == false then dataValue = "Off" end
                            bar.DataValue.Text = tostring(dataValue)
                            if PlayerDataIndex >= bar.LayoutOrder then
                                bar.BackgroundColor3 = Color3.fromRGB(7, 156, 255)
                            else
                                bar.BackgroundColor3 = Color3.fromRGB(107, 107, 107)
                            end
                        end
                    end
                end

                ItemClone.Parent = ScrollingFrame;
    
                ItemClone:WaitForChild("Button").MouseButton1Click:Connect(function()
                    if buttonDebounce then return end
                    buttonDebounce = true;
                    if (PlayerProgressionData[progressionName] >= progressionData.Max) then
                        NotificationUI:Message("Max Upgrade!", {Effect = false, Color = Color3.fromRGB(255, 200, 21)});
                        buttonDebounce = false;
                        return;
                    end

                    local CanAfford, AffordPromise = false, nil;
                    local PurchaseInfo, Promise = nil, nil;

                    AffordPromise = DataService:GetCurrency(ThemeData):andThen(function(Coins)
                        if Coins then
                            PlayerCurrency = Coins;
                            if not progressionData then
                                CanAfford = false;
                                return;
                            end
                            if progressionData.Data[PlayerDataIndex + 1] == nil then
                                CanAfford = false;
                                return;
                            end
                            CanAfford = (Coins >= progressionData.Data[PlayerDataIndex + 1].Price)
                            return;
                        else
                            CanAfford = false;
                            return;
                        end
                    end)
            
                    repeat task.wait(0) until AffordPromise:getStatus() ~= "Started" or Players.LocalPlayer == nil

                    if (CanAfford) then
                        Promise = ProgressionService:PurchaseUpgrade(ThemeData, progressionName):andThen(function(ResultInfo)
                            print(ResultInfo)
                            if ResultInfo.Currency then
                                PlayerCurrency = ResultInfo.Currency
                            end
                            if ResultInfo.ProgressionData then
                                PlayerProgressionData = ResultInfo.ProgressionData
                            end
                            NotificationUI:Message(ResultInfo.StatusString, ResultInfo.StatusEffect);
                            self:Update()
                            buttonDebounce = false;
                            return;
                        end);
                        repeat task.wait(0) until Promise:getStatus() ~= "Started" or Players.LocalPlayer == nil
                        warn("Done Purchase!")
                    else
                        Knit.GetController("ViewsUI"):OpenView("Shop");
                        task.wait(0.3);
                        Knit.GetController("ShopView"):GoToArea("Currency");
                    end
                    buttonDebounce = false;
                end)
            end
        end;

        table.sort(Skills, function(a, b)
            return a.Data.Data[2].Price < b.Data.Data[2].Price
        end)

        for i, key in ipairs(Skills) do
            ScrollingFrame:FindFirstChild(key.Name).LayoutOrder = i
        end
    end)
end

function UpgradeView:KnitStart()
    self:SetupUpgradeTabs()
end


function UpgradeView:KnitInit()
    CommaValue = require(Knit.ReplicatedModules.CommaValue);
end


return UpgradeView;
