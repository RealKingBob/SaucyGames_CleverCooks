local Candyland = {};
local Environment = require(script.Environment);

Candyland.IsPlaying = false;

function Candyland:Init()
    if Candyland.IsPlaying == true then
        warn("Stop the game -", debug.traceback());
        Candyland:Stop()
    end
    print("Setting up environment")
    local env = Environment:Init();

    return env
end



function Candyland:Stop()

end

return Candyland;