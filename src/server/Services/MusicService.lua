local TweenService = game:GetService("TweenService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MusicService = Knit.CreateService {
    Name = "MusicService";
    Client = {};
}

local lastPlayed, backgroundMusicConn;
local fadeStart = 3 -- The amount of seconds subtracted from the length of the song before the fade starts.
local fadeLength = 3 -- The amount of time it takes for the fade to finish.
local Fading = false;

local FrenchMusic = {
    Day = {
        "rbxassetid://12031681786", -- [DAY] Clever Cooks French Background 1
        "rbxassetid://12031685949", -- [DAY] Clever Cooks French Background 2
        "rbxassetid://12031687736", -- [DAY] Clever Cooks French Background 3
        "rbxassetid://12031688685", -- [DAY] Clever Cooks French Background 4
        "rbxassetid://12031690280", -- [DAY] Clever Cooks French Background 5
        "rbxassetid://12031691460", -- [DAY] Clever Cooks French Background 6
    };

    Night = {
        "rbxassetid://12031693197", -- [NIGHT] Clever Cooks French Background 1
        "rbxassetid://12031694211", -- [NIGHT] Clever Cooks French Background 2
    };
}

local BackgroundSFX = {
    Day = {
        "rbxassetid://9118151948";
        "rbxassetid://9118151948";
        "rbxassetid://9118151948";
        "rbxassetid://9118151948";
    };

    Night = {};
    
}

function FadeOut(sound, length)
    if not Fading then return end
    TweenService:Create(sound, TweenInfo.new(length), {Volume = 0}):Play()
    task.wait(length)
    sound:Stop();
    sound.Volume = 0.125;
    Fading = false
end

-- Function to choose a random audio
function chooseAudio(audioList)
    if not audioList then return "" end;
    if #audioList <= 1 then return "" end;
    local randomAudio = audioList[math.random(1, #audioList)];
    -- If it was just played
    --print("Audios:", randomAudio, lastPlayed, randomAudio == lastPlayed)
    if randomAudio == lastPlayed then 
        return chooseAudio(audioList);
    end

    lastPlayed = randomAudio;
    return randomAudio;
end


-- Function to choose a random audio
function getThemeAudios(theme)
    if theme == "French" then
        return FrenchMusic.Day, FrenchMusic.Night;
    end
    return FrenchMusic.Day, FrenchMusic.Night;
end

-- Function to choose a random audio
function getThemeSFX(theme)
    return BackgroundSFX.Day, BackgroundSFX.Night;
end


function MusicService:StartBackgroundSFX(Theme, DayNight)
    if not Theme then return end;
    local dayTheme, nightTheme = getThemeSFX(Theme);
    local currentTheme = (DayNight == "Day" and dayTheme) or nightTheme;

    local backgroundSFX = workspace:FindFirstChild("BackgroundSFX");

    if not backgroundSFX then
        backgroundSFX = Instance.new("Sound", workspace)
        backgroundSFX.Volume = 0.01
        backgroundSFX.Name = "BackgroundSFX"
    end

    backgroundSFX.SoundId = chooseAudio(currentTheme);
    repeat task.wait(0.3) until backgroundSFX.IsLoaded == true
    backgroundSFX:Play();
end

function MusicService:StartBackgroundMusic(Theme, DayNight)
    if not Theme then return end;

    local dayTheme, nightTheme = getThemeAudios(Theme);

    local currentTheme = (DayNight == "Day" and dayTheme) or nightTheme;
    --print("currentTheme:", currentTheme)
    local backgroundMusic = workspace:FindFirstChild("BackgroundMusic");

    if not backgroundMusic then
        backgroundMusic = Instance.new("Sound", workspace)
        backgroundMusic.Volume = 0.01
        backgroundMusic.Name = "BackgroundMusic"
    end

    if backgroundMusicConn then 
        if backgroundMusic then
            local backgroundSFX = workspace:FindFirstChild("BackgroundSFX");

            if backgroundSFX then
                backgroundSFX:Stop();
            end
            Fading = true
            FadeOut(backgroundMusic, fadeLength)
            --backgroundMusic:Stop();
        end
        backgroundMusicConn:Disconnect()
        backgroundMusicConn = nil;
    end
    
    backgroundMusicConn = backgroundMusic.Ended:Connect(function()
        --print("Background music ended")
        backgroundMusic.SoundId = chooseAudio(currentTheme);
        repeat task.wait(0.3) until backgroundMusic.IsLoaded == true
        backgroundMusic:Play();
        --print("Background replay")
    end)

    backgroundMusic:GetPropertyChangedSignal("TimePosition"):Connect(function()
        if backgroundMusic.TimePosition >= backgroundMusic.TimePosition - fadeStart and not Fading then
            Fading = true
            FadeOut(backgroundMusic, fadeLength)
        end
    end)

    backgroundMusic.SoundId = chooseAudio(currentTheme);
    repeat task.wait(0.3) until backgroundMusic.IsLoaded == true
    backgroundMusic:Play();
    task.spawn(function()
        self:StartBackgroundSFX(Theme, DayNight)
    end)
    --print("Background play")
end

function MusicService:KnitStart()
    
end


function MusicService:KnitInit()
    
end


return MusicService
