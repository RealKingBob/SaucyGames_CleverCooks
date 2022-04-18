local Lobby = {};
local MapSettings = require(script.Parent.Parent.Settings.MapSettings)
local Environment = require(script.Environment);

Lobby.IsPlaying = false;


function Lobby:Init()
    if Lobby.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Lobby:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Lobby:Stop()

end

return Lobby;