local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local badgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local BadgeService = Knit.CreateService {
    Name = "BadgeService";
    Client = {};
}

------- IDS -------
local welcomeBadgeId = 2124930914
local youPlayedWithKarl = 00000000
local firstGameId = 00000000
local wonGameId = 00000000

local unlockedCommon = 00000000
local unlockedUncommon = 00000000
local unlockedRare = 00000000
local unlockedEpic = 00000000
local unlockedLegendary = 00000000
local unlockedQATester = 00000000

------- Private Functions -------

function onPlayerAdded(player)
	local success, hasBadge = pcall(function()
		return badgeService:UserHasBadgeAsync(player.UserId, welcomeBadgeId)
	end)

	if not success then
		warn("Error while checking if player has badge!")
		return
	end
 
	if not hasBadge then
        BadgeService:AwardBadge(player, welcomeBadgeId);
	end
end


------- Public Methods -------

function BadgeService:AwardBadge(player, badgeId)
	local success, badgeInfo = pcall(function()
		return badgeService:GetBadgeInfoAsync(badgeId)
	end)
	if success then	
		if badgeInfo.IsEnabled then	
			local awarded, errorMessage = pcall(function()
				badgeService:AwardBadge(player.UserId, badgeId)
			end)
			if not awarded then
				warn("Error while awarding badge:", errorMessage)
			end
		end
	else
		warn("Error while fetching badge info!")
	end
end

------- Initialize -------

Players.PlayerAdded:Connect(onPlayerAdded)

function BadgeService:KnitStart()

end

function BadgeService:KnitInit()
    print("[SERVICE]: Badge Service Initialized");
end

return BadgeService;