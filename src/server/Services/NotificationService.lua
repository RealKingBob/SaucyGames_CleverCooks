local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NotificationService = Knit.CreateService {
    Name = "NotificationService",
    Client = {
        NotifyMessage = Knit.CreateSignal();
    },
}

function NotificationService:Message(allPlayers, player, message)
    if allPlayers == true then
        self.Client.NotifyMessage:FireAll(message);
    else
        self.Client.NotifyMessage:Fire(player, message);
    end
end

function NotificationService:KnitStart()
    
end


function NotificationService:KnitInit()
    
end


return NotificationService
