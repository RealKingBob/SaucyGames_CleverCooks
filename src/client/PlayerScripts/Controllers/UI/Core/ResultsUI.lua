--[[
    Information Given:
    {
        ["YourRank"] = 1,
        ["Deaths"] = 25,
        ["TimeElapsed"] = "01:23.45" -- in milliseconds
        ["CoinsEarned"] = 400,
        ["Results"] = {
            ["Complete Round"] = 200,
            ["First Duck"] = 100,
            ["Checkpoint"] = 20,
        }
    }
]]

local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--//Const
local ViewOriginalSizes = {};
local ViewOriginalPositions = {};
local ResultsUI = Knit.CreateController { Name = "ResultsUI" }

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local ResultsGui = PlayerGui:WaitForChild("Results")

local ResultsFrame = ResultsGui:WaitForChild("Results")
local InnerFrame = ResultsFrame:WaitForChild("Inner")
local GameMode = InnerFrame:WaitForChild("GameMode")
local LocalRank = InnerFrame:WaitForChild("LocalRank")
local LocalDeaths = InnerFrame:WaitForChild("LocalDeaths")
local TimeElapsed = InnerFrame:WaitForChild("TimeElapsed")
local TotalResults = InnerFrame:WaitForChild("TotalResults")
local ScrollingFrame = InnerFrame:WaitForChild("ScrollingFrame")

local ViewToggledEvent = Instance.new("BindableEvent");

--//State
local CurrentView;

--//Public Events
ResultsUI.ViewToggled = ViewToggledEvent.Event;

--//Private Functions
function convertToMilliString(milliseconds)
    local Minutes = math.floor(milliseconds / 60)
	local Seconds = math.floor(milliseconds % 60)
	local Milliseconds = (milliseconds % 1) * 100
	return string.format("%.2d:%.2d.%.2d", Minutes, Seconds, Milliseconds)
end

--//Public Methods
function ResultsUI:OpenView(ViewName)
	if (CurrentView and CurrentView.Name == ViewName) then return; end
	
	self:CloseView();
	
	CurrentView = ResultsGui[ViewName];
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

    ViewToggledEvent:Fire(ViewName, true);

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
end

function ResultsUI:GetView(ItemName)
    return ResultsGui[ItemName];
end

function ResultsUI:CloseView(ItemName)
    if (ItemName and CurrentView.Name ~= ItemName) then return; end
    if (not CurrentView) then return; end
    
    local TargetView = CurrentView
    CurrentView = nil;

    if (TargetView) then
        ViewToggledEvent:Fire(TargetView.Name, false);
        
        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end
end

function ResultsUI:AddResultTab(ResultsName, ResultsCoins)
    local ResultsTabPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("ResultsTab")
    local Clone = ResultsTabPrefab:Clone() do
        Clone:WaitForChild("DescTitle").Text = ResultsName;
        Clone:WaitForChild("Coins").Text = ResultsCoins;
        Clone.Name = ResultsName;
        Clone.Parent = ScrollingFrame;
    end
end

function ResultsUI:UpdateResults(resultsData, gameMode)
    if not resultsData then
        return
    end
    --print("results:", resultsData)

    GameMode.Text = tostring(gameMode)
    if resultsData["YourRank"] then
        LocalRank:WaitForChild("Rank").Text = tostring("#"..resultsData["YourRank"])
        LocalDeaths:WaitForChild("Num").Text = tostring(resultsData["Deaths"])
    end
    
    local stringTimeElapsed
    if tonumber(resultsData["TimeElapsedOnHill"]) > 0 then  
        TimeElapsed:WaitForChild("Title").Text = "Time Elapsed On Hill:"
        stringTimeElapsed = convertToMilliString(tonumber(resultsData["TimeElapsedOnHill"]))
    else
        TimeElapsed:WaitForChild("Title").Text = "Time Elapsed:"
        stringTimeElapsed = convertToMilliString(tonumber(resultsData["TimeElapsed"]))
    end
    
    TimeElapsed:WaitForChild("TimeText").Text = stringTimeElapsed
    TotalResults:WaitForChild("CoinsAmount").Text = tostring(resultsData["CoinsEarned"])
    
    for _, Frame in ipairs(ScrollingFrame:GetChildren()) do
        if Frame:IsA("Frame") then
            Frame:Destroy()
        end
    end

    for i, resultData in next, resultsData["Results"] do
        self:AddResultTab(tostring(i), tostring(resultData))
    end
    Knit.GetController("TargetIndicattorUI"):ClearMarkers();
    ResultsFrame.Visible = true
    --LocalDeaths:WaitForChild("Num").Text = resultsData["Results"]
end

function ResultsUI:KnitStart()
    for _,v in pairs(ResultsGui:GetChildren()) do
        ViewOriginalSizes[v.Name] = v.Size;
        ViewOriginalPositions[v.Name] = v.Position;
    end
end


function ResultsUI:KnitInit()
    
end


return ResultsUI
