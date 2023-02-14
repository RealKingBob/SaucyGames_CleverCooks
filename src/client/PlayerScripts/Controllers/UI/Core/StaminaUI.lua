local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local UserInputService = game:GetService("UserInputService")

local StaminaUI = Knit.CreateController { Name = "StaminaUI" }

local LocalPlayer = game.Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");

local SprintAnimTrack = nil;
local PrevAnim;

local ThemeData = workspace:GetAttribute("Theme")

local NormalWalkSpeed = 16
local NewWalkSpeed = 30

local ReductionRate = 1;
local ReductionDelay = 0.05;

local RegenAmount = 1;
local RegenDelay = 0.2;

local MaxStamina = Instance.new("IntValue", LocalPlayer)
MaxStamina.Name = "MS"
MaxStamina.Value = 100

local Stamina = Instance.new("IntValue", LocalPlayer)
Stamina.Name = "S"
Stamina.Value = MaxStamina.Value

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

local sprintAnimation = Instance.new('Animation')
sprintAnimation.AnimationId = "rbxassetid://8028996064"
sprintAnimation.Name = "SprintAnim"

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
    if not workspace:FindFirstChild(Character.Name) then 
        Character = workspace:WaitForChild(Character.Name)
    end
    local BoostSFX, BoomSFX;
    local AvatarService = Knit.GetService("AvatarService");

    Stamina.Value = MaxStamina.Value;

    local Humanoid = Character:WaitForChild("Humanoid");

    if Humanoid then
        local animator = Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            if not SprintAnimTrack then 
                if Humanoid:IsDescendantOf(workspace) then
                    SprintAnimTrack = animator:LoadAnimation(sprintAnimation);
                    SprintAnimTrack.Priority = Enum.AnimationPriority.Movement
                end
            end
        end
    end

    if not Humanoid or not Humanoid:FindFirstChildOfClass("Animator") or not SprintAnimTrack then return end

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
        if not Humanoid then return end
        if cooldownStamina == true and 
        (Stamina.Value <= percentageToUseAgain) or
        Humanoid.MoveDirection.Magnitude <= 0 then
            return;
        end

        if (sprinting == false) and (Stamina.Value > ReductionRate) then
            sprinting = true

            if staminaDebounce == true then
                return;
            end

            staminaDebounce = true

            task.spawn(function()
                task.wait(.5)
                staminaDebounce = false
            end)

            if Humanoid then
                Humanoid.WalkSpeed = NewWalkSpeed
            end

            --print(Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks())

            local camera = game.Workspace.CurrentCamera

            --local BoostSFX = Instance.new("Sound")
            --BoostSFX.SoundId = "rbxassetid://5274463739"
            --BoostSFX.PlayOnRemove = false

            if not Knit.GamePlayers.BoostSFX:FindFirstChild(LocalPlayer.Name) then return end;

            BoostSFX = Knit.GamePlayers.BoostSFX:FindFirstChild(LocalPlayer.Name):Clone();
            BoostSFX.Volume = .3
            BoostSFX.PlayOnRemove = false;

            BoomSFX = Instance.new("Sound")
            BoomSFX.SoundId = "rbxassetid://9125403260"
            BoomSFX.PlayOnRemove = false

            local CameraShaker = require(Knit.ReplicatedModules.CameraShaker)

            local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
                camera.CFrame = camera.CFrame * shakeCFrame
            end)

            BoomSFX.Parent = Character.PrimaryPart
            BoostSFX.Parent = Character.PrimaryPart

            BoostSFX:Play()
            task.wait(.1)

            task.spawn(function()
                task.wait(.1)
                BoomSFX:Play()
            end)

            task.spawn(function()
                BoostSFX.Ended:Wait()
                if BoostSFX then
                    BoomSFX:Destroy()
                end
                if BoostSFX then
                    BoostSFX:Destroy()
                end
            end)

            task.spawn(function()
                if Character:FindFirstChild("HumanoidRootPart") then
                    
                    local Circle = Character.HumanoidRootPart.Attachment:FindFirstChild("Circle");
                    Circle.Enabled = true;
                    
                    Circle:Clear();
                    Circle:Emit(1);
                    
                    Circle.Enabled = false;
                end
            end)


            --camShake:Start()
            
            -- Explosion shake:
            --camShake:ShakeOnce(3, 3, 0.2, 1.5)

            if Humanoid then
                local animator = Humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    if not SprintAnimTrack then 
                        repeat task.wait() until Character.Parent ~= nil
                        if Humanoid:IsDescendantOf(workspace) then
                            SprintAnimTrack = animator:LoadAnimation(sprintAnimation);
                            SprintAnimTrack.Priority = Enum.AnimationPriority.Movement
                        end
                    end
                end
            end

            if not Humanoid or not Humanoid:FindFirstChildOfClass("Animator") or not SprintAnimTrack then return end

            if SprintAnimTrack then
                SprintAnimTrack:Play()
            end
            
            AvatarService.BoostEffect:Fire(true)

            local MainUI = PlayerGui:WaitForChild("Main")
            local BarsFrame = MainUI:WaitForChild("BottomFrame"):WaitForChild("BarsFrame");
            local StaminaFrame = BarsFrame:WaitForChild("Stamina")
            local StaminaBar = StaminaFrame:WaitForChild("Bar")
            local StaminaTitle = StaminaFrame:WaitForChild("Title")

            repeat
                task.wait(ReductionDelay)
                Stamina.Value = Stamina.Value - ReductionRate
                PlayerGui:WaitForChild("Main"):WaitForChild("BottomFrame"):WaitForChild("BarsFrame"):WaitForChild("Stamina"):WaitForChild("Bar"):TweenSize(UDim2.new(Stamina.Value / MaxStamina.Value, 0, 1, 0), 'Out', 'Quint', .1, true)
                if (sprinting == true) then
                    StaminaBar.BackgroundColor3 = boostStaminaColor;
                end
                
                StaminaTitle.Text = math.floor(Stamina.Value).. '/' ..(MaxStamina.Value)
            until (sprinting == false) or not Humanoid or Humanoid.Health == 0 or (Stamina.Value <= 0) or (Humanoid.MoveDirection == Vector3.new(0,0,0))

            if Stamina.Value <= 0 then
                cooldownStamina = true;
            end

            if sprinting == true then
                if SprintAnimTrack then
                    SprintAnimTrack:Stop()
                end
                sprinting = false
                --if PrevAnim then PrevAnim:Play(); end

                if BoostSFX then
                    BoomSFX:Destroy()
                end
                if BoostSFX then
                    BoostSFX:Destroy()
                end

                AvatarService.BoostEffect:Fire(false)

                if cooldownStamina == true then
                    StaminaBar.BackgroundColor3 = cooldownStaminaColor;
                else
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end

                if Humanoid then
                    Humanoid.WalkSpeed = NormalWalkSpeed
                end
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

                if SprintAnimTrack then
                    SprintAnimTrack:Stop()
                end
                
                --if PrevAnim then PrevAnim:Play(); end
                if BoostSFX then
                    BoomSFX:Destroy()
                end
                if BoostSFX then
                    BoostSFX:Destroy()
                end
                AvatarService.BoostEffect:Fire(false)
                --print(PrevAnim)

                local MainUI = PlayerGui:WaitForChild("Main")
                local BarsFrame = MainUI:WaitForChild("BottomFrame"):WaitForChild("BarsFrame");
                local StaminaFrame = BarsFrame:WaitForChild("Stamina")
                local StaminaBar = StaminaFrame:WaitForChild("Bar")

                if cooldownStamina == true then
                    StaminaBar.BackgroundColor3 = cooldownStaminaColor;
                else
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end

                if Humanoid then
                    Humanoid.WalkSpeed = NormalWalkSpeed
                end
            end
        end
    end)
end



function StaminaUI:KnitStart()
    local ProgressionService = Knit.GetService("ProgressionService");
    ProgressionService:GetProgressionData(ThemeData):andThen(function(playerCurrency, playerStorage, progressionStorage)
        print("PlayerCurrency", playerCurrency, "PlayerStorage:", playerStorage, "ProgressionStorage:", progressionStorage)

        MaxStamina.Value = progressionStorage["Boost Stamina"].Data[playerStorage["Boost Stamina"]].Value;
        Stamina.Value = progressionStorage["Boost Stamina"].Data[playerStorage["Boost Stamina"]].Value;
        print(Stamina.Value, MaxStamina.Value)
    end)

    ProgressionService.Update:Connect(function(StatName, StatValue)
        if StatName == "Boost Stamina" then
            MaxStamina.Value = StatValue;
            Stamina.Value = StatValue;
            local MainUI = PlayerGui:WaitForChild("Main")
            local BarsFrame = MainUI:WaitForChild("BottomFrame"):WaitForChild("BarsFrame");
            local StaminaFrame = BarsFrame:WaitForChild("Stamina")
            local StaminaBar = StaminaFrame:WaitForChild("Bar")
            StaminaBar.Size = UDim2.new(1,0,1,0);
            print(Stamina.Value, MaxStamina.Value)
        end
    end)
end


function StaminaUI:KnitInit()
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        Character = character
        Stamina.Value = MaxStamina.Value;
        local MainUI = PlayerGui:WaitForChild("Main")
        local BarsFrame = MainUI:WaitForChild("BottomFrame"):WaitForChild("BarsFrame");
        local StaminaFrame = BarsFrame:WaitForChild("Stamina")
        local StaminaBar = StaminaFrame:WaitForChild("Bar")
        StaminaBar.BackgroundColor3 = regularStaminaColor;
        StaminaBar.Size = UDim2.new(1,0,1,0);
        SprintAnimTrack = nil;
        self:SetupStamina(character);
    end)

    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    
    self:SetupStamina(Character);

    local CookingService = Knit.GetService("CookingService");

    CookingService.PickUp:Connect(function(foodInfo)
        --print("FOOOD",food)
        if foodInfo.Type == "ChangeStamina" then
            NormalWalkSpeed = foodInfo.Data[1]
            NewWalkSpeed = foodInfo.Data[2]
            if Character then
                local Humanoid = Character:FindFirstChild("Humanoid");
                if Humanoid then
                    if sprinting == true then
                        Humanoid.WalkSpeed = NewWalkSpeed;
                    else
                        Humanoid.WalkSpeed = NormalWalkSpeed;
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(RegenDelay)
    
            if cooldownStamina == true and (Stamina.Value > percentageToUseAgain) then
                cooldownStamina = false;
                local MainUI = PlayerGui:WaitForChild("Main")
                local BarsFrame = MainUI:WaitForChild("BottomFrame"):WaitForChild("BarsFrame");
                local StaminaFrame = BarsFrame:WaitForChild("Stamina")
                local StaminaBar = StaminaFrame:WaitForChild("Bar")
                StaminaBar.BackgroundColor3 = regularStaminaColor;
            end
    
            if (sprinting == false) and (Stamina.Value < MaxStamina.Value) then
                local MainUI = PlayerGui:WaitForChild("Main")
                local BarsFrame = MainUI:WaitForChild("BottomFrame"):WaitForChild("BarsFrame");
                local StaminaFrame = BarsFrame:WaitForChild("Stamina")
                local StaminaBar = StaminaFrame:WaitForChild("Bar")
                local StaminaTitle = StaminaFrame:WaitForChild("Title")
                Stamina.Value += RegenAmount
                PlayerGui:WaitForChild("Main"):WaitForChild("BottomFrame"):WaitForChild("BarsFrame"):WaitForChild("Stamina"):WaitForChild("Bar"):TweenSize(UDim2.new(Stamina.Value / MaxStamina.Value, 0, 1, 0), 'Out', 'Quint', .1, true)
                if (sprinting == true) then
                    StaminaBar.BackgroundColor3 = regularStaminaColor;
                end
                StaminaTitle.Text = math.floor(Stamina.Value).. '/' ..(MaxStamina.Value)
            end
        end
    end)
end


return StaminaUI
