local HexagonStadium = {};
local Environment = require(script.Environment);

HexagonStadium.IsPlaying = false;

function HexagonStadium:Init()
    if HexagonStadium.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        HexagonStadium:Stop()
    end
    
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function HexagonStadium:Stop()

end

return HexagonStadium;