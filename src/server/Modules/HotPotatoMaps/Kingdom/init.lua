local Kingdom = {};
local Environment = require(script.Environment);

Kingdom.IsPlaying = false;

function Kingdom:Init()
    if Kingdom.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Kingdom:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Kingdom:Stop()

end

return Kingdom;