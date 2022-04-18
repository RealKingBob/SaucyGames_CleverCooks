--// Serversided Environmental Program
local Environment = {};

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local MapSettings = require(Knit.ServerModules.Settings.MapSettings)

function Environment:SetLighting()
    local Lighting = game:GetService("Lighting");
    local LightingInfo = MapSettings.Lobby.Lighting;
    print("[Lobby/Environment]:","Setting Up Lighting!")
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
end

return Environment;