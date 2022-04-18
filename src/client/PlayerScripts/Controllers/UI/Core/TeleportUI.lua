local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TeleportUI = Knit.CreateController { Name = "TeleportUI" }

--//Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

local placeSelected, TeleportService;

--//Public Methods
--/ UI Methods
function TeleportUI:OpenPanelUI()
    self.ViewsUI:OpenView("Teleport")
end

function TeleportUI:ClosePanelUI()
    self.ViewsUI:CloseView("Teleport")
end

function TeleportUI:SetupTeleportUI()
    self.TeleportUI = PlayerGui:WaitForChild("Views"):WaitForChild("Teleport")
    self.MainFrame = self.TeleportUI:WaitForChild("Main")
    self.MainContainer = self.MainFrame:WaitForChild("Places"):WaitForChild("MainContainer")
    self.TeleportSection = self.MainFrame:WaitForChild("TeleportSection")
    self.ViewsUI = Knit.GetController("ViewsUI")


    for _, ServerFrame in pairs(self.MainContainer:GetChildren()) do
        if not ServerFrame:IsA("Frame") then
            continue;
        end

        ServerFrame:WaitForChild("Main"):WaitForChild("Button").MouseButton1Click:Connect(function()
            if CollectionService:HasTag(ServerFrame:WaitForChild("Main"), "ButtonStyle") == true then
                placeSelected = ServerFrame:GetAttribute("ServerType");
                self.TeleportSection:WaitForChild("PlaceDesc").Text = "Place Chosen: " .. ServerFrame.Name;
            end
        end)
    end

    local VoiceChatService = game:GetService("VoiceChatService")

    function TeleportUI:PlayerHasVoiceChat()
        if plr then
            local success, enabled = pcall(function()
                return VoiceChatService:IsVoiceEnabledForUserIdAsync(plr.UserId)
            end)
            if success and enabled then
                return true;
            end
        end
        return false;
    end

    local TeleportPlaceButton = self.TeleportSection:WaitForChild("TeleportPlace"):WaitForChild("ImageButton")
    
    TeleportPlaceButton.MouseButton1Click:Connect(function()
        if CollectionService:HasTag(TeleportPlaceButton, "ButtonStyle") == true then
            if placeSelected then
                if placeSelected == 2 then
                    if self:PlayerHasVoiceChat() == false then return end
                end
                TeleportService.TeleportPlace:Fire(placeSelected)
            end
        end
    end)
end

--/ Other Methods

function TeleportUI:KnitStart()
    local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

    repeat task.wait(0) until Character
    if Character then
        TeleportService = Knit.GetService("TeleportService")

        self:SetupTeleportUI();
    end
end

function TeleportUI:KnitInit()
    
end

return TeleportUI
