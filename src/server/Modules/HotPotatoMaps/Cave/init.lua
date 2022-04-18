local Cave = {};
local Environment = require(script.Environment);

Cave.IsPlaying = false;

function Cave:Init()
    if Cave.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Cave:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Cave:Stop()

end

return Cave;