----- Services -----
local Players = game:GetService("Players");
local CollectionService = game:GetService("CollectionService");
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage");


----- Loaded Modules -----
local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(Knit.Util.Maid)

local PlayerStatTrack = {}
local PlayersBeingCounted = {};
PlayerStatTrack.__index = PlayerStatTrack

PlayerStatTrack.playerStats = {};

function PlayerStatTrack:GetTrackedPlayers(Player)
	local PlayersTracked = {};
	for player, data in next, self.playerStats do
		table.insert(PlayersTracked, {Player = player, TimeElapsed = data.TimeElapsed})
	end

	table.sort(PlayersTracked, function(a, b)
        return a.TimeElapsed > b.TimeElapsed
    end);

    for index, data in pairs(PlayersTracked) do
        if data.Player == Player then
            --print('Player Rank:', index, data.Player, data.TimeElapsed)
            return index
        end
    end
end;

function PlayerStatTrack:StartCountingMillisecondsPlayed(Player)
	if Player then
		if self.playerStats[Player.UserId] then
			if PlayersBeingCounted[Player] == false then
				PlayersBeingCounted[Player] = true;
				--print(Player.Name .. " Milliseconds has started");
				self.playerStats[Player.UserId].StartTime = tick();
			else
				--warn(Player.Name .. " Player is already being counted");
			end;
		end;
	end;
end;

function PlayerStatTrack:StopCountingSecondsPlayed(Player)
	if Player then
		if PlayersBeingCounted[Player] == true then
			PlayersBeingCounted[Player] = false;
            self.playerStats[Player.UserId].TimeElapsed = tick() - self.playerStats[Player.UserId].StartTime
			--print(Player.Name .. " SecondsPlayed has ended");
			return self.playerStats[Player.UserId].TimeElapsed;
		else
			--warn(Player.Name .. " Player is not being counted");
		end;
	end;
end;

function PlayerStatTrack:GetSecondsPlayed(Player)
	if Player then
		if self.playerStats[Player.UserId] then
			return tick() - self.playerStats[Player.UserId].StartTime;
        else
			--warn(Player.Name .. " Player is not being counted");
		end;
	end;
end;

function PlayerStatTrack:GetPlayerStats(player)
    return self.playerStats[player.UserId];
end

function PlayerStatTrack:AddCheckpoint(player)
    self.playerStats[player.UserId].Checkpoints += 1;
end

function PlayerStatTrack:AddKill(player)
    self.playerStats[player.UserId].Kills += 1;
end

function PlayerStatTrack:AddDeath(player)
    self.playerStats[player.UserId].Deaths += 1;
end

function PlayerStatTrack:AddTrapKill(player)
    self.playerStats[player.UserId].TrapKills += 1;
end

function PlayerStatTrack:ShotsFired(player)
    self.playerStats[player.UserId].ShotsFired += 1;
end

function PlayerStatTrack:UpdateResults(player)
	local TotalCoins = 0;
    if self.playerStats[player.UserId].WinRound == true then
		self.playerStats[player.UserId].Results["Won Round"] = 200;
		TotalCoins += 200;
	end

	if self.playerStats[player.UserId].YourRank ~= nil then
		if self.playerStats[player.UserId].YourRank > 50 then
			self.playerStats[player.UserId].Results["Rank Earnings"] = "20c";
			TotalCoins += 20;
		elseif self.playerStats[player.UserId].YourRank > 25 then
			self.playerStats[player.UserId].Results["Rank Earnings"] = "30c";
			TotalCoins += 30;
		elseif self.playerStats[player.UserId].YourRank > 10 then
			self.playerStats[player.UserId].Results["Rank Earnings"] = "40c";
			TotalCoins += 40;
		else
			self.playerStats[player.UserId].Results["Rank Earnings"] = "50c";
			TotalCoins += 50;
		end
	end

	local hasVIPGamepass = false

    local success, message = pcall(function()
        hasVIPGamepass = MarketplaceService:UserOwnsGamePassAsync(player.userId, 26228902)
    end)

    if not success then
        warn("Error while checking if player has pass: " .. tostring(message))
        return
    end

    if hasVIPGamepass == true then
		self.playerStats[player.UserId].Results["Coin Boost"] = "1.5x";
    end

	local PlayerHasPremium = (player.MembershipType == Enum.MembershipType.Premium)

	if PlayerHasPremium == true then
		self.playerStats[player.UserId].Results["Premium Boost"] = "1.1x";
	end

	if self.playerStats[player.UserId].Deaths == 0 then
		self.playerStats[player.UserId].Results["Zero Deaths"] = "50c";
		TotalCoins += 60;
	end

	if self.playerStats[player.UserId].Checkpoints > 0 then
		self.playerStats[player.UserId].Results["Checkpoints Reached"] = tostring(10 * self.playerStats[player.UserId].Checkpoints).."c";
		TotalCoins += (10 * self.playerStats[player.UserId].Checkpoints);
	end

	if self.playerStats[player.UserId].Participation == true then
		self.playerStats[player.UserId].Results["Participation"] = "20c";
		TotalCoins += 20;
	end

	if PlayerHasPremium == true then
		TotalCoins *= 1.1;
	end

	if hasVIPGamepass == true then
		TotalCoins *= 1.5;
	end

	self.playerStats[player.UserId].CoinsEarned = math.floor(TotalCoins);
end

function PlayerStatTrack.new(player)
    local self = setmetatable({}, PlayerStatTrack)

    self._maid = Maid.new()

    self.playerStats[player.UserId] = {};
    self.playerStats[player.UserId].Deaths = 0;
    self.playerStats[player.UserId].Checkpoints = 0;
    self.playerStats[player.UserId].Kills = 0;
    self.playerStats[player.UserId].TrapKills = 0;

    self.playerStats[player.UserId].ShotsFired = 0;

    self.playerStats[player.UserId].YourRank = 0;
    self.playerStats[player.UserId].CoinsEarned = 0;

    self.playerStats[player.UserId].StartTime = 0;
    self.playerStats[player.UserId].TimeElapsed = 0;
	self.playerStats[player.UserId].TimeElapsedOnHill = 0;

	self.playerStats[player.UserId].FirstDuck = false;
	self.playerStats[player.UserId].CompleteRound = false;
	self.playerStats[player.UserId].Participation = true;

	self.playerStats[player.UserId].WinRound = false;

    self.playerStats[player.UserId].Results = {};

    --print("[PlayerStatTrack]: Tracking",player, "now!")

    return self;
end


function PlayerStatTrack:Destroy()
    self._maid:Destroy()
end

return PlayerStatTrack;