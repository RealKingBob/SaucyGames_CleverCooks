
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit);
local DashUI = Knit.CreateController { Name = "DashUI" };

--//Services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService")

--//Const
local plr = Players.LocalPlayer;
local canDash = false;

local DashAnimation = Instance.new("Animation");
DashAnimation.AnimationId = "rbxassetid://8424421039";

local PlayerGui = plr:WaitForChild("PlayerGui");

DashUI.Gui = PlayerGui:WaitForChild("Dash");

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

local Cooldown = adjustCooldown(1,2.5, (Players.MaxPlayers / 2) / Players.MaxPlayers);

--//Public Methods
function DashUI:Visible(enabled)
	self.Gui.Enabled = enabled;
end

function DashUI:OnTouchDashButtonActivated(isMobile)
	self:OnDash(isMobile);
end

function DashUI:OnScreenSizeChanged()
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
            self.averagePCText.Text = "DASH READY";
            self.averagePCScreen.Visible = true;
		end
	end
end

function DashUI:OnDash(isMobile)
    local char = plr.Character or plr.CharacterAdded:Wait();
    local hum = char:WaitForChild("Humanoid");

    if hum then
        if char.Parent == nil or CollectionService:HasTag(plr, "Hunter") then
            return;
        end

        local dashA = hum:LoadAnimation(DashAnimation);
        dashA.Looped = false;
        dashA.Priority = "Action";
        
        local DashSFX = Instance.new("Sound")
        DashSFX.SoundId = "rbxassetid://5989939664"
        DashSFX.PlayOnRemove = false

        if canDash == false then
            canDash = true;
            --[[if (CollectionService:HasTag(plr, "Hunter") and not CollectionService:HasTag(plr, "Duck") and CollectionService:HasTag(plr, "Alive")) then
                return
            end]]

            if hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.1)
            end

            local bv = Instance.new("BodyVelocity",char.PrimaryPart);
            bv.MaxForce = Vector3.new(50000,50000,50000);
            bv.Velocity = char.PrimaryPart.CFrame.LookVector * 75 + Vector3.new(0,2.5,0);
            
            dashA:Play();
            
            task.spawn(function()
                DashSFX.Parent = char.PrimaryPart
                DashSFX:Play()
                if char.PrimaryPart:FindFirstChild("DashAttachment") then
                    char.PrimaryPart:FindFirstChild("Trail").Enabled = true;
                    
                    local Clouds = char.PrimaryPart:FindFirstChild("DashAttachment"):FindFirstChild("Clouds");
                    local Circle = char.PrimaryPart:FindFirstChild("DashAttachment"):FindFirstChild("Circle");
                    Clouds.Enabled = true;
                    Circle.Enabled = true;
                    
                    Circle:Clear();
                    Circle:Emit(1);
                    
                    Circle.Enabled = false;
                    
                    Clouds:Clear();
                    Clouds:Emit(20);
                end
                DashSFX.Ended:Wait()
                DashSFX:Destroy()
            end)

            task.spawn(function()
                for i = 1, 10 do
                    task.wait(0);
                    --local ray = Ray.new(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector * 3.5);
                    --local partOn = workspace:FindPartOnRay(ray, char);
                    local partOn = workspace:Raycast(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector * 3.5);
                    
                    if partOn ~= nil then
                        if partOn.Instance and partOn.Instance.CanCollide == true and partOn.Instance.Transparency ~= 1 then
                            if not partOn.Instance:FindFirstChild("Humanoid") and not partOn.Instance:GetAttribute("IgnorePart") then
                                bv.Velocity = char.PrimaryPart.CFrame.LookVector * -25;
                            end
                        end
                    end
                end
            end)
            
            task.wait(0.1515955924987793)

            bv:Destroy();
            if char.PrimaryPart:FindFirstChild("DashAttachment") then
                char.PrimaryPart:FindFirstChild("Trail").Enabled = false;
                char.PrimaryPart:FindFirstChild("DashAttachment"):FindFirstChild("Clouds").Enabled = false;
                char.PrimaryPart:FindFirstChild("DashAttachment"):FindFirstChild("Circle").Enabled = false;
            end
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
                        self.cooldownText.Text = "Dash Cooldown: "..string.format("%.2d.%.2d", seconds, milliseconds) .."s";
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
                            self.averagePCText.Text = "DASH READY";
                        end
                    end)
                end
            end)
            task.wait(Cooldown);
            canDash = false;
        end
    end
end

function DashUI:KnitStart()
    self.smallTouchscreen = self.Gui:WaitForChild("SmallTouchscreen");
    self.largeTouchscreen = self.Gui:WaitForChild("LargeTouchscreen");
    self.averagePCScreen = self.Gui:WaitForChild("AveragePCscreen");

    self.leftShiftImage = self.averagePCScreen:WaitForChild("DashSection"):WaitForChild("LeftShift");
    self.averagePCText = self.averagePCScreen:WaitForChild("DashSection"):WaitForChild("TextLabel");
    self.cooldownText = self.Gui:WaitForChild("CooldownText")

    self.smallDashButton = self.smallTouchscreen:WaitForChild("DashButton");
    self.smallDashButton.Activated:Connect(function() self:OnTouchDashButtonActivated(true) end);
    self.largeDashButton = self.largeTouchscreen:WaitForChild("DashButton");
    self.largeDashButton.Activated:Connect(function() self:OnTouchDashButtonActivated(true) end);

    self.Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:OnScreenSizeChanged() end);
	self:OnScreenSizeChanged();

    UserInputService.InputBegan:Connect(function(i,p)
        if i.KeyCode == Enum.KeyCode.LeftShift and not p then
            task.spawn(function()
                TweenService:Create(self.leftShiftImage, ClickInfo, { Size = UDim2.fromScale(1,2) }):Play();
                task.wait(.25)
                TweenService:Create(self.leftShiftImage, ClickInfo, { Size = UDim2.fromScale(1, 1.817)}):Play();
            end)
            self:OnDash(false);
        end
    end)

    local GameService = Knit.GetService("GameService")
    
    GameService.AdjustDashCooldown:Connect(function(adjustedCooldown)
        Cooldown = adjustedCooldown;
    end)
end


function DashUI:KnitInit()
    
end


return DashUI
