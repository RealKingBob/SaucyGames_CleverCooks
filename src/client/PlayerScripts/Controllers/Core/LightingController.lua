local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LightingController = Knit.CreateController { Name = "LightingController" }

function LightingController:GetLighting()
    local GameService = Knit.GetService("GameService")
    GameService:GetLighting():andThen(function(lightingData) -- When initialized complete, request inventory data
        return lightingData
    end)
end

function LightingController:SetLighting(lightingData)
    --print("lightingData:", lightingData)
    local Lighting = game:GetService("Lighting");
    local LightingInfo = lightingData
    --print("[Environment]:","Setting Up Lighting!", lightingData)
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


function LightingController:KnitStart()
    --[[GameService:GetLighting():andThen(function(lightingData) -- When initialized complete, request lighting data
        self:SetLighting(lightingData)
    end)]]
end


function LightingController:KnitInit()
    
end


return LightingController
