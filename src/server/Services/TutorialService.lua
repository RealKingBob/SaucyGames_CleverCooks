local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TutorialService = Knit.CreateService {
    Name = "TutorialService";
    PlayersInTutorial = {};
    Client = {
        TutorialStart = Knit.CreateSignal();
        TutorialStep = Knit.CreateSignal();
        TutorialEnd = Knit.CreateSignal();
    };
}

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TextService = game:GetService("TextService")

local inactiveTime = 900 -- if the player is inactive for 900 seconds, end the tutorial 
local ThemeData = workspace:GetAttribute("Theme")

function TutorialService:StartTutorial(player)
    if self.PlayersInTutorial[player.UserId] then return end
    self.PlayersInTutorial[player.UserId] = {
        isRunning = true;
        tutorialStep = 1;
        lastInteraction = os.time();
    };

    self.Client.TutorialStart:Fire(player)
    self.Client.TutorialStep:Connect(function(player)
        local data = self.PlayersInTutorial[player.UserId]
        data.lastInteraction = os.time()
        data.step = data.step + 1
        
        self.Client.TutorialStep:Fire(player, data.step)
    end)

    self.Client.TutorialEnd:Connect(function(player)
        self.PlayersInTutorial[player.UserId].isRunning = false
    end)
    
    task.spawn(function()
        while self.PlayersInTutorial[player.UserId].isRunning do
            if os.time() - self.PlayersInTutorial[player.UserId].lastInteraction >= inactiveTime then 
                self.PlayersInTutorial[player.UserId].isRunning = false
                self.Client.TutorialEnd:Fire(player)
            end
            task.wait(1)
        end

        self.PlayersInTutorial[player.UserId] = nil;
    end)
end

function TutorialService:KnitStart()
    
end


function TutorialService:KnitInit()
    local Zone = require(Knit.ReplicatedModules.Zone)
    local container = CollectionService:GetTagged("TutorialZone")
    local zone = Zone.new(container)

    self.Client.TutorialStart:Connect(function(player)
        if ThemeData == "French" then
            self:StartTutorial(player)
        end
    end)

    zone.playerEntered:Connect(function(player)
        print(("%s entered the zone!"):format(player.Name))
        if player.Character then
            local Forcefield = player.Character:FindFirstChildWhichIsA("ForceField")
            if not Forcefield then
                Forcefield = Instance.new("ForceField")
                Forcefield.Parent = player.Character
                Forcefield.Visible = false
            end
        end
    end)
    
    zone.playerExited:Connect(function(player)
        print(("%s exited the zone!"):format(player.Name))
        if player.Character then
            local Forcefield = player.Character:FindFirstChildWhichIsA("ForceField")
            if Forcefield then
                Forcefield:Destroy()
            end
        end
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            character:WaitForChild("Humanoid").Died:Connect(function()
                if self.PlayersInTutorial[player.UserId] and self.PlayersInTutorial[player.UserId].isRunning then
                    self.PlayersInTutorial[player.UserId].isRunning = false
                    self.Client.TutorialEnd:Fire(player)
                end
            end)
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self.PlayersInTutorial[player.UserId] = nil;
    end)
end


return TutorialService
