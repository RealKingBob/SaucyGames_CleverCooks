local KrakenAnim = {};

function KrakenAnim:Init(MapObject)
    for _,kraken in pairs(MapObject.Map:GetDescendants()) do
        if kraken:IsA("Model") and kraken.Name == "Tentacle" then
            local hum = kraken:WaitForChild("AnimationController")

            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://8084296273"
            
            local anim = hum:LoadAnimation(script:FindFirstChildOfClass("Animation"))
            anim.Priority = "Action"
            anim.Looped = true
            task.wait(2)
            anim:Play()
            anim:AdjustSpeed(math.random(90,110) / 100)
        end
    end
end

return KrakenAnim;