local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local UpgradeView = Knit.CreateController { Name = "UpgradeView" }

local UpgradesTab = {}

--//Service
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

--//Const
local CommaValue;

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local viewsUI = PlayerGui:WaitForChild("Main"):WaitForChild("Views")

local UpgradesGui = viewsUI:WaitForChild("Upgrades")
local ScrollingFrame = UpgradesGui:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("ScrollingFrame")

function UpgradeView:SetupUpgradeTabs()
    local ProgressionService = Knit.GetService("ProgressionService")

    for _, Frame in pairs(ScrollingFrame:GetChildren()) do
        if Frame:IsA("Frame") then
            Frame:Destroy();
        end
    end

    ProgressionService:GetProgressionData("French"):andThen(function(playerCurrency, playerStorage, progressionStorage)
        print("PlayerCurrency", playerCurrency, "PlayerStorage:", playerStorage, "ProgressionStorage:", progressionStorage)

        local Skills = {}

        for progressionName, progressionData in next, progressionStorage do
            table.insert(Skills, {Name = progressionName, Data = progressionData})
            local ProgressItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("ProgressionTemplate");
            local PlayerDataIndex = playerStorage[progressionName]
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
                    if playerCurrency >= progressionData.Data[PlayerDataIndex + 1].Price then
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
