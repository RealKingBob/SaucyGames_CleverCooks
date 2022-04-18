local ShipAnim = {};

function ShipAnim:Init(MapObject)
    if MapObject:FindFirstChild("MovableObjects"):FindFirstChild("Ships") then
        for _,ship in pairs(MapObject.MovableObjects.Ships:GetChildren()) do
            if ship:IsA("Model") and ship.Name == "GroupShip1" then
                local All = ship.Ship:GetChildren()
                for A = 1,#All do
                    if All[A].Name ~= "ShipBase01" then
                        local NewWeld = Instance.new("Weld")
                        NewWeld.Name = "Weld"
                        NewWeld.Part0,NewWeld.Part1 = All[A],ship.Ship.ShipBase01
                        NewWeld.C0 = All[A].CFrame:inverse()
                        NewWeld.C1 = ship.Ship.ShipBase01.CFrame:inverse()
                        NewWeld.Parent = ship.Ship.ShipBase01
                    end
                end
    
                local NewWeld = Instance.new("Motor6D")
                NewWeld.Name = "Motor6D"
                NewWeld.Part0,NewWeld.Part1 = ship.Ship.ShipBase01,ship.Part
                NewWeld.C0 = ship.Ship.ShipBase01.CFrame:inverse()
                NewWeld.C1 = ship.Part.CFrame:inverse()
                NewWeld.Parent = ship.Part
                
                task.spawn(function() 
                    while true do
                        game:GetService("TweenService"):Create(NewWeld,TweenInfo.new(60,0),{C1 = ship.Part.CFrame:inverse()*CFrame.new(100,0,50)}):Play()
                        task.wait(60)
                        game:GetService("TweenService"):Create(NewWeld,TweenInfo.new(60,0),{C1 = ship.Part.CFrame:inverse()*CFrame.new(0,0,0)}):Play()
                        task.wait(60)
                    end
                end)
            elseif ship:IsA("Model") and ship.Name == "GroupShip2" then
                local All = ship.Ship:GetChildren()
                for A = 1,#All do
                    if All[A].Name ~= "ShipBase01" then
                        local NewWeld = Instance.new("Weld")
                        NewWeld.Name = "Weld"
                        NewWeld.Part0,NewWeld.Part1 = All[A],ship.Ship.ShipBase01
                        NewWeld.C0 = All[A].CFrame:inverse()
                        NewWeld.C1 = ship.Ship.ShipBase01.CFrame:inverse()
                        NewWeld.Parent = ship.Ship.ShipBase01
                    end
                end
    
                local NewWeld = Instance.new("Motor6D")
                NewWeld.Name = "Motor6D"
                NewWeld.Part0,NewWeld.Part1 = ship.Ship.ShipBase01,ship.Part
                NewWeld.C0 = ship.Ship.ShipBase01.CFrame:inverse()
                NewWeld.C1 = ship.Part.CFrame:inverse()
                NewWeld.Parent = ship.Part
                
                task.spawn(function()
                    while true do
                        game:GetService("TweenService"):Create(NewWeld,TweenInfo.new(60,0),{C1 = ship.Part.CFrame:inverse()*CFrame.new(10,0,-150)}):Play()
                        task.wait(60)
                        game:GetService("TweenService"):Create(NewWeld,TweenInfo.new(60,0),{C1 = ship.Part.CFrame:inverse()*CFrame.new(0,0,0)}):Play()
                        task.wait(60)
                    end
                end)
            end
        end
    end
end

return ShipAnim;