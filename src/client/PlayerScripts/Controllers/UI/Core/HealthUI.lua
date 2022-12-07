local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local HealthUI = Knit.CreateController { Name = "HealthUI" }

local LocalPlayer = game.Players.LocalPlayer;

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");

local HealthConnection, MaxHealthConnection;

function HealthUI:Update(Humanoid)
    local health = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)

    local MainUI = PlayerGui:WaitForChild("Main")
    local BottomFrame = MainUI:WaitForChild("BottomFrame")
    local BarsFrame = BottomFrame:WaitForChild("BarsFrame");
    local HealthFrame = BarsFrame:WaitForChild("Health")
    local HealthBar = HealthFrame:WaitForChild("Bar")
    local HealthTitle = HealthFrame:WaitForChild("Title")

    HealthBar:TweenSize(UDim2.fromScale(health, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, Humanoid.Health / Humanoid.MaxHealth, true)
    HealthTitle.Text = math.floor(Humanoid.Health).. '/' ..Humanoid.MaxHealth
end

function HealthUI:KnitStart()

end


function HealthUI:KnitInit()

    LocalPlayer.CharacterAdded:Connect(function(Character)

        local Humanoid = Character:WaitForChild("Humanoid");

        if HealthConnection and MaxHealthConnection then
            HealthConnection:Disconnect();
            MaxHealthConnection:Disconnect();
        end

        HealthConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            print(Humanoid, Humanoid.Health)
            self:Update(Humanoid)
        end)

        MaxHealthConnection = Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
            self:Update(Humanoid)
        end)

    end)

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local Humanoid = Character:WaitForChild("Humanoid");

    if HealthConnection and MaxHealthConnection then
        HealthConnection:Disconnect();
        MaxHealthConnection:Disconnect();
    end

    HealthConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        print(Humanoid, Humanoid.Health)
        self:Update(Humanoid)
    end)

    MaxHealthConnection = Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        self:Update(Humanoid)
    end)

end


return HealthUI
