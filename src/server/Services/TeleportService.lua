local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TeleportService = Knit.CreateService {
    Name = "TeleportService";
    Client = {
        TeleportPlace = Knit.CreateSignal();
    };
}

local VOICE_CHAT_PLACE_ID = 8796113822;
local BIG_SERVER_PLACE_ID = 8796115102;
local SERVER_PLACE_ID = 8211530112;

local TEST_VOICE_CHAT_PLACE_ID = 8792750286;
local TEST_BIG_SERVER_PLACE_ID = 8793381822;
local TEST_SERVER_PLACE_ID = 8303278706;

local SafeTeleport = require(Knit.ServerModules.Settings.SafeTeleport);

function TeleportService:PlaceType(type)
    if game.PlaceId == SERVER_PLACE_ID or game.PlaceId == BIG_SERVER_PLACE_ID or game.PlaceId == VOICE_CHAT_PLACE_ID then
        if tonumber(type) == 3 then
            return BIG_SERVER_PLACE_ID;
        elseif tonumber(type) == 2 then
            return VOICE_CHAT_PLACE_ID;
        else
            return SERVER_PLACE_ID;
        end
    else
        if tonumber(type) == 3 then
            return TEST_BIG_SERVER_PLACE_ID;
        elseif tonumber(type) == 2 then
            return TEST_VOICE_CHAT_PLACE_ID;
        else
            return TEST_SERVER_PLACE_ID;
        end
    end
end

function TeleportService:TeleportPlayer(player, type)
    local TargetPlaceId = self:PlaceType(type);

    if game.PlaceId ~= TargetPlaceId then
        if TargetPlaceId == VOICE_CHAT_PLACE_ID then
            --if self:PlayerHasVoiceChat(player) == false then return end
        end

        local PartyService = Knit.GetService("PartyService");
        local PartyMembers = PartyService:GetPartyMembers(player);

        if PartyMembers == nil then return end
        if #PartyMembers == 0 then return end
        
        SafeTeleport(TargetPlaceId, {PartyMembers});
    end
end

function TeleportService:KnitStart()
    self.Client.TeleportPlace:Connect(function(player, type)
        self:TeleportPlayer(player, type);
    end)
end


function TeleportService:KnitInit()
    
end


return TeleportService
