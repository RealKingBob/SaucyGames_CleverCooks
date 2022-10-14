local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NpcService = Knit.CreateService {
    Name = "NpcService";
    Client = {};
}

-- Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService");

-- Modules
local AttackService = require(script.AttackService);
local AppearanceService = require(script.AppearanceService);
local PathfindingService = require(script.PathfindingService);
local ZoneService = require(Knit.ReplicatedModules.Zone)
local Config = require(script.Config)

local playerCollisionGroupName = "NPC";
local previousCollisionGroups = {};

local function CreateCollisionGroup(collisionGroupName)
    local createdGroups = PhysicsService:GetCollisionGroups()
    local collisionGroupExists = {} do
        for _, createdGroup in pairs(createdGroups) do
            collisionGroupExists[createdGroup] = true
        end
    end

    if not collisionGroupExists[collisionGroupName] then
        PhysicsService:CreateCollisionGroup(collisionGroupName)
    end
end

local function setCollisionGroup(object)
    if object then
        if object:IsA("BasePart") then
            previousCollisionGroups[object] = object.CollisionGroupId;
            PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName);
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
        local previousCollisionGroupId = previousCollisionGroups[object];
        if not previousCollisionGroupId then return end 

        local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId);
        if not previousCollisionGroupName then return end

        PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName);
        previousCollisionGroups[object] = nil;
    end
end

function NpcService:SetupChef(NPC)
    -- NPC Variables
    local NPC_Head = NPC:WaitForChild("Head");
    local NPC_Root = NPC:WaitForChild("HumanoidRootPart");
    local NPC_Humanoid = NPC:WaitForChild("Humanoid");
    local NPC_Animator = NPC_Humanoid:FindFirstChild("Animator");

    --------------------------------------------
    local IsR6 = (NPC_Humanoid.RigType.Value==0)
    local NPC_Torso = (IsR6 and NPC:WaitForChild("Torso")) or NPC:WaitForChild("UpperTorso")
    local Neck = (IsR6 and NPC_Torso:WaitForChild("Neck")) or NPC_Head:WaitForChild("Neck")	
    local Waist = (not IsR6 and NPC_Torso:WaitForChild("Waist"))

    local NeckOrgnC0 = Neck.C0
    local WaistOrgnC0 = (not IsR6 and Waist.C0)
    --------------------------------------------

    -- NPC Settings
    local NPC_ViewDistance = Config.NPC_ViewDistance;
    local NPC_MagnitudeDistance = Config.NPC_MagnitudeDistance;
    local NPC_CloseMagnitudeDistance = Config.NPC_CloseMagnitudeDistance;

    local NPC_WalkSpeed = Config.NPC_WalkSpeed;
    local NPC_RunSpeed = Config.NPC_RunSpeed;

    --[[
        [Horizontal and Vertical limits for head and body tracking.]
        Setting to 0 negates tracking, setting to 1 is normal tracking, and setting to anything higher than 1 goes past real life head/body rotation capabilities.
    --]]
    local HeadHorFactor = 0.8
    local HeadVertFactor = 0.5
    local BodyHorFactor = 0.4
    local BodyVertFactor = 0.4

    -- Don't set this above 1, it will cause glitchy behaviour.
    local UpdateSpeed = 0.3 -- How fast the body will rotates.
    local UpdateDelay = 0.05 -- How fast the heartbeat will update.

    local targetPresentCount = 0;

    -- Booleans
    local travelToRandomPoint = false;
    local targetPresent = false;
    local reachedWaypoint = false;

    local attackDebounce = false;

    local prevRandomPart;
    local prevSignal = nil;

    -- [Head, Torso, HumanoidRootPart], "Torso" and "UpperTorso" works with both R6 and R15.
    -- Also make sure to not misspell it.
    local PartToLookAt = "Head" -- Where should the npc look at.

    local LookBackOnNil = true -- Should the npc look at where they should when player is out of range.

    -- Empty Variables
    local prevReached, prevBlocked, prevWayPoint, prevError;

    local Character;

    local JobType, TaskExclusion;

    -- Extra Variables
    local swingContainer = workspace:WaitForChild("SwingZone")
    local swingZone = ZoneService.new(swingContainer)

    local RandomSpots = workspace.RandomSpots:GetChildren();
    local RandomPart = RandomSpots[math.random(1,#RandomSpots)];

    local friendIds = {};
    local backupFriendsIds = {21831137, 710489960, 126337093, 126833961, 39831016, 71631677, 121649, 
    25568057, 400900478, 97162681, 472860216, 14733384, 2051474553, 137759764, 65680312, 
    91529715, 294982847, 14169349, 16964256, 1510547390, 53347204, 148513655, 42350716, 
    72120971, 94158016, 62288192, 418172096, 313133642, 26432253, 53101289, 1727594062, 
    1956952532, 64172462, 108916687, 30969265, 11044605, 398496794, 122881779, 697883351, 
    151848836, 180028302, 64347573, 24160299, 6710154, 964148758, 13151032, 127786177, 
    11561183, 55976311, 92714340, 139458, 67306263};

    local DirectionType = {
        Up = "Up";
        Down = "Down";
    };

    local Ang = CFrame.Angles
    local aTan = math.atan

    --[[
    local id = '5230661597' --Replace the emote ID with another ID that you want the animation of
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

    local Path = PathfindingService.new(NPC, {
        AgentRadius = 20,
        AgentHeight = 37,
        AgentCanJump = false,
        Costs = {
            TravelZone = 0.01,
            NoZone = math.huge
        }
    });

    Path.Visualize = true;
    NPC:WaitForChild("FistParticles").Size = Vector3.new(8.518, 8.84, 6.045)
    
    ----------------------------------------------------------------------
    
    local function LookAt(NeckC0, WaistC0)
        if not IsR6 then
            Neck.C0 = Neck.C0:lerp(NeckC0, UpdateSpeed/2)
            Waist.C0 = Waist.C0:lerp(WaistC0, UpdateSpeed/2)
        else
            Neck.C0 = Neck.C0:lerp(NeckC0, UpdateSpeed/2)
        end
    end
    
    --------------------------------------------------------------------------
    
    local function SwingAttack()
        if attackDebounce == false then
            attackDebounce = true;
            
            local humanoidHeightScale = NPC_Humanoid.BodyHeightScale.Value
            local scaleY = 3 * humanoidHeightScale
    
            local charPos = NPC_Root.Position
            local changeY = Vector3.new(0, scaleY, 0)
    
            local charFloorPos = NPC_Root.CFrame
    
            charFloorPos = (charFloorPos - changeY) + (charFloorPos.LookVector * 12.5)
    
            NPC_Humanoid.WalkSpeed = 0;
    
            local success = AttackService:Swing(NPC_Animator, NPC:WaitForChild("FistParticles"));
    
            repeat task.wait() until success == true;
    
            NPC_Humanoid.WalkSpeed = 16;
            
            attackDebounce = false;
        end
    end
    
    local function StompAttack()
        if attackDebounce == false then
            attackDebounce = true;
    
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
    
            attackDebounce = false;
        end
    end
    
    local function PlayAnim(TaskType)
        
        local taskAnim = Instance.new("Animation");
        taskAnim.Name = "TaskAnim";
    
        local controller = NPC_Animator;
        local zeroSpeed = false;
        
        if TaskType == "Inspect" then
            taskAnim.AnimationId = InspectAnimId;
        elseif TaskType == "Prepare" then	
            taskAnim.AnimationId = PrepareAnimId;
        elseif TaskType == "Cook" then
            taskAnim.AnimationId = CookAnimId;
        elseif TaskType == "Alert" then
            taskAnim.AnimationId = AlertAnimId;
            zeroSpeed = true;
        end
        
        local taskAnimTrack = controller:LoadAnimation(taskAnim);
        taskAnimTrack.Priority = Enum.AnimationPriority.Action;
        
        repeat task.wait(0.1) until taskAnimTrack.length ~= 0;
        --print(taskAnimTrack.Name,taskAnimTrack.Length)
        
        if zeroSpeed then
            NPC_Humanoid.WalkSpeed = 0;
        end
        
        taskAnimTrack:Play();
        if TaskType == "Alert" then
            taskAnimTrack.Stopped:Wait()
        else
            task.wait(taskAnimTrack.Length);
        end
        --taskAnimTrack.Stopped:Wait()
        --task.wait(taskAnimTrack.Length);
        
        if TaskType ~= "Alert" then
            NPC_Humanoid.WalkSpeed = 16;
        end
    end
    
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
                    warn(errorMessage)
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
                warn(errorMessage)
            end
            if friendList then
                for item, pageNo in iterPageItems(friendList) do
                    table.insert(friendIds, item.Id);
                end
            else
                friendIds = backupFriendsIds;
            end

        end	
        
        print("friendIds:", friendIds)
    
        local RandomFriend;
            
        if Config.CustomAvatarId ~= nil then	
            RandomFriend = Config.CustomAvatarId;
        else
            RandomFriend = friendIds[math.random(1, #friendIds)] 
        end
        
        --print(RandomFriend)
        
        local randomNum = math.random(0,1)
        
        local isChef = randomNum == 1 and true or false;
        
        if isChef == true then
            JobType = "Chef";
            TaskExclusion = "Prepare"
        else
            JobType = "Waiter";
            TaskExclusion = "Cook"
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
    
        AppearanceService:SetShirtAndPants(NPC, AppearanceService:GetShirtAndPants(JobType))
    end
    
    --------------------------------------------------------------------------------
    
    local function isWithinFootRange(npc, plrChar)
        local distance = (npc.HumanoidRootPart.Position-plrChar.HumanoidRootPart.Position).Magnitude
        if distance <= NPC_CloseMagnitudeDistance then
            return distance
        end
    end
    
    local function MakeRay(startPos, endPos, show) -- Creates a new ray
        --local ray = Ray.new(startPos, endPos)
        
        local rayDirection = endPos - startPos;
        
        local directionType = DirectionType.Down;
    
        -- Build a "RaycastParams" object
        local raycastParams = RaycastParams.new();
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist;
        raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
        
        local raycastResult = workspace:Raycast(startPos, rayDirection, raycastParams);
        
        --local obj, endPoint = workspace:FindPartOnRayWithIgnoreList(ray, CollectionService:GetTagged("IgnoreParts"))
        --local obj, endPoint = workspace:FindPartOnRay(ray)
        
        if raycastResult then
            
            if show and CollectionService:HasTag(raycastResult.Instance, "TrackInstance") == true then -- This is for debugging. It will make the rays visible
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
            
            if rayDirection.Y < -14 then
                directionType = DirectionType.Down;
            else
                directionType = DirectionType.Up;
            end
            
            return raycastResult.Instance, directionType;
        else
            return nil
        end
    end

    ------------------------------------------------------------------------

    local function TravelToRandomPoint(exclude)
        print("travelToRandomPoint: ", travelToRandomPoint, "targetPresent: ", targetPresent)
        if travelToRandomPoint == true or targetPresent == true then return end
        
        travelToRandomPoint = true;
        
        task.wait(math.random(1,4));
        
        if prevRandomPart then
            prevRandomPart:SetAttribute("Activated", false)
        end
        
        repeat 
            RandomPart = RandomSpots[math.random(1,#RandomSpots)] 
        until (RandomPart ~= prevRandomPart) 
            and (RandomPart:GetAttribute("Activated") == false) 
            and (RandomPart:GetAttribute("TaskType") ~= exclude);
        
        prevRandomPart = RandomPart;
        
        local AnimationTracks = NPC_Animator:GetPlayingAnimationTracks()
        for _, AnimationTrack in pairs(AnimationTracks) do
            print("print", AnimationTrack.Name)
            if AnimationTrack.Name == "TaskAnim" then
                AnimationTrack:Stop();
            end
        end
        
        RandomPart:SetAttribute("Activated", true)
        
        NPC_Humanoid.WalkSpeed = NPC_WalkSpeed;
        
        Path:Run(RandomPart);
        warn("Random point Found");
    end
    
    
    local function TargetFound(hit, target)
        
        if targetPresent == true then return end
        
        targetPresent = true;
        travelToRandomPoint = false;
        
        if prevRandomPart then
            prevRandomPart:SetAttribute("Activated", false);
        end
        
        local AnimationTracks = NPC_Animator:GetPlayingAnimationTracks();
        for _, AnimationTrack in pairs(AnimationTracks) do
            if AnimationTrack.Name == "TaskAnim" then
                AnimationTrack:Stop();
            end
        end
        
        if prevSignal then
            prevSignal:Disconnect();
        end
        
        print(hit, target, typeof(hit))
        
        --local NPCroot = NPC.HumanoidRootPart
        --local CharRoot = Character.HumanoidRootPart

        if hit:IsA("Model") then
            Character = hit.PrimaryPart;
            
            local HRP = hit.PrimaryPart;
            
            NPC:SetPrimaryPartCFrame(CFrame.lookAt(
                NPC_Root.Position,
                HRP.Position * Vector3.new(1, 0, 1)
                    + NPC_Root.Position * Vector3.new(0, 1, 0)
            ))
            --local direction = HRP.Position + HRP.CFrame.LookVector * HRP.Position.Magnitude
            --NPC_Root.CFrame = CFrame.lookAt(NPC_Root.Position, direction)
        else
            Character = hit;
            
            local HRP = hit;
            
            NPC:SetPrimaryPartCFrame(CFrame.lookAt(
                NPC_Root.Position,
                HRP.Position * Vector3.new(1, 0, 1)
                    + NPC_Root.Position * Vector3.new(0, 1, 0)
            ))
            --local direction = HRP.Position + HRP.CFrame.LookVector * HRP.Position.Magnitude
            --NPC_Root.CFrame = CFrame.lookAt(NPC_Root.Position, direction)
        end
        
        local player = Players:GetPlayerFromCharacter(Character.Parent);
        if player then
            Knit.GetService("NotificationService"):Message(false, player, "A ".. tostring(string.upper(JobType)).." SPOTTED YOU!")
        end
        PlayAnim("Alert")
        
        NPC_Humanoid.WalkSpeed = NPC_RunSpeed;
    
        Path:Run(Character);
        warn("Target Found");
    end
    
    -------------------------------------------------------------
    
    NPC_Humanoid.Running:Connect(function(speed)
        task.wait(.1);
        
        local AnimationTracks = NPC_Animator:GetPlayingAnimationTracks()
        for _, AnimationTrack in pairs(AnimationTracks) do
            --print(AnimationTrack.Name);
            --[[if AnimationTrack.Name == "RunAnim" or AnimationTrack.Name == "Animation1" then
                
            end]]
            AnimationTrack:AdjustSpeed(0.58);
        end
    end)
    
    
    Path.Reached:Connect(function(agent, finalWaypoint)
        warn("Random point reached");
        --print("agent, finalWaypoint", agent, finalWaypoint,"|", travelToRandomPoint, targetPresent);
        --NPC_Root.CFrame = CFrame.new(NPC_Root.CFrame.Position) * CFrame.Angles(0, RandomPart.Orientation.Y, 0)
        
        if travelToRandomPoint == true then
            
            if targetPresent == false then
                local direction = RandomPart.Position + RandomPart.CFrame.LookVector * RandomPart.Position.Magnitude;
                
                local magnitudeInStuds = (NPC_Head.Position - RandomPart.Position).Magnitude; -- Distance between npc and target
                
                if magnitudeInStuds < 15 then
                    NPC_Root.CFrame= CFrame.lookAt(RandomPart.Position, direction);
                    warn("TaskType:", RandomPart:GetAttribute("TaskType"));
                    PlayAnim(RandomPart:GetAttribute("TaskType"));
                end
            end
            
            travelToRandomPoint = false;
            TravelToRandomPoint(TaskExclusion);
        elseif targetPresent == true then
            Path:Run(Character);
        end
    end)
    
    Path.Blocked:Connect(function()
        warn("Blocked off");
        
        if travelToRandomPoint == true then
            Path:Run(RandomPart);
        elseif targetPresent == true then
            
            local target;
    
            if Character:IsA("Model") then
                target = Character.PrimaryPart.Position;
            else
                target = Character.Position;
            end
            
            if (NPC_Head.Position - target).Magnitude > NPC_ViewDistance + 40 then
                if Path:GetStatus() ~= "Idle" then
                    Path:Stop();
                    travelToRandomPoint = false;
                    targetPresent = false;
                    
                    if prevSignal then
                        prevSignal:Disconnect()
                    end
                end
            else
                Path:Run(Character);
            end
        end
    end)
    
    Path.WaypointReached:Connect(function()
        --warn("Waypoint reached")
        if targetPresent == true then
            reachedWaypoint = true;
            
            local target;
            
            --print(Character, type(Character))
            if Character:IsA("Model") then
                target = Character.PrimaryPart.Position;
            else
                target = Character.Position;
            end
            
            if (NPC_Head.Position - target).Magnitude > NPC_ViewDistance + 40 then
                if Path:GetStatus() ~= "Idle" then
                    Path:Stop();
                    travelToRandomPoint = false;
                    targetPresent = false;
                    
                    if prevSignal then
                        prevSignal:Disconnect()
                    end
                end
            else
                NPC_Humanoid.WalkSpeed = NPC_RunSpeed;
                Path:Run(Character);
            end
        elseif travelToRandomPoint == true then
            NPC_Humanoid.WalkSpeed = NPC_WalkSpeed;
        end
    end)
    
    Path.Error:Connect(function(errorType)
        warn("errorType | ", errorType, "targetPresent:", targetPresent, "travelRandom:", travelToRandomPoint, "status:", Path:GetStatus())
        if travelToRandomPoint == true then
            if tostring(errorType) == "ComputationError" or tostring(errorType) == "TargetUnreachable" or tostring(errorType) == "LimitReached" then
                print(tostring(errorType),'| ', "targetPresent:", targetPresent, "travelRandom:", travelToRandomPoint, "status:", Path:GetStatus())
                
                travelToRandomPoint = false;
    
                if targetPresent == false then
                    print("TRAVEL RANDOM POINT")
                    TravelToRandomPoint(TaskExclusion);
                end
            end
        elseif targetPresent == true then
            if tostring(errorType) == "ComputationError" then
                print('ComputationError | ', "targetPresent:", targetPresent, "travelRandom:", travelToRandomPoint, "status:", Path:GetStatus())
                if Path:GetStatus() ~= "Idle" then
                    Path:Stop();
                end
    
                targetPresent = false;
                travelToRandomPoint = false;
                
                if prevSignal then
                    prevSignal:Disconnect()
                end
            end
        end
    end)
    
    -----------------------------------------------------------------------------------------
    
    PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false);
    
    setCollisionGroupRecursive(NPC);
    NPC.DescendantAdded:Connect(setCollisionGroup);
    NPC.DescendantRemoving:Connect(resetCollisionGroup);
    
    ApplyAppearance()
    
    NPC:WaitForChild("FistParticles").Size = Vector3.new(8.518, 8.84, 6.045)
    
    while true do
        
        local TrsoLV = NPC_Torso.CFrame.lookVector;
        local HdPos = NPC_Head.CFrame.p;
        local LookAtPart;
        
        for _, target in pairs(CollectionService:GetTagged("TrackInstance")) do
            
            if target:IsA("Model") then
                target = target.PrimaryPart.Position;
            else
                target = target.Position;
            end
            
            local npcToTarget = (NPC_Head.Position - target).Unit;
            local npcVision = - NPC_Head.CFrame.LookVector;
    
            local dotProduct = npcToTarget:Dot(npcVision);
            
            local magnitudeInStuds = (NPC_Head.Position - target).Magnitude; -- Distance between npc and target
    
            if ((dotProduct > .5) and (magnitudeInStuds <= NPC_MagnitudeDistance)) or (magnitudeInStuds <= NPC_CloseMagnitudeDistance) then
                targetPresentCount = 0;
                -- in npc fov
                local hit, directionType = MakeRay(NPC_Head.CFrame.p, target, true); -- Create a new ray. Set the last value to false if you're done debugging.
                
                --print("hit:", hit, hit.Parent, hit.Parent:IsA("Model")," || ", targetPresent, travelToRandomPoint)
                
                if hit.Parent:FindFirstChild("Humanoid") then
                    hit = hit.Parent
                end
                
                if hit and CollectionService:HasTag(hit, "TrackInstance") == true then -- If the ray has a hit
                    
                    --print("hit:", hit)
                    
                    if hit:IsA("Model") then
                        LookAtPart = hit.PrimaryPart
                    else
                        LookAtPart = hit
                    end
                    
                    --[[if IsR6 and Neck or Neck and Waist then
                        if LookAtPart then
                            local Dist = nil;
                            local Diff = nil;
                            local is_in_front = NPC_Root.CFrame:ToObjectSpace(LookAtPart.CFrame).Z < 0
                            if is_in_front then
                                Dist = (NPC_Head.CFrame.p-LookAtPart.CFrame.p).magnitude
                                Diff = NPC_Head.CFrame.Y-LookAtPart.CFrame.Y
    
                                if not IsR6 then
                                    LookAt(NeckOrgnC0*Ang(-(aTan(Diff/Dist)*HeadVertFactor), (((HdPos-LookAtPart.CFrame.p).Unit):Cross(TrsoLV)).Y*HeadHorFactor, 0), 
                                        WaistOrgnC0*Ang(-(aTan(Diff/Dist)*BodyVertFactor), (((HdPos-LookAtPart.CFrame.p).Unit):Cross(TrsoLV)).Y*BodyHorFactor, 0))
                                else	
                                    LookAt(NeckOrgnC0*Ang((aTan(Diff/Dist)*HeadVertFactor), 0, (((HdPos-LookAtPart.CFrame.p).Unit):Cross(TrsoLV)).Y*HeadHorFactor))
                                end
                            elseif LookBackOnNil then
                                LookAt(NeckOrgnC0, WaistOrgnC0)
                            end
                        end
                    end]]
                    
                    local tempTarget;
                    
                    if hit:IsA("Model") then	
                        tempTarget = hit.PrimaryPart;
                    else
                        tempTarget = hit;
                    end
                    
                    local hitMagInStuds = ((NPC_Root.Position) - tempTarget.Position).Magnitude; -- Distance between npc and target
                    
                    if (hitMagInStuds <= 25) then
                        print("directionType", directionType)
                        if directionType == DirectionType.Up then
                            SwingAttack()
                        elseif directionType == DirectionType.Down then
                            StompAttack()
                        end
                    end
                    
                    if targetPresent == false and travelToRandomPoint == true then -- If the hit is a humanoid	
                        --print('hit', hit, hit.Parent)
                        TargetFound(hit, target);
                    end
                else
                    if travelToRandomPoint == false and targetPresent == false then
                        TravelToRandomPoint(TaskExclusion);
                    end
                end
            else
                -- not in fov
                
                if targetPresent == true then
                    targetPresentCount += 1;
                    if targetPresentCount > 1000 then
                        targetPresent = false;
                    end
                else
                    targetPresentCount = 0;
                end
                
                if travelToRandomPoint == false and targetPresent == false then
                    targetPresentCount = 0;
                    TravelToRandomPoint(TaskExclusion);
                end
            end
        end
    
        task.wait();
    end    
end

function NpcService:KnitStart()
    
end


function NpcService:KnitInit()
    print("[SERVICE]: NPC Service Initialized")

    CreateCollisionGroup(playerCollisionGroupName);

    CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(v)
        task.spawn(function()
            self:SetupChef(v);
        end)
    end)

    for i,v in pairs(CollectionService:GetTagged("NPC")) do
        task.spawn(function()
            task.wait(i/2)
            self:SetupChef(v);
        end)
    end
end


return NpcService;
