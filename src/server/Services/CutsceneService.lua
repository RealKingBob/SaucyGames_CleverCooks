local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Signal = require(Knit.Util.Signal)

local CutsceneService = Knit.CreateService {
    Name = "CutsceneService";
    Client = {
        CutsceneIntroSignal = Knit.CreateSignal();
        CutsceneEndSignal = Knit.CreateSignal();
    };
}

CutsceneService.Finished = Signal.new();

function CutsceneService:CutsceneIntro(mapModel, gameMode)
    for _, player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
        CollectionService:AddTag(player, Knit.Config.CUTSCENE_TAG)
        CutsceneService.Client.CutsceneIntroSignal:Fire(player, mapModel, gameMode)
    end
end

function CutsceneService:CutsceneEnd()
    for _, player in pairs(CollectionService:GetTagged(Knit.Config.ALIVE_TAG)) do
        CutsceneService.Client.CutsceneEndSignal:Fire(player)
    end
end

function CutsceneService:KnitInit()
    print("[SERVICE]: Cutscene Service Initialized")
    self.Client.CutsceneIntroSignal:Connect(function(player)
        --print("CUTSCENE TAG", #CollectionService:GetTagged(Knit.Config.CUTSCENE_TAG))
        CollectionService:RemoveTag(player, Knit.Config.CUTSCENE_TAG)
    end)
end

function CutsceneService:KnitStart()
    
end

return CutsceneService