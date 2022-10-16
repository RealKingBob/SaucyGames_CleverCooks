local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LocalPlayer = Players.LocalPlayer

local AnimationController = Knit.CreateController { Name = "AnimationController" }

function AnimationController:Animate(Controller, Animation)
    print(Controller, Animation)
    local taskAnim = Instance.new("Animation");
    taskAnim.Name = "TaskAnim";
    taskAnim.AnimationId = Animation

    local taskAnimTrack = Controller:LoadAnimation(taskAnim)
    taskAnimTrack.Looped = false;

    for _, AnimationTrack in pairs(Controller:GetPlayingAnimationTracks()) do
        AnimationTrack:AdjustSpeed(0.58);
    end

    if Controller and Animation then
        taskAnimTrack:Play();
        taskAnimTrack:AdjustSpeed(0.58);
        taskAnimTrack.Stopped:Wait()
        print("STOP")
    end
end;

function AnimationController:SetAnimations(Animations)
    local Character = LocalPlayer.Character
    if Character and Animations then
        local Animate = Character:FindFirstChild("Animate");
        if Animate then
            if Animate:FindFirstChild("idle") and Animate:FindFirstChild("walk") then
                
                Animate.idle:FindFirstChild("Animation1").AnimationId = Animations[1];
                Animate.idle:FindFirstChild("Animation2").AnimationId = Animations[1];
                Animate.walk:FindFirstChild("WalkAnim").AnimationId = Animations[2];
                Animate.fall:FindFirstChild("FallAnim").AnimationId = Animations[2];
                Animate.jump:FindFirstChild("JumpAnim").AnimationId = Animations[3];

                Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            end;
        end;
    end;
end;

function AnimationController:KnitStart()
    --print("animation contrller")

    local ProximityService = Knit.GetService("ProximityService")
    ProximityService.SetAnimations:Connect(function(Animations)
        self:SetAnimations(Animations);
    end)

    local NpcService = Knit.GetService("NpcService")
    NpcService.PlayAnimation:Connect(function(Controller, Animation)
        self:Animate(Controller, Animation);
    end)
end


function AnimationController:KnitInit()
    
end


return AnimationController
