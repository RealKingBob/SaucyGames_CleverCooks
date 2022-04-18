local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LeaderboardUI = Knit.CreateController { Name = "LeaderboardUI" }

--//Services
local CollectionService = game:GetService("CollectionService")


local plr = game.Players.LocalPlayer;
local WinData, LevelData, KillData, DonationData;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local LeaderboardContainer = PlayerGui--PlayerGui:WaitForChild("LeaderboardContainer");

--//Public Methods
function LeaderboardUI:UpdateLeaderboard(LeaderboardName, Data)
    --print(LeaderboardName,Data)

    local CommaValue = require(Knit.ReplicatedModules.CommaValue);

    if not LeaderboardContainer:FindFirstChild(LeaderboardName) then
        return;
    end


    local LeaderboardGui = LeaderboardContainer[LeaderboardName];

    for _,v in pairs(LeaderboardGui:WaitForChild("ScrollingFrame"):GetChildren()) do      
        if (v:IsA("GuiObject")) then
            v:Destroy();
        end
    end
    
    local TargetClone

    if LeaderboardName == "Donations" then
        TargetClone = LeaderboardGui.ScrollingFrame:WaitForChild("UIListLayout"):WaitForChild("DonationPrefab");
    else
        TargetClone = LeaderboardGui.ScrollingFrame:WaitForChild("UIListLayout"):WaitForChild("ItemPrefab");
    end

    for i,v in pairs(Data) do
        local Clone = TargetClone:Clone() do
            if Clone then
                Clone.Pos.Text = ("#%s"):format(i);
                Clone.UserName.Text = ("(@%s)"):format(v.UserName);
                Clone.DisplayName.Text = v.DisplayName;
                Clone.Amount.Text = ("%s"):format(CommaValue(v.Value));
                Clone.ImageLabel.Image = game.Players:GetUserThumbnailAsync(
                    v.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size420x420
                );
                Clone.LayoutOrder = i;
                Clone.Parent = LeaderboardGui.ScrollingFrame;

                if (i == 1) then
                    Clone.Pos.TextColor3 = Color3.fromRGB(214, 171, 54);
                    Clone.ImageLabel.BackgroundColor3 = Color3.fromRGB(214, 171, 54);
                    Clone.Amount.TextColor3 = Color3.fromRGB(214, 171, 54);
                elseif (i == 2) then
                    Clone.Pos.TextColor3 = Color3.fromRGB(215, 215, 215);
                    Clone.ImageLabel.BackgroundColor3 = Color3.fromRGB(215, 215, 215);
                    Clone.Amount.TextColor3 = Color3.fromRGB(215, 215, 215);
                elseif (i == 3) then
                    Clone.Pos.TextColor3 = Color3.fromRGB(130, 74, 2);
                    Clone.ImageLabel.BackgroundColor3 = Color3.fromRGB(130, 74, 2);
                    Clone.Amount.TextColor3 = Color3.fromRGB(130, 74, 2);
                end
            end
        end
    end
end

function LeaderboardUI:SetupLeaderboard(Obj)
    local LeaderboardService = Knit.GetService("LeaderboardService")
    task.wait(3)
    LeaderboardService:GetLeaderboardData():andThen(function(leaderboardData) -- When initialized complete, request inventory data
        --print("GetLeaderboardData:", leaderboardData)
        WinData = leaderboardData["WinData"];
        KillData = leaderboardData["KillData"];
        DonationData = leaderboardData["CoinData"];
        --LevelData = leaderboardData["LevelData"];

        local LeaderboardPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("Leaderboard");
        
        local LeaderboardClone = LeaderboardPrefab:Clone() do
            LeaderboardClone.Adornee = Obj;
            LeaderboardClone.Name = Obj:GetAttribute("LeaderboardName");
            LeaderboardClone.Parent = LeaderboardContainer;
        end

        if LeaderboardClone.Name == "Wins" then
            if WinData then
                if #WinData > 0 then
                    --self:UpdateLeaderboard(LeaderboardClone.Name, WinData);
                end
            end
        end

        if LeaderboardClone.Name == "Kills" then
            if KillData then
                if #KillData > 0 then
                    --self:UpdateLeaderboard(LeaderboardClone.Name, KillData);
                end
            end
        end

        if LeaderboardClone.Name == "Donations" then
            if DonationData then
                if #DonationData > 0 then
                    --self:UpdateLeaderboard(LeaderboardClone.Name, DonationData);
                end
            end
        end
    end)
end

function LeaderboardUI:KnitStart()
    local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

    repeat task.wait(0) until Character
    if Character then
        CollectionService:GetInstanceAddedSignal("Leaderboard"):Connect(function(v)
            self:SetupLeaderboard(v);
        end)
    
        for _,v in pairs(CollectionService:GetTagged("Leaderboard")) do
            self:SetupLeaderboard(v);
        end
    
        task.wait(5)
    
        local LeaderboardService = Knit.GetService("LeaderboardService")
    
        LeaderboardService.LeaderboardSignal:Connect(function(leaderboardData)
            --print("GetLeaderboardData:", leaderboardData);
            WinData = leaderboardData["WinData"];
            DonationData = leaderboardData["CoinData"];
            --LevelData = leaderboardData["LevelData"];
    
            if WinData then
                if #WinData > 0 then
                    self:UpdateLeaderboard("Wins", WinData);
                end
            end
    
            if DonationData then
                if #DonationData > 0 then
                    self:UpdateLeaderboard("Donations", DonationData);
                end
            end
        end)
    end
end

function LeaderboardUI:KnitInit()
    
end

return LeaderboardUI
