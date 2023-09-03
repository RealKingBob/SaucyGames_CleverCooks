----- Services -----
local Players = game:GetService("Players");
local CollectionService = game:GetService("CollectionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage");

----- Variables -----

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(Knit.Util.Maid)
local Signal = require(Knit.Util.Signal)
local Config = require(Knit.Shared.Modules.Config)

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
    local self = setmetatable({}, Intermission)

    self._maid = Maid.new()


    task.wait(1)
    --// NOTE: Play music and sound effects for map

    if ((#Players:GetPlayers()) >= Config.MINIMUM_PLAYERS) or RunService:IsStudio() then
        GameService:SetState(Config.GAME_STATES.INTERMISSION, "Intermission Started")
        
        -- Start repeating function calls
        self.TimeLeft = length;
        self.InProgress = true;

        self:Update();
    else
        warn("[GameService]: Not enough players")
        GameService:SetState(Config.GAME_STATES.NOT_ENOUGH_PLAYERS, "Not Enough Players")
        GameService.Client.NotEnoughPlayersSignal:FireAll()
        repeat task.wait(1) until (#Players:GetPlayers() >= Config.MINIMUM_PLAYERS)
        return self.new(length)
    end

    return self;
end

function Intermission:Update()
    local GameService = Knit.GetService("GameService")
    
    for timeLeft = self.TimeLeft, 0, -1 do
        if ((#Players:GetPlayers()) < Config.MINIMUM_PLAYERS) then
            self.InProgress = false
        end
        GameService.Client.TimeLeftSignal:FireAll(timeLeft)
        if self.InProgress == false then
            break
        end
        task.wait(1)
    end
    --print('Intermission finished')
    self.Finished:Fire()
end

function Intermission:Destroy()
    --print("DESTROYING")
    self._maid:Destroy()
end

return Intermission;