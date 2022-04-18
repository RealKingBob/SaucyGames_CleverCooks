local Bezier = {};
Bezier.__index = Bezier

function Bezier.new(p0, p2)
	local self = setmetatable({
		p0 = p0,
		p2 = p2,
	}, Bezier)
	
	return self 
end

function Bezier:CalculateQuad(t, p1)
	return (1 - t)^2 * self.p0 + 2 * (1 - t) * t * p1 + t^2 * self.p2
end

function Bezier:CalculateCubic(t, p1, p3)
	return (1 - t)^3 * self.p0 + 3 * (1 - t)^2 * t * p1 + 3 * (1 - t) * t^2 * p3 + t^3 * self.p2
end

function Bezier:Quad(t, p1)
	local points = {}
	
---@diagnostic disable-next-line: count-down-loop
	for i = t, 1.0, .01 do
		local segpoint = self:CalculateQuad(i, p1)
		points[#points + 1] = segpoint
	end
	
	return points
end

function Bezier:Cubic(t, p1, p3)
	local points = {}
---@diagnostic disable-next-line: count-down-loop
	for i = t, 1.0, .01 do
		local segpoint = self:CalculateCubic(i, p1, p3)
		points[#points + 1] = segpoint
	end

	return points
end

function Bezier:Calculate(StartPoint, EndPoint, Step, Points)
    local NewPoints = {}
    for Count = 0, Step, 1 do
        local CalculatePoint = {StartPoint, EndPoint}
        for _, position in pairs(Points) do
            table.insert(CalculatePoint, #CalculatePoint, position)
        end
        local Len = #NewPoints
        while Len == #NewPoints do
            for i, position in pairs(CalculatePoint) do
                if i == #CalculatePoint then
                    CalculatePoint[i] = nil
                elseif #CalculatePoint == 2 then
					table.insert(NewPoints, position + ((CalculatePoint[2] - position).Unit * ((CalculatePoint[2] - position).Magnitude * (Count/Step))))
				else
					CalculatePoint[i] = position + ((CalculatePoint[i + 1]-position).Unit * ((CalculatePoint[i + 1] - position).Magnitude * (Count/Step)))
                end
            end
        end
    end
    return NewPoints;
end

function Bezier:CalculatePoint(StartPoint, EndPoint, Points, Time)
    local poses = {StartPoint,EndPoint}
	for Ind,Pos in pairs(Points) do
		table.insert(poses,#poses,Pos)
	end
	while true do
		for Ind,Pos in pairs(poses) do
			if Ind == #poses then
				poses[Ind] = nil
			elseif #poses == 2 then
				return Pos+((poses[Ind+1]-Pos).Unit*((poses[Ind+1]-Pos).Magnitude*Time))
			else
				poses[Ind] = Pos+((poses[Ind+1]-Pos).Unit*((poses[Ind+1]-Pos).Magnitude*Time))
			end
		end 
	end
end

return Bezier