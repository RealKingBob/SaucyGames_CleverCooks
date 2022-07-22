local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local UserInputService = game:GetService("UserInputService")

local StaminaUI = Knit.CreateController { Name = "StaminaUI" }

local NormalWalkSpeed = 16
local NewWalkSpeed = 30

local maxpower = 20
local power = 20 -- how fast/slow stamina bar decreases, higher # = slower

local staminaTextMultiplier = 100 / maxpower -- makes it so text is always cap at 100

local sprinting = false

local fartParticle;

local inStaminaCon, outStaminaCon;

local LocalPlayer = game.Players.LocalPlayer;

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local MainUI = PlayerGui:WaitForChild("Main")
local BarsFrame = MainUI:WaitForChild("BarsFrame");
local StaminaFrame = BarsFrame:WaitForChild("Stamina")
local StaminaBar = StaminaFrame:WaitForChild("Bar")
local StaminaTitle = StaminaFrame:WaitForChild("Title")

local SprintAnim;
local PrevAnim;

function StaminaUI:KnitStart()
    
end


function StaminaUI:KnitInit()

    local CameraShaker = require(Knit.ReplicatedModules.CameraShaker)
    
    LocalPlayer.CharacterAdded:Connect(function(Character)

        local Humanoid = Character:WaitForChild("Humanoid");
        fartParticle = Character.HumanoidRootPart.Attachment.Fart

        if Humanoid then
            local animator = Humanoid:FindFirstChildOfClass("Animator")
            if animator then
                local Anim = Instance.new('Animation',animator)
                Anim.AnimationId = "rbxassetid://8028996064"
                SprintAnim = animator:LoadAnimation(Anim)
            end
        end

        if inStaminaCon and outStaminaCon then
            inStaminaCon:Disconnect();
            outStaminaCon:Disconnect();
        end

        inStaminaCon = UserInputService.InputBegan:Connect(function(key, gameProcessed)
            if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
        
                Humanoid.WalkSpeed = NewWalkSpeed

                PrevAnim = Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()[1]
                for i,v in pairs(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
                    v:Stop()
                end

                local camera = game.Workspace.CurrentCamera

                local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
                    camera.CFrame = camera.CFrame * shakeCFrame
                end)
                
                camShake:Start()
                
                -- Explosion shake:
                camShake:Shake(CameraShaker.Presets.Earthquake)

                SprintAnim:Play()
                fartParticle.Enabled = true;
                sprinting = true
        
                while power > 0 and sprinting do
                    power = power - .1
                    StaminaBar:TweenSize(UDim2.new(power / maxpower, 0, 1, 0), 'Out', 'Quint', .1, true)
                    StaminaTitle.Text = math.floor(power * staminaTextMultiplier).. '/' ..(maxpower * staminaTextMultiplier)
                    --Bar.BackgroundColor3 = Bar.BackgroundColor3:lerp(Color3.fromRGB(255, 42, 42), 0.001)
                    task.wait()
                    if power <= 0 then
                        fartParticle.Enabled = false;
                        SprintAnim:Stop()
                        if PrevAnim then PrevAnim:Play(); end
                        StaminaTitle.Text = '0/' ..(maxpower * staminaTextMultiplier)
                        Humanoid.WalkSpeed = NormalWalkSpeed
                    end
                end
            end
        end)
        

        outStaminaCon = UserInputService.InputEnded:Connect(function(key, gameProcessed)
            if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
        
                Humanoid.WalkSpeed = NormalWalkSpeed
                SprintAnim:Stop()
                if PrevAnim then PrevAnim:Play(); end
                fartParticle.Enabled = false;
                sprinting = false
        
                while power < maxpower and not sprinting do
                    power = power + .03
                    StaminaBar:TweenSize(UDim2.new(power / maxpower, 0, 1, 0), 'Out', 'Quint', .1, true)
                    StaminaTitle.Text = math.floor(power * staminaTextMultiplier).. '/' ..(maxpower * staminaTextMultiplier)

                    --Bar.BackgroundColor3 = Bar.BackgroundColor3:lerp(Color3.fromRGB(255, 166, 11), 0.001)
                    task.wait()
                    if power <= 0 then
                        Humanoid.WalkSpeed = NormalWalkSpeed
                    end
                end
            end
        end)
    end)

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    local Humanoid = Character:WaitForChild("Humanoid");
    fartParticle = Character.HumanoidRootPart.Attachment.Fart

    if Humanoid then
        local animator = Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local Anim = Instance.new('Animation',animator)
            Anim.AnimationId = "rbxassetid://8028996064"
            SprintAnim = animator:LoadAnimation(Anim)
        end
    end

    if inStaminaCon and outStaminaCon then
        inStaminaCon:Disconnect();
        outStaminaCon:Disconnect();
    end

    inStaminaCon = UserInputService.InputBegan:Connect(function(key, gameProcessed)
        if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
    
            Humanoid.WalkSpeed = NewWalkSpeed
            PrevAnim = Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()[1]
            for i,v in pairs(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
                v:Stop()
            end

            local camera = game.Workspace.CurrentCamera

            local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
                camera.CFrame = camera.CFrame * shakeCFrame
            end)
            
            camShake:Start()
            
            -- Explosion shake:
            camShake:Shake(CameraShaker.Presets.Explosion)

            SprintAnim:Play()
            fartParticle.Enabled = true;
            sprinting = true
    
            while power > 0 and sprinting do
                power = power - .1
                StaminaBar:TweenSize(UDim2.new(power / maxpower, 0, 1, 0), 'Out', 'Quint', .1, true)
                StaminaTitle.Text = math.floor(power * staminaTextMultiplier).. '/' ..(maxpower * staminaTextMultiplier)
                --Bar.BackgroundColor3 = Bar.BackgroundColor3:lerp(Color3.fromRGB(255, 42, 42), 0.001)
                task.wait()
                if power <= 0 then
                    fartParticle.Enabled = false;
                    SprintAnim:Stop()
                    if PrevAnim then PrevAnim:Play(); end
                    StaminaTitle.Text = '0/' ..(maxpower * staminaTextMultiplier)
                    Humanoid.WalkSpeed = NormalWalkSpeed
                end
            end
        end
    end)
    

    outStaminaCon = UserInputService.InputEnded:Connect(function(key, gameProcessed)
        if key.KeyCode == Enum.KeyCode.LeftShift and gameProcessed == false then
    
            Humanoid.WalkSpeed = NormalWalkSpeed
            SprintAnim:Stop()
            
            if PrevAnim then PrevAnim:Play(); end
            fartParticle.Enabled = false;
            sprinting = false
    
            while power < maxpower and not sprinting do
                power = power + .03
                StaminaBar:TweenSize(UDim2.new(power / maxpower, 0, 1, 0), 'Out', 'Quint', .1, true)
                StaminaTitle.Text = math.floor(power * staminaTextMultiplier).. '/' ..(maxpower * staminaTextMultiplier)
                --Bar.BackgroundColor3 = Bar.BackgroundColor3:lerp(Color3.fromRGB(255, 166, 11), 0.001)
                task.wait()
                if power <= 0 then
                    Humanoid.WalkSpeed = NormalWalkSpeed
                end
            end
        end
    end)

end


return StaminaUI
