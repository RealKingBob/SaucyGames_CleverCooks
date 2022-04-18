local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ClickUI = Knit.CreateController { Name = "ClickUI" }

--//Services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService")

--//Const
local plr = Players.LocalPlayer;
local canClick = false;
local GameService
local debounce = tick();

local ClickAnimation = Instance.new("Animation");
ClickAnimation.AnimationId = "rbxassetid://8424421039";

local PlayerGui = plr:WaitForChild("PlayerGui");

ClickUI.Gui = PlayerGui:WaitForChild("Click");

local ClickInfo = TweenInfo.new(.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out);

--//Private Functions
local function GetJumpButton()
	if UserInputService.TouchEnabled then
		local touchGui = plr.PlayerGui:WaitForChild("TouchGui");
		return touchGui.TouchControlFrame:FindFirstChild("JumpButton");
	end

	return nil;
end

function adjustCooldown(min, max, alpha)
    return min + (max - min) * alpha;
end

local Cooldown = adjustCooldown(0.35,1, (Players.MaxPlayers / 2) / Players.MaxPlayers);

--//Public Methods
function ClickUI:Visible(enabled)
	self.Gui.Enabled = enabled;
end

function ClickUI:OnTouchClickButtonActivated(isMobile)
    if (tick() - debounce) > Cooldown then
        debounce = tick()
        self:OnClick(isMobile);
    end
end

function ClickUI:OnScreenSizeChanged()
	if self.smallTouchscreen and self.largeTouchscreen and self.averagePCScreen then
		if UserInputService.TouchEnabled then
			local isSmallScreen;
			local jumpButton = GetJumpButton();
			if jumpButton then
				isSmallScreen = jumpButton.Size.X.Offset <= 70;
                jumpButton:GetPropertyChangedSignal("Visible"):Connect(function()
                    if jumpButton.Visible == true then
                        self.smallTouchscreen.Visible = isSmallScreen;
			            self.largeTouchscreen.Visible = not isSmallScreen;
                    else
                        self.smallTouchscreen.Visible = false;
                        self.largeTouchscreen.Visible = false;
                    end
                end);
			else
				isSmallScreen = self.Gui.AbsoluteSize.Y < 600;
			end
			self.smallTouchscreen.Visible = isSmallScreen;
			self.largeTouchscreen.Visible = not isSmallScreen;
            self.averagePCScreen.Visible = false;
		else
			self.smallTouchscreen.Visible = false;
			self.largeTouchscreen.Visible = false;
            self.averagePCText.Text = "Click READY";
            self.averagePCScreen.Visible = true;
		end
	end
end

function ClickUI:OnClick(isMobile)
    local char = plr.Character or plr.CharacterAdded:Wait();
    local hum = char:WaitForChild("Humanoid");

    local SwingSFX = Instance.new("Sound")
    SwingSFX.Volume = 1;
    SwingSFX.SoundId = "rbxassetid://6767836089"
    SwingSFX.PlayOnRemove = false

    if hum then
        if char.Parent == nil then
            return;
        end

        if canClick == false then
            canClick = true;
            
            GameService.ToolAttack:Fire();
            SwingSFX.Parent = char.PrimaryPart
            SwingSFX:Play()

            task.spawn(function()
                local con
                if isMobile == true then
                    self.cooldownText.Visible = true
                    local startTime = tick()
                    con = RunService.Heartbeat:Connect(function()
                        local elapsed = tick() - startTime -- how long has it been since we started
                        local remaining = math.max(Cooldown - elapsed, 0) -- how much do we have left, max to prevent going negative
                     
                        local seconds = remaining % 60
                        local milliseconds = (seconds % 1) * 100--(seconds * 1000) % 1000
                        seconds = math.floor(seconds)
                        --print(string.format("%.2d.%.2d", seconds, milliseconds) .."s")
                        self.cooldownText.Text = "Click Cooldown: "..string.format("%.2d.%.2d", seconds, milliseconds) .."s";
                        if remaining == 0 then
                            con:Disconnect()
                            self.cooldownText.Text = "00.00s";
                            self.cooldownText.Visible = false
                        end
                    end)
                else
                    local startTime = tick()
                    con = RunService.Heartbeat:Connect(function()
                        local elapsed = tick() - startTime -- how long has it been since we started
                        local remaining = math.max(Cooldown - elapsed, 0) -- how much do we have left, max to prevent going negative
                     
                        local seconds = remaining % 60
                        local milliseconds = (seconds % 1) * 100--(seconds * 1000) % 1000
                        seconds = math.floor(seconds)
                        --print(string.format("%.2d.%.2d", seconds, milliseconds) .."s")
                        self.averagePCText.Text = string.format("%.2d.%.2d", seconds, milliseconds) .."s";
                        if remaining == 0 then
                            con:Disconnect()
                            self.averagePCText.Text = "CLICK READY";
                        end
                    end)
                end
            end)
            task.wait(Cooldown);
            canClick = false;
        end
    end
end

function ClickUI:KnitStart()
    self.smallTouchscreen = self.Gui:WaitForChild("SmallTouchscreen");
    self.largeTouchscreen = self.Gui:WaitForChild("LargeTouchscreen");
    self.averagePCScreen = self.Gui:WaitForChild("AveragePCscreen");

    self.mouseClickImage = self.averagePCScreen:WaitForChild("ClickSection"):WaitForChild("MouseClick");
    self.averagePCText = self.averagePCScreen:WaitForChild("ClickSection"):WaitForChild("TextLabel");
    self.cooldownText = self.Gui:WaitForChild("CooldownText")

    self.smallClickButton = self.smallTouchscreen:WaitForChild("ClickButton");
    self.smallClickButton.Activated:Connect(function() self:OnTouchClickButtonActivated(true) end);
    self.largeClickButton = self.largeTouchscreen:WaitForChild("ClickButton");
    self.largeClickButton.Activated:Connect(function() self:OnTouchClickButtonActivated(true) end);

    self.Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:OnScreenSizeChanged() end);
	self:OnScreenSizeChanged();

    UserInputService.InputBegan:Connect(function(i,p)
        if plr and plr.Character then
            local BreadTool = plr.Character:FindFirstChild("BreadTool")
            if BreadTool then
                if BreadTool.Parent == plr.Character then
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        if (tick() - debounce) > Cooldown then
                            debounce = tick()
                            task.spawn(function()
                                TweenService:Create(self.mouseClickImage, ClickInfo, { Size = UDim2.fromScale(1,1.4) }):Play();
                                task.wait(.25)
                                TweenService:Create(self.mouseClickImage, ClickInfo, { Size = UDim2.fromScale(1, 1.2)}):Play();
                            end)
                            --print("The left mouse button has been pressed!")
                            self:OnClick(false);
                        end
                    end
                end
            end
        end
    end)

    GameService = Knit.GetService("GameService")
    
    GameService.AdjustClickCooldown:Connect(function(adjustedCooldown)
        Cooldown = adjustedCooldown;
    end)

    task.spawn(function()
        local function onRenderStep(deltaTime)
            local Character = plr.Character;
            if Character then
                local BreadTool = Character:FindFirstChild("BreadTool")
                if BreadTool then
                    self:OnScreenSizeChanged();
                else
                    self.smallTouchscreen.Visible = false;
                    self.largeTouchscreen.Visible = false;
                    self.averagePCScreen.Visible = false;
                end
            end
        end
    
        RunService.RenderStepped:Connect(onRenderStep)
    end)
end


function ClickUI:KnitInit()
    
end

return ClickUI