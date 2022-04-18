local Wipeout = {};
local Environment = require(script.Environment);

Wipeout.IsPlaying = false;

function Wipeout:Init()
    if Wipeout.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Wipeout:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Wipeout:Stop()

end

return Wipeout;