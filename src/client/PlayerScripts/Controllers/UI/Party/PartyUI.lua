local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PartyUI = Knit.CreateController { Name = "PartyUI" }

--//Services
local Players = game:GetService("Players")

--//Imports
local TweenModule;

--//Const
local plr = Players.LocalPlayer;

local PlayerGui = plr:WaitForChild("PlayerGui");

local PartyInvitesUI = PlayerGui:WaitForChild("PartyInvites")

local viewsUI = PlayerGui:WaitForChild("Main"):WaitForChild("Views")
local PartyButtonView = PlayerGui:WaitForChild("LeftBar"):WaitForChild("LeftContainer"):WaitForChild("Frame"):WaitForChild("Party");

local PartyView = viewsUI:WaitForChild("Party");
local PartyMainFrame = PartyView:WaitForChild("Main")
local PlayerListFrame = PartyMainFrame:WaitForChild("PlayerList"):WaitForChild("List"):WaitForChild("MainContainer")
local PartyListFrame = PartyMainFrame:WaitForChild("PartyList"):WaitForChild("List"):WaitForChild("MainContainer")
local PartyButtons = PartyMainFrame:WaitForChild("PartyList"):WaitForChild("Buttons")

function PartyUI:UpdateMemberList(Data)
    print(Data)

    for _, button in pairs(PartyListFrame:GetChildren()) do
        task.spawn(function()
            if button:IsA("TextButton") then
                if button:GetAttribute("UserId") then
                    button:SetAttribute("UserId", Data.Members[button:GetAttribute("ID") + 1] ~= nil and Data.Members[button:GetAttribute("ID") + 1].UserId or 0)
                    button:SetAttribute("UserName", Data.Members[button:GetAttribute("ID") + 1] ~= nil and Data.Members[button:GetAttribute("ID") + 1].UserName or "")
                    button:SetAttribute("DisplayName", Data.Members[button:GetAttribute("ID") + 1] ~= nil and Data.Members[button:GetAttribute("ID") + 1].DisplayName or "")
                end
            end
        end)
        task.wait(0.002);
    end
end

function PartyUI:RefreshPartyMembers()
    local memberCount = 0;
    for _, button in pairs(PartyListFrame:GetChildren()) do
        task.spawn(function()
            if button:IsA("TextButton") then
                if button:GetAttribute("UserId") == 0 then
                    button.Displayname.Text = "";
                    button.Username.Text = "";
                    if button:FindFirstChild("Kick") then
                        button:FindFirstChild("Kick").Visible = false;
                    end
                    button.Avatar.ImageColor3 = Color3.fromRGB(0,0,0);
                    button.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420";
                    button.Avatar.Visible = false;
                else
                    memberCount += 1;
                    button.Displayname.Text = button:GetAttribute("DisplayName");
                    button.Username.Text = "(@"..button:GetAttribute("UserName")..")";
                    button.Avatar.ImageColor3 = Color3.fromRGB(255, 255, 255);
                    button.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=".. tostring(button:GetAttribute("UserId")) .."&w=420&h=420";
                    button.Avatar.Visible = true;
                end

                if button:GetAttribute("UserId") == plr.UserId then
                    button.Displayname.TextColor3 = Color3.fromRGB(255, 217, 0);
                else
                    button.Displayname.TextColor3 = Color3.fromRGB(255, 255, 255);
                end

                if button:GetAttribute("ID") == 0 then
                    local prevName = button.Displayname.Text;
                    button.Displayname.Text = "[👑] "..prevName;
                end
            end
        end)
        task.wait(0.002);
    end

    for _, button in pairs(PartyListFrame:GetChildren()) do
        task.spawn(function()
            if button:IsA("TextButton") then
                if button:GetAttribute("UserId") == 0 then
                    if button:FindFirstChild("Kick") then
                        button:FindFirstChild("Kick").Visible = false;
                    end
                else
                    if plr.UserId == PartyListFrame:FindFirstChild("PartyLeader"):GetAttribute("UserId")
                    and button:FindFirstChild("Kick") then
                        button:FindFirstChild("Kick").Visible = true;
                    end
                end
            end
        end)
        task.wait(0.002);
    end

    if PartyListFrame:FindFirstChild("PartyLeader"):GetAttribute("UserId") == plr.UserId then
        PartyButtons.Leave.Visible = false;
    else
        PartyButtons.Leave.Visible = true;
    end

    PartyButtonView:FindFirstChild("Title").Text = "(".. tostring(memberCount) .."/10)"
    PartyMainFrame:WaitForChild("PartyList"):FindFirstChild("NumOfParty").Text = "Party (".. tostring(memberCount) .."/10)"
end

function PartyUI:RefreshInvitePlayers()
    for _, button in pairs(PlayerListFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button:Destroy();
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player == plr then continue end
        local PartyPlayerPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("PartyPlayer");
        local ItemClone = PartyPlayerPrefab:Clone() do
            ItemClone.Name = player.UserId;
            ItemClone.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=".. tostring(player.UserId) .."&w=420&h=420";
            ItemClone.DisplayName.Text = player.DisplayName;
            ItemClone.Username.Text = "(@"..player.Name..")";

            local suc, err = pcall(function()
                if player:IsFriendsWith(plr.UserId) then
                    ItemClone.LayoutOrder = 0;
                else
                    ItemClone.LayoutOrder = 1;
                end
            end)

            if not suc then
                ItemClone.LayoutOrder = 1;
            end
            
            ItemClone.Parent = PlayerListFrame;

            ItemClone.MouseButton1Click:Connect(function()
                if plr ~= player then
                    local PartyService = Knit.GetService("PartyService");
                    print("SENT", plr, player)
                    PartyService.SendInvite:Fire(player)
                    ItemClone.Invited.Visible = true;
                end
            end)
        end
    end
end

function PartyUI:PendInvite(player)
    local InviteTween, Tween;

    local InvitePlayerPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("InvitePlayer");
    local ItemClone = InvitePlayerPrefab:Clone() do
        ItemClone.Name = player.UserId;
        ItemClone.Main.Username.Text = player.DisplayName;

        if player:IsFriendsWith(plr.UserId) then
            ItemClone.Main.Username.TextColor3 = Color3.fromRGB(255, 217, 0);
        else
            ItemClone.Main.Username.TextColor3 = Color3.fromRGB(255, 255, 255);
        end

        ItemClone.Main.Position = UDim2.fromScale(0.5, 1.5);

        local PartyInvitesController = Knit.GetController("PartyInvitesUI");
        
        PartyInvitesController:CreateInvite(player);

        local InviteInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

        InviteTween = TweenModule.new(InviteInfo, function(Alpha)
            if ItemClone then
                if ItemClone:FindFirstChild("Main") then
                    ItemClone.Main.Position = UDim2.fromScale(0.5, 1.5):Lerp(UDim2.fromScale(0.5, 0.5), Alpha);
                end
            end
        end)

        ItemClone.MouseButton1Click:Connect(function()
            --if plr ~= player then
                local PartyService = Knit.GetService("PartyService");
                PartyService.JoinParty:Fire(player)
        
                PartyInvitesController:DestroyInvite(player);
                
                local InviteInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

                InviteTween = TweenModule.new(InviteInfo, function(Alpha)
                    if ItemClone then
                        if ItemClone:FindFirstChild("Main") then
                            ItemClone.Main.Position = UDim2.fromScale(0.5, 0.5):Lerp(UDim2.fromScale(0.5, 1.5), Alpha);
                        end
                    end
                end)

                InviteTween:Play();
                InviteTween.Completed:Wait();

                ItemClone.Visible = false;

                task.delay(2, function()
                    if ItemClone then

                        if InviteTween then InviteTween:Cancel() end
                        if Tween then Tween:Cancel() end

                        ItemClone:Destroy();
                    end
                end)
            --end
        end)

        ItemClone.Parent = PartyInvitesUI.InvitesFrame;

        InviteTween:Play();
        InviteTween.Completed:Wait();

        task.spawn(function()
            local BarInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

            Tween = TweenModule.new(BarInfo, function(Alpha)
                if ItemClone then
                    if ItemClone:FindFirstChild("Main"):FindFirstChild("BarHolder"):FindFirstChild("Bar") then
                        ItemClone.Main.BarHolder.Bar.Size = UDim2.fromScale(1,1):Lerp(UDim2.fromScale(0,1), Alpha);
                    end
                end
            end)

            Tween:Play();
            Tween.Completed:Wait();
            Tween:Cancel();

            local InviteInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

            InviteTween = TweenModule.new(InviteInfo, function(Alpha)
                if ItemClone then
                    if ItemClone:FindFirstChild("Main") then
                        ItemClone.Main.Position = UDim2.fromScale(0.5, 0.5):Lerp(UDim2.fromScale(0.5, 1.5), Alpha);
                    end
                end
            end)

            InviteTween:Play();
            InviteTween.Completed:Wait();

            ItemClone.Visible = false;

            task.delay(2, function()
                if ItemClone then

                    if InviteTween then InviteTween:Cancel() end
                    if Tween then Tween:Cancel() end
                    
                    ItemClone:Destroy();
                end
            end)
        end)
        
    end
end

function PartyUI:KnitStart()
    local PartyService = Knit.GetService("PartyService")
    local GameController = Knit.GetController("GameController")
    PartyService.SendInvite:Connect(function(InviteOwner)
        --print("SendInvite:", InviteOwner)
        self:PendInvite(InviteOwner);
    end)
    
    PartyService.JoinParty:Connect(function(PartyInfo)
        --print("PartyInfo [JoinParty]:", PartyInfo)
        GameController:ChangePartyOwner(PartyInfo)
        self:UpdateMemberList(PartyInfo);
        self:RefreshPartyMembers();
    end)
    
    PartyService.LeaveParty:Connect(function(PartyInfo)
        --print("PartyInfo [LeaveParty]:", PartyInfo)
        GameController:ChangePartyOwner(PartyInfo)
        self:UpdateMemberList(PartyInfo);
        self:RefreshPartyMembers();
    end)
end

function PartyUI:KnitInit()
    TweenModule = require(Knit.Modules.Tween);

    local LeaderFrame = PartyListFrame:FindFirstChild("PartyLeader");
    LeaderFrame:SetAttribute("UserId", plr.UserId);
    LeaderFrame:SetAttribute("UserName", plr.Name);
    LeaderFrame:SetAttribute("DisplayName", plr.DisplayName);

    self:RefreshInvitePlayers();
    self:RefreshPartyMembers();

    for _, button in pairs(PartyListFrame:GetChildren()) do
        if button:IsA("TextButton") then
            if button:FindFirstChild("Kick") then
                button:FindFirstChild("Kick").MouseButton1Click:Connect(function()
                    local PartyService = Knit.GetService("PartyService");
                    local TargetPlayer = Players:GetPlayerByUserId(button:GetAttribute("UserId"));
                    PartyService.KickPlayer:Fire(TargetPlayer);
                end)
            end
        end
    end

    PartyButtons.Invites:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        local PartyInvitesController = Knit.GetController("PartyInvitesUI");
        
        PartyInvitesController:OpenView();
    end)

    PartyButtons.Leave:WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        local PartyService = Knit.GetService("PartyService");
        PartyService.LeaveParty:Fire()
    end)
end


return PartyUI
