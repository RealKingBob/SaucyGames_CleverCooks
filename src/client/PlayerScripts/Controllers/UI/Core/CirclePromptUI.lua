local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CirclePromptUI = Knit.CreateController { Name = "CirclePromptUI" }

function CirclePromptUI:SetupPrompts(Obj)
    if Obj:GetAttribute("NoSpin") then
        return;
    end
    local ts = game:GetService("TweenService") --TweenService
    local object = Obj --Path to what object you're tweening
    local info = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
    local goals = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
    local tween = ts:Create(object, info, goals)
    tween:Play()
end

function CirclePromptUI:KnitStart()
    CollectionService:GetInstanceAddedSignal("CirclePrompts"):Connect(function(v)
        self:SetupPrompts(v);
    end)

    for _,v in pairs(CollectionService:GetTagged("CirclePrompts")) do
        self:SetupPrompts(v);
    end

    self.ShopUI = Knit.GetController("ShopUI");
    self.ViewsUI = Knit.GetController("ViewsUI");
    self.MapQueueUI = Knit.GetController("QueueUI");
    self.PartyQueueUI = Knit.GetController("PartyQueueUI");

    ProximityPromptService.PromptShown:Connect(function(prompt, inputStyle)
        if prompt.Style == Enum.ProximityPromptStyle.Default then
            return
        end

        if prompt.ActionText == "MapQueue" then
            self.MapQueueUI:OpenPanelUI()

            prompt.PromptHidden:Wait()

            self.MapQueueUI:ClosePanelUI()
        elseif prompt.ActionText == "PlaceQueue" then
            self.ViewsUI:OpenView("Teleport");
            
            prompt.PromptHidden:Wait()

            self.ViewsUI:CloseView()
        elseif prompt.ActionText == "Shop" then
            self.ViewsUI:OpenView("Shop");
            self.ShopUI:GoToPage("Daily");

            prompt.PromptHidden:Wait()

            self.ViewsUI:CloseView()
        elseif prompt.ActionText == "TournamentQueue"
        or prompt.ActionText == "VCTournamentQueue" then
            
            self.PartyQueueUI:UpdateText(tostring(prompt.ActionText));

            if self.PartyQueueUI:IsViewing() == true then return end

            self.ViewsUI:OpenView("Queue");

            prompt.PromptHidden:Wait()

            self.ViewsUI:CloseView()
        end
    end)
end


function CirclePromptUI:KnitInit()
    
end


return CirclePromptUI
