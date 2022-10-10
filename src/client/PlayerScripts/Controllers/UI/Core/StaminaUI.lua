local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local UserInputService = game:GetService("UserInputService")

local StaminaUI = Knit.CreateController { Name = "StaminaUI" }

local LocalPlayer = game.Players.LocalPlayer;

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");

local SprintAnim;
local PrevAnim;

local NormalWalkSpeed = 16
local NewWalkSpeed = 30

local ReductionRate = 1;
local ReductionDelay = 0.05;

local RegenAmount = 1;
local RegenDelay = 0.2;

local Stamina = 100000000;
local MaxStamina = 100000000;

local percentageToUseAgain = 30 

local sprinting = false;
local staminaDebounce = false;

local lShiftEnabled = false;

local inStaminaCon, outStaminaCon, movementCon;

local disableMovementCon = false;

local DefaultRunAnim = "rbxassetid://8028984908"

local infiniteStamina = false;
local cooldownStamina = false;

local regularStaminaColor = Color3.fromRGB(16, 165, 251);
local boostStaminaColor = Color3.fromRGB(192, 14, 251);
local cooldownStaminaColor = Color3.fromRGB(206, 6, 6);


function StaminaUI:CheckSprintAnim(Humanoid)
    local Tracks = Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()
    
    for index, value in ipairs(Tracks) do
        if tostring(value) == "SprintAnim" then
            return true;
        end
    end
    return false;
end

function StaminaUI:SetupStamina(Character)

    Stamina = MaxStamina;

    local Humanoid = Character:WaitForChild("Humanoid");

    if Humanoid then
        local animator = Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local Anim = Instance.new('Animation',animator)
            Anim.AnimationId = "rbxassetid://8028996064"
            Anim.Name = "SprintAnim"
            SprintAnim = animator:LoadAnimation(Anim)
            SprintAnim.Priority = Enum.AnimationPriority.Movement
        end
    end

    if inStaminaCon and outStaminaCon and movementCon then
        inStaminaCon:Disconnect();
        outStaminaCon:Disconnect();
        movementCon:Disconnect();
    end

    -- @TODO: Replace this to detect movement and check if holding lshift

    --[[Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function() 
        print(Humanoid.MoveDirection)
    end)]]

    local function startStamina()
        if cooldownStamina == true and 
        (Stamina <= percentageToUseAgain) or
        Humanoid.MoveDirection.Magnitude <= 0 then
            return;
        end

        if (sprinting == false) and (Stamina > ReductionRate) then
            sprinting = true

            if staminaDebounce == true then
                return;
            end

            staminaDebounce = true

            task.spawn(function()
                task.wait(.5)
                staminaDebounce = false
            end)

            Humanoid.WalkSpeed = NewWalkSpeed

            --print(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks())

            local camera = game.Workspace.CurrentCamera

            local FartSFX = Instance.new("Sound")
            FartSFX.SoundId = "rbxassetid://5274463739"
            FartSFX.PlayOnRemove = false

            local BoomSFX = Instance.new("Sound")
            BoomSFX.SoundId = "rbxassetid://9125403260"
            BoomSFX.PlayOnRemove = false

            local CameraShaker = require(Knit.ReplicatedModules.CameraShaker)

            local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
                camera.CFrame = camera.CFrame * shakeCFrame
            end)

            BoomSFX.Parent = Character.PrimaryPart
            FartSFX.Parent = Character.PrimaryPart

            FartSFX:Play()
            task.wait(.1)

            task.spawn(function()
                task.wait(.1)
                BoomSFX:Play()
            end)

            task.spawn(function()
                FartSFX.Ended:Wait()
                BoomSFX:Destroy()
                FartSFX:Destroy()
            end)

            task.spawn(function()
                if Character.HumanoidRootPart then
                    
                    local Circle = Character.HumanoidRootPart.Attachment:FindFirstChild("Circle");
                    Circle.Enabled = true;
                    
                    Circle:Clear();
                    Circle:Emit(1);
                    
                    Circle.Enabled = false;
                end
            end)


            camShake:Start()
            
            -- Explosion shake:
            camShake:ShakeOnce(3, 3, 0.2, 1.5)
            --camShake:Shake(CameraShaker.Presets.Earthquake)

            SprintAnim:Play()
            for index, particle in ipairs(Character.HumanoidRootPart.Attachment:GetChildren()) do
                if particle.Name ~= "Circle" and particle:IsA("ParticleEmitter") then
                    particle.Enabled = true;
                end
            end

            local MainUI = PlayerGui:WaitForChild("Main")
            local BarsFrame = MainUI:WaitForChild("BarsFrame");
            local StaminaFrame = BarsFrame:WaitForChild("Stamina")
            local StaminaBar = StaminaFrame:WaitForChild("Bar")
            local StaminaTitle = StaminaFrame:WaitForChild("Title")

            repeat
                task.wait(ReductionDelay)
                Stamina = Stamina - ReductionRate
                PlayerGui:WaitForChild("Main"):WaitForChild("BarsFrame"):WaitForChild("Stamina"):WaitForChild("Bar"):TweenSize(UDim2.new(Stamina / MaxStamina, 0, 1, 0), 'Out', 'Quint', .1, true)
                if (sprinting == true) then
                    StaminaBar.BackgroundColor3 = boostStaminaColor;
                end
                
                StaminaTitle.Text = math.floor(Stamina).. '/' ..(MaxStamina)
            until (sprinting == false) or not Humanoid or Humanoid.Health == 0 or (Stamina <= 0) or (Humanoid.MoveDirection == Vector3.new(0,0,0))

            if Stamina <= 0 then
                cooldownStamina = true;
            end

            if sprinting == true then
                SprintAnim:Stop()
                sprinting = false
                --if PrevAnim then PrevAnim:Play(); end

                for index, particle in ipairs(Character.HumanoidRootPart.Attachment:GetChildren()) do
                    if particle:IsA("ParticleEmitter") then
                        particle.Enabled = false;
                    end
                end

                if cooldownStamina == true then
                    StaminaBar.BackgroundColor3 = cooldownStaminaColor;
                else
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end

                Humanoid.WalkSpeed = NormalWalkSpeed
            end
        end
    end

    movementCon = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function() 
        if Humanoid.MoveDirection.Magnitude > 0 and sprinting == false and lShiftEnabled == true then
            startStamina()
        end
    end)

    inStaminaCon = UserInputService.InputBegan:Connect(function(key, gameProcessed)
        if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
            lShiftEnabled = true;
            startStamina()
        end
    end)
    

    outStaminaCon = UserInputService.InputEnded:Connect(function(key, gameProcessed)
        if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
            lShiftEnabled = false

            if (sprinting == true) then
                sprinting = false

                SprintAnim:Stop()
                --if PrevAnim then PrevAnim:Play(); end
                for index, particle in ipairs(Character.HumanoidRootPart.Attachment:GetChildren()) do
                    if particle:IsA("ParticleEmitter") then
                        particle.Enabled = false;
                    end
                end

                --print(PrevAnim)

                local MainUI = PlayerGui:WaitForChild("Main")
                local BarsFrame = MainUI:WaitForChild("BarsFrame");
                local StaminaFrame = BarsFrame:WaitForChild("Stamina")
                local StaminaBar = StaminaFrame:WaitForChild("Bar")

                if cooldownStamina == true then
                    StaminaBar.BackgroundColor3 = cooldownStaminaColor;
                else
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end

                Humanoid.WalkSpeed = NormalWalkSpeed
            end
        end
    end)
end



function StaminaUI:KnitStart()
    
end


function StaminaUI:KnitInit()
    
    LocalPlayer.CharacterAdded:Connect(function(Character)
        self:SetupStamina(Character);
    end)

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    
    self:SetupStamina(Character);

    task.spawn(function()
        while true do
            task.wait(RegenDelay)
    
            if cooldownStamina == true and (Stamina > percentageToUseAgain) then
                cooldownStamina = false;
                local MainUI = PlayerGui:WaitForChild("Main")
                local BarsFrame = MainUI:WaitForChild("BarsFrame");
                local StaminaFrame = BarsFrame:WaitForChild("Stamina")
                local StaminaBar = StaminaFrame:WaitForChild("Bar")
                StaminaBar.BackgroundColor3 = regularStaminaColor;
            end
    
            if (sprinting == false) and (Stamina < 100) then
                local MainUI = PlayerGui:WaitForChild("Main")
                local BarsFrame = MainUI:WaitForChild("BarsFrame");
                local StaminaFrame = BarsFrame:WaitForChild("Stamina")
                local StaminaBar = StaminaFrame:WaitForChild("Bar")
                local StaminaTitle = StaminaFrame:WaitForChild("Title")
                Stamina += RegenAmount
                PlayerGui:WaitForChild("Main"):WaitForChild("BarsFrame"):WaitForChild("Stamina"):WaitForChild("Bar"):TweenSize(UDim2.new(Stamina / MaxStamina, 0, 1, 0), 'Out', 'Quint', .1, true)
                if (sprinting == true) then
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end
                StaminaTitle.Text = math.floor(Stamina).. '/' ..(MaxStamina)
            end
        end
    end)

end


return StaminaUI
