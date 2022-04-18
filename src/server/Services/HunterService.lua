local RunService = game:GetService("RunService");
local CollectionService = game:GetService("CollectionService");
local Players = game:GetService("Players");
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit);

local HunterService = Knit.CreateService {
    Name = "HunterService";
    Client = {
        updatePosition = Knit.CreateSignal();
        HunterEyesOn = Knit.CreateSignal();
    };
}

local PlayerAttachments = {};
local PlayerMousePositions = {};
local HunterEnabled = nil;
local HunterCon = nil;

function HunterService:ClearMousePositions()
    PlayerMousePositions = {};
end

function HunterService:CreateLaser(player)
    --print('create lasers')
    PlayerAttachments[player] = {};
    local att = Instance.new("Attachment");
    att.Name = tostring(player.UserId);
    att.Parent = workspace.Terrain;
    table.insert(PlayerAttachments[player], att);
    local att2 = Instance.new("Attachment");
    att2.Name = "Lasers";
    if player.Character:FindFirstChild("Head") then
        att2.Parent = player.Character.Head;
    end
    table.insert(PlayerAttachments[player], att2);
    local beam = Instance.new("Beam", att2);
    table.insert(PlayerAttachments[player], beam);
    beam.Name = "LaserBeam";
    beam.FaceCamera = true;
    beam.Color = ColorSequence.new(Color3.fromRGB(255,0,0));
    beam.Attachment0 = att2;
    beam.Attachment1 = att;
    beam.Width0 = 0.1;
    beam.Width1 = 0.1;
end

function HunterService:AddLaserAttach(player)
    --print('attach lasers')
    if PlayerAttachments[player] then
        local att2 = Instance.new("Attachment");
        att2.Name = "Lasers";
        att2.Parent = player.Character.Head;
        table.insert(PlayerAttachments[player], att2);
        local beam = Instance.new("Beam", att2);
        table.insert(PlayerAttachments[player], beam);
        beam.Name = "LaserBeam";
        beam.FaceCamera = true;
        beam.Color = ColorSequence.new(Color3.fromRGB(255,0,0));
        beam.Attachment0 = att2;
        if workspace.Terrain:FindFirstChild(tostring(player.UserId)) then
            beam.Attachment1 = workspace.Terrain:FindFirstChild(tostring(player.UserId));
        end
        beam.Width0 = 0.1;
        beam.Width1 = 0.1;
    end
end

function HunterService:UpdateLaser(player)
    --print('update lasers')
    if PlayerAttachments[player] then
        local att2 = Instance.new("Attachment", player.Character.Head);
        att2.Name = "Lasers";
        table.insert(PlayerAttachments[player], att2);
        if workspace.Terrain:FindFirstChild(tostring(player.UserId)) then
            local Beam = workspace.Terrain:FindFirstChild(tostring(player.UserId)):FindFirstChild("Beam");
            if Beam then
                Beam.Attachment0 = att2;
            end
        end
    end
end

function HunterService:DestroyLasers()
    --print('destroy lasers')
    for _, player in pairs(Players:GetPlayers()) do
        if player then
            if player.Character then
                local Head = player.Character:FindFirstChild("Head")
                if Head then
                    if Head:FindFirstChild("Lasers") then
                        if PlayerAttachments[player] then
                            for _,v in pairs(PlayerAttachments[player]) do
                                v:Destroy();
                            end
                        end
                    end
                end
            end
        end
    end
    
    PlayerAttachments = {}
    for _, att in pairs(workspace.Terrain:GetChildren()) do
        if att:IsA("Attachment") then
            att:Destroy();
        end
    end
end

function HunterService:StartHunterPos()
    PlayerMousePositions = {};
    --[[HunterCon = CollectionService:GetInstanceAddedSignal(Knit.Config.HUNTER_TAG):Connect(function(player)
        self.Client.HunterEyesOn:Fire(player);
    end)

    for _, player in pairs(CollectionService:GetTagged(Knit.Config.HUNTER_TAG)) do
        self.Client.HunterEyesOn:Fire(player);
    end]]
    HunterEnabled = true;

    task.spawn(function()
        while HunterEnabled == true do
            for player, mousePos in next, PlayerMousePositions do
                if CollectionService:HasTag(player, Knit.Config.HUNTER_TAG) then
                    if player then
                        if player.Character then
                            if PlayerAttachments[player] == nil and workspace.Terrain:FindFirstChild(tostring(player.UserId)) == nil then
                                self:CreateLaser(player);
                            elseif player.Character:FindFirstChild("Head") then
                                if player.Character:FindFirstChild("Head"):FindFirstChild("Lasers") == nil and workspace.Terrain:FindFirstChild(tostring(player.UserId)) then
                                    self:AddLaserAttach(player);
                                end
                            elseif player.Character:FindFirstChild("Head") then
                                if player.Character:FindFirstChild("Head"):FindFirstChild("Lasers") == nil then
                                    self:UpdateLaser(player);
                                end
                            end
                            self.Client.updatePosition:FireAll(player, mousePos);
                        end
                    end
                end
            end
            task.wait(0);
        end
    end)
end

function HunterService:EndHunterPos()
    if HunterCon then
        HunterCon:Disconnect();
        HunterCon = nil;
    end
    if HunterEnabled then
        HunterEnabled = false;
    end
    self:DestroyLasers();
end

function HunterService:KnitStart()
    self.Client.HunterEyesOn:Connect(function(player, mousePosition)
        PlayerMousePositions[player] = mousePosition;
    end)
end


function HunterService:KnitInit()
    
end


return HunterService
