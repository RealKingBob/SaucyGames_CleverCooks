local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid);

local PotatoBomb = {};
PotatoBomb.__index = PotatoBomb;

PotatoBomb.Tag = "PotatoBomb";


function PotatoBomb:AdjustedPotatoTime()
    local GetTournamentStatus = Knit.GetService("TournamentService"):GetIfTournament();
    local MaxFate, MinFate
    if GetTournamentStatus == true then 
        MaxFate = 27;
        MinFate = 25;
    else 
        MaxFate = 17;
        MinFate = 15;
    end
    if #CollectionService:GetTagged(Knit.Config.ALIVE_TAG) > 0 then
        local function adjustCooldown(min, max, alpha)
            return min + (max - min) * alpha;
        end

        local newCooldown = adjustCooldown(
            MaxFate, 
            MinFate,  
            #CollectionService:GetTagged(Knit.Config.NO_POTATO_TAG) / Players.MaxPlayers
        )

        return newCooldown;
    end
    return 15;
end

function PotatoBomb:StartTimer(Potato)
    --print("FLASH POTATO:", Potato);
    local TimerSound = Potato:WaitForChild('Tick');
    local ExplosionSound = Potato:WaitForChild('Explosion');

    local Fate = 0

    if Fate >= self.MaxFate then
        Fate = self.MaxFate - 2;
    end
    
	task.spawn(function()
		while Potato ~= nil and Fate <= (self.MaxFate + 1) do
            if Potato:FindFirstChild("Neon") then
                if Potato:FindFirstChild("Neon").Transparency == 1 then
                    Potato:FindFirstChild("Neon").Transparency = 0;
                    self.TimerUI.TextColor3 = Color3.fromRGB(255, 0, 0)
                    self.TimerUI.Text = (self.MaxFate) - Fate > 0 and tostring((math.floor(self.MaxFate + 1) - Fate)) or 0
                    TimerSound:Play();
                else
                    Potato:FindFirstChild("Neon").Transparency = 1;
                end
            end
            if Fate > self.MaxFate * 0.6 then
                task.wait((self.MaxFate - Fate) * 0.1);
            else
                task.wait(0.5);
            end
		end
	end)
	task.spawn(function()
		while Potato ~= nil and Fate <= (self.MaxFate + 1) do
			math.randomseed(tick()) math.random();
			Fate += 1;
            self.TimerUI.TextColor3 = Color3.fromRGB(255, 255, 255)
            --self.TimerUI.TEXT.Text = (self.MaxFate) - Fate > 0 and tostring((self.MaxFate) - Fate) or 0
			if Fate >= self.MaxFate and Potato.Parent ~= workspace then
                ExplosionSound.PlayOnRemove = true;
                task.wait(0.1);
				ExplosionSound:Destroy();
				TimerSound:Stop();

                if Potato.Parent ~= nil then
                    local player = Players:GetPlayerFromCharacter(Potato.Parent)

                    if player then
                        local humanoid = Potato.Parent:FindFirstChildWhichIsA("Humanoid");
                        if humanoid then
                            humanoid.Health = -1;
                        end
                        task.wait(.5)
                        if player.Character then
                            player.Character = nil;
                        end
                        task.wait(1)
                        if player.Character == nil then
                            player:LoadCharacter();
                        end
                    end

                    task.wait(3);

                    if Potato then
                        Potato = nil
                        self:Destroy()
                    end
                end
                break;
            elseif Fate == (self.MaxFate / 2) and Potato.Parent ~= workspace then
                local GameService = Knit.GetService("GameService")
                local gameMode = GameService:GetGameRound()
                
                if gameMode then
                    gameMode:PassPotato(Potato, Players:GetPlayerFromCharacter(Potato.Parent))
                end
			end
            task.wait(1);
		end
	end)
end

function PotatoBomb.new(instance)
    if instance:IsA("Model") then
        return;
    end
    local self = setmetatable({}, PotatoBomb);
    self._maid = Maid.new();

    self.Object = instance;
    self.TimerUI = self.Object:WaitForChild("TIMER_UI"):WaitForChild("TEXT");
    self.MaxFate = self:AdjustedPotatoTime();
    self.debounce = false;

    self:StartTimer(self.Object)

    self.Owner = Players:GetPlayerFromCharacter(instance.Parent)
    
    if self.Owner.Character then
        if self.Owner.Character:FindFirstChild("Humanoid") then
            self.Owner.Character:FindFirstChild("Humanoid").WalkSpeed = 32
            self.Owner.Character:FindFirstChild("Humanoid").JumpPower = 35
        end
    end

    self._maid:GiveTask(self.Object.Touched:Connect(function(hit)
        local Player = Players:GetPlayerFromCharacter(hit.Parent)
        self.Owner = Players:GetPlayerFromCharacter(instance.Parent)
        if Player then
            if Player == self.Owner then
                return;
            end

            local GameService = Knit.GetService("GameService")
            local gameMode = GameService:GetGameRound()
            
            --print("gameMode", gameMode)
            if gameMode then
                gameMode:PassPotato(instance, Player)
            end
        end
    end))

    return self;
end

function PotatoBomb:Destroy()
    self._maid:Destroy();
    --print("PotatoBomb Module Destroyed")
    if self.Object then
        --self.Object:Destroy();
        self.Object = nil;
    end
end

return PotatoBomb;