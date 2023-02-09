local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local LocalPlayer = Players.LocalPlayer
local currAnimName = {};
local currAnimId;
local currentAnimKeyframeHandler = {}
local currentAnimSpeed = {}; --0.58

local currAnimPlaying;


local AnimationController = Knit.CreateController { Name = "AnimationController" }

function AnimationController:SetupNPC(Character)
    --task.spawn(AnimateBIG, Character)
end;

local function playAnimationForDuration(animationTrack, duration)
	local speed = animationTrack.Length / duration
	animationTrack:AdjustSpeed(speed)
	animationTrack:Play()
end

-- TODO: MAKE CONTROLLER TABLE SO THE IF STATEMENT DOESNT STOP THE OTHER WALKING ANIMATIONS
function AnimationController:Animate(Controller, Animation, AnimationName, Agent, byPass)
    --print(Controller, Animation, AnimationName, AnimationName == currAnimName[Agent])
    --assert(Agent, "You didnt insert an agent!")
    --assert(Controller, "You didnt insert an Controller!")
    --assert(Animation, "You didnt insert an Animation!")
    --assert(AnimationName, "You didnt insert an AnimationName!")
    if not Agent or not Controller or not Animation or not AnimationName then return end
    if AnimationName == currAnimName[Agent] and not byPass then return end;

    --print(Agent:FindFirstChildOfClass("Humanoid").WalkSpeed)

    currAnimName[Agent] = AnimationName

    if Agent:FindFirstChildOfClass("Humanoid").WalkSpeed > 16 then
        currentAnimSpeed[Agent] = 0.65
    else
        currentAnimSpeed[Agent] = 0.58
    end
    

    local taskAnim = Instance.new("Animation");
    taskAnim.Name = AnimationName;
    taskAnim.AnimationId = Animation

    local taskAnimTrack = Controller:LoadAnimation(taskAnim)
    taskAnimTrack.Looped = false;

    local function keyFrameReachedFunc(frameName)
        if (frameName == "End") then
            taskAnimTrack:Play(0.100000001, 1, currentAnimSpeed[Agent]);
        end
    end

    for _, AnimationTrack in pairs(Controller:GetPlayingAnimationTracks()) do
        --AnimationTrack:AdjustSpeed(0.58);
        AnimationTrack:Stop();
        AnimationTrack:Destroy();
    end

    if Controller and Animation then
        taskAnimTrack:Play(0.100000001, 1, currentAnimSpeed[Agent]);
         -- set up keyframe name triggers
         if (currentAnimKeyframeHandler[Agent] ~= nil) then
            currentAnimKeyframeHandler[Agent]:disconnect()
        end
        currentAnimKeyframeHandler[Agent] = taskAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)
        
        --print("STOP")
    end
end;

function AnimationController:SetAnimations(Animations)
    local Character = LocalPlayer.Character
    if Character and Animations then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        local Animate = Character:FindFirstChild("Animate");
        if humanoid and Animate then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                local Tracks = animator:GetPlayingAnimationTracks(); -- Get all playing animations from our character
                --print("Tracks:", Tracks)
                -- Stop all animation tracks
                for _, playingTrack in pairs(animator:GetPlayingAnimationTracks()) do
                    playingTrack:Stop(0)
                    playingTrack:Destroy();
                end
                --print("Tracks 2:", Tracks)
                if Animate:FindFirstChild("idle") and Animate:FindFirstChild("walk") then
                    Animate.idle:FindFirstChild("Animation1").AnimationId = Animations[1];
                    Animate.idle:FindFirstChild("Animation2").AnimationId = Animations[1];
                    Animate.walk:FindFirstChild("WalkAnim").AnimationId = Animations[2];
                    Animate.fall:FindFirstChild("FallAnim").AnimationId = Animations[2];
                    Animate.jump:FindFirstChild("JumpAnim").AnimationId = Animations[3];
    
                    --Character.Humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
                    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                end;
            end
        end
    end;
end;


function AnimationController:KnitStart()
    --print("animation contrller")

    local ProximityService = Knit.GetService("ProximityService")
    ProximityService.SetAnimations:Connect(function(Animations)
        self:SetAnimations(Animations);
    end)

    local NpcService = Knit.GetService("NpcService")
    NpcService.PlayAnimation:Connect(function(Controller, Animation, AnimationName, Agent, byPass)
        self:Animate(Controller, Animation, AnimationName, Agent, byPass);
    end)

    NpcService.SetupNPC:Connect(function(Character)
        --self:SetupNPC(Character);
    end)
end


function AnimationController:KnitInit()
    
end


return AnimationController