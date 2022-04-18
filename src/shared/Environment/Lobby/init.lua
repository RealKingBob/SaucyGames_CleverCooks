--// Covers clients side of environment
local Lobby = {};


function Lobby:SetClientEnvironment(MapObject)
    if MapObject then
        print("[Client]: Setting Environment")
    end
end

return Lobby;