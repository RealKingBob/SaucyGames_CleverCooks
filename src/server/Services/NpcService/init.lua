local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NpcService = Knit.CreateService {
    Name = "NpcService";
    Client = {
        NpcAction = Knit.CreateSignal();
        PlayAnimation = Knit.CreateSignal();
        SetupNPC = Knit.CreateSignal();
    };
}

-- Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService");
local TweenService = game:GetService("TweenService")

-- Modules
local AttackService = require(script.AttackService);
local AppearanceService = require(script.AppearanceService);
local PathfindingService = require(script.PathfindingService);
local Config = require(script.Config)

local playerCollisionGroupName = "NPC";
local previousCollisionGroups = {};

local inCutscene = {};
local isReady = {};
local npcPaths = {};
local npcDifficulty = {};
local npcTargets = {};
local TaskExclusion = {};
local JobType = {};
local travelToRandomPoint = {};
local targetPresentCount = {};
local attackDebounce = {};
local animDebounce = {};
local npcAwareness = {};
local asAtExitDoor = {};

local NPC_WalkSpeeds = {};
local NPC_RunSpeeds = {};

local NPC_ViewDistances = {};
local NPC_MagnitudeDistances = {};
local NPC_CloseMagnitudeDistances = {};

local DirectionType = {
    Up = "Up";
    Down = "Down";
};

local prevRandomPart = {};
local prevSignal = {};

local RandomParts = {}

-- Extra Variables
local RandomSpots = workspace.RandomSpots:GetChildren();

-- NPC Settings
local ViewDistances = Config.NPC_ViewDistance;
local MagnitudeDistances = Config.NPC_MagnitudeDistance;
local CloseMagnitudeDistances = Config.NPC_CloseMagnitudeDistance;

local AttackDifficulties = Config.AttackDifficulties;

local WalkSpeeds = Config.NPC_WalkSpeed;
local RunSpeeds = Config.NPC_RunSpeed;

local backupFriendsIds = {21831137, 710489960, 126337093, 126833961, 39831016, 71631677, 121649, 
    25568057, 400900478, 97162681, 472860216, 14733384, 2051474553, 137759764, 65680312, 
    91529715, 294982847, 14169349, 16964256, 1510547390, 53347204, 148513655, 42350716, 
    72120971, 94158016, 62288192, 418172096, 313133642, 26432253, 53101289, 1727594062, 
    1956952532, 64172462, 108916687, 30969265, 11044605, 398496794, 122881779, 697883351, 
    151848836, 180028302, 64347573, 24160299, 6710154, 964148758, 13151032, 127786177, 
    11561183, 55976311, 92714340, 139458, 67306263};

--[[
local id = '3821527813' --Replace the emote ID with another ID that you want the animation of
local is = game:GetService('InsertService')
print(is:LoadAsset(id):FindFirstChildOfClass'Animation'.AnimationId) --> http://www.roblox.com/asset/?id=3344650532
]]

-- Task Animations
local InspectAnimId = "http://www.roblox.com/asset/?id=5230599789";
local PrepareAnimId = "http://www.roblox.com/asset/?id=6531483720";
local CookAnimId = "http://www.roblox.com/asset/?id=6532839007";

-- Emote Animations
local AlertAnimId = "http://www.roblox.com/asset/?id=4841401869";
local ConfusedAnimId = "http://www.roblox.com/asset/?id=4940561610";

local function setCollisionGroup(object)
    if object then
        if object:IsA("BasePart") then
            previousCollisionGroups[object] = object.CollisionGroup;
            object.CollisionGroup = playerCollisionGroupName;
        end
    end
end

local function setCollisionGroupRecursive(object)
    if object then
        setCollisionGroup(object);
        for _, child in ipairs(object:GetChildren()) do
            setCollisionGroupRecursive(child);
        end
    end
end

local function resetCollisionGroup(object)
    if object then
        local previousCollisionGroup = previousCollisionGroups[object];
        if not previousCollisionGroup then return end 

        object.CollisionGroup = previousCollisionGroup;
        previousCollisionGroups[object] = nil;
    end
end

local function GetTouchingParts(part)
    if not part:IsA("BasePart") then return {} end;
    local connection = part.Touched:Connect(function() end)
    local results = part:GetTouchingParts()
    connection:Disconnect()
    return results
end

local function updateAwareness(NPC)
    if not NPC or not npcAwareness[NPC] then return end
    local NPC_Head = NPC:FindFirstChild("Head");
    if not NPC_Head then return end
    local awarenessNum = npcAwareness[NPC];
    local HeadBillboard = NPC_Head:WaitForChild("HeadBillboard");
    local HeadText = HeadBillboard:WaitForChild("TextLabel");

    local awarenessNumColor = awarenessNum - 10;
    awarenessNumColor = math.max(0, math.min(awarenessNumColor, 100));

    local whiteColor = Color3.fromRGB(255,255,255);
    local redColor = Color3.fromRGB(255, 0, 0);


    if awarenessNum > 70 then
        HeadBillboard.Enabled = true
        HeadText.Text = "!"
        HeadText.TextColor3 = redColor
    elseif awarenessNum > 20 then
        HeadBillboard.Enabled = true
        HeadText.Text = "?"
        HeadText.TextColor3 = whiteColor
    elseif awarenessNum > 10 then
        HeadBillboard.Enabled = true
        HeadText.Text = "?"
        HeadText.TextColor3 = whiteColor
    else
        HeadBillboard.Enabled = false
    end
end

local function makeRayPart(startPos, endPos)
    local rayPart = Instance.new("Part");
    rayPart.Name = "RayPart";
    rayPart.Color = Color3.fromRGB(255, 255, 255);
    rayPart.Transparency = 0.3;
    rayPart.Anchored = true;
    rayPart.CanCollide = false;
    rayPart.TopSurface = Enum.SurfaceType.Smooth;
    rayPart.BottomSurface = Enum.SurfaceType.Smooth;
    rayPart.formFactor = Enum.FormFactor.Custom;
    local distance = (startPos - endPos).Magnitude;
    rayPart.Size = Vector3.new(0.2, 0.2, distance);
    rayPart.CFrame = CFrame.lookAt(startPos, endPos)*CFrame.new(0, 0, -distance/2);
    --rayPart.CFrame = CFrame.new(startPos, Vector3.new(endPos.x,1.5,endPos.z)) * CFrame.new(0, 0, -dist/2)
    CollectionService:AddTag(rayPart, "IgnoreParts");
    rayPart.Parent = workspace;
    game.Debris:AddItem(rayPart, 0.1); -- Add the part to Debris so it will remove itself after 0.1 second
end

local function MakeRay(startPos, endPos, show) -- Creates a new ray
    local rayDirection = endPos - startPos;
    
    local directionType = DirectionType.Down;

    -- Build a "RaycastParams" object
    local raycastParams = RaycastParams.new();
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist;

    raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
    
    local raycastResult = workspace:Raycast(startPos, rayDirection, raycastParams);
    
    if raycastResult then
        
        --if show and CollectionService:HasTag(raycastResult.Instance, "TrackInstance") == true then -- This is for debugging. It will make the rays visible
            --makeRayPart(startPos, endPos)
        --end
        
        if rayDirection.Y < -18 then
            directionType = DirectionType.Down;
        else
            directionType = DirectionType.Up;
        end
        
        return raycastResult.Instance, directionType;
    else
        return nil
    end
end

--------------------------------------------------------------------------

local function StopTaskAnim(NPC)
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");
    if not NPC_Humanoid or not NPC_Animator then return end
    local animationTracks = NPC_Animator:GetPlayingAnimationTracks()
    for i, animationTrack in pairs(animationTracks) do
        local animationId = animationTrack.Animation.AnimationId
        local stopAnimationIds = {InspectAnimId, PrepareAnimId, CookAnimId, AlertAnimId, ConfusedAnimId}
        for _, stopAnimationId in pairs(stopAnimationIds) do
            if animationId == stopAnimationId then
                animationTrack:Stop()
            end
        end
    end
end

local function SprayAttack(NPC, targetPos)
    local NPC_Humanoid = NPC:FindFirstChild("Humanoid");
    if not NPC_Humanoid then return end

    if attackDebounce[NPC] == false then
        attackDebounce[NPC] = true;

        NPC_Humanoid.WalkSpeed = 0;

        local success = AttackService:Swing(NPC, targetPos);

        repeat task.wait() until success == true;

        NPC_Humanoid.WalkSpeed = 16;

        attackDebounce[NPC] = false;
    end
end

local function ThrowObjectAttack(NPC, targetPos)
    --print(NPC, targetPos)
    local NPC_Humanoid = NPC:FindFirstChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");
    --print(NPC_Humanoid, NPC_Animator)
    if not NPC_Humanoid or not NPC_Animator then return end
    if attackDebounce[NPC] == false then
        attackDebounce[NPC] = true;

        NPC_Humanoid.WalkSpeed = 0;

        local success = AttackService:ThrowObject(NPC, NPC_Animator, targetPos);

        repeat task.wait() until success == true;

        NPC_Humanoid.WalkSpeed = 16;

        attackDebounce[NPC] = false;
    end
end

local function BroomAttack(NPC, targetPos)
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");
    if not NPC_Humanoid or not NPC_Animator then return end
    if attackDebounce[NPC] == false then
        attackDebounce[NPC] = true;

        NPC_Humanoid.WalkSpeed = 0;

        local success = AttackService:BroomHitTop(NPC, NPC_Animator, targetPos);

        repeat task.wait() until success == true;

        NPC_Humanoid.WalkSpeed = 16;

        attackDebounce[NPC] = false;
    end
end

local function StompAttack(NPC)
    local NPC_Root = NPC:WaitForChild("HumanoidRootPart");
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");
    if not NPC_Root or not NPC_Humanoid or not NPC_Animator then return end
    if attackDebounce[NPC] == false then
        attackDebounce[NPC] = true;

        local humanoidHeightScale = NPC_Humanoid.BodyHeightScale.Value
        local scaleY = 3 * humanoidHeightScale

        local charPos = NPC_Root.Position
        local changeY = Vector3.new(0, scaleY, 0)

        local charFloorPos = NPC_Root.CFrame

        charFloorPos = (charFloorPos - changeY) + (charFloorPos.LookVector * 12.5)

        NPC_Humanoid.WalkSpeed = 0;

        local success = AttackService:Stomp(NPC_Animator, charFloorPos.Position);

        repeat task.wait() until success == true;

        NPC_Humanoid.WalkSpeed = 16;

        attackDebounce[NPC] = false;
    end
end

local function PlayAnim(NPC, TaskType)
    --print("ANIM PLAYED")
    local NPC_Humanoid = NPC:FindFirstChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");
    if not NPC_Humanoid or not NPC_Animator then return end
    --print("ANIM PLAYED 2")
    if animDebounce[NPC] == false then
        --print("ANIM PLAYED 3")
        animDebounce[NPC] = true

        local taskAnim = Instance.new("Animation");
        taskAnim.Name = "TaskAnim";
    
        local controller = NPC_Animator;
        local zeroSpeed = false;
    
        local taskAnimIds = {
            Inspect = InspectAnimId,
            Prepare = PrepareAnimId,
            Cook = CookAnimId,
            Alert = AlertAnimId,
            Confused = ConfusedAnimId,
        }
        
        local taskAnimId = taskAnimIds[TaskType]
        taskAnim.AnimationId = taskAnimId
        
        if TaskType == "Alert" or TaskType == "Confused" then
            zeroSpeed = true;
        end
        
        local taskAnimTrack = controller:LoadAnimation(taskAnim);
        taskAnimTrack:AdjustSpeed(0.58);
        taskAnimTrack.Looped = false;
        taskAnimTrack.Priority = Enum.AnimationPriority.Action;
        repeat task.wait(0.1) until taskAnimTrack.length ~= 0;
        --warn("Length:",taskAnimTrack.Name,taskAnimTrack.Length)
        
        if zeroSpeed == true then
            NPC_Humanoid.WalkSpeed = 0;
        end
    
        Knit.GetService("NpcService").Client.PlayAnimation:FireAll(controller, taskAnim.AnimationId, "TaskAnim", NPC, true)
        
        --taskAnimTrack:Play();
        taskAnimTrack:AdjustSpeed(0.58);
    
        task.wait(taskAnimTrack.Length);
    
        --taskAnimTrack.Stopped:Wait()
        --print("anim done")
        --[[if TaskType == "Alert" or TaskType == "Confused" then
            taskAnimTrack.Stopped:Wait()
            print("anim done")
        else
            task.wait(taskAnimTrack.Length);
        end]]
    
        --taskAnimTrack.Stopped:Wait()
        --task.wait(taskAnimTrack.Length);
        
        if TaskType ~= "Alert" then
            NPC_Humanoid.WalkSpeed = 16;
        end

        animDebounce[NPC] = false
        --print("ANIM PLAYED 4")
    end
end

--------------------------------------------------------------------------

local function TravelToRandomPoint(NPC, exclude)
    --print("NPC: ", NPC, "extra: ", inCutscene[NPC], "uh")
    --print("travelToRandomPoint: ", travelToRandomPoint[NPC], "targetPresent: ", npcTargets[NPC])
    --print("animDebounce: ", animDebounce[NPC])
    if not NPC then return end;
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");
    if not NPC_Humanoid then return end
    if travelToRandomPoint[NPC] or npcTargets[NPC] or animDebounce[NPC] == true then return end
    if inCutscene[NPC] == true then return end

    --print("OK")
    
    travelToRandomPoint[NPC] = true;
    
    task.wait(math.random(1,4));
    
    if prevRandomPart[NPC] then
        prevRandomPart[NPC]:SetAttribute("Activated", false)
    end
    
    repeat 
        RandomParts[NPC] = RandomSpots[math.random(1,#RandomSpots)] 
        task.wait()
    until ((RandomParts[NPC] ~= prevRandomPart[NPC]) 
        and (RandomParts[NPC]:GetAttribute("Activated") == false) 
        and (RandomParts[NPC]:GetAttribute("TaskType") ~= exclude))
        or NPC == nil

    if not NPC then return end
    
    prevRandomPart[NPC] = RandomParts[NPC];
    
    StopTaskAnim(NPC)
    
    RandomParts[NPC]:SetAttribute("Activated", true)
    
    NPC_Humanoid.WalkSpeed = (NPC_WalkSpeeds[NPC] ~= nil and NPC_WalkSpeeds[NPC]) or 16;

    if inCutscene[NPC] == true then return end
    
    if not npcPaths[NPC] then return end
    npcPaths[NPC]:Run(RandomParts[NPC]);
    --warn("Random point Found");
end


local function TargetFound(NPC, hit, target)
    --print("TARGET FOUND", NPC, hit, target)
    if not NPC then return end;
    if not hit or not target then return end;

    --print("TARGET 1")
    local NPC_Root = NPC:WaitForChild("HumanoidRootPart");
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");
    if not NPC_Root or not NPC_Humanoid or not NPC_Animator then return end
    --print("TARGET 2")
    if npcTargets[NPC] ~= nil then return end
    if inCutscene[NPC] == true then return end
    if hit:FindFirstChild("Humanoid") then if hit:FindFirstChild("Humanoid").Health <= 0 then return end end
    
    --print("TARGET 3")
    npcTargets[NPC] = true;
    travelToRandomPoint[NPC] = nil;
    animDebounce[NPC] = false;
    
    if prevRandomPart[NPC] then
        prevRandomPart[NPC]:SetAttribute("Activated", false);
    end
    --print("TARGET 4")
    
    StopTaskAnim(NPC)
    
    if prevSignal[NPC] then
        prevSignal[NPC]:Disconnect();
    end
    
    --print(hit, target, typeof(hit))
    
    --local NPCroot = NPC.HumanoidRootPart
    --local CharRoot = Character.HumanoidRootPart

    local Character = (hit:IsA("Model") and hit.PrimaryPart ~= nil and hit.PrimaryPart) or hit

    --print("Character", Character)

    npcTargets[NPC] = Character;

    local HRP = Character;

    NPC:SetPrimaryPartCFrame(CFrame.lookAt(
        NPC_Root.Position,
        HRP.Position * Vector3.new(1, 0, 1)
            + NPC_Root.Position * Vector3.new(0, 1, 0)
    ))
    --print("TARGET 5")
    --local direction = HRP.Position + HRP.CFrame.LookVector * HRP.Position.Magnitude
    --NPC_Root.CFrame = CFrame.lookAt(NPC_Root.Position, direction)
    
    local player = Players:GetPlayerFromCharacter(Character.Parent);
    if player then
        Knit.GetService("NotificationService"):Alert(false, player)
        Knit.GetService("NotificationService"):Message(false, player, "A ".. tostring(string.upper(JobType[NPC])).." SPOTTED YOU!", {Effect = true, Color = Color3.fromRGB(250, 11, 11)})
    end
    PlayAnim(NPC, "Alert")
    
    NPC_Humanoid.WalkSpeed = (NPC_RunSpeeds[NPC] ~= nil and NPC_RunSpeeds[NPC]) or 26;
    --print("TARGET 6")

    if inCutscene[NPC] == true then return end

    if not npcPaths[NPC] then return end
    if attackDebounce[NPC] then return end;
    npcPaths[NPC]:Run(npcTargets[NPC]);
    warn("Target Found");
end

local leftDeb = false;
local leftDoorPivotOpen, leftDoorPivotClose = nil, nil;
function LeftDoorTween(door, command)
    if not door or not command then return end
    if leftDeb == false then
        leftDeb = true;
        if command == "open" then
            local TweenValue: CFrameValue = door.TweenValue
            if not leftDoorPivotOpen then
                leftDoorPivotOpen = door:GetPivot()
            end
            TweenValue.Value = leftDoorPivotOpen;
            
            local Info = TweenInfo.new(1); -- all defaults
            
            local Tween = TweenService:Create(TweenValue, Info, {Value = leftDoorPivotOpen*CFrame.Angles(0, (-110 * (math.pi/180)), 0)})
            
            TweenValue.Changed:Connect(function()
                door:PivotTo(TweenValue.Value)
            end)
        
            Tween:Play();
        else
            local TweenValue: CFrameValue = door.TweenValue
            if not leftDoorPivotClose then
                leftDoorPivotClose = door:GetPivot()--*CFrame.Angles(0, (-110 * (math.pi/180)), 0)
            end
            TweenValue.Value = leftDoorPivotClose;
            
            local Info = TweenInfo.new(1); -- all defaults
            
            local Tween = TweenService:Create(TweenValue, Info, {Value = leftDoorPivotClose*CFrame.Angles(0, (110 * (math.pi/180)), 0)})
            
            TweenValue.Changed:Connect(function()
                door:PivotTo(TweenValue.Value)
            end)
        
            Tween:Play();
        end
        task.wait(1)
        leftDeb = false;
    end
end

local rightDeb = false;
local rightDoorPivotOpen, rightDoorPivotClose = nil, nil;
function RightDoorTween(door, command)
    if not door or not command then return end
    if rightDeb == false then
        rightDeb = true;
        if command == "open" then
            local TweenValue: CFrameValue = door.TweenValue
            if not rightDoorPivotOpen then
                rightDoorPivotOpen = door:GetPivot()
            end
            TweenValue.Value = rightDoorPivotOpen
            
            local Info = TweenInfo.new(1) -- all defaults
            
            local Tween = TweenService:Create(TweenValue, Info, {Value = rightDoorPivotOpen*CFrame.Angles(0, (110 * (math.pi/180)), 0)})
            
            TweenValue.Changed:Connect(function()
                door:PivotTo(TweenValue.Value)
            end)
        
            Tween:Play();        
        else
            local TweenValue: CFrameValue = door.TweenValue
            if not rightDoorPivotClose then
                rightDoorPivotClose = rightDoorPivotOpen*CFrame.Angles(0, (110 * (math.pi/180)), 0)
            end
            TweenValue.Value = rightDoorPivotClose
            
            local Info = TweenInfo.new(1) -- all defaults
            
            local Tween = TweenService:Create(TweenValue, Info, {Value = rightDoorPivotClose*CFrame.Angles(0, (-110 * (math.pi/180)), 0)})
            
            TweenValue.Changed:Connect(function()
                door:PivotTo(TweenValue.Value)
            end)
        
            Tween:Play();  
        end
        task.wait(1)
        rightDeb = false;
    end
end

function NpcService:CloseDoors()
    local NPCDoor = CollectionService:GetTagged("NPCDoor")[math.random(1, #CollectionService:GetTagged("NPCDoor"))];
    local DoorModel1 = NPCDoor:FindFirstChild("Door1");
    local DoorModel2 = NPCDoor:FindFirstChild("Door2");

    RightDoorTween(DoorModel1, "close")
    LeftDoorTween(DoorModel2, "close")
end

function NpcService:RegularEnterCutscene(NPC)
    if not NPC then return end
    local NPC_Root = NPC:FindFirstChild("HumanoidRootPart");
    local NPC_Humanoid = NPC:FindFirstChild("Humanoid");
    if not NPC_Root or not NPC_Humanoid then return end
    inCutscene[NPC] = true;

    local NPCDoor = CollectionService:GetTagged("NPCDoor")[math.random(1, #CollectionService:GetTagged("NPCDoor"))];
    local DoorModel = NPCDoor:FindFirstChild("Door1");
    local EntryIn = NPCDoor:FindFirstChild("RightOut");
    local EntryOut = NPCDoor:FindFirstChild("RightIn");

    local npcHeight = math.ceil((0.5 * NPC_Humanoid.RootPart.Size.Y) + NPC_Humanoid.HipHeight);
    --local bossWidth = math.ceil(myRoot.Size.X * 2);

    if npcPaths[NPC]:GetStatus() ~= "Idle" then
        npcPaths[NPC]:Stop();
    end

    local targetPosition = EntryIn.CFrame + Vector3.new(0, npcHeight * 1, 0);

    Knit.GetService("NpcService").Client.PlayAnimation:FireAll(NPC_Humanoid:FindFirstChildOfClass("Animator"), "rbxassetid://913367814", "IdleAnim", NPC)
    if NPC then
        if NPC.PrimaryPart then
            NPC:SetPrimaryPartCFrame(targetPosition)
            NPC:WaitForChild("Highlight").Enabled = true
        end
    end
    
    task.wait(2);

    RightDoorTween(DoorModel, "open")

    Knit.GetService("NpcService").Client.PlayAnimation:FireAll(NPC_Humanoid:FindFirstChildOfClass("Animator"), "rbxassetid://913402848", "RunAnim", NPC)
    NPC_Humanoid:MoveTo(EntryOut.Position)
    NPC_Humanoid.MoveToFinished:Wait();

    Knit.GetService("NpcService").Client.PlayAnimation:FireAll(NPC_Humanoid:FindFirstChildOfClass("Animator"), "rbxassetid://913367814", "IdleAnim", NPC)

    task.wait(1);

    RightDoorTween(DoorModel, "close")

    if NPC then
        inCutscene[NPC] = false; 
    end
end

function NpcService:RegularExitCutscene(NPC)
    if not NPC then return end
    local NPC_Root = NPC:FindFirstChild("HumanoidRootPart");
    local NPC_Humanoid = NPC:FindFirstChild("Humanoid");
    if not NPC_Root or not NPC_Humanoid then return end
    inCutscene[NPC] = true;

    local NPCDoor = CollectionService:GetTagged("NPCDoor")[math.random(1, #CollectionService:GetTagged("NPCDoor"))];
    local DoorModel = NPCDoor:FindFirstChild("Door2");
    local ExitIn = NPCDoor:FindFirstChild("LeftIn");
    local ExitOut = NPCDoor:FindFirstChild("LeftOut");

    local npcHeight = math.ceil((0.5 * NPC_Humanoid.RootPart.Size.Y) + NPC_Humanoid.HipHeight);
    --local bossWidth = math.ceil(myRoot.Size.X * 2);

    asAtExitDoor[NPC] = nil;
    npcPaths[NPC]:Run(ExitIn.Position);

    repeat
        task.wait(1);
    until asAtExitDoor[NPC] == true;

    local targetPosition = ExitIn.CFrame + Vector3.new(0, npcHeight * 1, 0);

    Knit.GetService("NpcService").Client.PlayAnimation:FireAll(NPC_Humanoid:FindFirstChildOfClass("Animator"), "rbxassetid://913367814", "IdleAnim", NPC)
    if NPC then
        if NPC.PrimaryPart then
            NPC:SetPrimaryPartCFrame(targetPosition)
        end
    end

    task.wait(2);

    LeftDoorTween(DoorModel, "open")

    Knit.GetService("NpcService").Client.PlayAnimation:FireAll(NPC_Humanoid:FindFirstChildOfClass("Animator"), "rbxassetid://913402848", "RunAnim", NPC)
    NPC_Humanoid:MoveTo(ExitOut.Position)
    NPC_Humanoid.MoveToFinished:Wait();

    Knit.GetService("NpcService").Client.PlayAnimation:FireAll(NPC_Humanoid:FindFirstChildOfClass("Animator"), "rbxassetid://913367814", "IdleAnim", NPC)

    task.wait(.5);

    LeftDoorTween(DoorModel, "close")


    if npcPaths[NPC] then
        npcPaths[NPC] = nil;
    end
    if NPC then
        NPC:Destroy();
    end
end

function NpcService:SetupChef(NPC, Difficulty)
    if not NPC then return end
    if not Difficulty or Difficulty == "" then Difficulty = "Medium" end

    NPC:SetAttribute("Difficulty", Difficulty)

    inCutscene[NPC] = true;
    npcAwareness[NPC] = 0;

    -- NPC Variables
    local NPC_Head = NPC:WaitForChild("Head");
    local NPC_Root = NPC:WaitForChild("HumanoidRootPart");
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");

    --------------------------------------------

    -- NPC Settings
    NPC_ViewDistances[NPC] = ViewDistances[Difficulty];
    NPC_MagnitudeDistances[NPC] = MagnitudeDistances[Difficulty];
    NPC_CloseMagnitudeDistances[NPC] = CloseMagnitudeDistances[Difficulty];

    NPC_WalkSpeeds[NPC] = WalkSpeeds[Difficulty];
    NPC_RunSpeeds[NPC] = RunSpeeds[Difficulty];

    targetPresentCount[NPC] = 0;

    -- Booleans
    travelToRandomPoint[NPC] = nil;

    npcDifficulty[NPC] = Difficulty;

    attackDebounce[NPC] = false;
    animDebounce[NPC] = false;

    repeat 
        RandomParts[NPC] = RandomSpots[math.random(1,#RandomSpots)];
        task.wait()
    until ((RandomParts[NPC] ~= prevRandomPart[NPC])
        and (RandomParts[NPC]:GetAttribute("Activated") == false))
        or NPC == nil

    local friendIds = {};

    npcPaths[NPC] = PathfindingService.new(NPC, {
        AgentRadius = math.ceil(NPC_Root.Size.X * 2) - 20, --20,
        AgentHeight = math.ceil((0.5 * NPC_Humanoid.RootPart.Size.Y) + NPC_Humanoid.HipHeight),--37,
        WaypointSpacing = 5, --4,
        AgentCanJump = false,
        Costs = {
            TravelZone = 0.01,
            NoZone = math.huge
        }
    });

    npcPaths[NPC].Visualize = true;
    for i,v in pairs(NPC:GetDescendants()) do
        if v:IsA("BasePart") then
            v:SetNetworkOwner(nil);
        end
    end
    NPC:WaitForChild("FistParticles").Size = Vector3.new(8.518, 8.84, 6.045)
    --NPC_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    
    local function ApplyAppearance()
        task.wait(5)
        
        local function iterPageItems(pages)
            return coroutine.wrap(function()
                local pagenum = 1
                while true do
                    for _, item in ipairs(pages:GetCurrentPage()) do
                        coroutine.yield(item, pagenum)
                    end
                    if pages.IsFinished then
                        break
                    end
                    pages:AdvanceToNextPageAsync()
                    pagenum = pagenum + 1
                end
            end)
        end
        
        local GetPlayers = Players:GetPlayers();
        local friendList;
        
        if #GetPlayers > 0 then	
            for _, player in pairs(GetPlayers) do
    
                local success, errorMessage = pcall(function()
                    friendList = Players:GetFriendsAsync(player.UserId)
                end)
                if not success then
                    print("errorMessage:", errorMessage)
                end
                if friendList then
                    for item, pageNo in iterPageItems(friendList) do
                        table.insert(friendIds, item.Id);
                    end
                else
                    friendIds = backupFriendsIds;
                end

            end
        else

            local success, errorMessage = pcall(function()
                friendList = Players:GetFriendsAsync(21831137)
            end)
            if not success then
                print("errorMessage:", errorMessage)
            end
            if friendList then
                for item, pageNo in iterPageItems(friendList) do
                    table.insert(friendIds, item.Id);
                end
            else
                friendIds = backupFriendsIds;
            end

        end	
        
        --print("friendIds:", friendIds)
    
        local RandomFriend = (Config.CustomAvatarId ~= nil and Config.CustomAvatarId) or friendIds[math.random(1, #friendIds)];

        --print(RandomFriend)
        
        local randomNum = math.random(0,1)
        
        local isChef = randomNum == 1 and true or false;
        
        if isChef == true then
            JobType[NPC] = "Chef";
            TaskExclusion[NPC] = "Prepare"
        else
            JobType[NPC] = "Waiter";
            TaskExclusion[NPC] = "Cook"
        end
    
        local accessoryIds = AppearanceService:GetAvatarAccessories(RandomFriend, isChef);
    
        for _, accessoryId in pairs(accessoryIds) do
            local accessoryItem = game:GetService("InsertService"):LoadAsset(accessoryId)
            --print(accessoryItem)
            NPC_Humanoid:AddAccessory(accessoryItem:GetChildren()[1])
        end
        
        for _, part in pairs(NPC:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") then
                CollectionService:AddTag(part, "IgnoreParts")
            end
        end
        
        AppearanceService:SetAvatarColor(NPC, AppearanceService:GetAvatarColor(RandomFriend))
        AppearanceService:SetAvatarFace(NPC, AppearanceService:GetAvatarFace(RandomFriend))
        AppearanceService:SetShirtAndPants(NPC, AppearanceService:GetShirtAndPants(JobType[NPC]))
    end
    
    --------------------------------------------------------------------------------

    npcPaths[NPC].Reached:Connect(function(agent, finalWaypoint)
        warn("Random point reached");
        if not NPC then return end
        if attackDebounce[NPC] then 
            repeat task.wait() until attackDebounce[NPC] == false;
        end;

        print("agent, finalWaypoint", agent, finalWaypoint,"|", travelToRandomPoint);
        --NPC_Root.CFrame = CFrame.new(NPC_Root.CFrame.Position) * CFrame.Angles(0, RandomParts[NPC].Orientation.Y, 0)

        if asAtExitDoor[NPC] == true then return end

        if inCutscene[NPC] == true then
            asAtExitDoor[NPC] = true;
            npcPaths[NPC]:Destroy();
            return;
        end
        
        if travelToRandomPoint[NPC] then
            
            if npcTargets[NPC] == nil then
                local direction = RandomParts[NPC].Position + RandomParts[NPC].CFrame.LookVector * RandomParts[NPC].Position.Magnitude;
                
                local magnitudeInStuds = (NPC_Head.Position - RandomParts[NPC].Position).Magnitude; -- Distance between npc and target

                --print(magnitudeInStuds)
                
                if magnitudeInStuds < 25 then
                    warn('X')
                    npcPaths[NPC]:Stop();
                    task.wait(.5)

                    NPC_Root.CFrame= CFrame.lookAt(RandomParts[NPC].Position, direction);
                    --warn("TaskType:", RandomParts[NPC]:GetAttribute("TaskType"));
                    PlayAnim(NPC, RandomParts[NPC]:GetAttribute("TaskType"));
                end
            end
            
            travelToRandomPoint[NPC] = nil;
            TravelToRandomPoint(NPC, TaskExclusion[NPC]);
        elseif npcTargets[NPC] ~= nil then
            if not npcPaths[NPC] then return end
            npcPaths[NPC]:Run(npcTargets[NPC]);
        end
    end)
    
    npcPaths[NPC].Blocked:Connect(function()
        if not NPC then return end
        if attackDebounce[NPC] then 
            repeat task.wait() until attackDebounce[NPC] == false;
        end;
        warn("Blocked off");
        if inCutscene[NPC] == true then 
            local NPCDoor = CollectionService:GetTagged("NPCDoor")[math.random(1, #CollectionService:GetTagged("NPCDoor"))];
            local ExitIn = NPCDoor:FindFirstChild("LeftIn");

            if asAtExitDoor[NPC] ~= true then
                asAtExitDoor[NPC] = nil;
                if not npcPaths[NPC] then return end
                npcPaths[NPC]:Run(ExitIn.Position);
            end
            return;
        end

        if travelToRandomPoint[NPC] then
            if not npcPaths[NPC] then return end
            npcPaths[NPC]:Run(RandomParts[NPC]);
        elseif npcTargets[NPC] ~= nil then
            
            local target = npcTargets[NPC]:IsA("Model") and npcTargets[NPC].PrimaryPart.Position or npcTargets[NPC].Position

            if (NPC_Head.Position - target).Magnitude > NPC_ViewDistances[NPC] + 40 then
                if npcPaths[NPC]:GetStatus() ~= "Idle" then
                    npcPaths[NPC]:Stop();
                    travelToRandomPoint[NPC] = nil;
                    npcTargets[NPC] = nil;
                    
                    if prevSignal[NPC] then
                        prevSignal[NPC]:Disconnect()
                    end
                end
            else
                if not npcPaths[NPC] then return end
                npcPaths[NPC]:Run(npcTargets[NPC]);
            end
        end
    end)
    
    npcPaths[NPC].WaypointReached:Connect(function(agent: Model, last: PathWaypoint, next: PathWaypoint)
        --print("Waypoint reached")
        --print(last, next)
        if not NPC then return end
        if attackDebounce[NPC] then 
            repeat task.wait() until attackDebounce[NPC] == false;
        end;

        if inCutscene[NPC] == true then 
            local NPCDoor = CollectionService:GetTagged("NPCDoor")[math.random(1, #CollectionService:GetTagged("NPCDoor"))];
            local ExitIn = NPCDoor:FindFirstChild("LeftIn");

            if (NPC_Root.Position - ExitIn.Position).Magnitude < 25 then
                asAtExitDoor[NPC] = true;
                if not npcPaths[NPC] then return end
                npcPaths[NPC]:Destroy();
            else
                if asAtExitDoor[NPC] ~= true then
                    asAtExitDoor[NPC] = nil;
                    if not npcPaths[NPC] then return end
                    npcPaths[NPC]:Run(ExitIn.Position);
                end
            end
            return;
        end

        if npcTargets[NPC] then
            local target = (npcTargets[NPC]:IsA("Model") and npcTargets[NPC].PrimaryPart ~= nil and npcTargets[NPC].PrimaryPart.Position) or npcTargets[NPC].Position
  
            if (NPC_Head.Position - target).Magnitude > NPC_ViewDistances[NPC] + 40 then
                if npcPaths[NPC]:GetStatus() ~= "Idle" then
                    npcPaths[NPC]:Stop();
                    travelToRandomPoint[NPC] = nil;
                    npcTargets[NPC] = nil;
                    
                    if prevSignal[NPC] then
                        prevSignal[NPC]:Disconnect()
                    end
                end
            else
                NPC_Humanoid.WalkSpeed = (NPC_RunSpeeds[NPC] ~= nil and NPC_RunSpeeds[NPC]) or 26;
                if not npcPaths[NPC] then return end
                npcPaths[NPC]:Run(npcTargets[NPC]);
            end
        elseif travelToRandomPoint[NPC] then

            if npcTargets[NPC] == nil then
                local direction = RandomParts[NPC].Position + RandomParts[NPC].CFrame.LookVector * RandomParts[NPC].Position.Magnitude;
                
                local magnitudeInStuds = (NPC_Head.Position - RandomParts[NPC].Position).Magnitude; -- Distance between npc and target

                if magnitudeInStuds < 50 then
                    print(magnitudeInStuds)
                end
                
                if magnitudeInStuds < 20 then
                    warn('Y')
                    npcPaths[NPC]:Stop();
                    task.wait(.5)
                    NPC_Root.CFrame = CFrame.lookAt(RandomParts[NPC].Position, direction);
                    --warn("TaskType:", RandomParts[NPC]:GetAttribute("TaskType"));
                    PlayAnim(NPC, RandomParts[NPC]:GetAttribute("TaskType"));

                    travelToRandomPoint[NPC] = nil;
                    TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                    return
                end
            end
            
            StopTaskAnim(NPC)
            NPC_Humanoid.WalkSpeed = (NPC_WalkSpeeds[NPC] ~= nil and NPC_WalkSpeeds[NPC]) or 16;
        end
    end)
    
    npcPaths[NPC].Error:Connect(function(errorType)
        if not NPC then return end
        if attackDebounce[NPC] then 
            repeat task.wait() until attackDebounce[NPC] == false;
        end;
        warn("Error reached")
        if inCutscene[NPC] == true then 
            local NPCDoor = CollectionService:GetTagged("NPCDoor")[math.random(1, #CollectionService:GetTagged("NPCDoor"))];
            local ExitIn = NPCDoor:FindFirstChild("LeftIn");
            
            if asAtExitDoor[NPC] ~= true then
                asAtExitDoor[NPC] = nil;
                if not npcPaths[NPC] then return end
                if not ExitIn then return end
                npcPaths[NPC]:Run(ExitIn.Position);
            end
            return
        end

        warn("errorType | ", errorType, "targetPresent:", npcTargets[NPC], "travelRandom:", travelToRandomPoint, "status:", npcPaths[NPC]:GetStatus())

        if travelToRandomPoint[NPC] then
            if errorType == PathfindingService.ErrorType.ComputationError 
            or errorType == PathfindingService.ErrorType.TargetUnreachable then
                warn("REDIRECT:", tostring(errorType),'| ', "targetPresent:", npcTargets[NPC], "travelRandom:", travelToRandomPoint, "status:", npcPaths[NPC]:GetStatus())
                
                travelToRandomPoint[NPC] = nil;
    
                if npcTargets[NPC] == nil and inCutscene[NPC] == false then
                    print("TRAVEL RANDOM POINT")
                    TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                end
            elseif errorType == PathfindingService.ErrorType.LimitReached then
                warn("REDIRECT:", tostring(errorType),'| ', "targetPresent:", npcTargets[NPC], "travelRandom:", travelToRandomPoint, "status:", npcPaths[NPC]:GetStatus())
                
                local xrand = NPC_Root.Position.X + math.random(-20,20)
	            local zrand = NPC_Root.Position.Z + math.random(-20,20)

	            NPC_Humanoid:MoveTo(Vector3.new(xrand,0,zrand))

                travelToRandomPoint[NPC] = nil;
    
                if npcTargets[NPC] == nil and inCutscene[NPC] == false then
                    print("TRAVEL RANDOM POINT")
                    TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                end
            end
        elseif npcTargets[NPC] then
            if errorType == PathfindingService.ErrorType.ComputationError 
            or errorType == PathfindingService.ErrorType.LimitReached
            then
                warn("HUH:", 'ComputationError | ', "targetPresent:", npcTargets[NPC], "travelRandom:", travelToRandomPoint, "status:", npcPaths[NPC]:GetStatus())
                
                repeat task.wait(0) until attackDebounce[NPC] == false or NPC == nil
                
                if npcPaths[NPC]:GetStatus() ~= "Idle" then
                    npcPaths[NPC]:Stop();
                end

                PlayAnim(NPC, "Confused")
                StopTaskAnim(NPC)

                npcAwareness[NPC] = 35;
    
                npcTargets[NPC] = nil;
                travelToRandomPoint[NPC] = nil;
                
                if prevSignal[NPC] then
                    prevSignal[NPC]:Disconnect()
                end

                if inCutscene[NPC] == false then
                    TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                end
            end
        end
    end)
    
    -----------------------------------------------------------------------------------------
    
    --PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false);
    
    setCollisionGroupRecursive(NPC);
    NPC.DescendantAdded:Connect(setCollisionGroup);
    NPC.DescendantRemoving:Connect(resetCollisionGroup);
    
    ApplyAppearance()
    
    NPC:WaitForChild("FistParticles").Size = Vector3.new(8.518, 8.84, 6.045)

    if not isReady[NPC] then isReady[NPC] = true end
    print("NPC READY")
end

function NpcService:KnitStart()
    task.spawn(function()
        while task.wait(0) do
            for _, NPC in pairs(CollectionService:GetTagged("NPC")) do
                local npcRoutine = coroutine.create(function()
                    if not isReady[NPC] then return end;
                    if attackDebounce[NPC] then return end;

                    --print("BRO")

                    local NPC_Head = NPC:WaitForChild("Head");

                    if inCutscene[NPC] == true then 
                        travelToRandomPoint[NPC] = nil;
                        npcTargets[NPC] = nil;
                        return;
                    end
                    
                    for _, target in pairs(CollectionService:GetTagged("TrackInstance")) do

                        if tostring(target) == "Goal" then continue end
                        
                        target = (target:IsA("Model") and target.PrimaryPart ~= nil and target.PrimaryPart.Position) or target.Position
                        
                        local npcToTarget = (NPC_Head.Position - target).Unit;
                        local npcVision = - NPC_Head.CFrame.LookVector;
                        local dotProduct = npcToTarget:Dot(npcVision);
                        local magnitudeInStuds = (NPC_Head.Position - target).Magnitude; -- Distance between npc and target

                        --print("awareness:", npcAwareness[NPC], ((dotProduct > .0) and (magnitudeInStuds <= NPC_ViewDistance)))
                        --npcAwareness[NPC]

                        local hit, directionType = MakeRay(NPC_Head.CFrame.p, target, false); -- Create a new ray. Set the last value to false if you're done debugging.
                        
                        hit = (CollectionService:HasTag(hit, "TrackInstance") and hit) 
                        or (CollectionService:HasTag(hit.Parent, "TrackInstance") and hit.Parent) 
                        or (CollectionService:HasTag(hit.Parent.Parent, "TrackInstance") and hit.Parent.Parent) 
                        or hit
                        
                        if hit:FindFirstChild("Humanoid") then if hit:FindFirstChild("Humanoid").Health <= 0 then return end end

                        --print("magnitudeInStuds:", magnitudeInStuds, "| dotProduct:", dotProduct)

                        --task.spawn(updateAwareness, NPC)
                        updateAwareness(NPC)

                        -- in npc fov
                        if ((dotProduct > .5) and (magnitudeInStuds <= NPC_MagnitudeDistances[NPC])) 
                        or (magnitudeInStuds <= NPC_CloseMagnitudeDistances[NPC]) then -- FULL ON ATTACK
                            targetPresentCount[NPC] = 0;

                            --warn("hit:", hit, "| TrackInstance:", CollectionService:HasTag(hit, "TrackInstance"))

                            if hit and CollectionService:HasTag(hit, "TrackInstance") == true then -- If the ray has a hit
                                npcAwareness[NPC] = 80;
                                npcAwareness[NPC] = math.max(0, math.min(npcAwareness[NPC], 100)); -- clamp awareness between 0 and 100

                                local tempTarget = (hit:IsA("Model") and hit.PrimaryPart ~= nil and hit.PrimaryPart) or hit     
                                local NPC_Root = NPC:WaitForChild("HumanoidRootPart");
                                local hitMagInStuds = ((NPC_Root.Position) - tempTarget.Position).Magnitude; -- Distance between npc and target

                                --if attackSwitch == true then
                                --warn("NPC", hitMagInStuds, inCutscene[NPC] == false)

                                --print(GetTouchingParts(tempTarget))
                                if npcTargets[NPC] or npcDifficulty[NPC] == "Hard" then
                                    if (hitMagInStuds > 60) and inCutscene[NPC] == false then
                                       --print("far", directionType)
                                        if directionType == DirectionType.Up then
                                            --print("upper attack")
                                            --task.spawn(ThrowObjectAttack, NPC, tempTarget.Position)
                                            --if table.find(AttackDifficulties[npcDifficulty[NPC]], "Throw") then
                                            if JobType[NPC] == "Chef" then
                                                ThrowObjectAttack(NPC, tempTarget.Position)
                                            end
                                            --end
                                            
                                            --SwingAttack(tempTarget.Position)
                                        elseif directionType == DirectionType.Down then
                                            if JobType[NPC] == "Chef" then
                                                ThrowObjectAttack(NPC, tempTarget.Position)
                                            end
                                            --task.spawn(ThrowObjectAttack, NPC, tempTarget.Position)
                                        end
                                    elseif (hitMagInStuds <= 25) and inCutscene[NPC] == false then
                                        --print("close", directionType)
                                        if directionType == DirectionType.Up then
                                            print("upper attack")
                                            --task.spawn(BroomAttack, NPC, tempTarget.Position)
                                            BroomAttack(NPC, tempTarget.Position)
                                            --SwingAttack(tempTarget.Position)
                                        elseif directionType == DirectionType.Down then           
                                            --task.spawn(StompAttack, NPC)
                                            local attackStyle = math.random(1, 2) == 1 and "Broom" or "Stomp"
                                            if attackStyle == "Broom" then
                                                BroomAttack(NPC, tempTarget.Position)
                                            else
                                                StompAttack(NPC)
                                            end
                                            --StompAttack(NPC)
                                        end
                                    end
                                end
                                
                                --end
                                
                                --print(npcTargets[NPC], travelToRandomPoint[NPC] , inCutscene[NPC])
                                if not npcTargets[NPC] and travelToRandomPoint[NPC] and inCutscene[NPC] == false then -- If the hit is a humanoid	
                                    --task.spawn(TargetFound, hit, target)
                                    if attackDebounce[NPC] and npcDifficulty[NPC] ~= "Hard" then return end;
                                    magnitudeInStuds = (NPC_Head.Position - target).Magnitude; -- Distance between npc and target
                                    if ((dotProduct > .5) and (magnitudeInStuds <= NPC_MagnitudeDistances[NPC])) 
                                    or (magnitudeInStuds <= NPC_CloseMagnitudeDistances[NPC]) then -- FULL ON ATTACK
                                        --print('TARGET', hit, hit.Parent)
                                        TargetFound(NPC, hit, target)
                                    end
                                else
                                    targetPresentCount[NPC] = 0;
                                    --print("rand")
                                    if attackDebounce[NPC] and npcDifficulty[NPC] ~= "Hard" then return end;
                                    --task.spawn(TravelToRandomPoint, NPC, TaskExclusion[NPC])
                                    TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                                end
                            else
                                if not travelToRandomPoint[NPC] and not npcTargets[NPC] and inCutscene[NPC] == false and animDebounce[NPC] == false then
                                    --task.spawn(TravelToRandomPoint, NPC, TaskExclusion[NPC])
                                    if attackDebounce[NPC] and npcDifficulty[NPC] ~= "Hard" then return end;
                                    TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                                end
                            end
                        elseif ((dotProduct > .25) and (magnitudeInStuds <= NPC_ViewDistances[NPC])) then -- increase awareness more
                            npcAwareness[NPC] += 0.1;
                            npcAwareness[NPC] = math.max(0, math.min(npcAwareness[NPC], 100));

                        elseif ((dotProduct > .0) and (magnitudeInStuds <= NPC_ViewDistances[NPC])) then -- increase awareness slightly
                            npcAwareness[NPC] += 0.05;
                            npcAwareness[NPC] = math.max(0, math.min(npcAwareness[NPC], 100));

                        else -- decrease awareness / not in npc view
                            npcAwareness[NPC] -= 0.01;
                            npcAwareness[NPC] = math.max(0, math.min(npcAwareness[NPC], 100));

                            if inCutscene[NPC] == true then 
                                travelToRandomPoint[NPC] = nil;
                                npcTargets[NPC] = nil;
                                continue
                            end

                            if npcTargets[NPC] then
                                targetPresentCount[NPC] += 1;
                                if targetPresentCount[NPC] > 1000 then
                                    npcTargets[NPC] = nil;
                                end
                            else
                                targetPresentCount[NPC] = 0;
                            end
                            --print("T:" , not travelToRandomPoint[NPC] , not npcTargets[NPC] , inCutscene[NPC] == false , animDebounce[NPC] == false)
                            if not travelToRandomPoint[NPC] and not npcTargets[NPC] and inCutscene[NPC] == false and animDebounce[NPC] == false then
                                targetPresentCount[NPC] = 0;
                                --print("rand")
                                if attackDebounce[NPC] and npcDifficulty[NPC] ~= "Hard" then return end;
                                --task.spawn(TravelToRandomPoint, NPC, TaskExclusion[NPC])
                                TravelToRandomPoint(NPC, TaskExclusion[NPC]);
                            end
                        end
                    end
                end)

                coroutine.resume(npcRoutine)
            end
        end 
    end)
end

function NpcService:KnitInit()
    print("[SERVICE]: NPC Service Initialized")

    --CreateCollisionGroup(playerCollisionGroupName);

    CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(v)
        task.spawn(function()
            self:SetupChef(v, (v:GetAttribute("Difficulty") ~= "" and v:GetAttribute("Difficulty") or "Medium"));
            self:RegularEnterCutscene(v)
        end)
    end)

    CollectionService:GetInstanceRemovedSignal("NPC"):Connect(function(v)
        print("exit scene")
        task.spawn(function()
            self:RegularExitCutscene(v)
        end)
    end)

    for i,v in pairs(CollectionService:GetTagged("NPC")) do
        task.spawn(function()
            task.wait(i/2)
            self:SetupChef(v, (v:GetAttribute("Difficulty") ~= nil and v:GetAttribute("Difficulty") or "Medium"));
            print("enter")
            self:RegularEnterCutscene(v)

            task.wait(20)
            --self:RegularExitCutscene(v)
        end)
    end
end


return NpcService;
