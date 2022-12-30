local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService");
local Knit = require(ReplicatedStorage.Packages.Knit)

local BlenderController = Knit.CreateController { Name = "BlenderController" }

function BlenderController:SpinBlade(blenderObject, enabled)
    if enabled == true then
        print('huh')
        local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

        -- create two conflicting tweens (both trying to animate part.Position)
        local SpinTween = TweenService:Create(blenderObject.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 100 });

        --[[local SpinTween = TweenModule.new(FadeTween, function(Alpha)
            print(Alpha)
            self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = NumberUtil.LerpClamp(0, 100, Alpha); 
        end)]]

        SpinTween:Play();
        SpinTween.Completed:Wait();

        blenderObject.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 70;
    else

        local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

        local SpinTween = TweenService:Create(blenderObject.Blade.PrimaryPart.HingeConstraint, FadeTween, { AngularVelocity = 0 });

        --[[local SpinTween = TweenModule.new(FadeTween, function(Alpha)
            print(Alpha)
            self.Object.Blade.PrimaryPart.HingeConstraint.AngularVelocity = NumberUtil.LerpClamp(100, 0, Alpha); 
        end)]]

        SpinTween:Play();
        SpinTween.Completed:Wait();

        blenderObject.Blade.PrimaryPart.HingeConstraint.AngularVelocity = 0;
    end
end

function BlenderController:FluidChange(blenderObject, percentage, fluidColor)
    local blenderFluid = blenderObject.Flood;
    local maxSize = 11.47;
    local currentSize = blenderFluid.Size.Y
    local newSize = maxSize * percentage;
    local difference = newSize - currentSize

    difference /= 2

    local endSize = Vector3.new(blenderFluid.Size.X, newSize, blenderFluid.Size.Z)
    local endCFrame = blenderFluid.CFrame * CFrame.new(0, (newSize/2), 0)
    local endPosition = blenderFluid.Position + Vector3.new(0,difference, 0)

    print(fluidColor)

    local goal = {
        Size = endSize,
        Position = endPosition,
        Color = fluidColor;
        --CFrame = endCFrame
    }

    local timeInSeconds = 3

    local tweenInfo = TweenInfo.new(timeInSeconds)
    local powerBlender = TweenService:Create(blenderFluid, tweenInfo, goal)
    powerBlender:Play()
    powerBlender.Completed:Wait();
    blenderFluid.Size = endSize;
    --blenderFluid.CFrame = endCFrame;
end

function BlenderController:BlenderText(blender, text)
    blender.Glass.Glass.NumOfObjects.TextLabel.Text = text
end

function BlenderController:KnitStart()
    local CookingService = Knit.GetService("CookingService");

    CookingService.ChangeClientBlender:Connect(function(blenderObject, command, data)
        
        if command == "fluidPercentage" then
            self:BlenderText(blenderObject, data.FluidText);
            self:FluidChange(blenderObject, data.FluidPercentage, data.FluidColor);
        elseif command == "bladeSpin" then
            self:SpinBlade(blenderObject, data[1]);
        end
        
    end)
end


function BlenderController:KnitInit()
    
end


return BlenderController
