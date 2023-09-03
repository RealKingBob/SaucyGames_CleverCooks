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
local CollectionService = game:GetService("CollectionService")
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
PartyService.Parties = {}
PartyService.PlayersInParties = {}
PartyService.PlayerInvites = {}

PartyService.PartyStatus = {
    Active = "Active",
    Inactive = "Inactive",
    Queued = "Queued",
}

--//Private Functions
local function OnPlayerAdded(Player : Player)
    local createdParty = PartyService:CreateParty(Player)

    if createdParty == false then
        for i, v in pairs(PartyService:GetPartyMembers(Player)) do
            PartyService:RemovePlayerFromParty(v)
        end
        PartyService:RemovePlayerFromParty(Player)
    end
end

local function OnPlayerRemoved(Player : Player)
    --[[for i, v in pairs(PartyService:GetPartyMembers(Player)) do
        PartyService:RemovePlayerFromParty(v)
    end
    PartyService:RemovePlayerFromParty(Player)
    PartyService:DestroyParty(Player)]]

    local OwnerParty = PartyService:FindPartyFromPlayer(Player)
    local PartyOwnerId = OwnerParty.OwnerId
    if OwnerParty then
        local PlayerIndexWithinParty = PartyService:FindIndexOfPartyMembers(OwnerParty.Members, Player)
        print("PlayerIndexWithinParty,", PlayerIndexWithinParty)
        if PlayerIndexWithinParty then
            table.remove(OwnerParty.Members, PlayerIndexWithinParty)
        end
    end

    local Owner = Players:GetPlayerByUserId(PartyOwnerId)
    if Owner then
        PartyService.Client.LeaveParty:Fire(Owner, PartyService.Parties[Owner.UserId])
    end
    
    if PartyService.Parties[PartyOwnerId] then
        for _, memberInParty in pairs(PartyService.Parties[PartyOwnerId].Members) do
            local memberIdToPlayer = memberInParty.Player
            if memberIdToPlayer then
                Knit.GetService("NotificationService"):Message(false, memberIdToPlayer, tostring(memberIdToPlayer).." has left party!", {Effect = false, Color = Color3.fromRGB(255, 23, 23)})
                PartyService.Client.LeaveParty:Fire(memberIdToPlayer, PartyService.Parties[PartyOwnerId])
            end
        end 
    end

    PartyService.PlayersInParties[Player.UserId] = nil
    PartyService:DestroyParty(Player)
end

--//Public Methods
function PartyService:GetAllInvites()
    return self.PlayerInvites
end

function PartyService:GetAllParties()
    return self.Parties
end

function PartyService:GetPartyMembers(Owner : Player)
    if self:IsPlayerInParty(Owner) == true then
        Knit.GetService("NotificationService").Client.Notification:Fire(Owner, "Error!", "Only party owner can teleport players", "OK")
        return nil
    end

    local PartyMembers = {}
    
    if self.Parties[Owner.UserId] then
        for _, memberInParty in pairs(self.Parties[Owner.UserId].Members) do
            local memberIdToPlayer = memberInParty.Player
            table.insert(PartyMembers, memberIdToPlayer)
        end
    end

    return PartyMembers
end

function PartyService:IsPlayerInParty(Player : Player)
    if self.PlayersInParties[Player.UserId] then
        if self.PlayersInParties[Player.UserId].PartyOwnerId ~= Player.UserId then
            return true
        end
    end
    return false
end

function PartyService:GetPlayerInvites(Player : Player)
    return self.PlayerInvites[Player.UserId]
end

function PartyService:GetParty(Player : Player)
    return self.Parties[Player.UserId]
end

function PartyService:RemovePlayerInvite(Player : Player, Owner : Player)
    if Player and Owner then
        if self.PlayerInvites[Player.UserId] == nil then
            self.PlayerInvites[Player.UserId] = {}
        end
        if table.find(self.PlayerInvites[Player.UserId], Owner.UserId) then
            local IndexOfInvite = table.find(self.PlayerInvites[Player.UserId], Owner.UserId)
            table.remove(self.PlayerInvites[Player.UserId], IndexOfInvite)
            self.Client.RemoveInvite:Fire(Player, Owner)
            return true
        end
    end 
    return false
end

function PartyService:SendPlayerInvite(Owner : Player, Target : Player)
    if Owner and Target then 
        if self.PlayerInvites[Target.UserId] == nil then
            self.PlayerInvites[Target.UserId] = {}
        end

        if #self.Parties[Owner.UserId].Members > 10 then
            Knit.GetService("NotificationService").Client.Notification:Fire(Owner, "Error!", "Party is full!", "OK")
            return false
        end

        if self:IsPlayerInParty(Owner) == true then 
            Knit.GetService("NotificationService").Client.Notification:Fire(Owner, "Error!", "Only party owner can send invites!", "OK")
            return false
        end

        if #self.Parties[Owner.UserId].Members > 10 then
            Knit.GetService("NotificationService").Client.Notification:Fire(Owner, "Error!", "Party is full!", "OK")
            return false
        end

        local OwnerParty = self.Parties[Owner.UserId]
        if OwnerParty then
            local PlayerIndexWithinParty = self:FindIndexOfPartyMembers(OwnerParty.Members, Target)
            print("PlayerIndexWithinParty,", PlayerIndexWithinParty)
            if PlayerIndexWithinParty then
                Knit.GetService("NotificationService").Client.Notification:Fire(Owner, "Error!", "Player already in your party!", "OK")
                return false
            end
        end
        if table.find(self.PlayerInvites[Target.UserId], Owner.UserId) == nil then
            table.insert(self.PlayerInvites[Target.UserId], Owner.UserId)
            print(Target, Owner)
            self.Client.SendInvite:Fire(Target, Owner)
            return true
        end
    end
    return false
end

function PartyService:FindPartyFromPlayer(Player : Player)
    if Player then
        if self.PlayersInParties[Player.UserId] then
            return self.Parties[self.PlayersInParties[Player.UserId].PartyOwnerId]
        else
            return self.Parties[Player.UserId]
        end
    end
    return false
end

function PartyService:FindIndexOfPartyMembers(Party : table, Player : Player)
    if Player and Party then
        if Party then
            for index, memberInfo in pairs(Party) do
                if memberInfo.UserId and Player.UserId then
                    if tonumber(memberInfo.UserId) == tonumber(Player.UserId) then
                        return index
                    end
                end
            end
        end
    end
    return nil
end

function PartyService:AddPlayerToParty(Player : Player, Owner : Player)
    if Player and Owner then
        if self:IsPlayerInParty(Player) == true then
            Knit.GetService("NotificationService").Client.Notification:Fire(Player, "Error!", "You must leave your current party to join a new one!", "OK")
            return false
        end

        local CookingService = Knit.GetService("CookingService")

        if CookingService:GetPickUpData(Player)[1] == true then
            Knit.GetService("NotificationService").Client.Notification:Fire(Player, "Error!", "Please drop your item and request for an invite again!", "OK")
            return false
        end
        
        if CookingService:GetNumberOfFoodCooking(Player) > 0 then
            Knit.GetService("NotificationService").Client.Notification:Fire(Player, "Error!", "Finish cooking your food before you can join a party!", "OK")
            return false
        end

        if #self.Parties[Owner.UserId].Members > 10 then
            Knit.GetService("NotificationService").Client.Notification:Fire(Player, "Error!", "This party is full!", "OK")
            return false
        end

        if self.Parties[Owner.UserId] then
            for _, memberInParty in pairs(self.Parties[Player.UserId].Members) do
                if memberInParty.UserId == Owner.UserId then continue end
                local memberIdToPlayer = memberInParty.Player
                self:RemovePlayerFromParty(memberIdToPlayer)
            end

            --[[if table.find(self.Parties[Owner.UserId], Player.UserId) == nil then
                table.insert(self.Parties[Owner.UserId], Player.UserId)
            end]]

            table.insert(self.Parties[Owner.UserId].Members, {
                Player = Player,
                UserId = Player.UserId,
                DisplayName = Player.DisplayName,
                UserName = Player.Name,
            })
            
            self.PlayersInParties[Player.UserId] = {
                PlayerId = Player.UserId,
                PartyOwnerId = Owner.UserId
            }

            local OrderService = Knit.GetService("OrderService")

            self.Client.JoinParty:Fire(Owner, self.Parties[Owner.UserId])
            Knit.GetService("NotificationService"):Message(false, Owner, tostring(Player).." has joined party!", {Effect = false, Color = Color3.fromRGB(31, 255, 23)})

            for _, memberInParty in pairs(self.Parties[Owner.UserId].Members) do
                print(memberInParty)
                if memberInParty.UserId == Owner.UserId then continue end
                local memberIdToPlayer = memberInParty.Player
                self.Client.JoinParty:Fire(memberIdToPlayer, self.Parties[Owner.UserId])
                Knit.GetService("NotificationService"):Message(false, memberIdToPlayer, tostring(Player).." has joined party!", {Effect = false, Color = Color3.fromRGB(31, 255, 23)})
                OrderService.Client.RemoveAllOrders:Fire(memberIdToPlayer)
                for _, recipeData in pairs(OrderService:getPlayerRecipeStorage(Owner)) do
                    OrderService.Client.AddOrder:Fire(memberIdToPlayer, recipeData)
                end
            end            
            return true
        end
    end
    return false
end

function PartyService:RemovePlayerFromParty(Player : Player)
    if Player then
        if self:IsPlayerInParty(Player) == false then return false end
        
        if self.PlayersInParties[Player.UserId] then
            local OwnerParty = self:FindPartyFromPlayer(Player)
            local PartyOwnerId = OwnerParty.OwnerId
            if OwnerParty then
                local PlayerIndexWithinParty = self:FindIndexOfPartyMembers(OwnerParty.Members, Player)
                print("PlayerIndexWithinParty,", PlayerIndexWithinParty)
                if PlayerIndexWithinParty then
                    table.remove(OwnerParty.Members, PlayerIndexWithinParty)
                end
            end

            local OrderService = Knit.GetService("OrderService")

            if Player then
                self.Client.LeaveParty:Fire(Player, self.Parties[Player.UserId])
                local CookingService = Knit.GetService("CookingService")
                for _, panHitbox in pairs(CollectionService:GetTagged("Pan")) do
                    local panInfo = CookingService:GetAdditionalPansInfo(Player)
                    if panInfo[panHitbox] then
                        CookingService.Cook:Fire(Player, "Destroy", tostring(panInfo[panHitbox].Recipe), panHitbox)
                    end
                end
                OrderService.Client.RemoveAllOrders:Fire(Player)
                for _, recipeData in pairs(OrderService:getPlayerRecipeStorage(Player)) do
                    OrderService.Client.AddOrder:Fire(Player, recipeData)
                end
            end

            local Owner = Players:GetPlayerByUserId(PartyOwnerId)
            if Owner then
                self.Client.LeaveParty:Fire(Owner, self.Parties[Owner.UserId])
            end
            
            if self.Parties[PartyOwnerId] then
                for _, memberInParty in pairs(self.Parties[PartyOwnerId].Members) do
                    local memberIdToPlayer = memberInParty.Player
                    if memberIdToPlayer then
                        Knit.GetService("NotificationService"):Message(false, memberIdToPlayer, tostring(Player).." has left party!", {Effect = false, Color = Color3.fromRGB(255, 23, 23)})
                        self.Client.LeaveParty:Fire(memberIdToPlayer, self.Parties[PartyOwnerId])
                    end
                end 
            end

            self.PlayersInParties[Player.UserId] = nil
            return true
        end
    end
    return false
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
        self.PlayerInvites[Owner.UserId] = {}
        return self.Parties[Owner.UserId]
    end
    return false
end

function PartyService:DestroyParty(Owner : Player)
    if self.Parties[Owner.UserId] then
        for _, memberInParty in pairs(self.Parties[Owner.UserId].Members) do
            local memberIdToPlayer = memberInParty.Player
            local CookingService = Knit.GetService("CookingService")
            for _, panHitbox in pairs(CollectionService:GetTagged("Pan")) do
                local panInfo = CookingService:GetAdditionalPansInfo(memberIdToPlayer)
                if panInfo[panHitbox] then
                    CookingService.Cook:Fire(memberIdToPlayer, "Destroy", tostring(panInfo[panHitbox].Recipe), panHitbox)
                end
            end
            Knit.GetService("NotificationService"):Message(false, memberIdToPlayer, tostring(Owner).." party disbanded!", {Effect = false, Color = Color3.fromRGB(23, 143, 255)})
            self:RemovePlayerFromParty(memberIdToPlayer)
        end
        self.PlayerInvites[Owner.UserId] = nil
        self.Parties[Owner.UserId] = nil
        return true
    end
    return false
end

function PartyService:KnitStart()
    --local TournamentService  = Knit.GetService("TournamentService")

    self.Client.JoinParty:Connect(function(Player : Player, Owner : Player)
        if Player and Owner then
            if table.find(self.PlayerInvites[Player.UserId], Owner.UserId) then
                local indexOfInvite = table.find(self.PlayerInvites[Player.UserId], Owner.UserId)
                table.remove(self.PlayerInvites[Player.UserId], indexOfInvite)
                self:AddPlayerToParty(Player, Owner)
            end
        end
    end)

    self.Client.LeaveParty:Connect(function(Player : Player)
        if Player then
            self:RemovePlayerFromParty(Player)
        end
    end)

    self.Client.KickPlayer:Connect(function(Player : Player, Target : Player)
        if Player and Target then
            if self.PlayersInParties[Target.UserId].PartyOwnerId == Player.UserId then
                Knit.GetService("NotificationService"):Message(false, Target, tostring(Player).." has kicked you from party!", {Effect = false, Color = Color3.fromRGB(255, 23, 23)})
                self:RemovePlayerFromParty(Target)
            end
        end
    end)

    self.Client.SendInvite:Connect(function(Player : Player, Target : Player)
        if Player and Target then
            self:SendPlayerInvite(Player, Target)
        end
    end)

    self.Client.RemoveInvite:Connect(function(Player : Player, Owner : Player)
        if Player and Owner then
            self:RemovePlayerInvite(Player, Owner)
        end
    end)

end

function PartyService:KnitInit()
    
    for _, player in ipairs(Players:GetPlayers()) do
        coroutine.wrap(OnPlayerAdded)(player)
    end
    
    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(OnPlayerRemoved)
    
end


return PartyService
