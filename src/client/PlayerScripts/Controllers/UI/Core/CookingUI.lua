local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CookingUI = Knit.CreateController { Name = "CookingUI" }

--[[
    Payload = {
        ["CurrentTime"] = 0,
        ["Alpha"] = .3
    }
]]

--//Services
local TweenService = game:GetService("TweenService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

--local ProgressBar = TierFrame:WaitForChild("InnerFrame"):WaitForChild("ProgressBar");

local SizeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);


local roundDecimals = function(num, places) --num is your number or value and places is number of decimal places, in your case you would need 2
    
    places = math.pow(10, places or 0)
    num = num * places
   
    if num >= 0 then 
        num = math.floor(num + 0.5) 
    else 
        num = math.ceil(num - 0.5) 
    end
    
    return num / places
    
end

--//Public Methods

function CookingUI:SpawnCookedParticles(food)
    local MidAttachClone = Knit.Spawnables:WaitForChild("CookedParticle"):WaitForChild("MidAttach"):Clone()
    MidAttachClone.Parent = food;

    local HS = require(game:GetService("ReplicatedStorage"):FindFirstChild("HintService"))

    local NewHint = HS.new() -- Creates a blank, and new hint

    HS.HintAdding:Connect(function(AddedHint) -- Connect this to a function to detect when a hint is added
        print(string.format("The new hint that was added says '%s'", AddedHint:getLabel()))
    end)

    NewHint:setText(tostring(food).." has been made!") -- Sets the text of NewHint
    NewHint:setBottomCenter() -- Sets the position of the hint to the bottom center.
    NewHint:setTweenLength(.1,.1) -- Sets how long the animations will last
    NewHint:setTweenStyle(Enum.EasingStyle.Linear, Enum.EasingStyle.Linear)  -- Sets the animation styles
    NewHint:setTweenDirection(Enum.EasingDirection.In, Enum.EasingDirection.Out) -- Sets the animation directions
    NewHint:broadcast(false) -- Broadcasts the hint

    for _, v in ipairs(MidAttachClone:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v:Emit(60)
        end
    end

    task.wait(1)

    MidAttachClone:Destroy()
end

function CookingUI:StartCooking(RecipeName, Pan, CookingTime)
    local cookBillUI = Knit.GameLibrary.BillboardUI.CookHeadUI:Clone();
    local recipeAssets = require(Knit.ReplicatedAssets.Recipes);

    local currentRecipeImage = recipeAssets[RecipeName].Image;

    local mainFrame = cookBillUI:WaitForChild("Frame")

    mainFrame:WaitForChild("ItemImage").Image = currentRecipeImage;
    mainFrame:WaitForChild("Duration").Text = tostring(CookingTime).."s";

    cookBillUI.Parent = Pan

    local SizeInfo = TweenInfo.new(CookingTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

    for _, v in pairs(Pan:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = true;
        end
    end

    TweenService:Create(mainFrame.BarHolder:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(1, 1) }):Play();

    for i = CookingTime, 0, -1 do
        mainFrame:WaitForChild("Duration").Text = tostring(roundDecimals(i, 1)).."s";

        if i == 0 then
            
        end
        task.wait(1);
    end

    for _, v in pairs(Pan:GetChildren()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false;
        end
    end


    cookBillUI:Destroy()
end

function CookingUI:KnitStart()
    --[[while task.wait(3) do
        CookingUI:Update({
            CurrentLevel = math.random(1, 200),
            Alpha = math.random(),
        });
    end]]
end


function CookingUI:KnitInit()
    
end


return CookingUI
