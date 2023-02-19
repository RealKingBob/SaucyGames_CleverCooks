local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ButtonStyle = Knit.CreateController { Name = "ButtonStyle" }

--//Services
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

--//Imports
local TweenModule;
local NumberUtil;
local Maid = require(Knit.Util.Maid);

--//Const
local HoverInfo = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local ClickInfo = TweenInfo.new(.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out);

local MouseUpSound = game.SoundService:WaitForChild("Sfx"):WaitForChild("MouseUp");
local MouseDownSound = game.SoundService:WaitForChild("Sfx"):WaitForChild("MouseDown");

--//State
local Styles = {};

--//Public Methods
function ButtonStyle:StyleButton(Container)
    local ButtonMaid = Maid.new();
    local Button;

    if (Container:IsA("TextButton") or Container:IsA("ImageButton")) then
        Button = Container;
    else
        Button = (Container:FindFirstChildWhichIsA("TextButton", true) ~= nil and Container:FindFirstChildWhichIsA("TextButton", true)) or Container:FindFirstChildWhichIsA("ImageButton", true);
    end

    if not Button then return end;

    Styles[Container] = ButtonMaid;

    ButtonMaid:GiveTask(Button.MouseButton1Down:Connect(function()
        if not Button then return end;
        if Button:FindFirstChildWhichIsA("UIScale") then
            local ButtonTween = TweenModule.new(ClickInfo, function(Alpha)
                if not Button then return end;
                if not Button:FindFirstChildWhichIsA("UIScale") then return end
                Button:FindFirstChildWhichIsA("UIScale").Scale = NumberUtil.LerpClamp(1, 0.9, Alpha); 
            end)
            ButtonTween:Play()
            MouseDownSound:Play();
        else
            TweenService:Create(Container, ClickInfo, { Size = UDim2.fromScale(.9, .9) }):Play();
            MouseDownSound:Play();
        end
    end))
    
    ButtonMaid:GiveTask(Button.MouseButton1Up:Connect(function()
        if not Button then return end;
        if Button:FindFirstChildWhichIsA("UIScale") then
            local ButtonTween = TweenModule.new(ClickInfo, function(Alpha)
                if not Button then return end;
                Button:FindFirstChildWhichIsA("UIScale").Scale = NumberUtil.LerpClamp(1, 1.15, Alpha); 
            end)
            ButtonTween:Play()
            MouseUpSound:Play();
        else
            TweenService:Create(Container, ClickInfo, { Size = UDim2.fromScale(1.15, 1.15) }):Play();
            MouseUpSound:Play();
        end
    end))
    
    ButtonMaid:GiveTask(Button.MouseEnter:Connect(function()
        if not Button then return end;
        if Button:FindFirstChildWhichIsA("UIScale") then
            local ButtonTween = TweenModule.new(ClickInfo, function(Alpha)
                if not Button then return end;
                if not Button:FindFirstChildWhichIsA("UIScale") then return end
                Button:FindFirstChildWhichIsA("UIScale").Scale = NumberUtil.LerpClamp(1, 1.15, Alpha); 
            end)
            ButtonTween:Play()
        else
            TweenService:Create(Container, HoverInfo, { Size = UDim2.fromScale(1.15, 1.15) }):Play();
        end
    end))
    
    ButtonMaid:GiveTask(Button.MouseLeave:Connect(function()
        if not Button then return end;
        if Button:FindFirstChildWhichIsA("UIScale") then
            local ButtonTween = TweenModule.new(ClickInfo, function(Alpha)
                if not Button then return end;
                if not Button:FindFirstChildWhichIsA("UIScale") then return end
                Button:FindFirstChildWhichIsA("UIScale").Scale = NumberUtil.LerpClamp(1.15, 1, Alpha); 
            end)
            ButtonTween:Play()
        else
            TweenService:Create(Container, HoverInfo, { Size = UDim2.fromScale(1, 1) }):Play();
        end
    end))
end

function ButtonStyle:RemoveStyle(Container)
    if not Container then return end;
    local ButtonMaid = Styles[Container];
    
    if (ButtonMaid) then
        ButtonMaid:DoCleaning();
    end

    TweenService:Create(Container, HoverInfo, { Size = UDim2.fromScale(1, 1) }):Play();
end

function ButtonStyle:KnitStart()

    TweenModule = require(Knit.Modules.Tween);
    NumberUtil = require(Knit.ReplicatedModules.NumberUtil);

    CollectionService:GetInstanceAddedSignal("ButtonStyle"):Connect(function(v)
        self:StyleButton(v)
    end)
    
    CollectionService:GetInstanceRemovedSignal("ButtonStyle"):Connect(function(v)
        self:RemoveStyle(v)
    end)

    for _,v in pairs(CollectionService:GetTagged("ButtonStyle")) do
        self:StyleButton(v);
    end
end

function ButtonStyle:KnitInit()
    
end

return ButtonStyle
