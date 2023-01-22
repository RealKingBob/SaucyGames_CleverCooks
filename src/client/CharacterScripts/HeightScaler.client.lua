local char = script.Parent
local rootPart = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local upVector = Vector3.yAxis

local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = {char}
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

while task.wait(0) do

	local result = workspace:Raycast(rootPart.Position, rootPart.CFrame.UpVector * -1000, rayParams)

	if result then
		upVector = result.Normal
	end
	
	if (result) then
		--print("result", result.Instance, result.Normal)
		--Convert normal X and Z to degrees
		local X = math.deg(math.asin(upVector.X))
		local Z = math.deg(math.asin(upVector.Z))

		local FloorAngle = math.floor( --Round to get rid of floating-point weirdness
			math.max( --math.max to not get negative numbers
				X == 0 and Z or X,   --Needs some revision
				X == 0 and -Z or -X
			)
		)

		if FloorAngle ~= 0 then
			--print("angle", FloorAngle, (FloorAngle >= 30 and FloorAngle <= 60))
		end
		--print("angle", FloorAngle, (FloorAngle >= 30 and FloorAngle <= 60))
		
        if FloorAngle >= 40 then
			hum.HipHeight = 2
		elseif FloorAngle >= 30 then
			hum.HipHeight = 1.5
		else
			hum.HipHeight = 0.55
		end
	end
end