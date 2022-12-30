local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CurrencySessionService = Knit.CreateService {
    Name = "CurrencySessionService";
    Client = {
        DropCurrency = Knit.CreateSignal();
        CurrencyCollected = Knit.CreateSignal();
    };
}

--// Services
local Players = game:GetService("Players")

--// Tables
local SessionStorage = {};

--// Variables
local MaxCheeseStorage = 150;

--// Modules
local PositionFinder = require(Knit.ReplicatedModules.PositionFinder);

local function PlayerAdded(player)
    SessionStorage[player] = {
        Cheese = {};
    };
end;

local function PlayerRemoving(player)
    SessionStorage[player] = nil;
end;

local function Length(Table)
	local counter = 0;
	for _, v in pairs(Table) do
		counter += 1;
	end
	return counter
end

local function visualizePosition(Position : Vector3)
    local part = Instance.new("Part")
    part.Size = Vector3.new(.3,.3,.3)
    part.Shape = Enum.PartType.Ball
    part.BrickColor = BrickColor.White()
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Anchored = true
    part.CFrame = CFrame.new(Position)
    part.Parent = workspace

    game:GetService("Debris"):AddItem(part, 5)
end

function CurrencySessionService:DropCheese(oCFrame, player, amount, value)
    local localSessionStorage = {};
    local CheeseObj = game.ReplicatedStorage.Spawnables.Cheese;

    for i= 0, amount do
        local currentTime = tick();

        local randomX = {math.random(-10, -4), math.random(4,10)}
        local randomZ = {math.random(-10, -4), math.random(4,10)}

        local initialVelocity = Vector3.new(randomX[math.random(1,2)], math.random(60,70), randomZ[math.random(1,2)])

        local finalPosition = PositionFinder.getFinalPosition(initialVelocity, oCFrame.Position)

        --visualizePosition(finalPosition)

        if Length(SessionStorage[player].Cheese) > MaxCheeseStorage then continue end
        
        SessionStorage[player].Cheese["Cheese"..tostring(currentTime)] = {
            ObjectId = "Cheese"..tostring(currentTime);
            UserId = player.UserId;
            Amount = value;
            Position = finalPosition;
            timestamp = tick();
        }

        table.insert(localSessionStorage, {
            ObjectId = "Cheese"..tostring(currentTime);
            OriginalCFrame = oCFrame;
            Type = "Cheese";
            Object = CheeseObj;
            InitialVelocity = initialVelocity;
        })
    end
    
    self.Client.DropCurrency:Fire(player, "Cheese", localSessionStorage)
end

function CurrencySessionService:CollectedCurrency(player, objectId, objectType, rootCframe)
    if objectType == "Cheese" then
        if SessionStorage[player].Cheese[objectId] then
            local magnitude = (SessionStorage[player].Cheese[objectId].Position - rootCframe.Position).Magnitude;
            if magnitude < 64 then -- checks if within range
                local DropAmount = SessionStorage[player].Cheese[objectId].Amount;
                local DataService = Knit.GetService("DataService")
                DataService:GiveCurrency(player, tonumber(DropAmount))
                self.Client.CurrencyCollected:Fire(player, rootCframe, DropAmount)
            end
            SessionStorage[player].Cheese[objectId] = nil;
        end
    end
end

function CurrencySessionService:KnitStart()
    
end


function CurrencySessionService:KnitInit()
    --// In case Players have joined the server earlier than this script ran:
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(PlayerAdded)(player);
    end

    Players.PlayerAdded:Connect(PlayerAdded);
    Players.PlayerRemoving:Connect(PlayerRemoving);

    self.Client.CurrencyCollected:Connect(function(player, objectId, objectType, rootCFrame)
        self:CollectedCurrency(player, objectId, objectType, rootCFrame)
    end)
end


return CurrencySessionService
