local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local NPCThrowableObjects = Knit.GameLibrary:WaitForChild("NPCThrowableObjects")

local NpcController = Knit.CreateController { Name = "NpcController" }

local ratio = 2; --5uphi's ratio thing is very smart

local function visualizePosition(Position : Vector3)
	local part = Instance.new("Part");
	part.Size = Vector3.new(.3,.3,.3);
	part.Shape = Enum.PartType.Ball;
	part.BrickColor = BrickColor.White();
	part.Material = Enum.Material.Neon;
	part.CanCollide = false;
	part.Anchored = true;
	part.CFrame = CFrame.new(Position);
	part.Parent = workspace;

	game:GetService("Debris"):AddItem(part, 5);
end

function NpcController:ThrowableObject(objectName, startPosition, finalPosition)
	local objectItem = NPCThrowableObjects:WaitForChild(objectName):Clone();
    local direction = (finalPosition - startPosition);

	local force = direction * ratio + Vector3.new(0, workspace.Gravity * 0.5 / ratio, 0);
	
    --print(objectItem)
    objectItem.CanCollide = true;
    objectItem.Position = startPosition
	objectItem.Parent = (workspace:FindFirstChild("WorkspaceBin") ~= nil and workspace:FindFirstChild("WorkspaceBin")) or workspace;
	objectItem.AssemblyLinearVelocity = force;
    --print(objectItem)
	--visualizePosition(finalPosition);

    game:GetService("Debris"):AddItem(objectItem, 5);
    --objectItem:Destroy();
end

function NpcController:KnitStart()
    local NpcService = Knit.GetService("NpcService")
    NpcService.NpcAction:Connect(function(objectName, startPosition, finalPosition)
        --print(objectName, startPosition, finalPosition)
        self:ThrowableObject(objectName, startPosition, finalPosition);
    end)
end


function NpcController:KnitInit()
    
end


return NpcController
