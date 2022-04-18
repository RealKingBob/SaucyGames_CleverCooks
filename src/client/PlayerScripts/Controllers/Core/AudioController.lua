local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local LibraryAudios = ReplicatedStorage:WaitForChild("Audios")
local AudioMusic = LibraryAudios:WaitForChild("Music")
local AudioEffects = LibraryAudios:WaitForChild("Effects")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local AudioController = Knit.CreateController { Name = "AudioController" }
--print("AudioController")

local CurrentMusicSound = LibraryAudios.Current.Music.Sound
local CurrentlyPlaying = "";
local CurrentlyPlayingPackage = nil;
local isMuted = false;
local isActive = true;

function AudioController:StartMusic(directory, fade)
    if directory then
        for _, sound in pairs(directory:GetChildren()) do
            if CurrentMusicSound.SoundId == sound.SoundId then
                continue;
            end
            CurrentMusicSound.SoundId = sound.SoundId;
            CurrentMusicSound:Play();
            --[[sound:Play();
            if isMuted == false then
                sound.Volume = 0.3;
            end]]
            --print("Now Playing:",tostring(sound));
        end
    end
    CurrentlyPlayingPackage = directory;
    --[[if directory ~= CurrentlyPlayingPackage then
        local FadeOut = fade;
        if isActive == true then
            --[[if FadeOut then
                if CurrentlyPlayingPackage then
                    --print(CurrentlyPlayingPackage)
                    for _, sound in pairs(CurrentlyPlayingPackage:GetChildren()) do
                        task.spawn(function()
                            TweenService:Create(sound,TweenInfo.new(1,Enum.EasingStyle.Linear),{Volume = 0}):Play()
                            task.wait(1)
                        end)
                    end
                end
            end
            
            if CurrentlyPlayingPackage then
                for _, sound in pairs(CurrentlyPlayingPackage:GetChildren()) do
                    sound:Stop();
                    if isMuted == false then
                        sound.Volume = 0.3;
                    end
                end
            end
            CurrentlyPlayingPackage = directory;
        end
    else
        --print("Sound attempted to play again")
    end]]
end

function AudioController:StopMusic(directory)
    if directory then
        --[[for _, sound in pairs(directory:GetDescendants()) do
            task.spawn(function()
                local pastVolume = sound.Volume
                TweenService:Create(sound,TweenInfo.new(1,Enum.EasingStyle.Linear),{Volume = 0}):Play()
                task.wait(1)
                sound:Stop()
                sound.Volume = pastVolume
            end)
        end]]
        --print("STOP", CurrentMusicSound.Volume)
        local pastVolume = CurrentMusicSound.Volume
        TweenService:Create(CurrentMusicSound,TweenInfo.new(1,Enum.EasingStyle.Linear),{Volume = 0}):Play()
        task.wait(1.1);
        CurrentMusicSound:Stop()
        --print(CurrentMusicSound.Volume)
        CurrentMusicSound.Volume = pastVolume
        --print(CurrentMusicSound.Volume)
        CurrentlyPlayingPackage = nil;
    end
end

function AudioController:PlaySound(directory, soundName)
    --print("[SoundPlayer] Playing Sound - "..soundName)
    if directory:FindFirstChild(soundName) then
        directory:FindFirstChild(soundName):Play()
    end
end

function AudioController:PlaySoundPackage(directory)
    --print("[SoundPlayer] Playing Sound - ", directory)
    for _, sound in pairs(directory:GetDescendants()) do
        sound:Play()
    end
end

function AudioController:StopSoundPackage(directory)
    --print("[SoundPlayer] Playing Sound - ", directory)
    for _, sound in pairs(directory:GetDescendants()) do
        task.spawn(function()
            local pastVolume = sound.Volume
            TweenService:Create(sound,TweenInfo.new(1,Enum.EasingStyle.Linear),{Volume = 0}):Play()
            task.wait(1)
            sound:Stop()
            sound.Volume = pastVolume
        end)
    end
end

function AudioController:StopSound(directory, soundName)
    --print("[SoundPlayer] Playing Sound - "..soundName)
    if directory:FindFirstChild(soundName) then
        local pastVolume = directory:FindFirstChild(soundName).Volume
        TweenService:Create(directory:FindFirstChild(soundName),TweenInfo.new(1,Enum.EasingStyle.Linear),{Volume = 0}):Play()
        task.wait(1)
        directory:FindFirstChild(soundName):Stop()
        directory:FindFirstChild(soundName).Volume = pastVolume
    end
end

function AudioController:setupConnections()
    --print("AudioController setupConnections")

    local AudioService = Knit.GetService("AudioService")

    AudioService.StartMusicSignal:Connect(function(directory, fade)
        self:StartMusic(directory, true)
    end)

    AudioService.StopMusicSignal:Connect(function(directory)
        self:StopMusic(directory)
    end)

    AudioService.MuteMusicSignal:Connect(function(mute)
        --print(mute)
        --self:MuteMusic(mute)
    end)
    
    AudioService.StartSoundPackageSignal:Connect(function(directory)
        self:PlaySoundPackage(directory)
    end)

    AudioService.StartSoundSignal:Connect(function(directory, soundName)
        self:PlaySound(directory, soundName)
    end)

    AudioService.StopSoundSignal:Connect(function(directory, soundId)
        self:StopSound(directory, soundId)
    end)

    AudioService.StopSoundPackageSignal:Connect(function(directory)
        self:StopSoundPackage(directory)
    end)

    local musicDirectory = AudioMusic:FindFirstChild("Lobby").Intro; -- AudioMusic:FindFirstChild(tostring(self.Map)).Background 

    self:StartMusic(musicDirectory, true)
end

function AudioController:KnitStart()
    --print("AudioController KnitStart called")
    local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

    repeat task.wait(0) until Character
    if Character then
        self:setupConnections()
    end
end

function AudioController:KnitInit()
    --print("AudioController KnitInit called")
end

return AudioController