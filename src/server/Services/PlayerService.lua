local CollectionService = game:GetService("CollectionService")
local LocalizationService = game:GetService("LocalizationService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PlayerService = Knit.CreateService {
    Name = "PlayerService",
    Client = {
        Visuals = Knit.CreateSignal(),
        Lighting = Knit.CreateSignal(),
        Cutscenes = Knit.CreateSignal(),
        Transition = Knit.CreateSignal(),
        Transition2 = Knit.CreateSignal(),

        PlaySound = Knit.CreateSignal(),
        StopSound = Knit.CreateSignal(),

        GuideCharacter = Knit.CreateSignal(),

        StartedTutorial = Knit.CreateSignal(),
        CompletedTutorial = Knit.CreateSignal()
    },
}

----- Variables -----
local Config = require(Knit.Shared.Modules.Config)
local playerCollisionGroupName = "Players"
--PhysicsService:CreateCollisionGroup(playerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)

local previousCollisionGroups = {}
local playerProfiles = {} -- [player] = profile
local deathCooldown = {}

local isFalling = {}
local fallingDebounce = {}

local playerDoubleJumped = {}
local playerTripleJumped = {}

local canJump = {}
local currentJump = {}
local newHeight = {}

local maxJumpAmounts = {}

local CHECK_DELAY_IN_SECONDS = 0.2

local Whitelist = true -- if true then only whitelisted players can play
local Profiles = {} -- [player] = profile
local WhitelistedPlayers = {52624453, 21831137, 1464956079, 51714312, 131997771, 47330208, 1154275938, 2283059942, 475945078, 418172096, 259288924, 933996022, 121998890, 76172952}

local ThemeData = workspace:GetAttribute("Theme")

local function setCollisionGroup(object)
	if CollectionService:HasTag(object, "CC_Food") then
		return
	end
    if object then
        if object:IsA("BasePart") then
            previousCollisionGroups[object] = object.CollisionGroupId
            --PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName)
            object.CollisionGroup = playerCollisionGroupName
        end
    end
end

local function setCollisionGroupRecursive(object)
	if object:GetAttribute("Owner") then
		return
	end
	if CollectionService:HasTag(object, "CC_Food") then
		return
	end
    if object then
        setCollisionGroup(object)

        for _, child in ipairs(object:GetChildren()) do
            setCollisionGroupRecursive(child)
        end
    end
end

local function resetCollisionGroup(object)
	if object:GetAttribute("Owner") then
		return
	end

	if CollectionService:HasTag(object, "CC_Food") then
		return
	end
    if object then
        local previousCollisionGroupId = previousCollisionGroups[object]
        if not previousCollisionGroupId then return end 

        local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId)
        if not previousCollisionGroupName then return end

        --PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName)
        object.CollisionGroup = previousCollisionGroupName
        previousCollisionGroups[object] = nil
    end
end

function PlayerService.Client:GetRoot(Player: Player)
    return self.Server:GetRoot(Player)
end

function PlayerService.Client:GetHumanoid(Player: Player)
    return self.Server:GetHumanoid(Player)
end

function PlayerService.Client:WaitForCharacter(Player: Player)
    return self.Server:WaitForCharacter(Player)
end


function ChangeText(Player, NewUI) -- // NAME CHANGE
	NewUI.Main.Username.Text = ((Player.DisplayName == Player.Name) and Player.Name) or Player.DisplayName
    --NewUI.Title.Text = (Player:GetAttribute("Title") == "None" and "") or NewUI.Title.Text
    local Profile = Knit.GetService("DataService"):GetProfile(Player)

    task.wait(.1)
    
    if Profile then
        if Profile.Data then
            Knit.GetService("InventoryService"):EquipItem(Player, Profile.Data["CurrentTitle"], "Title")

            local currentLevel = Knit.GetService("BattlePassService"):GetCurrentTier(Profile.Data.BattlepassXP)
            NewUI.Lvl.Text = "Lv. ".. tostring(currentLevel)
        end
    end
end

-- Adjust the height of the billboard
local function AdjustBillboardHeight(Player, billboardGui)
    PlayerService:WaitForCharacter(Player)

    local Root, Character = PlayerService:GetRoot(Player)
	local CF, Size = Character:GetBoundingBox()

	billboardGui.StudsOffset = Vector3.new(0, Size.Y / 2, 0)
end


function PlayerService:AddNametag(Player)
    PlayerService:WaitForCharacter(Player)

    local Root, Character = PlayerService:GetRoot(Player)
    local NameTagsPart = workspace.Game.NameTags
    if not NameTagsPart:FindFirstChild(Player.UserId) then
		local New_Nametag = game.ReplicatedStorage.Assets.UI.Nametag:Clone()
		New_Nametag.Name = Player.UserId

        AdjustBillboardHeight(Player, New_Nametag)

		New_Nametag.Parent = NameTagsPart
        ChangeText(Player, New_Nametag)
        if Character:FindFirstChild("Head") then
            New_Nametag.Adornee = Character.Head
        end
	else
		local New_Nametag = NameTagsPart:FindFirstChild(Player.UserId)
		ChangeText(Player, New_Nametag)

        AdjustBillboardHeight(Player, New_Nametag)

        if Character:FindFirstChild("Head") then
            New_Nametag.Adornee = Character.Head
        end
	end
end

function PlayerService:AddDot(Player)
    if not Player then return end 

    local DotsPart = workspace.Game.Dots
    if not DotsPart:FindFirstChild(Player.UserId) then
		local New_Dots = game.ReplicatedStorage.Assets.UI.Dot:Clone()
		New_Dots.Name = Player.UserId
		New_Dots.Parent = DotsPart
        if not Player.Character then return end 
        if Player.Character:FindFirstChild("Head") then
            New_Dots.Adornee = Player.Character.Head
        end
	else
		local New_Dots = DotsPart:FindFirstChild(Player.UserId)
        if not Player.Character then return end 
        if Player.Character:FindFirstChild("Head") then
            New_Dots.Adornee = Player.Character.Head
        end
	end
end


function PlayerService:Kill(Player: Player) -- Player OR Humanoid object.

    -- // This kills the player and makes sure they die.

    if Player:IsA("Player") then
        local Humanoid, Character = self:GetHumanoid(Player)
        if Humanoid and Character then
            if Character:FindFirstChild("Health") then Character.Health:Destroy() end
            Humanoid.Health = -1
        end
    elseif Player:IsA("Humanoid") then
        if Player.Parent:FindFirstChild("Health") then Player.Parent.Health:Destroy() end
        Player.Health = -1
    end

end

-- // Returns root part of the players character
function PlayerService:GetRoot(Player: Player)
    local Character = Player and Player.Character

    if Character and Character.PrimaryPart then
        return Character.PrimaryPart, Character
    end
end


-- // Returns the Humanoid on the players character
function PlayerService:GetHumanoid(Player: Player)
    local Character = Player and Player.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")

    if Humanoid then
        return Humanoid, Character
    end
end

-- // Waits until the players Humanoid & root part exist or the player is nil
function PlayerService:WaitForCharacter(Player: Player)

    if not Player then return end

    while not (self:GetRoot(Player) and self:GetHumanoid(Player)) and Player do
        task.wait()
    end

    local _, Character = self:GetRoot(Player)
    while Character and Character.Parent ~= workspace and Player do
        task.wait()
        _, Character = self:GetRoot(Player)
    end

end


local function CharacterAdded(Player)

    PlayerService:WaitForCharacter(Player)

    local Root, Character = PlayerService:GetRoot(Player)
    local Humanoid = PlayerService:GetHumanoid(Player)

    if Character and Root and Humanoid then

        local E = Instance.new("ObjectValue")
        E.Name = "Ingredient"
        E.Parent = Character

        local userId = Player.UserId

        setCollisionGroupRecursive(Character)
        Character.DescendantAdded:Connect(setCollisionGroup)
        Character.DescendantRemoving:Connect(resetCollisionGroup)

        local AvatarService = Knit.GetService("AvatarService")

        local playerAccessories = AvatarService:GetAvatarAccessories(userId)
        local playerColor = AvatarService:GetAvatarColor(userId)
        local playerFace = AvatarService:GetAvatarFace(userId)
        local hasHeadless = AvatarService:CheckForHeadless(userId)
        
        for _, assetId in pairs(playerAccessories) do
            AvatarService:SetAvatarAccessory(userId,Character.Humanoid,assetId)
        end
        
        AvatarService:SetAvatarColor(userId,Character, playerColor)
        AvatarService:SetAvatarFace(userId,Character,playerFace, false)

        --AvatarService:SetAvatarHat(player, AvatarService:GetAvatarHat(player))
        AvatarService:SetBoosterEffect(Player, AvatarService:GetBoosterEffect(Player))

        if hasHeadless == true then
            AvatarService:SetHeadless(userId,Character)
        end

        CollectionService:AddTag(Character, "TrackInstance")

        local humanoid = Character:FindFirstChildWhichIsA("Humanoid")

        currentJump[Player] = 0
        canJump[Player] = true
        newHeight[Player] = false

        local debounceJump = false

        local ProgressionService = Knit.GetService("ProgressionService")
        local playerCurrency, playerStorage, progressionStorage = ProgressionService:GetProgressionData(Player, ThemeData)

        humanoid.MaxHealth = progressionStorage["Extra Health"].Data[playerStorage["Extra Health"]].Value
        humanoid.Health = progressionStorage["Extra Health"].Data[playerStorage["Extra Health"]].Value

        maxJumpAmounts[Player] = progressionStorage["Jump Amount"].Data[playerStorage["Jump Amount"]].Value
        
        local function manageConsecutiveJumps(_, newState)
            if newState == Enum.HumanoidStateType.Jumping then
                if canJump[Player] == false then return end
                currentJump[Player] = currentJump[Player] + 1
                canJump[Player] = currentJump[Player] < maxJumpAmounts[Player]
            elseif newState == Enum.HumanoidStateType.Landed then
                currentJump[Player] = 0
                canJump[Player] = true
                newHeight[Player] = false
            end
        end
        
        --humanoid.StateChanged:Connect(manageConsecutiveJumps)

        humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
            if debounceJump then return end
            debounceJump = true
            if currentJump[Player] < maxJumpAmounts[Player] then
                currentJump[Player] += 1
                newHeight[Player] = true
            end
            task.wait(0.2)
            debounceJump = false
        end)
        
        humanoid.FreeFalling:Connect(function(falling)
            isFalling[Player] = falling
            if isFalling[Player] and not fallingDebounce[Player] then
                fallingDebounce[Player] = true
                local maxHeight = 0
                local humRoot = Character:FindFirstChild("HumanoidRootPart")
                while isFalling[Player] do
                    local height = math.abs(humRoot.Position.y)
                    if height > maxHeight then
                        maxHeight = height
                        --[[if currentJump[player] >= 1 and currentJump[player] <= maxJumpAmounts[player] then
                            print("NEW HEGHT")
                            newHeight[player] = true
                        end]]
                    end
                    --warn(height, currentJump[player], newHeight[player], maxJumpAmounts[player])
                    if newHeight[Player] == true and currentJump[Player] <= maxJumpAmounts[Player] then
                        --print("NEW HEGHT")
                        maxHeight = height
                        newHeight[Player] = false
                    end
                    task.wait()
                end
        
                local fallHeight = maxHeight - humRoot.Position.y
                --warn("Damage:", fallHeight, humanoid:GetState())
                if fallHeight >= Config.LOWEST_FALL_HEIGHT 
                and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    humanoid:TakeDamage(fallHeight)
                end
                currentJump[Player] = 0
                fallingDebounce[Player] = nil
            end
        end)

        humanoid.Died:Connect(function()
            if deathCooldown[Player.UserId] == nil then
                deathCooldown[Player.UserId] = true
                if CollectionService:HasTag(Player, Config.CHEF_TAG) == false or Character:FindFirstChild("HumanoidRootPart") ~= nil then
                    --// Initiliaze Death Effect
                    print("death!")
                    Knit.GetService("DeathEffectService"):Fire(Player, Character)
                    task.wait(1)
                    deathCooldown[Player.UserId] = nil
                end
            end
        end)
    end

end

local function PlayerAdded(Player)
    -- 1. Whitelist and Kick
    if game.PlaceId == 0000000 and Config.WHITELIST and not Player:IsInGroup(13585944) and Player.UserId > 0 then
        Player:Kick("Not Whitelisted")
    end

    -- 2. Initialize and track player stats
    task.spawn(function()
        -- @todo: Add Missions
        --MissionService:Initialize(player, profile)
        --Knit.StatTrackService:StartTracking(player)
    end)
    
    local function createInstance(className, properties)
        local obj = Instance.new(className)
        for k, v in pairs(properties) do
            obj[k] = v
        end
        return obj
    end

    local DataFolder = createInstance("Folder", {Name = "Data", Parent = Player})
    local GameValues = createInstance("Folder", {Name = "GameValues", Parent = DataFolder})
    createInstance("ObjectValue", {Name = "Ingredient", Parent = GameValues})
    createInstance("ObjectValue", {Name = "Food", Parent = GameValues})

    local CookingFolder = createInstance("Folder", {Name = "Cooking", Parent = DataFolder})
    createInstance("IntValue", {Name = "FoodMade", Value = 0, Parent = CookingFolder})

    local QuestFolder = createInstance("Folder", {Name = "Quests", Parent = DataFolder})
    createInstance("BoolValue", {Name = "John", Value = false, Parent = QuestFolder})

    local Bosses = createInstance("Folder", {Name = "Bosses", Parent = DataFolder})
    createInstance("BoolValue", {Name = "Rdite", Value = false, Parent = Bosses})

    --Knit.GetService("BadgeService"):AwardBadge(Player, "You Played")

    local Root, Character = PlayerService:GetRoot(Player)
    if Root and Character then CharacterAdded(Player) end

    Player.CharacterAdded:Connect(function(Character)
        CharacterAdded(Player)
    end)

    local Result, Code = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, Player)
    print(Player, "joined from", Code, Result)

end

function PlayerService:KnitStart()

    Knit.GetService("ProgressionService").UpdateJumpAmount:Connect(function(player, jumpAmount)
        --if not player or not jumpAmount then return end
        print("JUMP CHANGED")
        maxJumpAmounts[player] = jumpAmount
    end)

end

function PlayerService:KnitInit()

    --Knit.GetService("GameService"):SetupWheel()

    -- // Functions that happen on loading.

    for _, Player in pairs(Players:GetPlayers()) do
        PlayerAdded(Player)
    end

    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        
    end)

end



return PlayerService
