local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MapProgessService = Knit.CreateService {
    Name = "MapProgessService";
    Client = {
        MapProgressStartSignal = Knit.CreateSignal();
        MapProgressEndSignal = Knit.CreateSignal();

        TimerStartSignal = Knit.CreateSignal();
        TimerEndSignal = Knit.CreateSignal();

        UpdateCharSelectSignal = Knit.CreateSignal();
        TargetHitSignal = Knit.CreateSignal();
    };
}

function MapProgessService:ProgressStart()
    MapProgessService.Client.MapProgressStartSignal:FireAll()
end

function MapProgessService:ProgressEnd()
    MapProgessService.Client.MapProgressEndSignal:FireAll()
end

function MapProgessService:TimerStart(Intermission)
    MapProgessService.Client.TimerStartSignal:FireAll(Intermission)
end

function MapProgessService:TimerEnd()
    MapProgessService.Client.TimerEndSignal:FireAll()
end

function MapProgessService:UpdateCharSelectUI(string, player)
    if player then
        MapProgessService.Client.UpdateCharSelectSignal:Fire(player, string)
    else
        MapProgessService.Client.UpdateCharSelectSignal:FireAll(string)
    end
end

function MapProgessService:KnitInit()
    print("[SERVICE]: MapProgess Service Initialized")
end

function MapProgessService:KnitStart()

end

return MapProgessService