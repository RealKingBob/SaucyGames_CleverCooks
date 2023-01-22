-- now in a module script for accessibility and cleanliness
local maxRaycasts = 15 -- the number of raycasts to do for checking. higher = better accuracy but causes more lag in the instant that it calculates
local acc = -workspace.Gravity -- the acceleration of the world

-- just a normal function for raycasting for obstructions. Add a blacklist RaycastParams for ignore lists
local function raycast(origin, nextPoint)
	local result = workspace:Raycast(origin, (nextPoint - origin))
	return result
end

-- solve the quadratic formula for the time
local function quadraticSolver(a, b, c)
	local x1 = (-b + math.sqrt((b*b) -4 * a * c)) / (2 * a)
	local x2 = (-b - math.sqrt((b*b) -4 * a * c)) / (2 * a)
	-- usually going to be x2
	return if x2 > x1 then x2 else x1
end

-- solve for time when you put a certain height in
local function findTimeAtHeight(a, vel, h, startingH)
	local x = h - startingH
	local x1 = (math.sqrt((vel * vel) + 2 * a * x ) - vel) / a
	local x2 = -(math.sqrt((vel * vel) + 2 * a * x) + vel) / a
	return if x2 > x1 then x2 else x1
end

-- find what the height is at with input time
local function findHeightAtTime(vel, t)
	return vel.Y * t + 0.5 * acc * (t*t)
end

-- find the final position given a time
local function findPositionAtTime(vel, t, startingPos)
	local height = findHeightAtTime(vel, t)
	return startingPos + Vector3.new(vel.X * t, height, vel.Z * t)
end

-- find the final position given a height
local function findPositionAtHeight(vel, t, startingPos, height)
	return startingPos + Vector3.new(vel.X * t, height, vel.Z * t)
end

-- find the final time given at its target position
local function findLandingTime(Vo: Vector3, startingPosition: Vector3, targetPosition: Vector3)
	local acc = -workspace.Gravity
	local deltaX = targetPosition.X - startingPosition.X
	local deltaZ = targetPosition.Z - startingPosition.Z
	local horzVel = Vector3.new(Vo.X, 0, Vo.Z)
	local horzDist = Vector3.new(deltaX, 0, deltaZ).Magnitude
	local horzTime = horzDist / horzVel.Magnitude
	local vertVel = Vo.Y
	local vertDist = targetPosition.Y - startingPosition.Y
	local vertTime = (-vertVel + math.sqrt(vertVel^2 - 2*acc*vertDist)) / acc
	return math.max(horzTime, vertTime)
end

-- find the position that the part will land at based on starting velocity and position
local function findLandingPosition(Vo: Vector3, startingPosition: Vector3)
	local acc = -workspace.Gravity
	local seconds = quadraticSolver((0.5 * acc), Vo.Y, startingPosition.Y)
	local lastPosition = startingPosition

	for i = 1, maxRaycasts do
		local t = seconds * (1/maxRaycasts * i)
		local nextPosition = findPositionAtTime(Vo, t, startingPosition)

		local result = raycast(lastPosition, nextPosition)	
		if result then
			-- there was an obstruction in the way of the brick, stop the function here
			local baseHeight = result.Position.Y
			local timeAtHeight = findTimeAtHeight(acc, Vo.Y, baseHeight, startingPosition.Y)
			local offset = findPositionAtTime(Vo, timeAtHeight, startingPosition)
			return offset
		end
		lastPosition = nextPosition
	end

	local horizontalVel = Vector3.new(Vo.X, 0, Vo.Z)
	local endingOffset = horizontalVel * seconds
	return startingPosition + endingOffset + Vector3.new(0, findHeightAtTime(Vo, seconds), 0)
end

local PositionFinder = {}

-- use to easily find the final pos
function PositionFinder.getFinalPosition(startingVelocity: Vector3, startingPosition: Vector3)
	return findLandingPosition(startingVelocity, startingPosition)
end

-- use to easily find the final time
function PositionFinder.getFinalTime(startingVelocity: Vector3, startingPosition: Vector3, finalPosition: Vector3)
	return findLandingTime(startingVelocity, startingPosition, finalPosition)
end

return PositionFinder