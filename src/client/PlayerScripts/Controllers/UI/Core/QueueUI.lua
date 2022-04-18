local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local QueueUI = Knit.CreateController { Name = "QueueUI" }

--//Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local plr = game.Players.LocalPlayer;

--//Const
local PlayerGui = plr:WaitForChild("PlayerGui");
local QueueContainer = PlayerGui

local MapInfo, mapSelected, GameService;
local currentMap, nextMap, boosted;
local MapDataChances = {};



--//Public Methods
--/ UI Methods
function QueueUI:OpenPanelUI()
    self.ViewsUI:OpenView("MapQueue")
end

function QueueUI:ClosePanelUI()
    self.ViewsUI:CloseView("MapQueue")
end

function QueueUI:UnlockMapUI(MapName)
    local MapFrame = self.MainContainer:FindFirstChild(tostring(MapName))

    if MapFrame then
        local MainFrame = MapFrame:WaitForChild("Main")
        MainFrame:WaitForChild("MapLocked").Visible = false;

        if CollectionService:HasTag(MainFrame, "ButtonStyle") == false then
            CollectionService:AddTag(MainFrame, "ButtonStyle")
        end
    end
end

function QueueUI:LockMap(MapName)
    local MapFrame = self.MainContainer:FindFirstChild(tostring(MapName))

    if MapFrame then
        local MainFrame = MapFrame:WaitForChild("Main")
        MainFrame:WaitForChild("MapLocked").Visible = true;

        if CollectionService:HasTag(MainFrame, "ButtonStyle") == true then
            CollectionService:RemoveTag(MainFrame, "ButtonStyle")
        end
    end
end

function QueueUI:UpdateMapQueueUI()
    mapSelected = nil;
    self.BoostSection:WaitForChild("MapDesc").Text = "Map Chosen: N/A";
    for _, mapFrame in pairs(self.MainFrame:WaitForChild("Maps"):WaitForChild("MainContainer"):GetChildren()) do
        if mapFrame:IsA("Frame") then
            local mapData = MapInfo.getMapTitleFromName(mapFrame.Name)
            if mapData then
                local translatedName = mapData
                self:UnlockMapUI(mapFrame.Name)
                if (translatedName == currentMap) or (translatedName == nextMap) then
                    self:LockMap(mapFrame.Name)
                end
            end
        end
    end

    local BoostButton = self.BoostSection:WaitForChild("BoostMap"):WaitForChild("ImageButton")
    
    if CollectionService:HasTag(BoostButton, "ButtonStyle") == true then
        BoostButton.BackgroundColor3 = Color3.fromRGB(255, 204, 0)
        BoostButton.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
        BoostButton.TextLabel.Text = "Boost Map"
    else
        BoostButton.BackgroundColor3 = Color3.fromRGB(181, 145, 0)
        BoostButton.TextLabel.TextColor3 = Color3.fromRGB(218, 218, 218)
        BoostButton.TextLabel.Text = "Someone Boosted"
    end
end

function QueueUI:SetupMapQueueUI()
    self.MapQueueUI = PlayerGui:WaitForChild("Views"):WaitForChild("MapQueue")
    self.MainFrame = self.MapQueueUI:WaitForChild("Main")
    self.MainContainer = self.MainFrame:WaitForChild("Maps"):WaitForChild("MainContainer")
    self.BoostSection = self.MainFrame:WaitForChild("BoostSection")
    self.ViewsUI = Knit.GetController("ViewsUI")

    for _, MapData in pairs(MapInfo.Maps) do
        if MapData.Name == "N/A" then
            continue;
        end
        local MapFramePrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("MapFrame");
        local MapClone = MapFramePrefab:Clone() do
            local MainFrame = MapClone:WaitForChild("Main")
            MapClone.Name = MapData.Name;
            MainFrame:WaitForChild("Inner"):WaitForChild("ImageLabel").Image = MapData.DecalId;
            MapClone:WaitForChild("TextLabel").Text = MapData.Name;

            MapClone.Parent = self.MainContainer;

            MainFrame:WaitForChild("Button").MouseButton1Click:Connect(function()
                if CollectionService:HasTag(MainFrame, "ButtonStyle") == true then
                    mapSelected = MapData.Name;
                    self.BoostSection:WaitForChild("MapDesc").Text = "Map Chosen: " .. MapData.Name;
                end
            end)
        end
    end
    
    local BoostButton = self.BoostSection:WaitForChild("BoostMap"):WaitForChild("ImageButton")
    
    if CollectionService:HasTag(BoostButton, "ButtonStyle") == true then
        BoostButton.BackgroundColor3 = Color3.fromRGB(255, 204, 0)
        BoostButton.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
        BoostButton.TextLabel.Text = "Boost Map"
    else
        BoostButton.BackgroundColor3 = Color3.fromRGB(181, 145, 0)
        BoostButton.TextLabel.TextColor3 = Color3.fromRGB(218, 218, 218)
        BoostButton.TextLabel.Text = "Someone Boosted"
    end
    
    BoostButton.MouseButton1Click:Connect(function()
        if CollectionService:HasTag(BoostButton, "ButtonStyle") == true then
            if mapSelected then
                --print("Boosting:", mapSelected)
                GameService.BoostCheck:Fire(mapSelected)
            end
        end
    end)

    repeat task.wait(0) until nextMap ~= nil
    self:UpdateMapQueueUI()
end

--/ Board Methods

function QueueUI:UpdateMapQueueBoard(LeaderboardName, currentMap, nextMap, boosted)
    --print(LeaderboardName, currentMap, nextMap)
    if not QueueContainer:FindFirstChild(LeaderboardName) then
        return;
    end

    if currentMap == nil then
        currentMap = "N/A"
    end

    if nextMap == nil then
        nextMap = "N/A"
    end

    local MapQueueGui = QueueContainer[LeaderboardName];
    
    local CurrentMapFrame = MapQueueGui:WaitForChild("CurrentMap")
    local NextMapFrame = MapQueueGui:WaitForChild("NextMap")

    local mapInfo = MapInfo.Maps[currentMap]

    CurrentMapFrame:WaitForChild("Title"):WaitForChild("TextLabel").Text = "CURRENT MAP: "..string.upper(MapInfo.Maps[currentMap].Name)

    if boosted == true then
        NextMapFrame:WaitForChild("TextLabel").TextColor3 = Color3.fromRGB(253, 200, 27)
        NextMapFrame:WaitForChild("TextLabel").Text = "BOOSTED NEXT MAP: "..string.upper(MapInfo.Maps[nextMap].Name)
    else
        NextMapFrame:WaitForChild("TextLabel").TextColor3 = Color3.fromRGB(255,255,255)
        NextMapFrame:WaitForChild("TextLabel").Text = "NEXT MAP: "..string.upper(MapInfo.Maps[nextMap].Name)
    end
    

    local mapImageId = ""

	mapImageId = mapInfo.DecalId

    CurrentMapFrame:WaitForChild("MapFrame"):WaitForChild("MapBG"):WaitForChild("Inner"):WaitForChild("ImageLabel").Image = mapImageId
end

function QueueUI:SetupMapQueueBoard(Obj)
    GameService = Knit.GetService("GameService")
    task.wait(3)
    GameService:GetMapQueue():andThen(function(mapData)
        currentMap = mapData["CurrentMap"];
        nextMap = mapData["NextMap"];
        boosted = mapData["Boosted"];
        local MapQueuePrefab = PlayerGui:WaitForChild("Prefabs"):WaitForChild("MapQueue");
        
        local MapQueueClone = MapQueuePrefab:Clone() do
            MapQueueClone.Adornee = Obj;
            MapQueueClone.Name = Obj:GetAttribute("LeaderboardName");
            MapQueueClone.Parent = QueueContainer;
        end
    
        self:UpdateMapQueueBoard("Maps", currentMap, nextMap, boosted);
    end)
end


--/ Other Methods

function QueueUI:KnitStart()
    local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

    repeat task.wait(0) until Character
    if Character then
        GameService = Knit.GetService("GameService")
        
        CollectionService:GetInstanceAddedSignal("Queues"):Connect(function(v)
            self:SetupMapQueueBoard(v);
        end)
    
        for _,v in pairs(CollectionService:GetTagged("Queues")) do
            self:SetupMapQueueBoard(v);
        end

        self:SetupMapQueueUI();
    
        GameService.UpdateMapQueue:Connect(function(mapData)
            currentMap = mapData["CurrentMap"];
            nextMap = mapData["NextMap"];
            boosted = mapData["Boosted"];

            if boosted == true then
                CollectionService:RemoveTag(self.BoostSection:WaitForChild("BoostMap"):WaitForChild("ImageButton"), "ButtonStyle")
            else
                CollectionService:AddTag(self.BoostSection:WaitForChild("BoostMap"):WaitForChild("ImageButton"), "ButtonStyle")
            end
            --print("P", currentMap, nextMap, boosted)
            self:UpdateMapQueueBoard("Maps",currentMap, nextMap, boosted);
            self:UpdateMapQueueUI()
        end)
    end
end

function QueueUI:KnitInit()
    MapInfo = require(Knit.ReplicatedAssets.SystemInfo);
end

return QueueUI
