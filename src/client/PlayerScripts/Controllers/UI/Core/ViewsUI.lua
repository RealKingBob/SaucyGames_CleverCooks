local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ViewsUI = Knit.CreateController { Name = "ViewsUI" }

local plr = game.Players.LocalPlayer;

local PlayerGui = plr:WaitForChild("PlayerGui");
local Views = PlayerGui:WaitForChild("Views");
local LeftBar = PlayerGui:WaitForChild("LeftBar");
local Main = LeftBar:WaitForChild("MainContainer"):WaitForChild("Main");

--//Const
local ViewOriginalSizes = {};
local ViewOriginalPositions = {};

local ViewToggledEvent = Instance.new("BindableEvent");

--//State
local CurrentView;

--//Public Events
ViewsUI.ViewToggled = ViewToggledEvent.Event;

--//Public Methods
function ViewsUI:OpenView(ViewName)
	if (CurrentView and CurrentView.Name == ViewName) then return; end
	
	self:CloseView();
	
	CurrentView = Views[ViewName];
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

    ViewToggledEvent:Fire(ViewName, true);

    if ViewName == "Party" then
        local PartyController = Knit.GetController("PartyUI");
        PartyController:RefreshInvitePlayers();
    end

	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
	CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
end

function ViewsUI:GetView(ItemName)
    return Views[ItemName];
end

local deselectDeb = false;

function ViewsUI:CloseView(ItemName)
    if (not CurrentView) then return; end

    if (ItemName and CurrentView.Name ~= ItemName) then return; end

    if CurrentView.Name == "Settings" or ItemName == "Settings" then
        if deselectDeb == false then
            deselectDeb = true;
            local SettingsUI = Knit.GetController("SettingsUI")
            SettingsUI:DeselectButton()
            task.spawn(function()
                task.wait(.45)
                deselectDeb = false;
            end)
        end
    end
    
    local TargetView = CurrentView
    CurrentView = nil;

    if (TargetView) then
        ViewToggledEvent:Fire(TargetView.Name, false);
        
        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
    end
    
end

function ViewsUI:GetCurrentView()
    return CurrentView;
end

function ViewsUI:KnitStart()
    for _,v in pairs(Views:GetChildren()) do
        ViewOriginalSizes[v.Name] = v.Size;
        ViewOriginalPositions[v.Name] = v.Position;
    end

    for _,v in pairs(Main:GetChildren()) do
        if (v:IsA("GuiObject")) then
            v.Main.Button.MouseButton1Click:Connect(function()
                if (Views:FindFirstChild(v.Name)) then
                    if (CurrentView and CurrentView.Name == v.Name) then
                        self:CloseView();
                    else		
                        self:OpenView(v.Name);
                    end
                end
            end)
        end
    end
end

function ViewsUI:KnitInit()
    
end

return ViewsUI
