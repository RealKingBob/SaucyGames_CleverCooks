local TrapObject = {};

TrapObject.Cooldown = 40
TrapObject.StartTime = 0;
TrapObject.Activated = false;
local HasStarted = false
local trapFolder = nil

function TrapObject:OnStart()
	
end

function TrapObject:OnAction()
	local FruitSpish1 = trapFolder.FruitSpish1
	local FruitSpish2 = trapFolder.FruitSpish2

	if FruitSpish1 and FruitSpish2 then
		if not HasStarted then
			HasStarted = true

            local FruitSpish1Clone = FruitSpish1:Clone()
            local FruitSpish2Clone = FruitSpish2:Clone()
            
            if FruitSpish1.PrimaryPart.Transparency == 1 then
                for _, meshpart in pairs(FruitSpish1:GetDescendants()) do
                    if meshpart:IsA("MeshPart") then
                        meshpart.CanCollide = true
                        meshpart.Transparency = 0
                    end
                end
                for _, meshpart in pairs(FruitSpish2:GetDescendants()) do
                    if meshpart:IsA("MeshPart") then
                        meshpart.CanCollide = true
                        meshpart.Transparency = 0
                    end
                end
            end
            
            FruitSpish1Clone.Parent = trapFolder
            FruitSpish2Clone.Parent = trapFolder
            
            if FruitSpish1.PrimaryPart.Transparency == 0 then
                for _, meshpart in pairs(FruitSpish1:GetDescendants()) do
                    if meshpart:IsA("MeshPart") then
                        meshpart.CanCollide = false
                        meshpart.Transparency = 1
                    end
                end
                for _, meshpart in pairs(FruitSpish2:GetDescendants()) do
                    if meshpart:IsA("MeshPart") then
                        meshpart.CanCollide = false
                        meshpart.Transparency = 1
                    end
                end
            end
            
            for _, meshpart in pairs(FruitSpish1Clone:GetChildren()) do
                if FruitSpish1Clone.PrimaryPart == meshpart then
                    continue
                end
                meshpart:Destroy()
            end
            
            for _, meshpart in pairs(FruitSpish2Clone:GetChildren()) do
                if FruitSpish2Clone.PrimaryPart == meshpart then
                    continue
                end
                meshpart:Destroy()
            end
            
            FruitSpish1Clone.PrimaryPart.Anchored = false
            FruitSpish2Clone.PrimaryPart.Anchored = false
            
            FruitSpish1Clone.PrimaryPart.CanCollide = false
            FruitSpish2Clone.PrimaryPart.CanCollide = false
            
            task.spawn(function()
                task.wait(8)
                if FruitSpish1.PrimaryPart.Transparency == 1 then
                    for _, meshpart in pairs(FruitSpish1:GetDescendants()) do
                        if meshpart:IsA("MeshPart") then
                            meshpart.CanCollide = true
                            meshpart.Transparency = 0
                        end
                    end
                    for _, meshpart in pairs(FruitSpish2:GetDescendants()) do
                        if meshpart:IsA("MeshPart") then
                            meshpart.CanCollide = true
                            meshpart.Transparency = 0
                        end
                    end
                end
            end)

			HasStarted = false
		end
	end
end

function TrapObject:Activate(targetObject)
    if not targetObject then
        return
    end
    trapFolder = targetObject.Parent.Parent:FindFirstChild("Trap")
    if trapFolder then
        if (self.StartTime == 0) or (tick() - self.StartTime >= self.Cooldown) then
            self.StartTime = tick()
			self.Activated = true
            task.spawn(function()
                self:OnAction()
            end)
        else
            --print("[Fruit Spish] Cooldown: ", (Cooldown - (tick() - StartTime)))
        end
    end
end

return TrapObject;
