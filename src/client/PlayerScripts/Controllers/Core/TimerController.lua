local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local TweenModule;

local PlayerGUI = Players.LocalPlayer.PlayerGui
local MainGUI = PlayerGUI:WaitForChild("MainGUI")
local PartyInvites = PlayerGUI:WaitForChild("PartyInvites")
local LeftBar = PlayerGUI:WaitForChild("LeftBar")
local Hatcher = PlayerGUI:WaitForChild("Hatcher")
local Views = PlayerGUI:WaitForChild("Views")
local CoinCollectorGui = PlayerGUI:WaitForChild("CoinCollectorGui")
local GameplayFrameUI = PlayerGUI:WaitForChild("GameplayFrame")
local GameplayFrameFrame = GameplayFrameUI:WaitForChild("GameplayFrame")
local SpectateButton = GameplayFrameFrame:WaitForChild("SpectateButton")
local DuckFrame = GameplayFrameFrame:WaitForChild("DuckFrame")
local CharSelect = GameplayFrameUI:WaitForChild("GameDesc")
local HunterFrame = GameplayFrameFrame:WaitForChild("HunterFrame")
local TimerFrame = GameplayFrameFrame:WaitForChild("TimerFrame")

local ModeText = GameplayFrameFrame:WaitForChild("ModeText") 
local PotatoText = GameplayFrameFrame:WaitForChild("PotatoText")
local AFKText = GameplayFrameFrame:WaitForChild("AFKText")
local ArenaText = GameplayFrameFrame:WaitForChild("ArenaText") 

local TitleText = TimerFrame:WaitForChild("TitleText")
local TimerText = TimerFrame:WaitForChild("TimerText")

local GameLibrary = ReplicatedStorage:WaitForChild("Common")
local GameEffects = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("GameEffects")
local LibraryAudios = ReplicatedStorage:WaitForChild("Audios")
local ThirtySecondsLeft = LibraryAudios.Effects:WaitForChild("ThirtySecondsLeft")

local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Config = require(GameLibrary.Modules.Config)

local currentGameState = 0;

local TimerUIController = Knit.CreateController { Name = "TimerUIController" }
--print("TimerUIController")

function Format(Int)
	return string.format("%02i", Int)
end

function convertToMinutes(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return Format(Minutes)..":"..Format(Seconds)
end

local coreCall do
    local MAX_RETRIES = 8

    local StarterGui = game:GetService('StarterGui')
    local RunService = game:GetService('RunService')

    function coreCall(method, ...)
        local result = {}
        for retries = 1, MAX_RETRIES do
            result = {pcall(StarterGui[method], StarterGui, ...)}
            if result[1] then
                break
            end
            RunService.Stepped:Wait()
        end
        return unpack(result)
    end
end

function HideProgressBar(bool)
    local GameplayGUI = PlayerGUI:WaitForChild("GameplayFrame")
    local GameplayFrame = GameplayGUI:WaitForChild("GameplayFrame")
    local ProgressBar = GameplayFrame:WaitForChild("ProgressBar")
    if bool == true then
        ProgressBar:TweenPosition(UDim2.new(0.5, 0, -0.05, 0),"InOut","Quad",.8,true)
    else
        ProgressBar:TweenPosition(UDim2.new(0.5, 0, 0.086, 0),"InOut","Quad",.8,true)
    end
end

function updateUI(gameMode)
    if currentGameState == 0 then
        NotEnoughPlayers()
        coreCall('SetCore', 'ResetButtonCallback', true)
    elseif currentGameState == 1 then
        StartTimerUI(true)
        coreCall('SetCore', 'ResetButtonCallback', true)
    elseif currentGameState == 2 then
        StartTimerUI(false)
        coreCall('SetCore', 'ResetButtonCallback', false)
    else
        HideTimerUI()
        coreCall('SetCore', 'ResetButtonCallback', true)
    end
    if tostring(gameMode) == "CLASSIC MODE" then
        ModeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        HideProgressBar(false)
    elseif tostring(gameMode) == "INFECTION MODE" then
        ModeText.TextColor3 = Color3.fromRGB(5, 219, 5)
        HideProgressBar(false)
    elseif tostring(gameMode) == "RACE MODE" then
        ModeText.TextColor3 = Color3.fromRGB(5, 138, 247)
        HideProgressBar(false)
    elseif tostring(gameMode) == "HOT POTATO" then
        ModeText.TextColor3 = Color3.fromRGB(221, 30, 30)
        HideProgressBar(true)
    elseif tostring(gameMode) == "DUCK OF THE HILL" then
        ModeText.TextColor3 = Color3.fromRGB(255, 204, 0)
        HideProgressBar(true)
    elseif tostring(gameMode) == "DOMINATION" then
        ModeText.TextColor3 = Color3.fromRGB(32, 152, 250)
        HideProgressBar(true)
    else
        HideProgressBar(true)
    end
    ModeText.Text = tostring(gameMode)
end

function NotEnoughPlayers()
    --print("[TimerUIController]: Players Needed")
    TitleText.Text = "Paused"
    TimerText.Text = tostring(Config.MINIMUM_PLAYERS).." Players Required"
    TimerFrame:TweenPosition(UDim2.new(0.5, 0,0.019, 0),"InOut","Quad",.8,true)
    DuckFrame:TweenPosition(UDim2.new(0.57, 0, -0.065, 0),"InOut","Quad",.8,true)
    HunterFrame:TweenPosition(UDim2.new(0.43, 0, -0.065, 0),"InOut","Quad",.8,true)
end

function StartTimerUI(Intermission, tournamentEnabled)
    --print("[TimerUIController]: Starting Now")
    if not Intermission then
        TitleText.Text = "Time left"
        DuckFrame:TweenPosition(UDim2.new(0.57, 0, 0.035, 0),"InOut","Quad",.8,true)
        HunterFrame:TweenPosition(UDim2.new(0.43, 0, 0.035, 0),"InOut","Quad",.8,true)
        ModeText:TweenPosition(UDim2.new(0, 0, 0.118, 0),"InOut","Quad",.8,true)
    else
        TitleText.Text = "Intermission"
        DuckFrame:TweenPosition(UDim2.new(0.57, 0, -0.065, 0),"InOut","Quad",.8,true)
        HunterFrame:TweenPosition(UDim2.new(0.43, 0, -0.065, 0),"InOut","Quad",.8,true)
    end

    if tournamentEnabled == true then
        TitleText.Text = "Tournament starts in"
    end

    TimerFrame:TweenPosition(UDim2.new(0.5, 0,0.019, 0),"InOut","Quad",.8,true)
end

function StartCharSelect(string)
    local UIController = Knit.GetController("GameUI")
    --[[if CollectionService:HasTag(LocalPlayer, "Hunter") then
        UIController:SetCharSelect("YOU ARE A HUNTER!", "PREVENT THE DUCKS FROM REACHING THE END OF THE MAP!")
    else
        UIController:SetCharSelect("YOU ARE A DUCK!", "REACH TO THE END OF THE MAP TO COMPLETE ROUND!")
    end]]
    UIController:SetCharSelect("", string)
    CharSelect.Visible = true
    --CharSelect:TweenPosition(UDim2.new(0.5, 0, 0.12, 0),"InOut","Quad",.8,true)
end

function HideSelect()
    CharSelect.Visible = false
    --CharSelect:TweenPosition(UDim2.new(0.5, 0,-0.11, 0),"InOut","Quad",.8,true)
end

function HideTimerUI()
    --print("[TimerUIController]: Hiding Now")
    
    DuckFrame:TweenPosition(UDim2.new(0.57, 0, -0.065, 0),"InOut","Quad",.8,true)
    HunterFrame:TweenPosition(UDim2.new(0.43, 0, -0.065, 0),"InOut","Quad",.8,true)
    TimerFrame:TweenPosition(UDim2.new(0.5, 0, -0.065, 0),"InOut","Quad",.8,true)
    ModeText:TweenPosition(UDim2.new(0, 0, -0.065, 0),"InOut","Quad",.8,true)
end

function TimerUIController:setupConnections()
    --print("TimerUIController setupConnections")
    HideTimerUI()
    HideSelect()

    local GameService = Knit.GetService("GameService")
    local MapProgessService = Knit.GetService("MapProgessService")

    GameService:GetGameState():andThen(function(gameState)
        currentGameState = gameState
    end)

    GameService.NotEnoughPlayersSignal:Connect(function()
        NotEnoughPlayers()
    end)

    GameService.DisplayLobbyUI:Connect(function(bool, spectate)
        if bool == false then
            game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true);
            game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true);
        end
        Hatcher.Enabled = bool;
        CoinCollectorGui.Enabled = bool;
        PartyInvites.Enabled = bool;
        LeftBar.Enabled = bool;
        Views.Enabled = bool;

        if spectate then
            SpectateButton.Visible = spectate;
        end
    end)

    GameService.UpdateGameStateSignal:Connect(function(gameState)
		currentGameState = gameState
	end)

    local POTATO_TAG = "Potato";
    local AFK_TAG = "AFK";
    local ARENA_TAG = "LobbyArena";
    local CHECKPOINT_TAG = "Checkpoint";

    local RED_TEAM = "RedTeam";

    local SettingsUI = Knit.GetController("SettingsUI")

    local RiseTween = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

    CollectionService:GetInstanceAddedSignal(CHECKPOINT_TAG):Connect(function(Object)
        local Checkpoint = Object;
        local Touched = false;
        local OriginalColor = Checkpoint:WaitForChild("Pad").Color
        Checkpoint.Pad.Color = Color3.fromRGB(255, 255, 255)
        Checkpoint.Pad.Material = Enum.Material.Neon
        Checkpoint.Pad.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid");
            if not humanoid then
                return;
            end
            local Player = game.Players:GetPlayerFromCharacter(humanoid.Parent);
            if Player == LocalPlayer then
                if CollectionService:HasTag(Player, "Duck") then
                    --print(table.find(touchedCheckpoints[Checkpoint], Player.UserId))
                    if Touched == false then
                        Touched = true;
                        --Checkpoint.Pad.Material = Enum.Material.Plastic
                        local CheckpointSFX = LibraryAudios.Effects:WaitForChild("Checkpoint")
                        local ImpactSFX = LibraryAudios.Effects:WaitForChild("Impact")
                        CheckpointSFX:Play()
                        ImpactSFX:Play()
                        task.spawn(function()
                            local ImpactClone = GameEffects:WaitForChild("TargetEffect").Impact:Clone()
                            ImpactClone.Parent = Checkpoint.Pad
                            Debris:AddItem(ImpactClone, 0.2)
                        end)
                        local CheckpointTween = TweenModule.new(RiseTween, function(Alpha)
                            Checkpoint.Pad.Color = Color3.fromRGB(255, 255, 255):Lerp(OriginalColor, Alpha)
                            local x,y,z = Checkpoint.PrimaryPart.Position.X, Checkpoint.PrimaryPart.Position.Y, Checkpoint.PrimaryPart.Position.Z
                            Checkpoint.Pad.Position = Vector3.new(x, y, z):Lerp(Vector3.new(x, y - 0.2, z), Alpha)
                        end)
                        Checkpoint.Pad.Material = Enum.Material.Neon
                        CheckpointTween:Play();
                    end
                end
            end
        end)
    end)

    CollectionService:GetInstanceAddedSignal(AFK_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            AFKText.Visible = true;
            SettingsUI:SetSetting("AFK", "On");
        end
    end)

    CollectionService:GetInstanceRemovedSignal(AFK_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            AFKText.Visible = false;
            SettingsUI:SetSetting("AFK", "Off");
        end
    end)

    CollectionService:GetInstanceAddedSignal(ARENA_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            ArenaText.Visible = true;
        end
    end)

    CollectionService:GetInstanceRemovedSignal(ARENA_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            ArenaText.Visible = false;
        end
    end)

    CollectionService:GetInstanceAddedSignal(POTATO_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            PotatoText.Visible = true;
            for _, ui in pairs(workspace.Lobby.NameTags:GetChildren()) do
                if ui:IsA("BillboardGui") and ui.Name == "DOT_UI" then
                    ui.Enabled = true;
                end
            end
        end
    end)

    CollectionService:GetInstanceRemovedSignal(POTATO_TAG):Connect(function(Object)
        if Object == LocalPlayer then
            PotatoText.Visible = false;
            for _, ui in pairs(workspace.Lobby.NameTags:GetChildren()) do
                if ui:IsA("BillboardGui") and ui.Name == "DOT_UI" then
                    ui.Enabled = false;
                end
            end
        end
    end)

	GameService.TimeLeftSignal:Connect(function(timeLeft, gameMode)

        updateUI(gameMode)
        
        if timeLeft == 30 then
            ThirtySecondsLeft:Play();
        end

        TimerText.Text = tostring(convertToMinutes(timeLeft))

        if #CollectionService:GetTagged(RED_TEAM) > 0 then
            HunterFrame.Title.Text = "Red Team Points";
            DuckFrame.Title.Text = "Blue Team Points";
            HunterFrame.HunterText.Text = workspace.CurrentMap:GetAttribute("RedPoints")
            DuckFrame.DuckText.Text = workspace.CurrentMap:GetAttribute("BluePoints")
            --HunterFrame.HunterText.Text = tostring(#CollectionService:GetTagged("RedTeam"))
            --DuckFrame.DuckText.Text = tostring(#CollectionService:GetTagged("BlueTeam"))
        elseif #CollectionService:GetTagged("Hill") > 0 then
            HunterFrame.Title.Text = "Ducks On Hill";
            DuckFrame.Title.Text = "Ducks";
            HunterFrame.HunterText.Text = tostring(#CollectionService:GetTagged("Hill"))
            DuckFrame.DuckText.Text = tostring(#CollectionService:GetTagged("Duck"))
        elseif #CollectionService:GetTagged("Potato") > 0 or #CollectionService:GetTagged("NoPotato") > 0 then
            HunterFrame.Title.Text = "Hot Potatoes";
            DuckFrame.Title.Text = "Ducks";
            HunterFrame.HunterText.Text = tostring(#CollectionService:GetTagged("Potato"))
            DuckFrame.DuckText.Text = tostring(#CollectionService:GetTagged("NoPotato"))
        else
            HunterFrame.Title.Text = "Hunters";
            DuckFrame.Title.Text = "Ducks";
            HunterFrame.HunterText.Text = tostring(#CollectionService:GetTagged("Hunter"))
            DuckFrame.DuckText.Text = tostring(#CollectionService:GetTagged("Duck"))
        end
	end)

    MapProgessService.TimerStartSignal:Connect(function(Intermission, tournamentEnabled)
        --print("Timer UI Start")
        game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true);
        game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true);
        StartTimerUI(Intermission, tournamentEnabled)
        if not CollectionService:HasTag(LocalPlayer, "Alive") and (currentGameState == 2) then
            SpectateButton.Visible = true;
        end
    end)

    MapProgessService.TimerEndSignal:Connect(function()
        --print("Timer UI End")
        if (currentGameState ~= 2) then
            SpectateButton.Visible = false;
            --MainScreenFrame.Visible = true
        end
        HideTimerUI()
    end)

    MapProgessService.UpdateCharSelectSignal:Connect(function(string)
        StartCharSelect(string)
    end)

end

function TimerUIController:KnitInit()
    --print("TimerUIController KnitInit called")
end


function TimerUIController:KnitStart()
    --print("TimerUIController KnitStart called")
    TweenModule = require(Knit.Modules.Tween);
    self:setupConnections()

    local isIdle = false;
    local currentTime  = 0;
    local max_minutes = 1;

    UserInputService.InputBegan:Connect(function()
        isIdle = false;
        currentTime  = 0;
    end)

    UserInputService.InputEnded:Connect(function()
        isIdle = true;
    end)

    task.spawn(function()
        while task.wait(1) do
            if not isIdle then
                currentTime = 0;
            end
            if currentTime >= (max_minutes * 60) then
                currentTime = 0;
                if CollectionService:HasTag(LocalPlayer, "IsIdle") == false then
                    local GameService = Knit.GetService("GameService")
                    GameService.SetIdle:Fire();
                end
            end
            --print("currentTime", currentTime)
            currentTime += 1
        end
    end)
end

return TimerUIController