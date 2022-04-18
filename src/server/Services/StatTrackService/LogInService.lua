local LogInService = {};

function LogInService:Increment(Player,Profile)
	if Player then
		if Profile then
			local profileData = Profile.Data;
            profileData.PlayerInfo.LogInTimes = profileData.PlayerInfo.LogInTimes + 1;
            --print("[PlayerHandler]: "..Player.Name .. " has logged in " .. tostring(profileData.PlayerInfo.LogInTimes)
            --    .. " time" .. ((profileData.PlayerInfo.LogInTimes > 1) and "s" or ""));
            --print("[PlayerHandler]: "..Player.Name .. " owns " .. tostring(profileData.PlayerInfo.Coins) .. " Coins now!");
		end;
	end;
end;

function LogInService:Decrement(Player,Profile)
	if Player then
		if Profile then
			local profileData = Profile.Data;
            profileData.PlayerInfo.LogInTimes = profileData.PlayerInfo.LogInTimes - 1;
            --print("[PlayerHandler]: "..Player.Name .. " has logged in " .. tostring(profileData.PlayerInfo.LogInTimes)
            --    .. " time" .. ((profileData.PlayerInfo.LogInTimes > 1) and "s" or ""));
            --print("[PlayerHandler]: "..Player.Name .. " owns " .. tostring(profileData.PlayerInfo.Coins) .. " Coins now!");
		end;
	end;
end;

return LogInService;