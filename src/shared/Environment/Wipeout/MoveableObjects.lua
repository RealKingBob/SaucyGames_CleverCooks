local MovableObjects = {};

function MovableObjects:Init(MapObject)
    local movableObjects = MapObject.MovableObjects

    local flyingPropellors = "rbxassetid://8329104270"
    local bigPropFlying = "rbxassetid://8329306062"
    local cameraFlying = "rbxassetid://8329555085"

    for _, part in pairs(movableObjects:GetChildren()) do
        if part.Name == "Camera" and part:IsA("Model") then
            local cameracontroller = part:WaitForChild("AnimationController")

            local cameraAnimation = Instance.new("Animation")
            cameraAnimation.AnimationId = cameraFlying
            local camAnim = cameracontroller:LoadAnimation(cameraAnimation)
            camAnim.Priority = "Action"
            camAnim.Looped = true
            camAnim:Play()

        elseif part.Name == "Drone" and part:IsA("Model") then
            local flyingPropcontroller = part:WaitForChild("AnimationController")
            local flyingPropAnimation = Instance.new("Animation")
            flyingPropAnimation.AnimationId = flyingPropellors
            
            local flyingPropAnim = flyingPropcontroller:LoadAnimation(flyingPropAnimation)
            flyingPropAnim.Priority = "Action"
            flyingPropAnim.Looped = true

            flyingPropAnim:Play()
        elseif part.Name == "Screen" and part:IsA("Model") then
            local bigPropcontroller = part:WaitForChild("AnimationController")
            local bigPropAnimation = Instance.new("Animation")
            bigPropAnimation.AnimationId = bigPropFlying      
            local bigPropAnim = bigPropcontroller:LoadAnimation(bigPropAnimation)

            bigPropAnim.Priority = "Action"
            bigPropAnim.Looped = true

            bigPropAnim:Play()
        end
    end
end

return MovableObjects;