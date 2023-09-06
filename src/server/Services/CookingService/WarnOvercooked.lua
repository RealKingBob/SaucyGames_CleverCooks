-- Made by Real_KingBob
-- Warns the cook if the food is overcooked

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ReplicatedModules = Knit.Shared.Modules
local Phrases = require(ReplicatedModules:FindFirstChild("Phrases"))

local easyCookTalkPhrases = Phrases.easyCookTalkPhrases
local annoyedCookTalkPhrases = Phrases.annoyedCookTalkPhrases
local defeatedCookTalkPhases = Phrases.defeatedCookTalkPhases

local foodCookWarnings = {}

return function (player, obj)
	if not foodCookWarnings[obj] then foodCookWarnings[obj] = 0 end
	
	foodCookWarnings[obj] += 1

	local NotificationService = Knit.GetService("NotificationService")
	local talkPhrase

	if foodCookWarnings[obj] < math.random(3,5) then
		talkPhrase = easyCookTalkPhrases[math.random(1, #easyCookTalkPhrases)]
		NotificationService:Message(false, player, talkPhrase, {Effect = true, Color = Color3.fromRGB(255,255,255)})
		return false
	elseif foodCookWarnings[obj] < math.random(6,10)  then
		talkPhrase = annoyedCookTalkPhrases[math.random(1, #annoyedCookTalkPhrases)]
		NotificationService:Message(false, player, talkPhrase, {Effect = true, Color = Color3.fromRGB(255, 23, 23)})
		return false
	else
		talkPhrase = defeatedCookTalkPhases[math.random(1, #defeatedCookTalkPhases)]
		NotificationService:Message(false, player, talkPhrase, {Effect = true, Color = Color3.fromRGB(255,255,255)})
		return true
	end
end