local Jungle = {};
local Environment = require(script.Environment);

Jungle.IsPlaying = false;

function Jungle:Init()
    if Jungle.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Jungle:Stop()
    end
    
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Jungle:Stop()

end

return Jungle;