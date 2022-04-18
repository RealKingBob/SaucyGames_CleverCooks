--[[
    Name: Party Service [V1]
    By: Real_KingBob
    Date: 3/8/22
    Description: This module handles all functions that requires partying up with players.

    Handles:
    -> Sending & Removing Invites From Players
    -> Creating & Destroying Parties From Players
    -> Joining & Leaving Parties From Players
]]

--//Services
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PartyService = Knit.CreateService {
    Name = "PartyService",
    Client = {
        JoinParty = Knit.CreateSignal(),
        LeaveParty = Knit.CreateSignal(),
        SendInvite = Knit.CreateSignal(),
        RemoveInvite = Knit.CreateSignal(),

        KickPlayer = Knit.CreateSignal(),

        PartyStatus = Knit.CreateSignal(),
    },
}

--//Tables
PartyService.Parties = {};
PartyService.PlayersInParties = {};
PartyService.PlayerInvites = {};

PartyService.PartyStatus = {
    Active = "Active";
    Inactive = "Inactive";
    Queued = "Queued";
};

--//Private Functions
local function OnPlayerAdded(Player : Player)
    PartyService:CreateParty(Player);
end

local function OnPlayerRemoved(Player : Player)
    PartyService:RemovePlayerFromParty(Player);
    PartyService:DestroyParty(Player);
end

--//Public Methods
function PartyService:GetAllInvites()
    return self.PlayerInvites;
end

function PartyService:GetAllParties()
    return self.Parties;
end

function PartyService:GetPartyMembers(Owner : Player)
    if self:IsPlayerInParty(Owner) == true then
        local DataService = Knit.GetService("DataService")
        DataService.Client.Notification:Fire(Owner, "Error!", "Only party owner can teleport players", "OK");
        return nil;
    end

    local PartyMembers = {};
    
    if self.Parties[Owner.UserId] then
        for _, memberInParty in pairs(self.Parties[Owner.UserId].Members) do
            local memberIdToPlayer = memberInParty.Player;
            table.insert(PartyMembers, memberIdToPlayer);
        end
    end

    return PartyMembers;
end

function PartyService:IsPlayerInParty(Player : Player)
    if self.PlayersInParties[Player.UserId] then
        if self.PlayersInParties[Player.UserId].PartyOwnerId ~= Player.UserId then
            return true;
        end
    end
    return false;
end

function PartyService:GetPlayerInvites(Player : Player)
    return self.PlayerInvites[Player.UserId];
end

function PartyService:GetParty(Player : Player)
    return self.Parties[Player.UserId];
end

function PartyService:RemovePlayerInvite(Player : Player, Owner : Player)
    if Player and Owner then
        if self.PlayerInvites[Player.UserId] == nil then
            self.PlayerInvites[Player.UserId] = {};
        end
        if table.find(self.PlayerInvites[Player.UserId], Owner.UserId) then
            local IndexOfInvite = table.find(self.PlayerInvites[Player.UserId], Owner.UserId);
            table.remove(self.PlayerInvites[Player.UserId], IndexOfInvite);
            self.Client.RemoveInvite:Fire(Player, Owner);
            return true;
        end
    end 
    return false;
end

function PartyService:SendPlayerInvite(Owner : Player, Target : Player)
    if Owner and Target then 
        if self.PlayerInvites[Target.UserId] == nil then
            self.PlayerInvites[Target.UserId] = {};
        end

        if #self.Parties[Owner.UserId].Members > 10 then
            local DataService = Knit.GetService("DataService")
            DataService.Client.Notification:Fire(Owner, "Error!", "Party is full!", "OK");
            return false;
        end

        if self:IsPlayerInParty(Owner) == true then 
            local DataService = Knit.GetService("DataService")
            DataService.Client.Notification:Fire(Owner, "Error!", "Only party owner can send invites!", "OK");
            return false
        end

        if #self.Parties[Owner.UserId].Members > 10 then
            local DataService = Knit.GetService("DataService")
            DataService.Client.Notification:Fire(Owner, "Error!", "Party is full!", "OK");
            return false;
        end

        local OwnerParty = self.Parties[Owner.UserId];
        if OwnerParty then
            local PlayerIndexWithinParty = self:FindIndexOfPartyMembers(OwnerParty.Members, Target)
            print("PlayerIndexWithinParty,", PlayerIndexWithinParty)
            if PlayerIndexWithinParty then
                local DataService = Knit.GetService("DataService")
                DataService.Client.Notification:Fire(Owner, "Error!", "Player already in your party!", "OK");
                return false;
            end
        end
        if table.find(self.PlayerInvites[Target.UserId], Owner.UserId) == nil then
            table.insert(self.PlayerInvites[Target.UserId], Owner.UserId);
            print(Target, Owner)
            self.Client.SendInvite:Fire(Target, Owner);
            return true;
        end
    end
    return false;
end

function PartyService:FindPartyFromPlayer(Player : Player)
    if Player then
        if self.PlayersInParties[Player.UserId] then
            return self.Parties[self.PlayersInParties[Player.UserId].PartyOwnerId];
        end
    end
    return false;
end

function PartyService:FindIndexOfPartyMembers(Party : table, Player : Player)
    if Player and Party then
        if Party then
            for index, memberInfo in pairs(Party) do
                if memberInfo.UserId and Player.UserId then
                    if tonumber(memberInfo.UserId) == tonumber(Player.UserId) then
                        return index;
                    end
                end
            end
        end
    end
    return nil;
end

function PartyService:AddPlayerToParty(Player : Player, Owner : Player)
    if Player and Owner then
        if self:IsPlayerInParty(Player) == true then
            local DataService = Knit.GetService("DataService")
            DataService.Client.Notification:Fire(Player, "Error!", "You must leave your current party to join a new one!", "OK");
            return false;
        end

        if #self.Parties[Owner.UserId].Members > 10 then
            local DataService = Knit.GetService("DataService")
            DataService.Client.Notification:Fire(Player, "Error!", "This party is full!", "OK");
            return false;
        end

        if self.Parties[Owner.UserId] then
            for _, memberInParty in pairs(self.Parties[Player.UserId].Members) do
                if memberInParty.UserId == Owner.UserId then continue end
                local memberIdToPlayer = memberInParty.Player;
                self:RemovePlayerFromParty(memberIdToPlayer);
            end

            --[[if table.find(self.Parties[Owner.UserId], Player.UserId) == nil then
                table.insert(self.Parties[Owner.UserId], Player.UserId);
            end]]

            table.insert(self.Parties[Owner.UserId].Members, {
                UserId = Player.UserId,
                DisplayName = Player.DisplayName,
                UserName = Player.Name,
            });
            
            self.PlayersInParties[Player.UserId] = {
                PlayerId = Player.UserId,
                PartyOwnerId = Owner.UserId
            };

            self.Client.JoinParty:Fire(Owner, self.Parties[Owner.UserId]);

            for _, memberInParty in pairs(self.Parties[Owner.UserId].Members) do
                if memberInParty.UserId == Owner.UserId then continue end
                local memberIdToPlayer = memberInParty.Player;
                self.Client.JoinParty:Fire(memberIdToPlayer, self.Parties[Owner.UserId]);
            end            
            return true;
        end
    end
    return false;
end

function PartyService:RemovePlayerFromParty(Player : Player)
    if Player then
        if self:IsPlayerInParty(Player) == false then return false end
        
        if self.PlayersInParties[Player.UserId] then
            local OwnerParty = self.Parties[self.PlayersInParties[Player.UserId].PartyOwnerId]
            local PartyOwnerId = OwnerParty.OwnerId
            if OwnerParty then
                local PlayerIndexWithinParty = self:FindIndexOfPartyMembers(OwnerParty.Members, Player)
                print("PlayerIndexWithinParty,", PlayerIndexWithinParty)
                if PlayerIndexWithinParty then
                    table.remove(OwnerParty.Members, PlayerIndexWithinParty)
                end
            end
            self.Client.LeaveParty:Fire(Player, self.Parties[Player.UserId]);

            local Owner = Players:GetPlayerByUserId(PartyOwnerId);
            self.Client.LeaveParty:Fire(Owner, self.Parties[Owner.UserId]);
            
            if self.Parties[PartyOwnerId] then
                for _, memberInParty in pairs(self.Parties[PartyOwnerId].Members) do
                    local memberIdToPlayer = memberInParty.Player;
                    self.Client.LeaveParty:Fire(memberIdToPlayer, self.Parties[PartyOwnerId]);
                end 
            end

            self.PlayersInParties[Player.UserId] = nil;
            return true;
        end
    end
    return false;
end

function PartyService:CreateParty(Owner : Player)
    if not self.Parties[Owner.UserId] then
        self.Parties[Owner.UserId] = {
            OwnerId = Owner.UserId,
            Created = os.time(),
            Status = self.PartyStatus.Active,
            Members = {
                {
                    Player = Owner,
                    UserId = Owner.UserId,
                    DisplayName = Owner.DisplayName,
                    UserName = Owner.Name,
                },
            },
        }
        self.PlayerInvites[Owner.UserId] = {};
        return self.Parties[Owner.UserId];
    end
    return false;
end

function PartyService:DestroyParty(Owner : Player)
    if self.Parties[Owner.UserId] then
        for _, memberInParty in pairs(self.Parties[Owner.UserId].Members) do
            local memberIdToPlayer = memberInParty.Player;
            self:RemovePlayerFromParty(memberIdToPlayer);
        end
        self.PlayerInvites[Owner.UserId] = nil;
        self.Parties[Owner.UserId] = nil;
        return true;
    end
    return false;
end

function PartyService:KnitStart()
    local TournamentService  = Knit.GetService("TournamentService");

    self.Client.JoinParty:Connect(function(Player : Player, Owner : Player)
        if Player and Owner then
            if table.find(self.PlayerInvites[Player.UserId], Owner.UserId) then
                local indexOfInvite = table.find(self.PlayerInvites[Player.UserId], Owner.UserId);
                table.remove(self.PlayerInvites[Player.UserId], indexOfInvite);
                self:AddPlayerToParty(Player, Owner);
            end
        end
    end)

    self.Client.LeaveParty:Connect(function(Player : Player)
        if Player then
            self:RemovePlayerFromParty(Player);
        end
    end)

    self.Client.KickPlayer:Connect(function(Player : Player, Target : Player)
        if Player and Target then
            if self.PlayersInParties[Target.UserId].PartyOwnerId == Player.UserId then
                self:RemovePlayerFromParty(Target);
            end
        end
    end)

    self.Client.SendInvite:Connect(function(Player : Player, Target : Player)
        if Player and Target then
            self:SendPlayerInvite(Player, Target);
        end
    end)

    self.Client.RemoveInvite:Connect(function(Player : Player, Owner : Player)
        if Player and Owner then
            self:RemovePlayerInvite(Player, Owner);
        end
    end)

    self.Client.PartyStatus:Connect(function(Player : Player, Status : "String")
        local OwnerId = self:FindPartyFromPlayer(Player);

        if OwnerId ~= false then 
            local DataService = Knit.GetService("DataService")
            DataService.Client.Notification:Fire(Player, "Error!", "Only party owner start the queue!", "OK");
            return;
        end

        local PartyMembers = self:GetPartyMembers(Player);

        if Status == "RegularQueueStart" then
            TournamentService:AddToRegularQueue(PartyMembers);
        elseif Status == "VCQueueStart" then
            TournamentService:AddToVCQueue(PartyMembers);
        elseif Status == "QueueCancel" then
            TournamentService:RemoveFromQueue(PartyMembers);
        end
    end)
end

function PartyService:KnitInit()
    
end

for _, player in ipairs(Players:GetPlayers()) do
    coroutine.wrap(OnPlayerAdded)(player);
end;

Players.PlayerAdded:Connect(OnPlayerAdded);
Players.PlayerRemoving:Connect(OnPlayerRemoved);

return PartyService;
