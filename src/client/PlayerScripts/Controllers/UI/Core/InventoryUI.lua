local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local InventoryUI = Knit.CreateController { Name = "InventoryUI" }

--//Services
local plr = game.Players.LocalPlayer;

--//Imports
local DuckSkins;
local DeathEffects;
local Rarities;

local Item;

local onStart = false;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");

local InventoryView = PlayerGui:WaitForChild("Views"):WaitForChild("Inventory");
local ButtonContainer = InventoryView:WaitForChild("Main"):WaitForChild("MainInventory"):WaitForChild("Main"):WaitForChild("ButtonContainer"):WaitForChild("Inner");
local MainContainer = InventoryView.Main.MainInventory.Main:WaitForChild("Inner"):WaitForChild("MainContainer");

local SelectionStats = InventoryView.Main:WaitForChild("SelectionStats"):WaitForChild("Main")

--//State
local CategorySelected;
local LastInventory;

--//Private Function
function getRarityDataFromType(ItemName, Type)
    if Type == "Skins" then
        return Rarities.getRarityDataFromDuckName(ItemName);
    elseif Type == "Effects" then
        return Rarities.getRarityDataFromEffectsName(ItemName);
    elseif Type == "Emotes" then
        return Rarities.getRarityDataFromEmotesName(ItemName);
    else
        return nil;
    end
end

function getDuckDataFromType(ItemName, Type)
    if Type == "Skins" then
        return DuckSkins.SkinsTable[ItemName]
    elseif Type == "Effects" then
        return DeathEffects.EffectsTable[ItemName]
    elseif Type == "Emotes" then
        --return DuckSkins.SkinsTable[ItemName]
    else
        return nil;
    end
end

function getStringFromCategory(Type)
    if Type == "Skins" then
        return "CurrentDuckSkin"
    elseif Type == "Effects" then
        return "CurrentDeathEffect"
    elseif Type == "Emotes" then
        --return "CurrentDuckEmote"
    else
        return nil;
    end
end

--//Public Methods
function InventoryUI:AddItem(ItemName, Type)
    if ItemName and Type then
        local DuckData = getDuckDataFromType(ItemName, Type);
    
        local RarityData = getRarityDataFromType(ItemName, Type);
        local InnerContainer;


        local InventoryItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("InventoryItem");
        local Clone = InventoryItemPrefab:Clone() do
            InnerContainer = Clone:WaitForChild("Outer"):WaitForChild("Inner");

            Clone.Name = ItemName;
            Clone:WaitForChild("Outer"):WaitForChild("BannerColor").ImageColor3 = RarityData.Color
            InnerContainer:WaitForChild("MainImage"):WaitForChild("ImageLabel").Image = DuckData.DecalId;
            Clone.Parent = MainContainer;

            Clone:SetAttribute("Type", Type);
            Clone:SetAttribute("Equipped", false); -- math.random(1, 2) == 1
            if Knit.Config.GIVE_ALL_INVENTORY == true then
                Clone:SetAttribute("Locked", false); -- math.random(1, 2) == 1
            else
                Clone:SetAttribute("Locked", true); -- math.random(1, 2) == 1
            end
            
        end

        Clone.Outer.TextButton.MouseButton1Click:Connect(function()
            self:SelectItem(ItemName, Type);
        end)

        local function UpdateItem()
            if (Clone:GetAttribute("Equipped")) then
                InnerContainer.Locked.Visible = false;
                InnerContainer.Equipped.Visible = true;

                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255);
                InnerContainer.BackgroundColor3 = InnerContainer.Equipped.BackgroundColor3;

                Clone.LayoutOrder = -1;
            elseif (Clone:GetAttribute("Locked")) then
                InnerContainer.Locked.Visible = true;
                InnerContainer.Equipped.Visible = false;
                
                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0);
                InnerContainer.BackgroundColor3 = InnerContainer.Locked.BackgroundColor3;
                
                if RarityData.ID == -1 then
                    Clone.LayoutOrder = 1000 - RarityData.ID;
                else
                    Clone.LayoutOrder = 2000 - RarityData.ID;
                end
                
            else
                InnerContainer.Locked.Visible = false;
                InnerContainer.Equipped.Visible = false;
                
                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255);
                InnerContainer.BackgroundColor3 = Color3.fromRGB(146, 108, 71);
                
                if RarityData.ID == -1 then
                    Clone.LayoutOrder = 200 - RarityData.ID;
                else
                    Clone.LayoutOrder = 300 - RarityData.ID;
                end
            end
        end

        Clone.AttributeChanged:Connect(UpdateItem)
        UpdateItem();

        if (Clone:GetAttribute("Equipped")) then
            self:SelectItem(ItemName, Type);
        end
    end
end

function InventoryUI:GetItem(ItemName, Type)
    if ItemName and Type then
        for _, frame in pairs(MainContainer:GetChildren()) do
            if frame.Name == ItemName and frame:GetAttribute("Type") == Type then
                return frame
            end
        end
    end
end

function InventoryUI:SelectItem(ItemName, Type)
    if ItemName and Type then
        local DuckData = getDuckDataFromType(ItemName, Type);
        Item = self:GetItem(ItemName, Type);

        if DuckData == nil then return end

        SelectionStats.SelectedItem:WaitForChild("MainImage"):WaitForChild("ImageLabel").Image = DuckData.DecalId;

        if (Item:GetAttribute("Locked")) then
            SelectionStats:WaitForChild("SelectedItem").Locked.Visible = true;
            SelectionStats.SelectedItem.Equipped.Visible = false;
            
            SelectionStats.EquipButton.ImageButton.ImageTransparency = 0;
            SelectionStats.SelectedItem.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0);
            SelectionStats.SelectedItem.BackgroundColor3 = SelectionStats.SelectedItem.Locked.BackgroundColor3;        

            SelectionStats.EquipButton.ImageButton.ImageColor3 = Color3.fromRGB(59, 59, 59);
            SelectionStats.EquipButton.ImageButton.TextLabel.Text = "LOCKED";

            CollectionService:AddTag(SelectionStats.EquipButton.ImageButton, "ButtonStyle")
        else
            SelectionStats:WaitForChild("SelectedItem").Locked.Visible = false;
            SelectionStats.SelectedItem.Equipped.Visible = false;
            
            SelectionStats.SelectedItem.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255);
            SelectionStats.SelectedItem.BackgroundColor3 = Color3.fromRGB(146, 108, 71);

            if (Item:GetAttribute("Equipped")) then            
                SelectionStats.EquipButton.ImageButton.ImageTransparency = 1;
                SelectionStats.EquipButton.ImageButton.TextLabel.Text = "EQUIPPED";
                
                CollectionService:RemoveTag(SelectionStats.EquipButton.ImageButton, "ButtonStyle")
            else
                SelectionStats.EquipButton.ImageButton.ImageColor3 = Color3.fromRGB(0, 170, 255);
                SelectionStats.EquipButton.ImageButton.ImageTransparency = 0;
                SelectionStats.EquipButton.ImageButton.TextLabel.Text = "EQUIP";

                CollectionService:AddTag(SelectionStats.EquipButton.ImageButton, "ButtonStyle")
            end
        end

        SelectionStats:WaitForChild("NameInfo"):WaitForChild("ItemName").Text = DuckData.Name;

        local RarityData = getRarityDataFromType(ItemName, Type);

        SelectionStats.NameInfo:WaitForChild("Rarity").Text = RarityData.Name;
        SelectionStats.NameInfo:WaitForChild("Rarity").UIGradient.Color = RarityData.Gradient.Color;
    end
end

function InventoryUI:SelectCategory(CategoryName)
    if CategoryName then
        CategorySelected = CategoryName;

        for _,v in pairs(ButtonContainer:GetChildren()) do
            if (v:IsA("GuiObject")) then
                v.ImageButton.ImageColor3 = CategorySelected == v.Name and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(0, 105, 157);
            end
        end

        for _,v in pairs(MainContainer:GetChildren()) do
            if (v:IsA("GuiObject")) then
                local DuckData = getDuckDataFromType(v.Name, v:GetAttribute("Type"));
                if DuckData.Visible == false and v:GetAttribute("Locked") == true and CategorySelected == v:GetAttribute("Type") then
                    v.Visible = false;
                    continue;
                end
                v.Visible = CategorySelected == v:GetAttribute("Type");
            end
        end
    end
end

function InventoryUI:UpdateInventory(Inventory)
    if Inventory then
        local DuckSkinsInventory = Inventory["DuckSkins"]
        local DuckEffectsInventory = Inventory["DuckEffects"]
        --local DuckEmotesInventory = Inventory["DuckEmotes"]

        LastInventory = Inventory

        for _, frame in pairs(MainContainer:GetChildren()) do
            if Knit.Config.GIVE_ALL_INVENTORY == true then
                frame:SetAttribute("Locked", false); -- math.random(1, 2) == 1
            else
                frame:SetAttribute("Locked", true); -- math.random(1, 2) == 1
            end
            frame:SetAttribute("Equipped", false);
            if frame:IsA("Frame") then
                if frame:GetAttribute("Type") == "Skins" then
                    if DuckSkinsInventory[frame.Name] then
                        frame:SetAttribute("Locked", false);
                    end
                    if frame.Name == Inventory["CurrentDuckSkin"] then
                        frame:SetAttribute("Equipped", true);
                        if onStart == false then
                            onStart = true
                            self:SelectItem(tostring(Inventory["CurrentDuckSkin"]), "Skins");
                        end
                    end
                elseif frame:GetAttribute("Type") == "Effects" then
                    if DuckEffectsInventory[frame.Name] then
                        frame:SetAttribute("Locked", false);
                    end
                    if frame.Name == Inventory["CurrentDeathEffect"] then
                        frame:SetAttribute("Equipped", true);
                    end
                --[[elseif frame:GetAttribute("Type") == "Emotes" then
                    if DuckEmotesInventory[frame.Name] then
                        frame:SetAttribute("Locked", false);
                    end
                    if frame.Name == Inventory["CurrentDuckEmote"] then
                        frame:SetAttribute("Equipped", true);
                    end]]
                end
            end
        end
        if Item then
            self:SelectItem(tostring(Item), Item:GetAttribute("Type"));
        end
    end
end


function InventoryUI:KnitStart()
    local equipButtonDeb = false

    for _,v in pairs(ButtonContainer:GetChildren()) do
        if (v:IsA("GuiObject")) then
            v.ImageButton.MouseButton1Click:Connect(function()
                if v.Name ~= CategorySelected then 
                    local CurrentItem = getStringFromCategory(v.Name)
                    if CurrentItem and LastInventory then
                        self:SelectItem(tostring(LastInventory[CurrentItem]), v.Name);
                    end
                end
                self:SelectCategory(v.Name)
            end)
        end
    end
    
    SelectionStats:WaitForChild("EquipButton"):WaitForChild("ImageButton").MouseButton1Click:Connect(function()
        if equipButtonDeb == false then
            equipButtonDeb = true;
            if Item:GetAttribute("Equipped") == false and Item:GetAttribute("Locked") == false then
                local InventoryService = Knit.GetService("InventoryService")
                InventoryService.EquipItem:Fire(tostring(Item),Item:GetAttribute("Type"))
            elseif (Item:GetAttribute("Locked")) then
                Knit.GetController("ViewsUI"):OpenView("Shop");
                Knit.GetController("ShopUI"):GoToPage("Crates");
            end
            task.wait(1)
            equipButtonDeb = false;
        end
    end)

    for DuckName in pairs(DuckSkins.SkinsTable) do
        self:AddItem(DuckName, "Skins")
    end

    for DuckEffects in pairs(DeathEffects.EffectsTable) do
        self:AddItem(DuckEffects, "Effects")
    end

    self:SelectCategory("Skins");

    local InventoryService = Knit.GetService("InventoryService")

    InventoryService.ItemChanged:Connect(function(updatedInventory) -- When inventory updatses then give inventory data
        self:UpdateInventory(updatedInventory)
    end)

    InventoryService:RequestInventory():andThen(function(inventory) -- When initialized complete, request inventory data
        --print(inventory)
        self:UpdateInventory(inventory)
        self:SelectCategory("Skins");
    end)
end

function InventoryUI:KnitInit()
    DuckSkins = require(Knit.ReplicatedAssets.DuckSkins);
    DeathEffects = require(Knit.ReplicatedAssets.DeathEffects);
    Rarities = require(Knit.ReplicatedAssets.Rarities);
end

return InventoryUI