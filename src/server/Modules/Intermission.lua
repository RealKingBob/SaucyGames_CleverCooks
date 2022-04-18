----- Services -----
local Players = game:GetService("Players");
local CollectionService = game:GetService("CollectionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

----- Variables -----
local LibraryAudios = ReplicatedStorage:WaitForChild("Audios");
local AudioMusic = LibraryAudios:WaitForChild("Music");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(Knit.Util.Maid)
local Signal = require(Knit.Util.Signal)

local Intermission = {}
Intermission.__index = Intermission

Intermission.lobbySpawn = nil;

Intermission.InProgress = false;
Intermission.TimeLeft = 0;

Intermission.Finished = Signal.new();

function Intermission:SetLobbySpawn(spawn)
    self.lobbySpawn = spawn;
end

function Intermission.new(length, tournamentEnabled)
    print("[Intermission]: Intermission Started")
    local GameService = Knit.GetService("GameService")
    local MapProgessService = Knit.GetService("MapProgessService")
    local AudioService = Knit.GetService("AudioService");
    local self = setmetatable({}, Intermission)

    self._maid = Maid.new()

    local musicDirectory = AudioMusic:FindFirstChild("Lobby").Intro; -- AudioMusic:FindFirstChild(tostring(self.Map)).Background 

    task.wait(1)
    --// NOTE: Play music and sound effects for map
    AudioService:StartMusic(musicDirectory);

    if ((#Players:GetPlayers() - #CollectionService:GetTagged(Knit.Config.AFK_TAG)) >= Knit.Config.MINIMUM_PLAYERS) then
        GameService:SetState(Knit.Config.GAME_STATES.INTERMISSION, "Intermission Started")
        
        -- Start repeating function calls
        self.TimeLeft = length;
        self.InProgress = true;

        for _,player in pairs(Players:GetPlayers()) do
            if player.Character then
                if not player.Character:FindFirstChild("Sphere") then
                    --print("uh")
                    player:LoadCharacter()
                end
            end
        end
  
        MapProgessService:TimerStart(true, tournamentEnabled)
        self:Update();
    else
        warn("[GameService]: Not enough players")
        GameService:SetState(Knit.Config.GAME_STATES.NOT_ENOUGH_PLAYERS, "Not Enough Players")
        GameService.Client.NotEnoughPlayersSignal:FireAll()
        repeat task.wait(1) until (#Players:GetPlayers() >= Knit.Config.MINIMUM_PLAYERS)
        return self.new(length)
    end

    return self;
end

function Intermission:Update()
    local GameService = Knit.GetService("GameService")
    local MapProgessService = Knit.GetService("MapProgessService")
    
    for timeLeft = self.TimeLeft, 0, -1 do
        if ((#Players:GetPlayers() - #CollectionService:GetTagged(Knit.Config.AFK_TAG)) < Knit.Config.MINIMUM_PLAYERS) then
            self.InProgress = false
        end
        GameService.Client.TimeLeftSignal:FireAll(timeLeft)
        if self.InProgress == false then
            break
        end
        task.wait(1)
    end
    --print('Intermission finished')
    MapProgessService:TimerEnd()
    self.Finished:Fire()
end

function Intermission:Destroy()
    --print("DESTROYING")
    self._maid:Destroy()
end

return Intermission;