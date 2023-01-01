local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NotificationService = Knit.CreateService {
    Name = "NotificationService",
    Client = {
        NotifyMessage = Knit.CreateSignal();
    },
}

function NotificationService:Message(allPlayers, player, message, typeWriteEffect)
    if allPlayers == true then
        self.Client.NotifyMessage:FireAll(message, typeWriteEffect);
    else
        self.Client.NotifyMessage:Fire(player, message, typeWriteEffect);
    end
end

function NotificationService:KnitStart()
    
end


function NotificationService:KnitInit()
    
end


return NotificationService
