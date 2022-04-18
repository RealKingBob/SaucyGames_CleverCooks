--// Serversided Environmental Program
local Environment = {};

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local MapSettings = require(Knit.ServerModules.Settings.MapSettings)

function Environment:SetLighting()
    local Lighting = game:GetService("Lighting");
    local LightingInfo = MapSettings.WipePotato.Lighting;
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
    local MapObject = ServerStorage.HotPotatoMaps["Wipeout"];
    print("[Winterland/Environment]:","Setting Up Map!");
    if CurrentMap then
        CurrentMap:ClearAllChildren();
    end

    local MapClone = MapObject:Clone();

    --// Islands Sections
    MapClone.Parent = CurrentMap;

    if workspace:FindFirstChild("Baseplate") then
        workspace.Baseplate:Destroy();
    end

    local CollectionService = game:GetService("CollectionService")
    for _, v in pairs(CollectionService:GetTagged("Bounce")) do
        if v:IsA("Model") then
            v.PrimaryPart.Touched:Connect(function(hit)
                local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
                if humanoid and not humanoid.Parent:FindFirstChildWhichIsA("BodyVelocity") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "Bounce"
                    bv.Parent = humanoid.Parent.PrimaryPart
                    bv.MaxForce = Vector3.new(50000000000,50000000000,50000000000)
                    bv.Velocity = humanoid.Parent.PrimaryPart.CFrame.upVector * 50
                    task.wait(.15)
                    bv:Destroy()
                end
            end)
        end
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
    workspace.Lobby.Spawns.Locations.Spawn, Map.Spawns.SpawnLocation, nil,
    nil};
end

return Environment;