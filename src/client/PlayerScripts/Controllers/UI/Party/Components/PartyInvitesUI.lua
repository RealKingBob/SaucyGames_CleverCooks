local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PartyInvitesUI = Knit.CreateController { Name = "PartyInvitesUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Const
local isOpened = false;

local debounce = false;

local ViewOriginalSizes = {};
local ViewOriginalPositions = {};

local TweenModule = require(Knit.Modules.Tween);
local NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

local PlayerGui = plr:WaitForChild("PlayerGui");
local viewsUI = PlayerGui:WaitForChild("Main"):WaitForChild("Views")

local PartyView = viewsUI:WaitForChild("Party");
local InvitePanel = PartyView:WaitForChild("InvitePanel");
local PanelMainFrame = InvitePanel:WaitForChild("Inner"):WaitForChild("Main")
local BackButton = PanelMainFrame:WaitForChild("BackButton")
local PlayerListFrame = PanelMainFrame:WaitForChild("CaseContainer"):WaitForChild("Holder"):WaitForChild("Inner"):WaitForChild("ScrollingFrame")

function PartyInvitesUI:IsViewing()
    return isOpened;
end

function PartyInvitesUI:CreateInvite(Player : Player)
    if Player then
        local PlayerInvitePrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("PlayerInviteTab");
        local ItemClone = PlayerInvitePrefab:Clone() do
            ItemClone.Name = Player.UserId;
            ItemClone.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=".. tostring(Player.UserId) .."&w=420&h=420";

            ItemClone.DisplayName.Text = Player.DisplayName;
            ItemClone.Username.Text = "(@"..Player.Name..")";

            if Player:IsFriendsWith(plr.UserId) then
                ItemClone.LayoutOrder = 0;
            else
                ItemClone.LayoutOrder = 1;
            end

            ItemClone.Parent = PlayerListFrame;

            ItemClone:WaitForChild("Join").MouseButton1Click:Connect(function()
                if debounce == false then
                    debounce = true
                    --if plr ~= player then
                        local PartyService = Knit.GetService("PartyService");
                        PartyService.JoinParty:Fire(Player)
                        ItemClone:Destroy();
                    --end
                    task.wait(0.5)
                    debounce = false
                end
            end)

            ItemClone:WaitForChild("Decline").MouseButton1Click:Connect(function()
                if debounce == false then
                    debounce = true
                    --if plr ~= player then
                        local PartyService = Knit.GetService("PartyService");
                        PartyService.RemoveInvite:Fire(Player)
                        ItemClone:Destroy();
                    --end
                    task.wait(0.5)
                    debounce = false
                end
            end)
        end
    end
end

function PartyInvitesUI:DestroyInvite(Player : Player)
    if PlayerListFrame:FindFirstChild(tostring(Player.UserId)) then
        PlayerListFrame:FindFirstChild(tostring(Player.UserId)):Destroy();
    end
end

function PartyInvitesUI:OpenView()
    if isOpened == true then return end

    isOpened = true;

	local CurrentView = InvitePanel;
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

    CurrentView.Background.BackgroundTransparency = 1;

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
    
    task.wait(.2)
    local FadeTween = TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);
    local FadeOutTween = TweenModule.new(FadeTween, function(Alpha)
        CurrentView.Background.BackgroundTransparency = NumberUtil.LerpClamp(1, 0.45, Alpha);
    end)

    FadeOutTween:Play();
    FadeOutTween.Completed:Wait();
end

function PartyInvitesUI:CloseView()
    if isOpened == false then return end

    isOpened = false;

    local TargetView = InvitePanel;

    if (TargetView) then

        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end

end


function PartyInvitesUI:KnitStart()

    ViewOriginalSizes[InvitePanel.Name] = InvitePanel.Size;
    ViewOriginalPositions[InvitePanel.Name] = InvitePanel.Position;

    BackButton:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        self:CloseView();
    end)
end


function PartyInvitesUI:KnitInit()
    
end


return PartyInvitesUI
