--[[
    Name: Duck of the Hill Round [V2]
    By: Real_KingBob
    Created: 12/10/21 
    Updated: 2/9/21
    Description: This module handles the duck of the hill game mode
]]

----- Services -----
local Players = game:GetService("Players");
local CollectionService = game:GetService("CollectionService");
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit);
local Maid = require(Knit.Util.Maid);
local Signal = require(Knit.Util.Signal);
local MapProgress = require(script.Parent.Parent.MapProgress)
local Zone = require(Knit.ReplicatedModules.Zone)

----- Variables -----
local LibraryAudios = ReplicatedStorage:WaitForChild("Audios");
local AudioMusic = LibraryAudios:WaitForChild("Music");
local NumUI = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("NUM_UI");

local SinglePlayer = Knit.Config.SINGLE_PLAYER;

local GameService, CutsceneService, MapProgessService, AudioService;

----- Game Round -----
local GameRound = {};
GameRound.__index = GameRound;

GameRound.Map = nil;

GameRound.duckSpawn = nil;
GameRound.lobbySpawn = nil;
GameRound.endPoint = nil;

GameRound.CutsceneInProgress = false;
GameRound.InProgress = false;
GameRound.NumOfRebalances = 5;
GameRound.HillRebalances = 5;
GameRound.TimeLeft = 0;

GameRound.MessageTip = "STAY INSIDE THE HILL LONGER THAN THE REST OF THE DUCKS TO GET POINTS!"

GameRound.Finished = Signal.new();

GameRound.Cooldowns = {};

GameRound.PlayerOnHill = {};
GameRound.HillStats = {};

GameRound.LocationA = nil;
GameRound.LocationB = nil;
GameRound.LocationC = nil;

----- Public Methods -----

function GameRound:AddDuck(player)
    if player then
        GameService = Knit.GetService("GameService");
        CollectionService:AddTag(player, Knit.Config.DUCK_TAG);
        CollectionService:AddTag(player, Knit.Config.BREAD_TAG);
        --self.Hill[#self.Hill + 1] = {Player = player, Time = 0};
        if not self.HillStats[player] then  
            self.HillStats[player] = 0;
        end
        player.TeamColor = BrickColor.new("Dark blue")
        GameService.Client.DisplayLobbyUI:Fire(player, false, false)
    end
end

function GameRound:StartTracking()
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.DUCK_TAG)) do
        if player then
            task.spawn(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = 16;
                        player.Character.Humanoid.JumpPower = 25;
                    end
                    player.Character.HumanoidRootPart.Anchored = false;
                    GameService:CreateBreadTool(player);
                    task.spawn(function()
                        GameService:GetPlayerTracked(player):StartCountingMillisecondsPlayed(player);
                    end)
                end
            end)
        end
    end
end

function GameRound:TeleportDucks(SpawnLocations) --[TABLE]
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.DUCK_TAG)) do
        --print("[TELEPORTING DUCK_TAG]", "Player:", player, "Num of players:", #CollectionService:GetTagged(Knit.Config.DUCK_TAG))
        task.spawn(function()
            local SelectedSpawn = SpawnLocations[math.random(1, #SpawnLocations)];
            player.RespawnLocation = SelectedSpawn;
            if player.Character then
                if player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.Humanoid.WalkSpeed = 0;
                    player.Character.Humanoid.JumpPower = 0;
                    player.Character.HumanoidRootPart.Anchored = true;
                    player.Character:SetPrimaryPartCFrame((SelectedSpawn.CFrame * CFrame.new(Vector3.new(math.random(-5,5),1,math.random(-5,5)))) +
                        Vector3.new(0,2,0));
                end
            end
        end)
    end
end

function GameRound:GetSpawnLocations()
    local AllSpawns = {}

    table.insert(AllSpawns, self.duckSpawn)

    for _, Checkpoint in pairs(self.Map:FindFirstChild("Spawns"):GetChildren()) do
        if Checkpoint then
            table.insert(AllSpawns, Checkpoint)
        end
    end

    return AllSpawns;
end

function GameRound:CleanUp(player)
    if player then
        CollectionService:RemoveTag(player, Knit.Config.DUCK_TAG);
        CollectionService:RemoveTag(player, Knit.Config.HILL_TAG);
        CollectionService:RemoveTag(player, Knit.Config.BREAD_TAG);
        GameService.Client.UpdatePotatoText:Fire(player, false)
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
end

-- KOTH Methods

GameRound.HillInProgress = false;

function GameRound.Find(tbl,val)
    for i, v in pairs(tbl) do
        if v == val then
            return i;
        end;
    end;
    return nil;
end;

function GameRound:StartHill(hill)
    -- This constructs a zone based upon a group of parts in Workspace and listens for when a player enters and exits this group
    -- There are also the ``zone.localPlayerEntered`` and ``zone.localPlayerExited`` events for when you wish to listen to only the local player on the client
    local container = hill
    local zone = Zone.new(container)

    self.PlayerOnHill = {};
    self.PlayerCFrame = {};

    zone.playerEntered:Connect(function(player)
        --print(("%s entered the zone!"):format(player.Name))
        CollectionService:AddTag(player, Knit.Config.HILL_TAG);
    end)

    zone.playerExited:Connect(function(player)
        --print(("%s exited the zone!"):format(player.Name))
        CollectionService:RemoveTag(player, Knit.Config.HILL_TAG);
    end)

    self.HillInProgress = true;
    self.PrevLocation = self.LocationB;
    self.HillSeconds = 0;

    task.spawn(function()
        while self.HillInProgress == true do
            if self.HillSeconds >= (self.MaxTime / self.HillRebalances) then
                self.HillSeconds = 0;
                local Locations = {self.LocationA,self.LocationB,self.LocationC}
                if table.find(Locations, self.PrevLocation) then
                    table.remove(Locations,table.find(Locations, self.PrevLocation));
                end

                local SelectedLocation = Locations[math.random(1, #Locations)];
                self.PrevLocation = SelectedLocation;

                TweenService:Create(hill, TweenInfo.new(8),{
                    CFrame = SelectedLocation,
                }):Play()
            end


            for _, player in pairs(CollectionService:GetTagged(Knit.Config.HILL_TAG)) do 
                if not self.HillStats[player] then  
                    self.HillStats[player] = 0;
                end

                if not self.PlayerCFrame[player] then
                    self.PlayerCFrame[player] = {CFrame = nil, Count = 0}
                end

                if self.PlayerCFrame[player].Count <= 1 then
                    self.HillStats[player] += 1;
                end
                
                if player.Character.PrimaryPart then
                    if self.PlayerCFrame[player].CFrame == nil then
                        self.PlayerCFrame[player] = {CFrame = player.Character.PrimaryPart.CFrame, Count = 1}
                    elseif player.Character.PrimaryPart.CFrame ~= self.PlayerCFrame[player].CFrame then
                        self.PlayerCFrame[player] = {CFrame = player.Character.PrimaryPart.CFrame, Count = 1}
                    else
                        self.PlayerCFrame[player] = {CFrame = player.Character.PrimaryPart.CFrame, Count = self.PlayerCFrame[player].Count + 1}
                        if self.PlayerCFrame[player].Count > 1 then
                            player:LoadCharacter();
                            --[[local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid");
                            if humanoid then
                                repeat
                                    humanoid.Health = -1;
                                    task.wait(0.5)
                                until humanoid.Health == -1 or humanoid == nil;
                            end]]
                            self.PlayerCFrame[player] = {CFrame = player.Character.PrimaryPart.CFrame, Count = 1}
                        end
                    end
                    --print(self.PlayerCFrame[player], self.PlayerCFrame[player].Count)
                end
                
                --print(player, self.HillStats[player])
                for _, v in pairs(workspace.Lobby.NameTags:GetChildren()) do
                    if v:GetAttribute("Player") then
                        if v:GetAttribute("Player") == player.UserId then
                            v.NUM.Text = tostring(self.HillStats[player])
                        end
                    end
                end
            end

            local winner;
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr then
                    if self.HillStats[plr] then
                        if self.HillStats[plr] == 0 then
                            continue;
                        end
                        if not winner then winner = plr end
                        if self.HillStats[plr] > self.HillStats[winner] then
                            winner = plr
                        end
                    end
                end
            end

            if winner then
                if winner.Character then
                    if not winner.Character:FindFirstChild("KOTHCrown") then
                        for _, player in pairs(game.Players:GetPlayers()) do
                            if player and player.Character then
                                if player.Character:FindFirstChild("KOTHCrown") then
                                    player.Character:FindFirstChild("KOTHCrown"):Destroy();
                                end
                            end
                        end
                        local Crown = ReplicatedStorage.Assets.GameObjects:FindFirstChild("KOTHCrown"):Clone()
                        local CrownClone = Crown:Clone()
                        if CrownClone and winner.Character and winner.Character.PrimaryPart then
                            CrownClone.Position = winner.Character.PrimaryPart.Position + Vector3.new(0,4,0);
                            CrownClone.WeldConstraint.Part0 = winner.Character.PrimaryPart
                            CrownClone.Parent = winner.Character;
                        end
                    end
                end
            end
            self.HillSeconds += 1;
            task.wait(1)
        end
    end)
end

----- Game Round & Main Methods -----
function GameRound.new(length, gameMode, mapName)
    print("[GameRound][KOTH]: Classic round created")
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

        local MapLocation = Knit.ServerModules.HotPotatoMaps:FindFirstChild(tostring(SelectedMap))

        if MapLocation == nil then
            SelectedMap = "Tropical";
            MapLocation = Knit.ServerModules.HotPotatoMaps:FindFirstChild(tostring(SelectedMap));
        end

        if MapLocation then
            print("[GameRound][KOTH]: Map selected")
            local MapModule = require(MapLocation);

            local MapInfo = MapModule:Init();

            self.Map = MapInfo[1];
            self.lobbySpawn, self.duckSpawn = MapInfo[2], MapInfo[3];
            self.endPoint = MapInfo[5];

            self.MaxTime = length;
            self.TimeLeft = length;
            self.InProgress = true;

            self.CutsceneInProgress = true;

            self.HillStats = {};

            for _,v in ipairs(self.Map:GetChildren()) do
                if v.Name == "KOTH" then
                    for _, k in ipairs(v:GetChildren()) do
                        if k.Name ~= "Indicator" then
                            k:Destroy();
                        end
                    end
                elseif v.Name == "Domination" then
                    self.LocationA = v.Indicator1.CFrame;
                    self.LocationB = v.Indicator2.CFrame;
                    self.LocationC = v.Indicator3.CFrame;
                    v:Destroy()
                end
            end

            print("[GameRound][KOTH]: Adding ducks")
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
                    if Character:FindFirstChild("KillerTag") then
                        local KillerPlayer = Character:FindFirstChild("KillerTag").Value;
                        GameService:KillCam(player, KillerPlayer)
                    end
                end))

                self._maid:GiveTask(player.CharacterAdded:Connect(function(char)
                    repeat task.wait(0) until char
                    char.PrimaryPart.Anchored = true;

                    local newSpawnLocation = self:GetSpawnLocations()[math.random(1, #self:GetSpawnLocations())]

                    char:SetPrimaryPartCFrame(newSpawnLocation.CFrame * CFrame.new(Vector3.new(math.random(-3,3),1,math.random(-3,3))) +
                    Vector3.new(0,2.5,0));
                    char.PrimaryPart.Anchored = false;
                    local humanoid = char:WaitForChild("Humanoid")

                    for _, v in pairs(workspace.Lobby.NameTags:GetChildren()) do
                        if v:GetAttribute("Player") then
                            if v:GetAttribute("Player") == player.UserId then
                                v.Adornee = char.PrimaryPart
                            end
                        end
                    end

                    self._maid:GiveTask(humanoid.Running:Connect(function()
                        if CollectionService:HasTag(player, Knit.Config.IDLE_TAG) == true then
                            CollectionService:RemoveTag(player, Knit.Config.IDLE_TAG)
                        end
                    end))

                    self._maid:GiveTask(humanoid.Died:Connect(function()
                        GameService:GetPlayerTracked(player):AddDeath(player)
                        if char:FindFirstChild("KillerTag") then
                            local KillerPlayer = char:FindFirstChild("KillerTag").Value;
                            GameService:KillCam(player, KillerPlayer)
                        end
                    end))
                end))
            end

            print("[GameRound][KOTH]: Checking if current map exists if not then wait")
            repeat task.wait(0.5) until #workspace.CurrentMap:GetChildren() > 0
            print("[GameRound][KOTH]: Found map, starting music and game")
            --// NOTE: Gets music and sound effects for map
            local musicDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).Intro; -- AudioMusic:FindFirstChild(tostring(self.Map)).Background 
            local effectDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).SoundEffects;

            --// NOTE: Starts cutscene for map
            CutsceneService:CutsceneIntro(self.Map, gameMode);
            repeat task.wait(0) until #CollectionService:GetTagged(Knit.Config.CUTSCENE_TAG) > 0;
            --// NOTE: Do duck teleport to their spawn location
            task.wait(2)
            print("[GameRound][KOTH]: Teleporting ducks to the map")
            self:TeleportDucks(self:GetSpawnLocations())

            --// NOTE: Sets clients lighting for game
            task.spawn(function()
                task.wait(3)
                local SystemInfo = require(Knit.ReplicatedAssets.SystemInfo);
                local convertToHotPotato = SystemInfo.getHotPotatoKeyFromName(tostring(SelectedMap));
                if convertToHotPotato == nil then convertToHotPotato = "Lobby" end
                GameService:SetLighting(convertToHotPotato);
            end)
            
            task.wait(8);
            --// NOTE: Play music and sound effects for map
            AudioService:StartMusic(musicDirectory);
            AudioService:StartSoundPackage(effectDirectory);

            --// NOTE: Starts cutscene for map
            print("[GameRound][KOTH]: Starting cutscene for players")
            
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
                local NumUIClone = NumUI:Clone()
                if player.Character and player.Character.PrimaryPart then
                    NumUIClone:SetAttribute("Player", player.UserId)
                    NumUIClone.Adornee = player.Character.PrimaryPart
                    NumUIClone.Parent = workspace.Lobby.NameTags
                end
            end
            AudioService:StartMusic(musicDirectory);
            self:Update(gameMode);
        else
            warn("[GameRound][KOTH]: Map module not found!");
            self.Finished:Fire();
        end
    else
        warn("[GameRound][KOTH]: There no more maps");
        self.Finished:Fire();
    end

    return self;
end

function GameRound:Update(gameMode)
    print("[GameRound][KOTH]: Updating game now")
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

    print("[GameRound][KOTH]: Starting to track players")
    self:StartTracking();
    self:StartHill(self.Map.KOTH.Indicator)

    print("[GameRound][KOTH]: Starting timer")
    for timeLeft = self.TimeLeft, 0, -1 do
        GameService.Client.TimeLeftSignal:FireAll(timeLeft, gameMode)
        if #CollectionService:GetTagged(Knit.Config.DUCK_TAG) <= 1 and not SinglePlayer then
            break;
        end
        if #CollectionService:GetTagged(Knit.Config.DUCK_TAG) == 0 and SinglePlayer then
            break;
        end
        if self.InProgress == false then
            break;
        end
        task.wait(1);
    end

    self.HillInProgress = false;
    print("[GameRound][KOTH]: Timer ended, evaluating player")
    local PlayerTimes = {};
    --// Stop time for all players
    for player, point in next, self.HillStats do
        GameService:GetPlayerTracked(player):GetPlayerStats(player).TimeElapsedOnHill = tonumber(point);
        table.insert(PlayerTimes, {Player = player, TimeElapsed = point})
    end

    if #PlayerTimes > 0 then
        table.sort(PlayerTimes, function(a, b)
            return a.TimeElapsed > b.TimeElapsed
        end);
    end
    
    --// Evaluate player ranks
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
        MapProgessService:UpdateCharSelectUI("");
        task.spawn(function()
            for index, data in pairs(PlayerTimes) do
                if data.Player == player then
                    local PlayerRank = index
                    if tonumber(index) == 1 then
                        CollectionService:AddTag(data.Player, Knit.Config.WINNER_TAG);
                        GameService:GetPlayerTracked(data.Player):GetPlayerStats(data.Player).WinRound = true;
                    end
                    GameService:GetPlayerTracked(player):GetPlayerStats(player).YourRank = tonumber(PlayerRank);
                end
            end
        end)
        task.wait(0.02)
    end

    print("[GameRound][KOTH]: Classic round ended")
    MapProgessService:TimerEnd();
    MapProgessService:ProgressEnd();
    AudioService:StopMusic(musicDirectory);
    AudioService:StopSoundPackage(effectDirectory);
    self.Finished:Fire();
end

function GameRound:Destroy()
    self._maid:Destroy();

    MapProgress:ClearFinished()

    GameService = Knit.GetService("GameService"); 

    for _, ui in pairs(workspace.Lobby.NameTags:GetChildren()) do
        if ui:IsA("BillboardGui") and ui.Name == "NUM_UI" then
            ui:Destroy();
        end
    end

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