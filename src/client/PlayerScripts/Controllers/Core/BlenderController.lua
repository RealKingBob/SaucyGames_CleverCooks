--[[
    Name: Blender Controller [V1]
    By: Real_KingBob
    Updated: 2/17/23
    Description: Handles client-sided effects on the blending machine objects
]]

local TweenService = game:GetService("TweenService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local BlenderController = Knit.CreateController { Name = "BlenderController" }

function BlenderController:FluidChange(blenderObject, percentage, fluidColor)
    -- Get the blender fluid object and calculate the new size based on the percentage
    local blenderFluid = blenderObject.Flood
    local maxSize = 11.47
    local currentSize = blenderFluid.Size.Y
    local newSize = maxSize * percentage
    local difference = newSize - currentSize

    -- Divide the difference by 2 to get the correct displacement for the new position
    difference = difference / 2

    -- Calculate the new end size and position for the blender fluid
    local endSize = Vector3.new(blenderFluid.Size.X, newSize, blenderFluid.Size.Z)
    local endPosition = blenderFluid.Position + Vector3.new(0, difference, 0)

    -- Set up the goal for the TweenService
    local goal = {
        Size = endSize,
        Position = endPosition,
        Color = fluidColor
    }

    -- Set the duration of the tween animation
    local timeInSeconds = 3

    -- Create the TweenInfo object with the duration
    local tweenInfo = TweenInfo.new(timeInSeconds)

    -- Create the Tween object with the goal and TweenInfo
    local powerBlender = TweenService:Create(blenderFluid, tweenInfo, goal)

    -- Play the Tween animation
    powerBlender:Play()

    -- Wait for the Tween animation to complete
    powerBlender.Completed:Wait()

    -- Set the final size of the blender fluid to the end size
    blenderFluid.Size = endSize
end


function BlenderController:BlenderText(blender, text)
    -- Changes the UI text to the amount of objects the blender is holding
    blender.Glass.Glass.NumOfObjects.TextLabel.Text = text
end

function BlenderController:KnitStart()
    local CookingService = Knit.GetService("CookingService")

    CookingService.ChangeClientBlender:Connect(function(blenderObject, command, data)
        if command == "fluidPercentage" then
            self:BlenderText(blenderObject, data.FluidText)
            self:FluidChange(blenderObject, data.FluidPercentage, data.FluidColor)
        elseif command == "itemPoof" then
            local PlayerController = Knit.GetController("PlayerController")
            PlayerController:Poof(data.Position, data.Color)
        end
    end)
end


function BlenderController:KnitInit()
    
end


return BlenderController
