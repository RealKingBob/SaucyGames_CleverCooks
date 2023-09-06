----- Services -----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")


----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal)

----- Tournament Modes -----
local SandboxMode = require(Knit.Modules.Modes.SandboxMode)

----- Settings -----

----- GameService -----
local GameService = Knit.CreateService {
    Name = "GameService",
    TimeLeft = Signal.new(),
    Client = {
        AdjustTimeSignal = Knit.CreateSignal(),
        ResultSignal = Knit.CreateSignal(),
        ChangeSetting = Knit.CreateSignal(),
    }
}

----- GameService -----
-- Tables
GameService.Intermission = nil
GameService.PreviousMap = nil
GameService.PreviousMode = nil
GameService.GameMode = nil

GameService.PlayersTracked = {}
GameService.GameState = nil
GameService.SetGameplay = false

function GameService:ClearTracked(player)
    if player then
        if self.PlayersTracked[player.UserId] then
            self.PlayersTracked[player.UserId] = nil
            return
        end
    end
    self.PlayersTracked = {}
end

function GameService:GetPlayerTracked(player)
    if player and self.PlayersTracked[player.UserId] then
        return self.PlayersTracked[player.UserId]
    else
        return nil
    end
end

function GameService:ChangeSetting(player, SettingName, Option)
    local PlayerSettings = require(Knit.Shared.Modules.SettingsUtil)
    --print("CHANGE SETTING:",player, SettingName, Option, PlayerSettings[SettingName].Options[Option][2])
    if SettingName == "Music" then
        local AudioService = Knit.GetService("AudioService")
        if PlayerSettings[SettingName].Options[Option][2] == false then
            --print("MUTED")
            AudioService:MuteMusic(true, player)
        else
            --print("UNMUTED")
            AudioService:MuteMusic(false, player)
        end
    elseif SettingName == "Nametags" then
        if PlayerSettings[SettingName].Options[Option] then
            --print(player,Option)
            self.Client.DisplayNametags:Fire(player, Option)
        end
    end
    self.Client.ChangeSetting:Fire(player, SettingName, Option)
end

function GameService:StartGame(gamemode : string)
    if gamemode == "Round" then
        --self.GameMode = RoundMode:StartMode()
    else
        self.GameMode = SandboxMode:StartMode()
    end
end


function GameService:KnitInit()
    print("[SERVICE]: GameService initialized")

    self.Client.ChangeSetting:Connect(function(player, SettingName, Option)
        --print(player, SettingName, Option)
        self:ChangeSetting(player, SettingName, Option)
    end)
end


function GameService:KnitStart()
    task.wait(5)
    self:StartGame()
end

return GameService