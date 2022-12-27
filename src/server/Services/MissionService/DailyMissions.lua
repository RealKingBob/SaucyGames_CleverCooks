local numOfFoods = math.random(2,4);

local DailyMissions = {
    ["Mission1"] = {
        Name = "Delivering food",
        Progress = 0,
        Goal = math.random(2,5),
    },
    ["Mission2"] = {
        Name = "Use Blender",
        Progress = 0,
        Goal = math.random(5,10),
    },
    ["Mission3"] = {
        Name = "Survive a day",
        Progress = 0,
        Goal = 1,
    },
    ["Mission4"] = {
        Name = "Survive a day",
        Progress = 0,
        Goal = 1,
    },
}

return DailyMissions;