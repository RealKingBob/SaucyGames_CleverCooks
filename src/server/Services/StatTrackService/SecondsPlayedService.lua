local SecondsPlayed = {};
local PlayersBeingCounted = {};

local DataService = require(script.Parent.Parent.DataService)

function SecondsPlayed:StartCountingSecondsPlayed(Player,Profile)
	if Player then
		if Profile then
			local Data = Profile.Data;

			if not PlayersBeingCounted[Player] then
				PlayersBeingCounted[Player] = true;
				--print(Player.Name .. " SecondsPlayed has started");
				while PlayersBeingCounted[Player] == true do
					task.wait(1);
					Data.PlayerInfo.SecondsPlayed += 1;
					--print(Data, Data.PlayerInfo.SecondsPlayed,Data.PlayerInfo.SecondsPlayed + 1);
					--MissionService.Check(Player,"SecondsPlayed",SecondsPlayed)--// Checking;
				end;
			else
				warn(Player.Name .. " Player is already being counted");
			end;
		end;
	end;
end;

function SecondsPlayed:StopCountingSecondsPlayed(Player)
	if Player then
		if PlayersBeingCounted[Player] then
			PlayersBeingCounted[Player] = false;
			--print(Player.Name .. " SecondsPlayed has ended");
		else
			warn(Player.Name .. " Player is not being counted");
		end;
	end;
end;

function SecondsPlayed:GetSecondsPlayed(Player,Profile)
	if Player then
		if Profile then
			local Data = Profile.Data;
			return Data.PlayerInfo.SecondsPlayed,PlayersBeingCounted[Player];
		end;
	end;
end;

return SecondsPlayed;