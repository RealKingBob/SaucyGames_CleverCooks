local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local HealthUI = Knit.CreateController { Name = "HealthUI" }

local LocalPlayer = Players.LocalPlayer;

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");

local HealthConnection, MaxHealthConnection;

local prevHealth = nil;

function HealthUI:DamageEffect(char)
	
    if char:FindFirstChildWhichIsA("Highlight") then return end
	local highlightInstance = Instance.new("Highlight", char)
	highlightInstance.FillTransparency = 1
	highlightInstance.OutlineTransparency = 1
	highlightInstance.OutlineColor = Color3.new(0.666667, 0, 0)
	game:GetService("TweenService"):Create(highlightInstance, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {OutlineTransparency = 0, FillTransparency = .5}):Play()
	game.Debris:AddItem(highlightInstance, .25)

end


function HealthUI:Update(Humanoid)
    local health = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)

    local MainUI = PlayerGui:WaitForChild("Main")
    local BottomFrame = MainUI:WaitForChild("BottomFrame")
    local BarsFrame = BottomFrame:WaitForChild("BarsFrame");
    local HealthFrame = BarsFrame:WaitForChild("Health")
    local HealthBar = HealthFrame:WaitForChild("Bar")
    local WhiteHealthBar = HealthFrame:WaitForChild("WhiteBar")
    local HealthTitle = HealthFrame:WaitForChild("Title")

    HealthBar:TweenSize(UDim2.fromScale(health, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, .1, true) --Humanoid.Health / Humanoid.MaxHealth
    HealthTitle.Text = math.floor(Humanoid.Health).. '/' ..Humanoid.MaxHealth

    task.spawn(function()
        if Humanoid.Health < prevHealth then
            task.wait(.75)
            WhiteHealthBar:TweenSize(UDim2.fromScale(health, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, .1, true) --Humanoid.Health / Humanoid.MaxHealth
            prevHealth = Humanoid.Health
        else
            task.wait(.25)
            WhiteHealthBar.Size = UDim2.fromScale(health, 1);
            prevHealth = Humanoid.Health
        end
    end)
end

function HealthUI:KnitStart()
    
end


function HealthUI:KnitInit()

    LocalPlayer.CharacterAdded:Connect(function(Character)

        local Humanoid = Character:WaitForChild("Humanoid");
        prevHealth = Humanoid.Health

        if HealthConnection and MaxHealthConnection then
            HealthConnection:Disconnect();
            MaxHealthConnection:Disconnect();
        end

        HealthConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            --print(Humanoid, Humanoid.Health)
            if Humanoid.Health < prevHealth then self:DamageEffect(Character) end
            self:Update(Humanoid)
        end)

        MaxHealthConnection = Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
            self:Update(Humanoid)
        end)

        Humanoid.Health = Humanoid.MaxHealth
        self:Update(Humanoid)
    end)

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local Humanoid = Character:WaitForChild("Humanoid");

    prevHealth = Humanoid.Health

    if HealthConnection and MaxHealthConnection then
        HealthConnection:Disconnect();
        MaxHealthConnection:Disconnect();
    end

    HealthConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        --print(Humanoid, Humanoid.Health)
        if Humanoid.Health < prevHealth then self:DamageEffect(Character) end
        self:Update(Humanoid)
    end)

    MaxHealthConnection = Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        self:Update(Humanoid)
    end)

end


return HealthUI
