local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local SettingsUI = Knit.CreateController { Name = "SettingsUI" }

SettingsUI.Settings = {}

--//Services
local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local SettingTabPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("SettingTab")
local SettingButtonTabPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("SettingButtonTab")
local SettingSliderTabPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("SettingSliderTab")
local SettingsView = PlayerGui:WaitForChild("Views"):WaitForChild("Settings");

local PlayerSettings = require(Knit.ReplicatedModules.SettingsUtil);
local Icon = require(Knit.ReplicatedModules.Icon);

local deselectCooldown = false;

SettingsUI.icon = Icon.new()
    :setImage(8260514305)
    :setCaption("Settings")
    :setRight()
    :bindEvent("selected", function()
        local ViewsUI = Knit.GetController("ViewsUI");
        ViewsUI:OpenView("Settings")
	end)
	:bindEvent("deselected", function()
        local ViewsUI = Knit.GetController("ViewsUI");
		ViewsUI:CloseView("Settings")
	end)

local SettingChangedBindable = Instance.new("BindableEvent");

--//Public Events
SettingsUI.SettingChanged = SettingChangedBindable.Event;

local function adjust(min, max, alpha)
    return min + (max - min) * alpha;
end

local function GetJumpButton()
	if UserInputService.TouchEnabled then
		local touchGui = plr.PlayerGui:WaitForChild("TouchGui");
		return touchGui.TouchControlFrame:FindFirstChild("JumpButton");
	end

	return nil;
end

--//Public Methods
function SettingsUI:DeselectButton()
    if deselectCooldown == false then
        deselectCooldown = true;
        self.icon:deselect()
        task.spawn(function()
            task.wait(.45);
            deselectCooldown = false;
        end)
    end
    
end

function SettingsUI:GetSetting(SettingName)
    assert(PlayerSettings[SettingName], "Setting does not exist");

    local CurrentSetting = self.Settings[SettingName];

    if (not CurrentSetting) then
        return PlayerSettings[SettingName].Default, true;
    end

    return CurrentSetting;
end

function SettingsUI:CreateButton(SettingName, SettingOption)
    local Clone = SettingButtonTabPrefab:Clone() do
        Clone:WaitForChild("TextLabel").Text = SettingName;
        if SettingOption == "Off" then
            Clone:WaitForChild("Button"):WaitForChild("ImageButton").ImageColor3 = Color3.fromRGB(252, 59, 59)
        elseif SettingOption == "On" then
            Clone:WaitForChild("Button"):WaitForChild("ImageButton").ImageColor3 = Color3.fromRGB(74, 223, 0)
        else
            Clone:WaitForChild("Button"):WaitForChild("ImageButton").ImageColor3 = Color3.fromRGB(0, 174, 255)
        end
        Clone:WaitForChild("Button"):WaitForChild("ImageButton"):WaitForChild("TextLabel").Text = SettingOption;
        Clone.Name = SettingName;
        Clone.LayoutOrder = 1;
        Clone.Parent = SettingsView:WaitForChild("Inner"):WaitForChild("ScrollingFrame");
    end

    local CurrentOption = 1;
    local Debounce = false;

    local function Length(Table)
        local counter = 0 
        for _, v in pairs(Table) do
            counter = counter + 1
        end
        return counter
    end

    Clone:WaitForChild("Button"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        if Debounce == false then
            Debounce = true;
            --print("Toggled", SettingName, PlayerSettings[SettingName].Options);
            CurrentOption += 1
            local NumOfOptions = Length(PlayerSettings[SettingName].Options)
            if CurrentOption > NumOfOptions then
                CurrentOption = 1
            end
            for Name, Data in next, PlayerSettings[SettingName].Options do
                if Data[1] == CurrentOption then
                    --print(Name, Data)
                    self:SetSetting(SettingName, Name)
                end
            end
            Debounce = false;
        end
    end)
end

function SettingsUI:CreateSlider(SettingName, SettingOption)
    local Clone = SettingSliderTabPrefab:Clone() do
        Clone:WaitForChild("TextLabel").Text = SettingName;
        Clone.Name = SettingName;
        Clone.LayoutOrder = 0;
        Clone.Parent = SettingsView:WaitForChild("Inner"):WaitForChild("ScrollingFrame");
    end

    local MaxValue = PlayerSettings[SettingName].MaxValue;
    local MinValue = PlayerSettings[SettingName].MinValue;
    local SliderDrag = false;
    
    local SliderFrame = Clone:WaitForChild("Slider")

    SliderFrame:WaitForChild("Button").MouseButton1Down:Connect(function()
        SliderDrag = true
    end)

    UserInputService.InputChanged:Connect(function()
        if SliderDrag then
            local MousePos = UserInputService:GetMouseLocation()+Vector2.new(0,36)
            local RelPos = MousePos-SliderFrame.AbsolutePosition
            local Percent = math.clamp(RelPos.X/SliderFrame.AbsoluteSize.X,0,1)
            --print(math.floor(Percent*100), adjust(MinValue, MaxValue, Percent))
            SliderFrame.Button.Position = UDim2.new(Percent,0,0.5,0)
            Clone.Volume.Text = tostring(math.floor(Percent*100).."%")
            if SettingName == "Music" then
                ReplicatedStorage:WaitForChild("Audios").Current.Music.Sound.Volume = adjust(MinValue, MaxValue, Percent);
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            SliderDrag = false
        end
    end)
end

function SettingsUI:SetSetting(SettingName, Option)
    assert(PlayerSettings[SettingName].Options[Option], "Option does not exist");
    --self.Settings[SettingName] = Option
    local GameService = Knit.GetService("GameService");
    GameService.ChangeSetting:Fire(SettingName, Option);
end

function SettingsUI:UpdateSetting(SettingName, Option)
    assert(PlayerSettings[SettingName].Options[Option], "Option does not exist");
    self.Settings[SettingName] = Option
    local SettingButton = SettingsView:WaitForChild("Inner"):WaitForChild("ScrollingFrame"):FindFirstChild(SettingName)
    local ImageButton = SettingButton:WaitForChild("Button"):WaitForChild("ImageButton")
    ImageButton:WaitForChild("TextLabel").Text = Option
    if Option == "Off" then
        ImageButton.ImageColor3 = Color3.fromRGB(252, 59, 59)
    elseif Option == "On" then
        ImageButton.ImageColor3 = Color3.fromRGB(74, 223, 0)
    else
        ImageButton.ImageColor3 = Color3.fromRGB(0, 174, 255)
    end
end

function SettingsUI:AddSetting(SettingName, SettingOption, SettingType)
    if SettingType == "Button" then
        self:CreateButton(SettingName, SettingOption)
    elseif SettingType == "Slider" then
        self:CreateSlider(SettingName, SettingOption)
    end
end

function SettingsUI:KnitStart()
    for Name, Data in next, PlayerSettings do
        if PlayerSettings[Name]["IsMobile"] == true then
            local JumpButton = GetJumpButton()
            if JumpButton ~= nil then
                self:AddSetting(Name, Data.Default, Data.Type);
            end
        else
            self:AddSetting(Name, Data.Default, Data.Type);
        end
    end
    local GameService = Knit.GetService("GameService");
    GameService.ChangeSetting:Connect(function(SettingName, Option)
        SettingsUI:UpdateSetting(SettingName, Option)
    end)
end

function SettingsUI:KnitInit()
    
end

return SettingsUI
