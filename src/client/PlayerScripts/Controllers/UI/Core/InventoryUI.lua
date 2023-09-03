local SoundService = game:GetService("SoundService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local InventoryUI = Knit.CreateController { Name = "InventoryUI" }

--//Services
local plr = game.Players.LocalPlayer

--//Imports
local HatSkins
local BoosterEffects
local Rarities

local Item

local onStart = false

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui")

local inventoryItemClickSound = "rbxassetid://552900451"
local Config = require(Knit.Shared.Modules.Config)

--//State
local CategorySelected
local LastInventory

--//Private Function
local function playLocalSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    SoundService:PlayLocalSound(sound)
    sound.Ended:Wait()
    sound:Destroy()
end

function getRarityDataFromType(ItemName, Type)
    if ItemName and Type then
        return Rarities.getRarityDataFromItemName(ItemName, Type)
    else
        return nil
    end
end

function getItemDataFromType(ItemName, Type)
    local ItemType = {
        ["Hats"] = HatSkins,
        ["Booster Effects"] = BoosterEffects
    }

    --print(ItemName, Type, ItemType[tostring(Type)], ItemType["Hats"])
    if ItemType[tostring(Type)] then
        return ItemType[tostring(Type)].ItemsTable[ItemName]
    else
        return nil
    end
end

function getStringFromCategory(Type)
    if Type == "Hats" then
        return "CurrentHat"
    elseif Type == "Booster Effects" then
        return "CurrentBoosterEffect"
    elseif Type == "Emotes" then
        --return "CurrentDuckEmote"
    else
        return nil
    end
end

--//Public Methods
function InventoryUI:AddItem(ItemName, Type)
    if ItemName and Type then
        local ItemData = getItemDataFromType(ItemName, Type)
    
        local RarityData = getRarityDataFromType(ItemName, Type)
        local InnerContainer


        local InventoryItemPrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("InventoryItem")
        local InventoryView = PlayerGui:WaitForChild("Main"):WaitForChild("Views"):WaitForChild("Inventory")
        local MainContainer = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("MainInventory"):WaitForChild("Main"):WaitForChild("Inner"):WaitForChild("MainContainer")

        local Clone = InventoryItemPrefab:Clone() do
            InnerContainer = Clone

            Clone.Name = ItemName
            Clone:WaitForChild("BannerColor").ImageColor3 = RarityData.Color
            Clone:WaitForChild("MainImage"):WaitForChild("ImageLabel").Image = ItemData.DecalId
            Clone.Parent = MainContainer

            Clone:SetAttribute("Type", Type)
            Clone:SetAttribute("Equipped", false) -- math.random(1, 2) == 1
            if Config.GIVE_ALL_INVENTORY == true then
                Clone:SetAttribute("Locked", false) -- math.random(1, 2) == 1
            else
                Clone:SetAttribute("Locked", true) -- math.random(1, 2) == 1
            end
            
        end

        Clone.TextButton.MouseButton1Click:Connect(function()
            self:SelectItem(ItemName, Type)
        end)

        local function UpdateItem()
            if (Clone:GetAttribute("Equipped")) then
                InnerContainer.Locked.Visible = false
                InnerContainer.Equipped.Visible = true

                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
                InnerContainer.BackgroundColor3 = InnerContainer.Equipped.BackgroundColor3

                Clone.LayoutOrder = -1
            elseif (Clone:GetAttribute("Locked")) then
                InnerContainer.Locked.Visible = true
                InnerContainer.Equipped.Visible = false
                
                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
                InnerContainer.BackgroundColor3 = InnerContainer.Locked.BackgroundColor3
                
                if RarityData.ID == -1 then
                    Clone.LayoutOrder = 1000 - RarityData.ID
                else
                    Clone.LayoutOrder = 2000 - RarityData.ID
                end
                
            else
                InnerContainer.Locked.Visible = false
                InnerContainer.Equipped.Visible = false
                
                InnerContainer.MainImage.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
                InnerContainer.BackgroundColor3 = Color3.fromRGB(146, 108, 71)
                
                if RarityData.ID == -1 then
                    Clone.LayoutOrder = 200 - RarityData.ID
                else
                    Clone.LayoutOrder = 300 - RarityData.ID
                end
            end
        end

        Clone.AttributeChanged:Connect(UpdateItem)
        UpdateItem()

        if (Clone:GetAttribute("Equipped")) then
            self:SelectItem(ItemName, Type)
        end
    end
end

function InventoryUI:GetItem(ItemName, Type)
    local InventoryView = PlayerGui:WaitForChild("Main"):WaitForChild("Views"):WaitForChild("Inventory")
    local MainContainer = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("MainInventory"):WaitForChild("Main"):WaitForChild("Inner"):WaitForChild("MainContainer")

    if ItemName and Type then
        for _, frame in pairs(MainContainer:GetChildren()) do
            if frame.Name == ItemName and frame:GetAttribute("Type") == Type then
                return frame
            end
        end
    end
end

function InventoryUI:SelectItem(ItemName, Type)
    task.spawn(playLocalSound, inventoryItemClickSound, 0.2)
    if ItemName and Type then
        local ItemData = getItemDataFromType(ItemName, Type)
        Item = self:GetItem(ItemName, Type)

        if ItemData == nil then return end

        local InventoryView = PlayerGui:WaitForChild("Main"):WaitForChild("Views"):WaitForChild("Inventory")
        local SelectionStats = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("SelectionStats"):WaitForChild("Main")

        SelectionStats.ImageInfo:WaitForChild("ImageLabel").Image = ItemData.DecalId

        Item = self:GetItem(ItemName, Type)

        if Item == nil then return end

        if (Item:GetAttribute("Locked")) then
            SelectionStats:WaitForChild("ImageInfo").Locked.Visible = true
            SelectionStats.ImageInfo.Equipped.Visible = false
            
            SelectionStats.EquipButton.Transparency = 0
            SelectionStats.EquipButton.UIStroke.Transparency = 0
            SelectionStats.ImageInfo.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
            --SelectionStats.ImageInfo.BackgroundColor3 = SelectionStats.ImageInfo.Locked.BackgroundColor3        

            SelectionStats.EquipButton.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
            SelectionStats.EquipButton.Title.Text = "LOCKED"

            --CollectionService:AddTag(SelectionStats.EquipButton, "ButtonStyle")
        else
            SelectionStats:WaitForChild("ImageInfo").Locked.Visible = false
            SelectionStats.ImageInfo.Equipped.Visible = false
            
            SelectionStats.ImageInfo.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
            SelectionStats.ImageInfo.BackgroundColor3 = Color3.fromRGB(146, 108, 71)

            if (Item:GetAttribute("Equipped")) then            
                SelectionStats.EquipButton.Transparency = 1
                SelectionStats.EquipButton.UIStroke.Transparency = 1
                SelectionStats.EquipButton.Title.Text = "EQUIPPED"
                
                --CollectionService:RemoveTag(SelectionStats.EquipButton, "ButtonStyle")
            else
                SelectionStats.EquipButton.BackgroundColor3 = Color3.fromRGB(230, 107, 83)
                SelectionStats.EquipButton.Transparency = 0
                SelectionStats.EquipButton.UIStroke.Transparency = 0
                SelectionStats.EquipButton.Title.Text = "EQUIP"

                --CollectionService:AddTag(SelectionStats.EquipButton, "ButtonStyle")
            end
        end

        SelectionStats:WaitForChild("NameInfo"):WaitForChild("ItemName").Text = ItemData.Name

        local RarityData = getRarityDataFromType(ItemName, Type)

        SelectionStats.NameInfo:WaitForChild("Rarity").Text = RarityData.Name
        SelectionStats.NameInfo:WaitForChild("Rarity").UIGradient.Color = RarityData.Gradient.Color
    end
end

function InventoryUI:SelectCategory(CategoryName)
    if CategoryName then
        CategorySelected = CategoryName

        local InventoryView = PlayerGui:WaitForChild("Main"):WaitForChild("Views"):WaitForChild("Inventory")

        local ButtonContainer = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Buttons")

        for _,v in pairs(ButtonContainer:GetChildren()) do
            if (v:IsA("GuiObject")) then
                v.BackgroundColor3 = CategorySelected == v.Name and Color3.fromRGB(234, 184, 96) or Color3.fromRGB(159, 125, 65)
            end
        end

        local MainContainer = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("MainInventory"):WaitForChild("Main"):WaitForChild("Inner"):WaitForChild("MainContainer")

        for _,v in pairs(MainContainer:GetChildren()) do
            if (v:IsA("GuiObject")) then
                local ItemData = getItemDataFromType(v.Name, v:GetAttribute("Type"))
                if ItemData.Visible == false and v:GetAttribute("Locked") == true and CategorySelected == v:GetAttribute("Type") then
                    v.Visible = false
                    continue
                end
                v.Visible = CategorySelected == v:GetAttribute("Type")
            end
        end
    end
end

function InventoryUI:UpdateInventory(Inventory)
    if Inventory then
        local HatSkinsInventory = Inventory["Hats"]
        local BoosterEffectsInventory = Inventory["BoosterEffects"]

        LastInventory = Inventory

        local InventoryView = PlayerGui:WaitForChild("Main"):WaitForChild("Views"):WaitForChild("Inventory")

        local MainContainer = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("MainInventory"):WaitForChild("Main"):WaitForChild("Inner"):WaitForChild("MainContainer")

        for _, frame in pairs(MainContainer:GetChildren()) do
            if Config.GIVE_ALL_INVENTORY == true then
                frame:SetAttribute("Locked", false) -- math.random(1, 2) == 1
            else
                frame:SetAttribute("Locked", true) -- math.random(1, 2) == 1
            end
            frame:SetAttribute("Equipped", false)
            if frame:IsA("Frame") then
                if frame:GetAttribute("Type") == "Hats" then
                    if HatSkinsInventory[frame.Name] then
                        frame:SetAttribute("Locked", false)
                    end
                    if frame.Name == Inventory["CurrentHat"] then
                        frame:SetAttribute("Equipped", true)
                        if onStart == false then
                            onStart = true
                            self:SelectItem(tostring(Inventory["CurrentHat"]), "Hats")
                        end
                    end
                elseif frame:GetAttribute("Type") == "Booster Effects" then
                    if BoosterEffectsInventory[frame.Name] then
                        frame:SetAttribute("Locked", false)
                    end
                    if frame.Name == Inventory["CurrentBoosterEffect"] then
                        frame:SetAttribute("Equipped", true)
                    end
                --[[elseif frame:GetAttribute("Type") == "Emotes" then
                    if DuckEmotesInventory[frame.Name] then
                        frame:SetAttribute("Locked", false)
                    end
                    if frame.Name == Inventory["CurrentDuckEmote"] then
                        frame:SetAttribute("Equipped", true)
                    end]]
                end
            end
        end
        if Item then
            self:SelectItem(tostring(Item), Item:GetAttribute("Type"))
        end
    end
end


function InventoryUI:KnitStart()
    local equipButtonDeb = false
    local InventoryView = PlayerGui:WaitForChild("Main"):WaitForChild("Views"):WaitForChild("Inventory")

    local ButtonContainer = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Buttons")

    for _,v in pairs(ButtonContainer:GetChildren()) do
        if (v:IsA("GuiObject")) then
            v.MouseButton1Click:Connect(function()
                if v.Name ~= CategorySelected then 
                    local CurrentItem = getStringFromCategory(v.Name)
                    if CurrentItem and LastInventory then
                        self:SelectItem(tostring(LastInventory[CurrentItem]), v.Name)
                    end
                end
                --print(v.Name)
                self:SelectCategory(v.Name)
            end)
        end
    end

    local SelectionStats = InventoryView:WaitForChild("Book"):WaitForChild("Page"):WaitForChild("Page"):WaitForChild("ContentHolder"):WaitForChild("Contents"):WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("SelectionStats"):WaitForChild("Main")
    
    SelectionStats:WaitForChild("EquipButton").MouseButton1Click:Connect(function()
        if equipButtonDeb == false then
            equipButtonDeb = true
            if not Item then return end
            if Item:GetAttribute("Equipped") == false and Item:GetAttribute("Locked") == false then
                local InventoryService = Knit.GetService("InventoryService")
                InventoryService.EquipItem:Fire(tostring(Item),Item:GetAttribute("Type"))
            elseif (Item:GetAttribute("Locked")) then
                Knit.GetController("ViewsUI"):OpenView("Daily")
            end
            task.wait(1)
            equipButtonDeb = false
        end
    end)

    for HatName in pairs(HatSkins.ItemsTable) do
        self:AddItem(HatName, "Hats")
    end

    for BoosterName in pairs(BoosterEffects.ItemsTable) do
        self:AddItem(BoosterName, "Booster Effects")
    end

    task.wait(1)

    self:SelectCategory("Hats")

    local InventoryService = Knit.GetService("InventoryService")

    InventoryService.ItemChanged:Connect(function(updatedInventory) -- When inventory updatses then give inventory data
        --print("Item Change:", updatedInventory)
        self:UpdateInventory(updatedInventory)
    end)

    local inventory = InventoryService:RequestInventory()
    self:UpdateInventory(inventory)
    self:SelectCategory("Hats")
end

function InventoryUI:KnitInit()
    HatSkins = require(Knit.Shared.Assets.HatSkins)
    BoosterEffects = require(Knit.Shared.Assets.BoosterEffects)
    Rarities = require(Knit.Shared.Assets.Rarities)
end

return InventoryUI