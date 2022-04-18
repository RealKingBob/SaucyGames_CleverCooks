local SharkAnim = {};

function SharkAnim:Init(MapObject)
    if MapObject:FindFirstChild("MovableObjects"):FindFirstChild("Sharks") then
        for _,shark in pairs(MapObject.MovableObjects.Sharks:GetChildren()) do
            if shark:IsA("Model") and shark.Name == "GroupShark" then
                local hum = shark.Shark:WaitForChild("AnimationController")
    
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://8084296273"
    
                local anim = hum:LoadAnimation(animation)
                anim.Looped = true
                anim:Play()
    
                task.spawn(function()
                    local rNum = math.random(6,8)
                    if shark.PrimaryPart then
                        repeat
                            game:GetService("TweenService"):Create(shark.PrimaryPart,TweenInfo.new(rNum, Enum.EasingStyle.Linear), {CFrame = shark.PrimaryPart.CFrame * CFrame.Angles(0,360,0)}):Play()
                            task.wait(rNum)
                        until shark == nil
                    end
                end)
            end
        end
    end
end

return SharkAnim;