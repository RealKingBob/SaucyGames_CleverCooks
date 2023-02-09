local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local JumpController = Knit.CreateController { Name = "JumpController" }
local UserInputService = game:GetService("UserInputService");

local LocalPlayer = game.Players.LocalPlayer;

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");

local canJump = true;
local currentJump = 0;

local ThemeData = workspace:GetAttribute("Theme")

local CHECK_DELAY_IN_SECONDS = 0.2;
local MAX_JUMPS = Instance.new("IntValue", LocalPlayer);
MAX_JUMPS.Name = "MJ";
MAX_JUMPS.Value = 1;

local function createJumpParticle(humRoot)
    if not humRoot then return end
    local jumpEffect = game.ReplicatedStorage.GameLibrary.Effects.JumpEffect:Clone()
    jumpEffect.CanCollide = false;
	jumpEffect.Transparency = 1
    jumpEffect.Parent = workspace
    game.Debris:AddItem(jumpEffect,0.3)
    local weld = Instance.new("Weld",jumpEffect)
    weld.Part0 = humRoot
    weld.Part1 = jumpEffect
    weld.C0 = CFrame.new(0,-.72,0) * CFrame.fromEulerAnglesXYZ(0,0,1.5)
    jumpEffect.ParticleEmitter:Emit(45)
end

local function manageConsecutiveJumps(_, newState)
    if newState == Enum.HumanoidStateType.Jumping then
		canJump = false;
        if character and currentJump >= 1 then
            createJumpParticle(character.PrimaryPart)
        end
		task.wait(CHECK_DELAY_IN_SECONDS);
        currentJump = currentJump + 1;
		canJump = currentJump < MAX_JUMPS.Value;
    elseif newState == Enum.HumanoidStateType.Landed then
        currentJump = 0;
		canJump = true;
	end
end

local function dispatchConsecutiveJumps(inputObject, gameProcessedEvent)
    local shouldDispatch = (
        inputObject.KeyCode == Enum.KeyCode.Space
        and humanoid
		and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping
        and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
        and canJump and character
        and not gameProcessedEvent
        and character:IsDescendantOf(workspace)
    );

    if shouldDispatch then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
    end
end

function JumpController:KnitStart()
    local ProgressionService = Knit.GetService("ProgressionService");
    ProgressionService:GetProgressionData(ThemeData):andThen(function(playerCurrency, playerStorage, progressionStorage)
        print("PlayerCurrency", playerCurrency, "PlayerStorage:", playerStorage, "ProgressionStorage:", progressionStorage)

        MAX_JUMPS.Value = progressionStorage["Jump Amount"].Data[playerStorage["Jump Amount"]].Value;
    end)

    ProgressionService.Update:Connect(function(StatName, StatValue)
        if StatName == "Jump Amount" then
            MAX_JUMPS.Value = StatValue;
        end
    end)
end

function JumpController:KnitInit()
    LocalPlayer.CharacterAdded:Connect(function(Character)
        character = Character;
        humanoid = Character:WaitForChild("Humanoid")
        canJump = true;
        currentJump = 0;
        humanoid.StateChanged:Connect(manageConsecutiveJumps);
        UserInputService.InputBegan:Connect(dispatchConsecutiveJumps);
    end)

    humanoid.StateChanged:Connect(manageConsecutiveJumps);
    UserInputService.InputBegan:Connect(dispatchConsecutiveJumps);
end


return JumpController
