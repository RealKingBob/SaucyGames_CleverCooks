local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NotificationService = Knit.CreateService {
    Name = "NotificationService",
    Client = {
        NotifyMessage = Knit.CreateSignal(),
        NotifyLargeMessage = Knit.CreateSignal(),
        Notification = Knit.CreateSignal(),

        Alert = Knit.CreateSignal(),
    },
}

function NotificationService:LargeMessage(allPlayers, player, message, typeWriteEffect)
    if allPlayers == true then
        self.Client.NotifyLargeMessage:FireAll(message, typeWriteEffect)
    else
        self.Client.NotifyLargeMessage:Fire(player, message, typeWriteEffect)
    end
end

function NotificationService:Message(allPlayers, player, message, typeWriteEffect)
    --print("NOTIF", allPlayers, player, message, typeWriteEffect)
    if allPlayers == true then
        self.Client.NotifyMessage:FireAll(message, typeWriteEffect)
    else
        self.Client.NotifyMessage:Fire(player, message, typeWriteEffect)
    end
end

function NotificationService:Alert(allPlayers, player)
    if allPlayers == true then
        self.Client.Alert:FireAll()
    else
        self.Client.Alert:Fire(player)
    end
end

function NotificationService:KnitStart()
    
end


function NotificationService:KnitInit()
    
end


return NotificationService
