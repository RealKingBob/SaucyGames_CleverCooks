local TropicalIsland = {};
local Environment = require(script.Environment);

TropicalIsland.IsPlaying = false;

function TropicalIsland:Init()
    if TropicalIsland.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        TropicalIsland:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function TropicalIsland:Stop()

end

return TropicalIsland;