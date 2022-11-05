local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ViewsUI = Knit.CreateController { Name = "ViewsUI" }

local plr = game.Players.LocalPlayer;

local PlayerGui = plr:WaitForChild("PlayerGui");
local Views = PlayerGui:WaitForChild("Main"):WaitForChild("Views");
local BottomFrame = Views:WaitForChild("BottomFrame");
local LeftBar = PlayerGui:WaitForChild("LeftBar");
local LeftContainer = LeftBar:WaitForChild("LeftContainer");

--//Const
local ViewOriginalSizes = {};
local ViewOriginalPositions = {};

local ViewToggledEvent = Instance.new("BindableEvent");

--//State
local CurrentView;
local currentStatus, debounce = false, false;

--//Public Events
ViewsUI.ViewToggled = ViewToggledEvent.Event;

local function displayButtons(status)
    if debounce == false then
        debounce = true

        currentStatus = status;

        for _, button in pairs(BottomFrame:GetChildren()) do
            if not button:IsA("TextButton") then continue end
            if button.Name == "Menu" then continue end
    
            if currentStatus == true then
                button.Size = UDim2.fromScale(0.8, 0.6);
                
                button:TweenSize(UDim2.fromScale(0.8, 0.6), Enum.EasingDirection.Out, Enum.EasingStyle.Cubic, 0.7);
                task.wait(0.01)
                button.Visible = false;
            else
                button.Size = UDim2.fromScale(0,0);
                button.Visible = true;
    
                button:TweenSize(UDim2.fromScale(0.8, 0.6), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.7);
                task.wait(0.01)
            end
        end

        task.wait(.4)
        debounce = false
    end
    
end


--//Public Methods
function ViewsUI:OpenView(ViewName, ButtonEnabled, DisableTween)
	if (CurrentView and CurrentView.Name == ViewName) then return; end
	
	self:CloseView(nil, nil, DisableTween);
	
	CurrentView = Views[ViewName];
    
    local OriginalPosition = ViewOriginalPositions[CurrentView.Name];

    ViewToggledEvent:Fire(ViewName, true);

    if ViewName == "Menu" then
        print("menu clicked")
        return
    end

    if ButtonEnabled then
        if ViewName ~= "Settings" then
            task.spawn(displayButtons, false)
        end
    end
    
	CurrentView.Visible = true;
	CurrentView.Position = UDim2.fromScale(OriginalPosition.X.Scale, 1.6);
	CurrentView.Size = ViewOriginalSizes[CurrentView.Name]:Lerp(UDim2.fromScale(0, 0), .5);
    if DisableTween == true then
        CurrentView.Size = ViewOriginalSizes[CurrentView.Name];
    else
        CurrentView:TweenSizeAndPosition(ViewOriginalSizes[CurrentView.Name], OriginalPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .4, true);
    end
end

function ViewsUI:GetView(ItemName)
    return Views[ItemName];
end

local deselectDeb = false;

function ViewsUI:CloseView(ItemName, ButtonEnabled, DisableTween)
    if (not CurrentView) then return; end

    if (ItemName and CurrentView.Name ~= ItemName) then return; end
    
    local TargetView = CurrentView
    CurrentView = nil;

    if (TargetView) then
        ViewToggledEvent:Fire(TargetView.Name, false);

        if ButtonEnabled then
            task.spawn(displayButtons, true)
        end
        
        local OriginalPosition = ViewOriginalPositions[TargetView.Name];
        
        if DisableTween == true then
            --
        else
            TargetView:TweenSizeAndPosition(UDim2.new(), UDim2.fromScale(OriginalPosition.X.Scale, 1.6), Enum.EasingDirection.In, Enum.EasingStyle.Quart, .25, true);
        end
    end
    if not DisableTween then
        task.wait(.25)
    end
    TargetView.Visible = false;
end

function ViewsUI:GetCurrentView()
    return CurrentView;
end

function ViewsUI:KnitStart()
    for _,v in pairs(Views:GetChildren()) do
        if v:IsA("Frame") then
            ViewOriginalSizes[v.Name] = v.Size;
            ViewOriginalPositions[v.Name] = v.Position;
        end
    end

    local leftContainerDeb = false;

    for _,v in pairs(LeftContainer:GetDescendants()) do
        if (v:IsA("TextButton")) then
            v.MouseButton1Click:Connect(function()
                if (Views:FindFirstChild(v.Name)) then
                    if (CurrentView and CurrentView.Name == v.Name) then
                        if leftContainerDeb == false then leftContainerDeb = true else return end
                        self:CloseView(nil, true);
                        task.wait(.5)
                        leftContainerDeb = false;
                    else		
                        if leftContainerDeb == false then leftContainerDeb = true else return end
                        self:OpenView(v.Name, true);
                        task.wait(.5)
                        leftContainerDeb = false;
                    end
                end
            end)
        end
    end

    for _,v in pairs(BottomFrame:GetChildren()) do
        if (v:IsA("TextButton")) then
            v.MouseButton1Click:Connect(function()
                if (Views:FindFirstChild(v.Name)) then
                    if (CurrentView and CurrentView.Name == v.Name) then
                        --self:CloseView();
                    else		
                        self:OpenView(v.Name, nil, true);
                    end
                end
            end)
        end
    end
end

function ViewsUI:KnitInit()
    
end

return ViewsUI
