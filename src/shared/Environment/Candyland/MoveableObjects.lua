local CollectionService = game:GetService("CollectionService")
local MovableObjects = {};

function MovableObjects:Init(MapObject)
    local movableObjects = MapObject.MovableObjects

    local BigGingerbread = movableObjects:WaitForChild("BigGingerbread")
    local LittleGingerbread = movableObjects:WaitForChild("LittleGingerbread")

    local smallGingerBreadIdle = "rbxassetid://8313249714"
    local bigGingerBreadIdle = "rbxassetid://8313243091"
    local chompIdle = "rbxassetid://8314584684"
    local chocolateBarIdle = "rbxassetid://8598960938"

    local smallcontroller = LittleGingerbread:WaitForChild("AnimationController")
    local bigcontroller = BigGingerbread:WaitForChild("AnimationController")

    local bigAnimation = Instance.new("Animation")
    bigAnimation.AnimationId = bigGingerBreadIdle

    local smallAnimation = Instance.new("Animation")
    smallAnimation.AnimationId = smallGingerBreadIdle

    local chocolateBarAnimation = Instance.new("Animation")
    chocolateBarAnimation.AnimationId = chocolateBarIdle
    
    local bigAnim = bigcontroller:LoadAnimation(bigAnimation)
    local smallAnim = smallcontroller:LoadAnimation(smallAnimation)
    bigAnim.Priority = "Action"
    bigAnim.Looped = true
    
    smallAnim.Priority = "Action"
    smallAnim.Looped = true
    
    smallAnim:Play()
    bigAnim:Play()

    for _, chocolatebar in pairs(CollectionService:GetTagged("ChocolateBarMonster")) do
        local controller = chocolatebar.Parent:WaitForChild("AnimationController")
        local Anim = controller:LoadAnimation(chocolateBarAnimation)
        Anim.Priority = "Action"
        Anim.Looped = true
        Anim:Play()
    end

    for _, part in pairs(MapObject.Map:GetDescendants()) do
        if part.Name == "Hershey" and part:IsA("Model") then
            local chompcontroller = part:WaitForChild("AnimationController")

            local chompAnimation = Instance.new("Animation")
            chompAnimation.AnimationId = chompIdle

            local chompAnim = chompcontroller:LoadAnimation(chompAnimation)

            chompAnim.Priority = "Action"
            chompAnim.Looped = true
            chompAnim:Play()
        end
    end
end

return MovableObjects;