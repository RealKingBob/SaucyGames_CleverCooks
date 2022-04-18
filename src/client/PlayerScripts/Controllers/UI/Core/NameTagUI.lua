local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local NametagUI = Knit.CreateController { Name = "NametagUI" }

--//Services
local plr = game.Players.LocalPlayer;
local currentState;

function NametagUI:Display(state)
    currentState = state;
    for _, nametags in pairs(workspace:WaitForChild("Lobby").NameTags:GetChildren()) do
        if nametags:IsA("BillboardGui") then
            if state == "Everyone" then
                nametags.Enabled = true
            elseif state == "Friends" then
                if plr:IsFriendsWith(tonumber(nametags.Name)) or plr.UserId == tonumber(nametags.Name) then
                    nametags.Enabled = true
                else
                    nametags.Enabled = false
                end
            else
                nametags.Enabled = false
            end
        end
    end
end

function NametagUI:setupConnections()
    --print("NametagUI setupConnections")

    local GameService = Knit.GetService("GameService")

    GameService.DisplayNametags:Connect(function(state)
        self:Display(tostring(state))
    end)

    Players.PlayerAdded:Connect(function(player)
        if currentState then
            local playerTag = workspace:WaitForChild("Lobby").NameTags:WaitForChild(player.UserId)
            if currentState == "Everyone" then
                playerTag.Enabled = true
            elseif currentState == "Friends" then
                if plr:IsFriendsWith(tonumber(playerTag.Name)) or plr.UserId == tonumber(playerTag.Name) then
                    playerTag.Enabled = true
                else
                    playerTag.Enabled = false
                end
            else
                playerTag.Enabled = false
            end
        end
    end)
end

function NametagUI:KnitStart()
    self:setupConnections()
end


function NametagUI:KnitInit()
    
end


return NametagUI
