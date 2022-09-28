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

function CookingUI:StartCooking(RecipeName, Pan, CookingTime)
    local cookBillUI = Knit.GameLibrary.BillboardUI.CookHeadUI:Clone();
    local recipeAssets = require(Knit.ReplicatedAssets.Recipes);

    local currentRecipeImage = recipeAssets[RecipeName].Image;

    local mainFrame = cookBillUI:WaitForChild("Frame")

    mainFrame:WaitForChild("ItemImage").Image = currentRecipeImage;
    mainFrame:WaitForChild("Duration").Text = tostring(CookingTime).."s";

    cookBillUI.Parent = Pan

    local SizeInfo = TweenInfo.new(CookingTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);

    TweenService:Create(mainFrame.BarHolder:WaitForChild("Bar"), SizeInfo, { Size = UDim2.fromScale(1, 1) }):Play();

    for i = CookingTime, 0, -1 do
        mainFrame:WaitForChild("Duration").Text = tostring(roundDecimals(i, 1)).."s";
        task.wait(1);
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
