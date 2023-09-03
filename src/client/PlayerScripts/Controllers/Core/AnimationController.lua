--[[
    Name: Animation Controller [V1]
    By: Real_KingBob
    Updated: 2/17/23
    Description: Handles client-sided animations on a character or NPC.
]]

local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local localPlayer = Players.LocalPlayer
local currAnimName = {}
local currentAnimKeyframeHandler = {}
local currentAnimSpeed = {} --0.58

local AnimationController = Knit.CreateController { Name = "AnimationController" }

function AnimationController:Animate(controller, animation, animationName, agent, bypass)
    -- Check if required arguments are present
    if not agent or not controller or not animation or not animationName then
        return
    end

    -- Check if the animation is already playing and bypass is false
    if animationName == currAnimName[agent] and not bypass then
        return
    end

    -- Set the current animation name
    currAnimName[agent] = animationName

    -- Determine the animation speed based on the agent's walk speed
    if agent:FindFirstChildOfClass("Humanoid").WalkSpeed > 16 then
        currentAnimSpeed[agent] = 0.65
    else
        currentAnimSpeed[agent] = 0.58
    end

    -- Create a new Animation object and load it into the controller
    local taskAnim = Instance.new("Animation")
    taskAnim.Name = animationName
    taskAnim.AnimationId = animation
    local taskAnimTrack = controller:LoadAnimation(taskAnim)
    taskAnimTrack.Looped = false

    -- Define a function to be called when a keyframe is reached
    local function keyFrameReachedFunc(frameName)
        if frameName == "End" then
            taskAnimTrack:Play(0.100000001, 1, currentAnimSpeed[agent])
        end
    end

    -- Stop and destroy all currently playing animation tracks
    for _, animationTrack in pairs(controller:GetPlayingAnimationTracks()) do
        animationTrack:Stop()
        animationTrack:Destroy()
    end

    -- Play the animation and set up keyframe triggers
    if controller and animation then
        taskAnimTrack:Play(0.100000001, 1, currentAnimSpeed[agent])
        if currentAnimKeyframeHandler[agent] ~= nil then
            currentAnimKeyframeHandler[agent]:Disconnect()
        end
        currentAnimKeyframeHandler[agent] = taskAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)
    end
end

function AnimationController:SetAnimations(animations)
    -- Get the player's character and the animations to set
    local character = localPlayer.Character
    if character and animations then
        -- Find the humanoid and the Animate object in the character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local animate = character:FindFirstChild("Animate")
        if humanoid and animate then
            -- Find the Animator object in the humanoid
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                -- Stop all currently playing animation tracks
                for _, playingTrack in pairs(animator:GetPlayingAnimationTracks()) do
                    playingTrack:Stop()
                    playingTrack:Destroy()
                end

                -- Find the Idle, Walk, Fall, and Jump objects in the Animate object
                local idle = animate:FindFirstChild("idle")
                local walk = animate:FindFirstChild("walk")
                local fall = animate:FindFirstChild("fall")
                local jump = animate:FindFirstChild("jump")

                if idle and walk and fall and jump then
                    -- Set the animation IDs for each animation
                    idle.Animation1.AnimationId = animations[1]
                    idle.Animation2.AnimationId = animations[1]
                    walk.WalkAnim.AnimationId = animations[2]
                    fall.FallAnim.AnimationId = animations[2]
                    jump.JumpAnim.AnimationId = animations[3]

                    -- Change the humanoid's state to Swimming for testing purposes
                    humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                end
            end
        end
    end
end


function AnimationController:KnitStart()
    local ProximityService = Knit.GetService("ProximityService")
    ProximityService.SetAnimations:Connect(function(Animations)
        self:SetAnimations(Animations)
    end)

end


function AnimationController:KnitInit()
    
end


return AnimationController