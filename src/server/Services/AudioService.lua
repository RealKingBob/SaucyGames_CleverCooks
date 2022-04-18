local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local AudioService = Knit.CreateService {
    Name = "AudioService";
    Client = {
        StartMusicSignal = Knit.CreateSignal();
        StopMusicSignal = Knit.CreateSignal();
        MuteMusicSignal = Knit.CreateSignal();

        StartSoundSignal = Knit.CreateSignal();
        StopSoundSignal = Knit.CreateSignal();

        StartSoundPackageSignal = Knit.CreateSignal();
        StopSoundPackageSignal = Knit.CreateSignal();
    }
}

function AudioService:StartMusic(directory, player)
    if player then
        AudioService.Client.StartMusicSignal:Fire(player, directory)
    else
        AudioService.Client.StartMusicSignal:FireAll(directory)
    end
end

function AudioService:StopMusic(directory, player)
    if player then
        AudioService.Client.StopMusicSignal:Fire(player, directory)
    else
        AudioService.Client.StopMusicSignal:FireAll(directory)
    end
end

function AudioService:MuteMusic(bool, player)
    if bool ~= nil then
        if player then
            AudioService.Client.MuteMusicSignal:Fire(player, bool)
        else
            AudioService.Client.MuteMusicSignal:FireAll(bool)
        end
    end
end

function AudioService:StartSoundPackage(directory, player)
    if player then
        AudioService.Client.StartSoundPackageSignal:Fire(player, directory)
    else
        AudioService.Client.StartSoundPackageSignal:FireAll(directory)
    end
end

function AudioService:StopSoundPackage(directory, player)
    if directory then
        if player then
            AudioService.Client.StopSoundPackageSignal:Fire(player, directory)
        else
            AudioService.Client.StopSoundPackageSignal:FireAll(directory)
        end
    end
end

function AudioService:StartSound(soundId, player)
    if soundId then
        if player then
            AudioService.Client.StartSoundSignal:Fire(player, soundId)
        else
            AudioService.Client.StartSoundSignal:FireAll(soundId)
        end
    end
end

function AudioService:StopSound(soundId, player)
    if soundId then
        if player then
            AudioService.Client.StopSoundSignal:Fire(player, soundId)
        else
            AudioService.Client.StopSoundSignal:FireAll(soundId)
        end
    end
end

function AudioService:KnitInit()
    print("[SERVICE]: Audio Service Initialized")
end

function AudioService:KnitStart()
    
end

return AudioService