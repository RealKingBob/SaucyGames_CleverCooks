local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local MapProgressUtil = {}
local PlayersProgress = {};
local PlayerFinished = {};

function MapProgressUtil:GetMapLength(PathData) -- Gets the length of the map using the path data points
    local Length = 0
    for i = 2, #PathData do
        local Distance = (PathData[i] - PathData[i-1]).Magnitude
        Length = Length + Distance
    end
    return Length
end

function MapProgressUtil:ClearFinished() -- Clears the player progress
    PlayerFinished = {}
end

function MapProgressUtil:PlayerFinished(player) -- Clears the player progress
    if #PlayerFinished == 0 then
        table.insert(PlayerFinished, {Player = player, Progress = 2000 - #PlayerFinished})
        return;
    end
    local foundPlayer = false
    for _, playerData in pairs(PlayerFinished) do
        if playerData.Player == player then
            foundPlayer = true
        end
    end
    if foundPlayer == false then
        table.insert(PlayerFinished, {Player = player, Progress = 2000 - #PlayerFinished})
        return
    end
end

function MapProgressUtil:GetPlayerRank(Player, MapLength, PathDataPoints) -- Clears the player progress
    local PlayerProgress = {};

    for _, player : Player in pairs(Players:GetPlayers()) do
        if CollectionService:HasTag(player, "Duck") then
            if player.Character:FindFirstChild("HumanoidRootPart") then
                local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local Position, Distance = self:GetPositionOnMap(player, HumanoidRootPart.Position, self:GetMapRays(player, PathDataPoints))
                if Position then
                    local progress = Distance / MapLength
                    table.insert(PlayerProgress, {Player = player, Progress = progress + 0.02})
                end
            end
        end
    end

    for _, playerData in pairs(PlayerFinished) do
        table.insert(PlayerProgress, {Player = playerData.Player, Progress = playerData.Progress})
    end

    table.sort(PlayerProgress, function(a, b)
        return a.Progress > b.Progress
    end);

    for index, progressInfo in pairs(PlayerProgress) do
        if progressInfo.Player == Player then
            --print('Player Rank:', index, progressInfo.Player, progressInfo.Progress)
            return index
        end
    end
end

function MapProgressUtil:ClearPlayerProgress(Player) -- Clears the player progress
    if PlayersProgress[Player.UserId] then
        PlayersProgress[Player.UserId] = {}
    end
end

function MapProgressUtil:CheckPlayerProgress(Player) -- Checks the player progress
    local tab = {};
    if PlayersProgress[Player.UserId] then
        for _, Path in pairs(PlayersProgress[Player.UserId]) do
            table.insert(tab, Path["Passed"]);
        end
        local t,f = 0,0;
        for _, Passed in pairs(tab) do
            if Passed == true then
                t += 1;
            else
                f += 1;
            end
        end
        return (t / (t + f));
    end
    return nil
end

function MapProgressUtil:GetPlayerProgress(Player) -- Gets the player progress
    if PlayersProgress[Player.UserId] then
        return PlayersProgress[Player.UserId]
    end
    return nil
end

function MapProgressUtil:GetMapRays(Player, VectorTab) -- Creates rays between the Vector3 path indicators
    local MapRays = {}
    local Data = VectorTab
    for i = 2, #Data do
        local Start, End = VectorTab[i-1], VectorTab[i]
        local line = Ray.new(Start, (End-Start).Unit * (Start-End).Magnitude)
        MapRays[i-1] = {
            Line = line;
            Passed = false;
        }
    end
    if not PlayersProgress[Player.UserId] then
        PlayersProgress[Player.UserId] = MapRays;
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

function MapProgressUtil:GetPositionOnMap(Player, Vector, RayTab) -- Get the position of the player within the map length
    local Distances = {}
    if not PlayersProgress[Player.UserId] then
        PlayersProgress[Player.UserId] = {};
    end
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

    if PlayersProgress[Player.UserId] then
        if PlayersProgress[Player.UserId][LineNum] then
            PlayersProgress[Player.UserId][LineNum]["Passed"] = true
        end
    end
    --print("progress:",PointOnRay, TotalNum)
    --print("progress:",)
    return PointOnRay, TotalNum
end

return MapProgressUtil;