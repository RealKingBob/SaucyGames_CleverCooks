local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ClockUI = Knit.CreateController { Name = "ClockUI" }

local plr = game.Players.LocalPlayer;

local PlayerGui = plr:WaitForChild("PlayerGui");

local previousClockTime = nil;

local function formatTime(time)
    local split = tostring(time):split('.')
    local hour = (tonumber(split[1]) ~= nil and tonumber(split[1])) or time;
    local min = (tonumber(split[2]) ~= nil and tonumber(split[2])) or 0;

    min = (min / 100) * 60;

    return string.format("%02d:%02d", hour, min)
end

local function convert24HourTo12HourFormat(clockString)
    local currHours, currMinutes = string.match(clockString, "(%d+):(%d+)")
    local currAMPM = "AM";
    currMinutes = tonumber(currHours) * 60 + tonumber(currMinutes)

    if currMinutes >= 720 then
        currAMPM = "PM";
    end

    local clockHours = math.floor(currMinutes / 60) % 12
    if clockHours == 0 then clockHours = 12 end
    local clockMinutes = currMinutes % 60
    local clockNumber = string.format("%d:%02d %s", clockHours, clockMinutes, currAMPM)
    return clockNumber;
end

local function convert24HourToNumberFormat(clockString)
    local currHours, currMinutes = string.match(clockString, "(%d+):(%d+)")
    currMinutes = tonumber(currHours) * 60 + tonumber(currMinutes)
    return currMinutes;
end

local function convertNumberTo12HourFormat(num)
    local currAMPM = "AM";
    local currMinutes = num;

    if currMinutes >= 720 then
        currAMPM = "PM";
    end

    local clockHours = math.floor(currMinutes / 60) % 12
    if clockHours == 0 then clockHours = 12 end
    local clockMinutes = currMinutes % 60
    local clockNumber = string.format("%d:%02d %s", clockHours, clockMinutes, currAMPM)
    return clockNumber;
end


function ClockUI:AdjustTime(Day, Time, IsNight, InitialTick)
    local iTick = InitialTick;
    local LeftBar = PlayerGui:WaitForChild("LeftBar");
    local MainContainer = LeftBar:WaitForChild("MainContainer");

    local DayFrame = MainContainer:WaitForChild("Day");
    local TimeFrame = MainContainer:WaitForChild("Time");

    DayFrame.TextLabel.Text = "Day " .. tostring(Day);

    Time = convert24HourToNumberFormat(formatTime(string.format("%.2f", Time)));

    --print("clock:", previousClockTime, "-|-", tostring(Time))

    if previousClockTime ~= nil then
        local startTime = previousClockTime
        local endTime = Time
        --warn("TWEEN TIMES:", startTime, "|||||", endTime)

        local clockTimes = {}

        for i = startTime, endTime do
            local clockHours = math.floor(i / 60)
            local clockMinutes = i % 60
            local clockNumber = string.format("%d:%02d", clockHours, clockMinutes)

            table.insert(clockTimes, clockNumber)
        end

        
        local tickComparison = tick() - iTick; -- checks the tick comparison of function
        local remainingTime = 1 - tickComparison; -- subtracts the tick comparison with 1 second
        local waitTime = (remainingTime / #clockTimes); -- splits the remaining time the # of clock times

        for _, clockTimeTween in ipairs(clockTimes) do
            previousClockTime = convert24HourToNumberFormat(clockTimeTween);
            TimeFrame.TextLabel.Text = tostring(convert24HourTo12HourFormat(clockTimeTween));

            task.wait(waitTime);
        end
        previousClockTime = tostring(Time);
    else
        --print(Time)
        previousClockTime = Time;
        TimeFrame.TextLabel.Text = tostring(convertNumberTo12HourFormat(Time));
    end
end

function ClockUI:KnitStart()
    local GameService = Knit.GetService("GameService")

    GameService.AdjustTimeSignal:Connect(function(Package)
        local Day, Time, IsNight = Package["Day"], Package["Time"], Package["IsNight"];
        print(Day, Time, IsNight, tick())
        self:AdjustTime(Day, Time, IsNight, tick());
    end)
    
end


function ClockUI:KnitInit()
    
end


return ClockUI
