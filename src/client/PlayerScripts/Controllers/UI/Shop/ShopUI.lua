local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ShopUI = Knit.CreateController { Name = "ShopUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local ShopView = PlayerGui:WaitForChild("Views"):WaitForChild("Shop");
local ButtonContainer = ShopView:WaitForChild("Inner"):WaitForChild("Inner"):WaitForChild("Main"):WaitForChild("ButtonContainer"):WaitForChild("Main");
local MainPages = ShopView.Inner.Inner.Main:WaitForChild("MainPages");
local UIPageLayout = MainPages:WaitForChild("UIPageLayout");

function ShopUI:GoToPage(PageName)
    UIPageLayout:JumpTo(MainPages[PageName]);
end

function ShopUI:GetPage(PageName)
    return MainPages[PageName];
end

function ShopUI:KnitStart()
    self.ShopGiftsUI = Knit.GetController("ShopGiftsUI");

    for _,v in pairs(ButtonContainer:GetChildren()) do
        if (v:IsA("GuiObject")) then
            local function UpdateButton()
                v.ImageButton.ImageColor3 = UIPageLayout.CurrentPage.Name == v.Name and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(0, 105, 157)
            end
            
            v.ImageButton.MouseButton1Click:Connect(function()
                if self.ShopGiftsUI:IsViewing() == true then return end
                if (UIPageLayout.CurrentPage.Name ~= v.Name) then
                    self:GoToPage(v.Name);
                end
            end)

            UIPageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(UpdateButton)
            UpdateButton();
        end
    end
end

function ShopUI:KnitInit()
    
end

return ShopUI
