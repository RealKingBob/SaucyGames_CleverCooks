-- Made by Real_KingBob
-- Visualizes food based on its percentage

local coldRangeVisuals = {min = 0, max = 34}
local cookedRangeVisuals = {min = 35, max = 66}
local burntRangeVisuals = {min = 67, max = 96}

local function percentageInRange(currentNumber, startRange, endRange)
	if startRange > endRange then startRange, endRange = endRange, startRange end

	local normalizedNum = (currentNumber - startRange) / (endRange - startRange)

	normalizedNum = math.max(0, normalizedNum)
	normalizedNum = math.min(1, normalizedNum)

	return (math.floor(normalizedNum * 100) / 100) -- rounds to .2 decimal places
end


return function (foodObject, percentage)
    if not foodObject or not percentage then return end

	print("visualizing:", foodObject, percentage)

    local function destroyTexture()
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("SurfaceAppearance") and item.Name == "Texture" then
                item:Destroy()
            end

            if item:IsA("Decal") and item.Name == "Texture" then
                item:Destroy()
            end
        end
    end

    local function setTransparency(transparency)
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("Decal") and item.Name == "Texture" then
                item.Transparency = transparency
            end
        end
    end

    local function setFillTransparency(transparency)
        for _, item in pairs(foodObject:GetDescendants()) do
            if item:IsA("Decal") and item.Name == "Burnt" then --if item:IsA("Highlight") and item.Name == "Burnt" then
				item.Transparency = transparency --item.FillTransparency = transparency
            end
        end
    end

    if foodObject:GetAttribute("RawColor") ~= nil then
        foodObject.Color = foodObject:GetAttribute("RawColor")
    end

    if percentage <= coldRangeVisuals.min or (percentage > coldRangeVisuals.min and percentage <= coldRangeVisuals.max) then
        destroyTexture()
    elseif percentage > coldRangeVisuals.max and percentage <= cookedRangeVisuals.max then
        --destroyTexture()
        setTransparency(0)
    elseif percentage > cookedRangeVisuals.max and percentage <= burntRangeVisuals.max then
        setTransparency(0)
        setFillTransparency((1 - percentageInRange(percentage, cookedRangeVisuals.min, burntRangeVisuals.max)))
    else
        setTransparency(0)
        setFillTransparency(0)
    end
end