--[[
    Name: Hot Potato Round [V2]
    By: Real_KingBob
    Created: 12/10/21 
    Updated: 1/31/21
    Description: This module handles the hot potato round game mode
]]

----- Services -----
local Players = game:GetService("Players");
local CollectionService = game:GetService("CollectionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit);
local Maid = require(Knit.Util.Maid);
local Signal = require(Knit.Util.Signal);
local MapProgress = require(script.Parent.Parent.MapProgress)

----- Variables -----
local LibraryAudios = ReplicatedStorage:WaitForChild("Audios");
local AudioMusic = LibraryAudios:WaitForChild("Music");
local DotUI = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("DOT_UI");

local SinglePlayer = Knit.Config.SINGLE_PLAYER;

local GameService, CutsceneService, MapProgessService, AudioService;

----- Game Round -----
local GameRound = {};
local TimeTracked = {};
GameRound.__index = GameRound;

GameRound.Map = nil;

GameRound.duckSpawn = nil;
GameRound.lobbySpawn = nil;
GameRound.endPoint = nil;

GameRound.CutsceneInProgress = false;
GameRound.InProgress = false;
GameRound.NumOfRebalances = 5;
GameRound.TimeLeft = 0;
GameRound.MaxFate = 45;

GameRound.MessageTip = "PASS THE POTATO AROUND AND AVOID HAVING IT, LONGEST TO LIVE WINS!"

GameRound.Finished = Signal.new();

GameRound.Cooldowns = {};
GameRound.ActivePotatoes = {};

----- Public Methods -----

function GameRound:AddDuck(player)
    if player then
        GameService = Knit.GetService("GameService");
        CollectionService:AddTag(player, Knit.Config.NO_POTATO_TAG);
        CollectionService:AddTag(player, Knit.Config.DUCK_TAG);
        player.TeamColor = BrickColor.new("Dark blue")
        GameService.Client.UpdatePotatoText:Fire(player, false)
        GameService.Client.DisplayLobbyUI:Fire(player, false, false)
    end
end

function GameRound:StartTracking()
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.DUCK_TAG)) do
        if player then
            task.spawn(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if CollectionService:HasTag(player, Knit.Config.POTATO_TAG) then
                        player.Character.Humanoid.WalkSpeed = 32;
                        player.Character.Humanoid.JumpPower = 40;
                    else
                        player.Character.Humanoid.WalkSpeed = 16;
                        player.Character.Humanoid.JumpPower = 25;
                    end
                    player.Character.HumanoidRootPart.Anchored = false;
                    task.spawn(function()
                        TimeTracked[player] = tick();
                        --GameService:GetPlayerTracked(player):StartCountingMillisecondsPlayed(player);
                    end)
                end
            end)
        end
    end
end

function GameRound:TeleportDucks(SpawnLocations) --[TABLE]
    if SpawnLocations then
        for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.DUCK_TAG)) do
            --print("[TELEPORTING DUCK_TAG]", "Player:", player, "Num of players:", #CollectionService:GetTagged(Knit.Config.DUCK_TAG))
            task.spawn(function()
                local SelectedSpawn = SpawnLocations[math.random(1, #SpawnLocations)];
                player.RespawnLocation = SelectedSpawn;
                if player.Character
                and player.Character:FindFirstChild("Humanoid")
                and player.Character:FindFirstChild("HumanoidRootPart")
                then
                    player.Character.Humanoid.WalkSpeed = 0;
                    player.Character.Humanoid.JumpPower = 0;
                    player.Character.HumanoidRootPart.Anchored = true;
                    player.Character:SetPrimaryPartCFrame((SelectedSpawn.CFrame * CFrame.new(Vector3.new(math.random(-5,5),1,math.random(-5,5)))) +
                        Vector3.new(0,2,0));
                end
            end)
        end
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
        CollectionService:RemoveTag(player, Knit.Config.HUNTER_TAG);
        CollectionService:RemoveTag(player, Knit.Config.DUCK_TAG);
        CollectionService:RemoveTag(player, Knit.Config.POTATO_TAG);
        CollectionService:RemoveTag(player, Knit.Config.NO_POTATO_TAG);
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

----- Potato Methods -----

function GameRound:CalculateNumOfPotatos()
    local NumOfPlayers = #CollectionService:GetTagged(Knit.Config.ALIVE_TAG);
    local NumOfPotatos = math.floor(NumOfPlayers / 10);
    return (0 == NumOfPotatos and 1) or NumOfPotatos + 1;
end

function GameRound:BalancePotatoes()
    self:DestroyAllPotatoes();
    local calculatedPotatoes = math.floor(#CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG)/2) > 0 and math.floor(#CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG)/2) or 1
    self:PickPotatos(calculatedPotatoes);
end

function GameRound:PickPotatos(NumOfPlayers)
    if NumOfPlayers == 0 then return end
    if #CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG) < NumOfPlayers and not SinglePlayer then return end
    if #CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG) <= #CollectionService:GetTagged(Knit.Config.POTATO_TAG) then return end
    if #CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG) > 0 then
        local RandomPlayer = CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG)[math.random(1, #CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG))]; --// Selects random player
        if CollectionService:HasTag(RandomPlayer,Knit.Config.POTATO_TAG) then
            return self:PickPotatos(NumOfPlayers);
        else
            if RandomPlayer.Character:FindFirstChild("Humanoid") then
                RandomPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = 32
                RandomPlayer.Character:FindFirstChild("Humanoid").JumpPower = 40
            end
            local Potato = self:CreatePotato();
            self:PassPotato(Potato, RandomPlayer);
            return self:PickPotatos(NumOfPlayers - 1);
        end
    else
        return
    end
end

function GameRound:PassPotato(potato, player)
    --print("PassPotato",potato, player)
    if potato and player then
        local Character = player.Character
        if CollectionService:HasTag(player, Knit.Config.POTATO_TAG) then
            --warn(player.Name.." has potato already!")
            return;
        end
        CollectionService:AddTag(player, Knit.Config.POTATO_TAG)
        GameService.Client.UpdatePotatoText:Fire(player, true)
        if potato.Parent ~= nil then
            local formerPlayer = Players:GetPlayerFromCharacter(potato.Parent)
            if formerPlayer.Character:FindFirstChild("Humanoid") then
                formerPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = 16
                formerPlayer.Character:FindFirstChild("Humanoid").JumpPower = 25
            end
            if formerPlayer then
                GameService.Client.UpdatePotatoText:Fire(formerPlayer, false)
                task.spawn(function()
                    task.wait(1)
                    CollectionService:RemoveTag(formerPlayer, Knit.Config.POTATO_TAG)
                end)
            end
        end 
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            potato.Parent = Character
            local motor6D = potato:FindFirstChildWhichIsA("Motor6D");
            motor6D.Part1 = Character:FindFirstChild("HumanoidRootPart");
            if Character:FindFirstChild("Humanoid") then
                Character:FindFirstChild("Humanoid").WalkSpeed = 32
                Character:FindFirstChild("Humanoid").JumpPower = 40
            end
        end
    end
end

function GameRound:CreatePotato()
    local DuckModels = ReplicatedStorage:WaitForChild("Assets").DuckModels
    if DuckModels:FindFirstChild("PotatoC4") then
        for _, accessory in pairs(DuckModels:FindFirstChild("PotatoC4"):GetChildren()) do
            if accessory:IsA("MeshPart") and accessory.Name ~= "Sphere" and accessory.Name ~= "DuckV2" and accessory.Name ~= "RootPart" then
                local accessoryClone =  accessory:Clone()
                accessoryClone.Name = "PotatoC4"
                local motor6D = accessoryClone:FindFirstChildWhichIsA("Motor6D");
                motor6D.Part1 = nil; --player.Character:FindFirstChild("HumanoidRootPart")
                motor6D.Part0 = accessoryClone;
                motor6D.Parent = accessoryClone;
                accessoryClone.Parent = nil;
                table.insert(self.ActivePotatoes, accessoryClone);
                return accessoryClone;
            end
        end
    end
end

function GameRound:DestroyPotato(potato)
    if potato then
        potato:Destroy()
    end
end

function GameRound:DestroyAllPotatoes()
    for _, player in pairs(CollectionService:GetTagged(Knit.Config.POTATO_TAG)) do
        CollectionService:RemoveTag(player,Knit.Config.POTATO_TAG)
        if player.Character:FindFirstChild("Humanoid") then
            player.Character:FindFirstChild("Humanoid").WalkSpeed = 16
            player.Character:FindFirstChild("Humanoid").JumpPower = 25
        end
    end
    for _, potato in ipairs(self.ActivePotatoes) do
        if potato then
            potato:Destroy()
        end
    end
    self.ActivePotatoes = {};
end

----- Game Round & Main Methods -----
function GameRound.new(length, gameMode, mapName)
    print("[GameRound][POTATO]: Classic round created")
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
            print("[GameRound][POTATO]: Map selected")
            local MapModule = require(MapLocation);

            local MapInfo = MapModule:Init();

            self.Map = MapInfo[1];
            self.lobbySpawn, self.duckSpawn = MapInfo[2], MapInfo[3];
            self.endPoint = MapInfo[5];

            self.TimeLeft = length;
            self.InProgress = true;

            self.CutsceneInProgress = true;

            for _,v in ipairs(self.Map:GetChildren()) do
                if v.Name == "KOTH" then
                    for _, k in ipairs(v:GetChildren()) do
                        if k.Name == "Indicator" then
                            k:Destroy();
                        end
                    end
                elseif v.Name == "Domination" then
                    v:Destroy()
                end
            end
            print("[GameRound][POTATO]: Adding ducks")
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
                self._maid:GiveTask(humanoid.Died:Connect(function()
                    GameService:GetPlayerTracked(player):AddDeath(player)
                end))

                self._maid:GiveTask(player.CharacterRemoving:Connect(function()     
                    if self.InProgress == true then
                        if CollectionService:HasTag(player, Knit.Config.POTATO_TAG) == true then
                            self:PickPotatos(1);
                        end
                    end
                    CollectionService:AddTag(player, Knit.Config.LOBBY_TAG);
                    CollectionService:RemoveTag(player, Knit.Config.POTATO_TAG);
                    CollectionService:RemoveTag(player, Knit.Config.DUCK_TAG);
                    CollectionService:RemoveTag(player, Knit.Config.NO_POTATO_TAG);
                    if TimeTracked[player] ~= nil then
                        GameService:GetPlayerTracked(player):GetPlayerStats(player).TimeElapsed = tick() - TimeTracked[player]
                        TimeTracked[player] = nil
                    end
                    --GameService:GetPlayerTracked(player):StopCountingSecondsPlayed(player)
                    GameService.Client.UpdatePotatoText:Fire(player, false)
                    GameService.Client.DisplayLobbyUI:Fire(player, true, true)
                    player.RespawnLocation = self.lobbySpawn;
                end))
            end
            print("[GameRound][POTATO]: Checking if current map exists if not then wait")
            repeat task.wait(0.5) until #workspace.CurrentMap:GetChildren() > 0
            print("[GameRound][POTATO]: Found map, starting music and game")
            --// NOTE: Gets music and sound effects for map
            local musicDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).Intro; -- AudioMusic:FindFirstChild(tostring(self.Map)).Background 
            local effectDirectory = AudioMusic:FindFirstChild(tostring(self.Map)).SoundEffects;

            --// NOTE: Starts cutscene for map
            CutsceneService:CutsceneIntro(self.Map, gameMode);

            --// NOTE: Do duck teleport to their spawn location
            task.wait(2)
            print("[GameRound][POTATO]: Teleporting duckS to the map")
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
            print("[GameRound][POTATO]: Starting cutscene for players")
            
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
                local DotUIClone = DotUI:Clone()
                if player.Character and player.Character:FindFirstChild("Head") then
                    DotUIClone.Adornee = player.Character.Head
                    DotUIClone.PlayerToHideFrom = player
                    DotUIClone.Parent = workspace.Lobby.NameTags
                end
            end
            AudioService:StartMusic(musicDirectory);
            self:Update(gameMode);
        else
            warn("[GameRound][POTATO]: Map module not found!");
            self.Finished:Fire();
        end
    else
        warn("[GameRound][POTATO]: There no more maps");
        self.Finished:Fire();
    end

    return self;
end

function GameRound:Update(gameMode)
    print("[GameRound][POTATO]: Updating game now")
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

    local NumOfPotatos = self:CalculateNumOfPotatos() --// Calculate number of potatoes there should be for this round

    self:PickPotatos(NumOfPotatos);
    print("[GameRound][POTATO]: Starting to track players")
    self:StartTracking();

    local Rebalanced = false;
    print("[GameRound][POTATO]: Starting timer")
    for timeLeft = self.TimeLeft, 0, -1 do
        GameService.Client.TimeLeftSignal:FireAll(timeLeft, gameMode)
        if #CollectionService:GetTagged(Knit.Config.DUCK_TAG) <= 1 and not SinglePlayer then
            break;
        end
        if (#CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG) <= math.floor(Players.MaxPlayers / 10)) 
        and Rebalanced == false then
            Rebalanced = true
            self:BalancePotatoes()
            GameRound.NumOfRebalances -= 1;
        end
        if #CollectionService:GetTagged(Knit.Config.DUCK_TAG) == 0 and SinglePlayer then
            break;
        end
        if self.InProgress == false then
            break;
        end
        task.wait(1);
    end

    print("[GameRound][POTATO]: Timer ended, evaluating player")
    local PlayerTimes = {};
    --// Stop time for all players
    for _, player : Player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
        if TimeTracked[player] ~= nil then
            GameService:GetPlayerTracked(player):GetPlayerStats(player).TimeElapsed = tick() - TimeTracked[player]
            TimeTracked[player] = nil
        end
        --GameService:GetPlayerTracked(player):StopCountingSecondsPlayed(player);
        local timeElapsed = GameService:GetPlayerTracked(player):GetPlayerStats(player).TimeElapsed;
        table.insert(PlayerTimes, {Player = player, TimeElapsed = timeElapsed})
    end

    if #PlayerTimes > 0 then
        table.sort(PlayerTimes, function(a, b)
            return a.TimeElapsed > b.TimeElapsed
        end);
    end
    
    --// Evaluate player times
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

    print("[GameRound][POTATO]: Classic round ended")
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
        if ui:IsA("BillboardGui") and ui.Name == "DOT_UI" then
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