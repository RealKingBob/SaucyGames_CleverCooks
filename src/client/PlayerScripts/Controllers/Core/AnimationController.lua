local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LocalPlayer = Players.LocalPlayer

local AnimationController = Knit.CreateController { Name = "AnimationController" }

function AnimationController:SetAnimations(Animations)
    local Character = LocalPlayer.Character
    if Character and Animations then
        local Animate = Character:FindFirstChild("Animate");
        if Animate then
            if Animate:FindFirstChild("idle") and Animate:FindFirstChild("walk") then
                local Humanoid = Character:WaitForChild("Humanoid");
                local Animator = Humanoid:FindFirstChildOfClass("Animator");
                local AnimationTracks = Animator:GetPlayingAnimationTracks();
                local TempIdleAnim = Instance.new("Animation");
                TempIdleAnim.AnimationId = Animations[1];
                Animate.idle:FindFirstChild("Animation1").AnimationId = Animations[1];
                Animate.idle:FindFirstChild("Animation2").AnimationId = Animations[1];
                Animate.walk:FindFirstChild("WalkAnim").AnimationId = Animations[2];
                Animate.fall:FindFirstChild("FallAnim").AnimationId = Animations[2];
                Animate.jump:FindFirstChild("JumpAnim").AnimationId = Animations[3];
                local PrevJPower = Humanoid.JumpPower;
                --[[task.spawn(function() --// Might be a better way to reset the animations but this will do
                    Humanoid.JumpPower = 1;
                    Humanoid.Jump = true;
                    task.wait(.5)
                    Humanoid.JumpPower = PrevJPower;
                end)]]

                Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                --[[for _, track in pairs (AnimationTracks) do
                    track:Stop();
                    track:Destroy();
                end;]]
            end;
        end;
    end;
end;

function AnimationController:KnitStart()
    print("animation contrller")

    local ProximityService = Knit.GetService("ProximityService")
    ProximityService.SetAnimations:Connect(function(Animations)
        self:SetAnimations(Animations);
    end)
end


function AnimationController:KnitInit()
    
end


return AnimationController
