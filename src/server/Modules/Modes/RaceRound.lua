--[[
    Name: Race Round [V2]
    By: Real_KingBob
    Created: 12/10/21 
    Updated: 2/9/21
    Description: This module handles the race round game mode
]]

----- Services -----
local Players = game:GetService("Players");
local CollectionService = game:GetService("CollectionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit);
local Maid = require(Knit.Util.Maid);
local Signal = require(Knit.Util.Signal);
local MapProgress = require(script.Parent.Parent.MapProgress)

----- Variables -----
local LibraryAudios = ReplicatedStorage:WaitForChild("Audios");
local AudioMusic = LibraryAudios:WaitForChild("Music");

local SinglePlayer = Knit.Config.SINGLE_PLAYER;

local GameService, CutsceneService, MapProgessService, AudioService;

----- Game Round -----
local GameRound = {};
local TimeTracked = {};
GameRound.__index = GameRound;

GameRound.Map = nil;

GameRound.duckSpawn = nil;
GameRound.hunterSpawn = nil;
GameRound.lobbySpawn = nil;
GameRound.endPoint = nil;

GameRound.CutsceneInProgress = false;
GameRound.InProgress = false;
GameRound.TimeLeft = 0;
GameRound.WaitTime = 1;

GameRound.MessageTip = "REACH TO THE END OF THE MAP TO COMPLETE ROUND!";

GameRound.Finished = Signal.new();

GameRound.NumOfHunters = 1; --// NOTE: Changes after CalculateNumOfHunters()

----- Private Functions -----
function RoundToInt(n)
	return math.floor(n + 0.5)
end

----- Public Methods -----

--// Duck Methods -----

function GameRound:AddDuck(player)
    GameService = Knit.GetService("GameService");
    CollectionService:AddTag(player, Knit.Config.DUCK_TAG);
    player.TeamColor = BrickColor.new("Dark blue")
    GameService.Client.DisplayLobbyUI:Fire(player, false, false)
end

function GameRound:StartTracking()
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.DUCK_TAG)) do
        task.spawn(function()
            if player then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = 16;
                        player.Character.Humanoid.JumpPower = 25;
                    end
                    player.Character.HumanoidRootPart.Anchored = false;
                    task.spawn(function()
                        TimeTracked[player] = tick();
                        --GameService:GetPlayerTracked(player):StartCountingMillisecondsPlayed(player);
                    end)
                end
            end
        end)
    end
end

function GameRound:TeleportDucks(SelectedSpawn) --[INSTANCE]
    if SelectedSpawn then
        local nodeRadius = 1.2 -- 144 spawn locations
        local nodeDiameter = nodeRadius * 2
        local gridWorldSizeX, gridWorldSizeY = SelectedSpawn.Size.X, SelectedSpawn.Size.Z
        local gridsizeX = RoundToInt(gridWorldSizeX/nodeDiameter)
        local gridsizeY = RoundToInt(gridWorldSizeY/nodeDiameter)

        local worldBottomLeft = SelectedSpawn.position - Vector3.new(1,0,0) * gridWorldSizeX/2 - Vector3.new(0,0,1) * gridWorldSizeY/2;
        local newgridsizeX = gridsizeX - 1
        local newgridsizeY = gridsizeY - 1

        local count = 1
        for x = 0, newgridsizeX do
            for y = 0, newgridsizeY do
                --[[ Visualize the locations
                local part = Instance.new("Part")
                part.Anchored = true;
                part.CanCollide = false;
                part.Orientation = SelectedSpawn.Orientation
                part.CFrame = (CFrame.new(worldPosition)) + Vector3.new(0,2,0)
                part.Size = Vector3.new(1,1,1) * (nodeDiameter - 0.1)
                part.Parent = workspace]]
                task.spawn(function()
                    local worldPosition = worldBottomLeft + Vector3.new(1,0,0) * (x * nodeDiameter + nodeRadius) + Vector3.new(0,0,1) * (y * nodeDiameter + nodeRadius);
                    local player = CollectionService:GetTagged(Knit.Config.DUCK_TAG)[count]
                    if player then
                        if player:IsA("Player") then
                            --print("[TELEPORTING DUCK_TAG]", "Player:", player, "Num of players:", #CollectionService:GetTagged(Knit.Config.DUCK_TAG))
                            player.RespawnLocation = SelectedSpawn;
                            if player.Character then
                                if player.Character:FindFirstChild("Humanoid")
                                and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.Humanoid.WalkSpeed = 0;
                                player.Character.Humanoid.JumpPower = 0;
                                player.Character.HumanoidRootPart.Anchored = true;
                                player.Character:SetPrimaryPartCFrame((CFrame.new(worldPosition)) * CFrame.fromEulerAnglesXYZ(0, math.rad(SelectedSpawn.Orientation.Y), 0) +
                                    Vector3.new(0,1,0));
                                end
                            end
                        end
                    else
                        return;
                    end
                end)
                count += 1
            end
        end
    end
end

--// Other ------

function GameRound:SetupEndpoint()
    if self.Map:FindFirstChild("EndPoint") then
        self.Map:FindFirstChild("EndPoint"):FindFirstChild("Teleport").PrimaryPart.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid");
            if not humanoid then
                return;
            end
            local Player = game.Players:GetPlayerFromCharacter(humanoid.Parent);
            if Player then
                if CollectionService:HasTag(Player, Knit.Config.DUCK_TAG) then
                    local playerProgress = MapProgress:CheckPlayerProgress(Player);
                    --print('[PROGRESS REPORT]: playerProgress for',Player,'is',playerProgress * 100)
                    if playerProgress < 0.4 then --// If player doesn't go through 80% of the course then kick them for cheating.
                        --Player:Kick("Don't exploit please.", playerProgress * 10, "%");
                        warn('[EXPLOIT REPORT]: playerProgress for',Player,'is',playerProgress * 100)
                        return
                    end
                    MapProgress:PlayerFinished(Player);
                    task.spawn(function()
                        if GameService:GetPlayerTracked(Player) ~= nil then
                            if TimeTracked[Player] ~= nil then
                                GameService:GetPlayerTracked(Player):GetPlayerStats(Player).TimeElapsed = tick() - TimeTracked[Player]
                                TimeTracked[Player] = nil
                            end
                            --GameService:GetPlayerTracked(Player):StopCountingSecondsPlayed(Player)
                            GameService:GetPlayerTracked(Player):GetPlayerStats(Player).WinRound = true;
                        end
                    end)
                    CollectionService:AddTag(Player, Knit.Config.WINNER_TAG)
                    CollectionService:AddTag(Player, Knit.Config.LOBBY_TAG);
                    CollectionService:RemoveTag(Player, Knit.Config.DUCK_TAG);
                    GameService.Client.DisplayLobbyUI:Fire(Player, true, true)
                    Player.RespawnLocation = self.lobbySpawn;

                    if (#CollectionService:GetTagged(Knit.Config.WINNER_TAG) / #CollectionService:GetTagged(Knit.Config.ALIVE_TAG))>= 0.1 then
                        --self.InProgress = false
                        self.WaitTime = 0.35
                    end

                    local character = Player.Character;

                    if character then
                        character:SetPrimaryPartCFrame(self.lobbySpawn.CFrame * CFrame.new(Vector3.new(math.random(-2,2),1,math.random(-2,2))));
                    end
                end
            end
        end)
    end
end

function GameRound:SetupCheckpoints()
    if self.Map:FindFirstChild("Checkpoints") then
        for _, Checkpoint in pairs(self.Map:FindFirstChild("Checkpoints"):GetChildren()) do
            local touchedCheckpoints = {};
            touchedCheckpoints[Checkpoint] = {};
            CollectionService:AddTag(Checkpoint, Knit.Config.CHECKPOINT_TAG)
            Checkpoint.Pad.Touched:Connect(function(hit)
                local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid");
                if not humanoid then
                    return;
                end
                local Player = game.Players:GetPlayerFromCharacter(humanoid.Parent);
                if Player then
                    if CollectionService:HasTag(Player, "Duck") then
                        --print(table.find(touchedCheckpoints[Checkpoint], Player.UserId))
                        if not table.find(touchedCheckpoints[Checkpoint], Player.UserId) then
                            table.insert(touchedCheckpoints[Checkpoint], Player.UserId)
                            GameService:GetPlayerTracked(Player):AddCheckpoint(Player)
                        end
                        Player.RespawnLocation = Checkpoint.PrimaryPart;
                    end
                end
            end)
        end
    end
end

function GameRound:CleanUp(player)
    CollectionService:RemoveTag(player, Knit.Config.HUNTER_TAG);
    CollectionService:RemoveTag(player, Knit.Config.DUCK_TAG);
    GameService.Client.DisplayLobbyUI:Fire(player, true, false)
    if player.Character then
        if player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
        end
    end
    repeat task.wait(0) until not player.Character:FindFirstChildWhichIsA("Tool")
    task.wait(0.1)
    local spawnLocations = workspace.Lobby.Spawns.Locations
    local newSpawnLocation = spawnLocations:GetChildren()[math.random(1, #spawnLocations:GetChildren())]
    if player then
        player.RespawnLocation = newSpawnLocation;
        if CollectionService:HasTag(player, Knit.Config.LOBBY_TAG) == false then
            player:LoadCharacter();
        end
        GameService:SetHunterCamera(false, player); 
    end
end

----- Game Round & Main Methods -----
function GameRound.new(length, gameMode, mapName)
    print("[GameRound][RACE]: Race round created")
    GameService = Knit.GetService("GameService");
    CutsceneService = Knit.GetService("CutsceneService");
    MapProgessService = Knit.GetService("MapProgessService");
    AudioService = Knit.GetService("AudioService");
    
    local self = setmetatable({}, GameRound);
    self._maid = Maid.new();

    if mapName then
        local SelectedMap = mapName
        GameService:SetGameRound(self)
        GameService:SetPreviousMap(tostring(SelectedMap));

        local MapLocation = Knit.ServerModules.Assets:FindFirstChild(tostring(SelectedMap))

        if MapLocation == nil then
            MapLocation = Knit.ServerModules.Assets:FindFirstChild("Tropical")
        end

        if MapLocation then
            print("[GameRound][RACE]: Map selected")
            local MapModule = require(MapLocation);

            local MapInfo = MapModule:Init();
            
            self.Map = MapInfo[1];
            self.lobbySpawn, self.duckSpawn, self.hunterSpawn = MapInfo[2], MapInfo[3], MapInfo[4];
            self.endPoint = MapInfo[5];

            self.TimeLeft = length;
            self.InProgress = true;

            self.CutsceneInProgress = true;

            print("[GameRound][RACE]: Adding ducks")
            --// NOTE: Whenever character (DUCK) is added they get set to their respawn location and DISABLE THE HUNTER CAMERA
            for _, player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
                if CollectionService:HasTag(player,Knit.Config.HUNTER_TAG) == true then
                    continue;
                end
                self:AddDuck(player);

                if player.Character == nil or player.Character.Parent == nil then
                    player:LoadCharacter();
                end
                
                local Character = player.Character or player.CharacterAdded:Wait()
                local humanoid = Character:WaitForChild("Humanoid")

                self._maid:GiveTask(humanoid.Running:Connect(function()
                    if CollectionService:HasTag(player, Knit.Config.IDLE_TAG) == true then
                        CollectionService:RemoveTag(player, Knit.Config.IDLE_TAG)
                    end
                end))

                self._maid:GiveTask(humanoid.Died:Connect(function()
                    GameService:GetPlayerTracked(player):AddDeath(player)
                end))

                self._maid:GiveTask(player.CharacterAdded:Connect(function(char)
                    repeat task.wait(0) until char
                    char.PrimaryPart.Anchored = true;
                    char:SetPrimaryPartCFrame(player.RespawnLocation.CFrame * CFrame.new(Vector3.new(math.random(-3,3),1,math.random(-3,3))) +
                    Vector3.new(0,2.5,0));
                    char.PrimaryPart.Anchored = false;
                    local humanoid = char:WaitForChild("Humanoid")
                    
                    self._maid:GiveTask(humanoid.Running:Connect(function()
                        if CollectionService:HasTag(player, Knit.Config.IDLE_TAG) == true then
                            CollectionService:RemoveTag(player, Knit.Config.IDLE_TAG)
                        end
                    end))

                    self._maid:GiveTask(humanoid.Died:Connect(function()
                        if GameService:GetPlayerTracked(player) ~= nil then
                            GameService:GetPlayerTracked(player):AddDeath(player)
                        end
                    end))
                end))
            end

            print("[GameRound][RACE]: Set up checkpoints and endpoint")
            self:SetupCheckpoints();
            self:SetupEndpoint();

            print("[GameRound][RACE]: Checking if current map exists if not then wait")
            repeat task.wait(0.5) until #workspace.CurrentMap:GetChildren() > 0
            print("[GameRound][RACE]: Found map, starting music and game")
            --// NOTE: Gets music and sound effects for map
            local musicDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).Intro; -- AudioMusic:FindFirstChild(tostring(self.Map)).Background 
            local effectDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).SoundEffects;

            --print("cutscene")
            --// NOTE: Starts cutscene for map
            CutsceneService:CutsceneIntro(self.Map, gameMode);
            repeat task.wait(0) until #CollectionService:GetTagged(Knit.Config.CUTSCENE_TAG) > 0;
            task.wait(2)
            print("[GameRound][RACE]: Teleporting ducks to the map")
            --// NOTE: Do duck teleport to their spawn location
            self:TeleportDucks(self.duckSpawn)

            --// NOTE: Sets clients lighting for game
            task.spawn(function()
                task.wait(3)
                --print("lightting",tostring(SelectedMap))
                GameService:SetLighting(tostring(SelectedMap));
            end)

            task.wait(8);
            --// NOTE: Play music and sound effects for map
            AudioService:StartMusic(musicDirectory);
            AudioService:StartSoundPackage(effectDirectory);

            --// NOTE: Starts cutscene for map
            print("[GameRound][RACE]: Starting cutscene for players")

            task.wait(18)
            local forceStartGame = false
            task.spawn(function() task.wait(2) forceStartGame = true end)
            repeat task.wait(0) until (#CollectionService:GetTagged(Knit.Config.CUTSCENE_TAG) / #CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) <= 0.1 or forceStartGame == true

            --musicDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).Background
            self.CutsceneInProgress = false;
            MapProgessService:TimerStart(false);
            MapProgessService:ProgressStart();
            for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
                MapProgessService:UpdateCharSelectUI(self.MessageTip, player);
            end
            AudioService:StartMusic(musicDirectory);
            self:Update(gameMode);
        else
            warn("[GameRound][RACE]: Map module not found!");
            self.Finished:Fire();
        end
    else
        warn("[GameRound][RACE]: There no more maps");
        self.Finished:Fire();
    end

    return self;
end

function GameRound:Update(gameMode)
    print("[GameRound][RACE]: Updating game now")
    GameService = Knit.GetService("GameService");
    MapProgessService = Knit.GetService("MapProgessService");
    AudioService = Knit.GetService("AudioService");

    local musicDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).Intro;
    local effectDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).SoundEffects;

    local PathDataPoints = {};

    if workspace:FindFirstChild("CurrentMap") then
        local CurrentMap = workspace:FindFirstChild("CurrentMap"):GetChildren()[1];
        if CurrentMap then
            if CurrentMap:FindFirstChild("PathData")  then
                local PathPoints = CurrentMap.PathData:GetChildren()
                for i = 1, #PathPoints do
                    if CurrentMap.PathData:FindFirstChild(tostring(i)) then
                        table.insert(PathDataPoints,CurrentMap.PathData:FindFirstChild(i).Position)
                    end
                end
            end
        end
    end
    print("[GameRound][RACE]: Starting to track players")
    self:StartTracking();

    local MapLength = MapProgress:GetMapLength(PathDataPoints)
    print("[GameRound][RACE]: Starting timer")
    for timeLeft = self.TimeLeft, 0, -1 do
        GameService.Client.TimeLeftSignal:FireAll(timeLeft, gameMode)
        if #CollectionService:GetTagged(Knit.Config.DUCK_TAG) == 0 and not SinglePlayer then
            break;
        end
        if self.InProgress == false then
            break;
        end
        for _, target in pairs(CollectionService:GetTagged("Target")) do
            CollectionService:AddTag(target, "InitiateTrap")
        end
        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
            if CollectionService:HasTag(player, Knit.Config.IDLE_TAG) == true then
                if timeLeft <= (self.TimeLeft * (2/3)) then
                    CollectionService:RemoveTag(player, Knit.Config.ALIVE_TAG)
                    CollectionService:RemoveTag(player, Knit.Config.IDLE_TAG)
                    if TimeTracked[player] ~= nil then
                        GameService:GetPlayerTracked(player):GetPlayerStats(player).TimeElapsed = tick() - TimeTracked[player]
                        TimeTracked[player] = nil
                    end
                    --GameService:GetPlayerTracked(player):StopCountingSecondsPlayed(player)
                    CollectionService:AddTag(player, Knit.Config.AFK_TAG)
                    self:CleanUp(player);
                end
            end
            if player and player.Character then
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if HumanoidRootPart then
                        MapProgress:GetPositionOnMap(player, HumanoidRootPart.Position, MapProgress:GetMapRays(player, PathDataPoints))
                    end
                end
            end
        end
        task.wait(self.WaitTime);
    end

    --// Evaluate player performance
    print("[GameRound][RACE]: Timer ended, evaluating player")
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
        MapProgessService:UpdateCharSelectUI("");
        task.spawn(function()
            if TimeTracked[player] ~= nil then
                GameService:GetPlayerTracked(player):GetPlayerStats(player).TimeElapsed = tick() - TimeTracked[player]
                TimeTracked[player] = nil
            end
            --GameService:GetPlayerTracked(player):StopCountingSecondsPlayed(player)

            local PlayerRank = MapProgress:GetPlayerRank(player, MapLength, PathDataPoints)
            GameService:GetPlayerTracked(player):GetPlayerStats(player).YourRank = tonumber(PlayerRank);
        end)
        task.wait(0.02)
    end

    print("[GameRound][RACE]: Classic round ended")
    --HunterService:EndHunterPos()
    MapProgessService:TimerEnd();
    MapProgessService:ProgressEnd();
    AudioService:StopMusic(musicDirectory);
    AudioService:StopSoundPackage(effectDirectory);
    self.Finished:Fire();
end

function GameRound:Destroy()
    self._maid:Destroy();

    MapProgress:ClearFinished()

    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
        task.spawn(function()
            self:CleanUp(player)
        end)
        task.wait(0.02)
    end

    if Knit.ServerModules.Assets:FindFirstChild("Lobby") then
        local LobbyModule = require(Knit.ServerModules.Assets:FindFirstChild("Lobby"));
        LobbyModule:Init();
    end

    workspace.CurrentMap:ClearAllChildren();
end

return GameRound;