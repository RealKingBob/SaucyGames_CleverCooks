local MapProgressUtil = {}
local PlayersProgress = {};

function MapProgressUtil:GetMapLength(PathData) -- Gets the length of the map using the path data points
    local Length = 0
    for i = 2, #PathData do
        local Distance = (PathData[i] - PathData[i-1]).Magnitude
        Length = Length + Distance
    end
    return Length
end

function MapProgressUtil:GetMapRays(VectorTab) -- Creates rays between the Vector3 path indicators
    local MapRays = {}
    local Data = VectorTab
    for i = 2, #Data do
        local Start, End = VectorTab[i-1], VectorTab[i]
        local line = Ray.new(Start, (End-Start).Unit * (Start-End).Magnitude)
        MapRays[i-1] = {
            Line = line;
        }
    end
    return MapRays
end

function MapProgressUtil:CheckBounds(Start, End, Check) -- Check the  bounds to see if the player is in between two path data points
    local StartCFrame = CFrame.new(Start.X, Start.Y, Start.Z)
    local EndCFrame = CFrame.new(End.X, End.Y, End.Z)
    
    StartCFrame = CFrame.new(StartCFrame.Position, End)
    EndCFrame = CFrame.new(EndCFrame.Position, Start)
 
    if ((StartCFrame:Inverse()) * Check).Z < 0 
    and ((EndCFrame:Inverse()) * Check).Z < 0 then
        return true
    else
        return false
    end
end

function MapProgressUtil:GetPositionOnMap(Vector, RayTab) -- Get the position of the player within the map length
    local Distances = {}
    for i = 1, #RayTab do
        local MaxDistance = math.min((RayTab[i]["Line"].Origin - Vector).Magnitude,
         ((RayTab[i]["Line"].Direction + RayTab[i]["Line"].Origin) - Vector).Magnitude)

        local Default = Ray.new(RayTab[i]["Line"].Origin, 
        (RayTab[i]["Line"].Direction).Unit):Distance(Vector)

        local inBounds = self:CheckBounds(RayTab[i]["Line"].Origin,
         RayTab[i]["Line"].Origin + RayTab[i]["Line"].Direction, Vector)
        if inBounds == true then
            Distances[i] = Default
        else
            Distances[i] = MaxDistance
        end
    end

    local Lowest = math.min(unpack(Distances))
    local LineNum = 0
    for i = 1, #RayTab do
        if Lowest == Ray.new(RayTab[i]["Line"].Origin, (RayTab[i]["Line"].Direction).Unit):Distance(Vector) then
            LineNum = i
        end
    end

    local TotalNum = 0
    if LineNum > 1 then
        for t = 1, LineNum-1 do
            TotalNum = TotalNum + (RayTab[t]["Line"].Direction).Magnitude
        end
    end

    if LineNum == 0 then
        return nil, nil
    end

    local PointOnRay = Ray.new(RayTab[LineNum]["Line"].Origin,
     (RayTab[LineNum]["Line"].Direction).Unit):ClosestPoint(Vector)
    TotalNum = TotalNum + (RayTab[LineNum]["Line"].Origin - PointOnRay).Magnitude

    return PointOnRay, TotalNum
end

return MapProgressUtil;