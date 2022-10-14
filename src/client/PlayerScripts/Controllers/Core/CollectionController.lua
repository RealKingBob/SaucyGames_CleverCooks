local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local TweenService = game:GetService("TweenService")

local CollectionController = Knit.CreateController { Name = "CollectionController" }

local LocalPlayer = Players.LocalPlayer;

local Debounces = {};

local DropUtil = require(Knit.Shared.Modules.DropUtil);

function CollectionController:KnitStart()
    local ProximityService = Knit.GetService("ProximityService");

    ProximityService.CurrencyCollected:Connect(function(RootCFrame, DropAmount)
        --print("CurrencyCollected", RootCFrame, DropAmount)
        DropUtil.DropCurrencyText(RootCFrame, DropAmount, LocalPlayer.UserId)
    end)
    
    while true do
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
        if Character then
            local Root = Character:FindFirstChild("HumanoidRootPart")
            if Root then
                for _, dropable in pairs(workspace.Spawnables.Cheese:GetChildren()) do
                    if dropable:GetAttribute("userId") ~= LocalPlayer.UserId then
                        dropable:Destroy()
                        continue;
                    end
                    if dropable:IsA("Part") and CollectionService:HasTag(dropable, "Dropable") and dropable:GetAttribute("userId") == LocalPlayer.UserId then
                        local magnitude = (Root.Position - dropable.Position).Magnitude;

                        if magnitude < 10 then
                            local DropAmount = dropable:GetAttribute("Amount")

                            dropable.CanCollide = false;
                            dropable.Anchored = true;
                            dropable.CFrame = dropable.CFrame:Lerp(Root.CFrame, 0.15)

                            --print("magnitude: ".. magnitude)

                            task.spawn(function()
                                if magnitude <= 2 then
                                    if not Debounces[dropable] then
                                        Debounces[dropable] = true
                                        --print("+"..tostring(DropAmount).." GIVEN")
                                        TweenService:Create(dropable.Cheese, TweenInfo.new(0.1), {Size = UDim2.fromScale(0,0)}):Play()
                                        task.wait(0.1)
                                        ProximityService.CurrencyCollected:Fire(dropable, Root.CFrame, DropAmount)
                                        dropable:Destroy()
                                        Debounces[dropable] = nil
                                    end
                                end
                            end)

                        end
                    end
                end
            end
        end
        task.wait()
    end
end


function CollectionController:KnitInit()
    
end


return CollectionController
