--// Serversided Environmental Program
local Environment = {};

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local MapSettings = require(Knit.ServerModules.Settings.MapSettings)

function Environment:SetLighting()
    local Lighting = game:GetService("Lighting");
    local LightingInfo = MapSettings.Tropical.Lighting;
    print("[Candyland/Environment]:","Setting Up Lighting!")
    if workspace.Terrain:FindFirstChild("Clouds") then
        workspace.Terrain:FindFirstChild("Clouds"):Destroy()
    end
    Lighting:ClearAllChildren()
    for k, v in pairs(LightingInfo) do
        if tostring(k):match("Sky") or 
            tostring(k):match("Clouds") or 
            tostring(k):match("Effect") or 
            tostring(k):match("Atmosphere")
            then
            local newEffect = Instance.new(tostring(k));
            newEffect.Name = tostring(k);
            for a,b in pairs(v) do
                newEffect[a] = b;
            end
            continue;
        end
        
        Lighting[k] = v;
    end
end

function Environment:SetMap()
    local ServerStorage = game:GetService("ServerStorage");
    local CurrentMap = workspace.CurrentMap;
    local MapObject = ServerStorage.Maps["Tropical"];
    print("[".. script.Parent:GetFullName() .."]:","Setting Up Map!");
    if CurrentMap then
        CurrentMap:ClearAllChildren();
    end

    local MapClone = MapObject:Clone();

    --// Islands Sections
    local MainSection = {"Stage 4 (SHIPWRECK)", "Stage 4 (SKULL FORTRESS)", "Stage 4 (VOLCANO)"};

    --// Selecting Sections

    local ranNum1 = math.random(1, #MainSection)
    local SelectMainSection = MainSection[ranNum1];
    table.remove(MainSection, ranNum1)
    --TableUtil.SwapRemoveFirstValue(MainSection,SelectMainSection);
    local ranNum2 = math.random(1, #MainSection)
    local SelectBackground1 = MainSection[ranNum2];
    table.remove(MainSection, ranNum2)
    --TableUtil.SwapRemoveFirstValue(MainSection,SelectBackground1);
    local ranNum3 = math.random(1, #MainSection)
    local SelectBackground2 = MainSection[ranNum3];
    

    print(SelectMainSection,SelectBackground1,SelectBackground2)

    for _,v in pairs(MapClone.Map.MainStage:GetChildren()) do
        if v:IsA("Folder") then
            if v.Name ~= tostring(SelectMainSection) then
                v:Destroy()
            end
        end
    end

    for _,v in pairs(MapClone.Map.MainStage:GetChildren()) do
        if v:IsA("Folder") then
            if v.Name == "Stage 4 (SHIPWRECK)" then
                local trapFolder = v:FindFirstChild("Trap")
                for _, krakenArm in pairs(trapFolder:GetChildren()) do
                    task.spawn(function()
                        repeat task.wait(0) until MapClone.Parent == CurrentMap
                        task.wait(math.random(0.1,2))
                        if krakenArm:IsA("Model") and krakenArm.Name == "Tentacle" then
                            print(krakenArm, krakenArm:GetChildren())
                            local Controller = krakenArm:WaitForChild("AnimationController")
                
                            local animationTrack = Controller:LoadAnimation(trapFolder.SwimAnimation)
                            animationTrack.Looped = true
                            animationTrack:Play()
                        end
                    end)
                end
            elseif v.Name == "Stage 4 (VOLCANO)" then
                local trapFolder = v:FindFirstChild("Trap")
            elseif v.Name == "Stage 4 (SKULL FORTRESS)" then
                local trapFolder = v:FindFirstChild("Trap")
                task.spawn(function()
                    repeat task.wait(0) until MapClone.Parent == CurrentMap
                    task.wait(1)
                    if not v:IsA("Folder") then
                        v.Touched:Connect(function(hit)
                            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid.Health = -1
                            end
                        end)
                    end
                    
                end)
            end
        end
    end

    for _,v in pairs(MapClone.Map.Background1:GetChildren()) do
        if v:IsA("Folder") then
            if v.Name ~= tostring(SelectBackground1) then
                v:Destroy()
            end
        end
    end

    for _,v in pairs(MapClone.Map.Background2:GetChildren()) do
        if v:IsA("Folder") then
            if v.Name ~= tostring(SelectBackground2) then
                v:Destroy()
            end
        end
    end

    --[[for _, target in pairs(MapClone.Map:GetDescendants()) do
        if CollectionService:HasTag(target, "Target") then
            Target.new(target, target:GetAttribute("Trap"))
        end
    end]]

    MapClone.Parent = CurrentMap;

    if workspace:FindFirstChild("Baseplate") then
        workspace.Baseplate:Destroy();
    end

    return MapClone;
end

function Environment:ClientEnvironment(MapObject)
    local CurrentMap = workspace.CurrentMap;
    local GameService = Knit.GetService("GameService")

    if CurrentMap and MapObject then
        print("[".. script.Parent:GetFullName() .."]:","Connecting Client's Environment!");
        for _, player in pairs(game.Players:GetPlayers()) do
            GameService.Client.SetEnvironmentSignal:Fire(player, MapObject)
        end
    end
end

function Environment:Init()
    --self:SetLighting()
    local Map = self:SetMap();
    task.wait(0.2)
    self:ClientEnvironment(Map);
    return {Map, 
    workspace.Lobby.Spawns.Locations.Spawn, Map.Spawns.Spawn, Map.HunterSpawn.Spawn,
    Map.EndPoint.Teleport.PrimaryPart};
end

return Environment;