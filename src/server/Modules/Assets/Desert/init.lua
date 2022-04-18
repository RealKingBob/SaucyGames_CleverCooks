local Desert = {};
local Environment = require(script.Environment);

Desert.IsPlaying = false;

function Desert:Init()
    if Desert.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Desert:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Desert:Stop()

end

return Desert;