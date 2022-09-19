local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local UserInputService = game:GetService("UserInputService")

local StaminaUI = Knit.CreateController { Name = "StaminaUI" }

local LocalPlayer = game.Players.LocalPlayer;

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local MainUI = PlayerGui:WaitForChild("Main")
local BarsFrame = MainUI:WaitForChild("BarsFrame");
local StaminaFrame = BarsFrame:WaitForChild("Stamina")
local StaminaBar = StaminaFrame:WaitForChild("Bar")
local StaminaTitle = StaminaFrame:WaitForChild("Title")

local SprintAnim;
local PrevAnim;

local NormalWalkSpeed = 16
local NewWalkSpeed = 30

local ReductionRate = 1;
local ReductionDelay = 0.05;

local RegenAmount = 1;
local RegenDelay = 0.2;

local Stamina = 100;
local MaxStamina = 100;

local percentageToUseAgain = 30 

local sprinting = false;
local staminaDebounce = false;

local fartParticle;

local inStaminaCon, outStaminaCon;

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
    local Humanoid = Character:WaitForChild("Humanoid");
    fartParticle = Character.HumanoidRootPart.Attachment.Fart

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

    if inStaminaCon and outStaminaCon then
        inStaminaCon:Disconnect();
        outStaminaCon:Disconnect();
    end

    inStaminaCon = UserInputService.InputBegan:Connect(function(key, gameProcessed)
        if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
            
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

                --[[if self:CheckSprintAnim(Humanoid) == true then
                    for i,v in pairs(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
                        if v.Name == "WalkAnim" then continue end
                        v:Stop()
                    end
                    return
                end]]
    
    
                staminaDebounce = true
    
                task.spawn(function()
                    task.wait(.5)
                    staminaDebounce = false
                end)

                Humanoid.WalkSpeed = NewWalkSpeed

                --print(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks())

                --[[local AnimSelected = Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()[1]

                if AnimSelected == "rbxassetid://8028996064" then
                    AnimSelected = DefaultRunAnim;
                end

                PrevAnim = AnimSelected

                for i,v in pairs(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
                    v:Stop()
                end]]
    
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
                fartParticle.Enabled = true;

                repeat
                    task.wait(ReductionDelay)
                    Stamina = Stamina - ReductionRate
                    StaminaBar:TweenSize(UDim2.new(Stamina / MaxStamina, 0, 1, 0), 'Out', 'Quint', .1, true)
                    if (sprinting == true) then
                        StaminaBar.BackgroundColor3 = boostStaminaColor;
                    end
                    
                    StaminaTitle.Text = math.floor(Stamina).. '/' ..(MaxStamina)
                until (sprinting == false) or (Stamina <= 0) or (Humanoid.MoveDirection == Vector3.new(0,0,0))

                if Stamina <= 0 then
                    cooldownStamina = true;
                end

                if sprinting == true then
                    SprintAnim:Stop()
                    --if PrevAnim then PrevAnim:Play(); end
                    fartParticle.Enabled = false;
                    --[[for i,v in pairs(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
                        if v.Name == "WalkAnim" then continue end
                        v:Stop()
                    end
                    if PrevAnim then PrevAnim:Play(); end]]

                    if cooldownStamina == true then
                        StaminaBar.BackgroundColor3 = cooldownStaminaColor;
                    else
                        StaminaBar.BackgroundColor3 = regularStaminaColor;
                    end

                    Humanoid.WalkSpeed = NormalWalkSpeed
                end
            end
        end
    end)
    

    outStaminaCon = UserInputService.InputEnded:Connect(function(key, gameProcessed)
        if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
            if (sprinting == true) then
                sprinting = false

                SprintAnim:Stop()
                --if PrevAnim then PrevAnim:Play(); end
                fartParticle.Enabled = false;

                --print(PrevAnim)
                --[[for i,v in pairs(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
                    if v.Name == "WalkAnim" then continue end
                    v:Stop()
                end

                if PrevAnim then PrevAnim:Play(); end]]
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
                StaminaBar.BackgroundColor3 = regularStaminaColor;
            end
    
            if (sprinting == false) and (Stamina < 100) then
                Stamina += RegenAmount
                StaminaBar:TweenSize(UDim2.new(Stamina / MaxStamina, 0, 1, 0), 'Out', 'Quint', .1, true)
                if (sprinting == true) then
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end
                StaminaTitle.Text = math.floor(Stamina).. '/' ..(MaxStamina)
            end
        end
    end)

end


return StaminaUI
