local CollectionService = game:GetService("CollectionService")
local Component = require(game:GetService("ReplicatedStorage").Packages.Component)

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Maid = require(Knit.Util.Maid)

local MyComponent = Component.new({
	Tag = "Stoves",
	Ancestors = {workspace}, -- Optional array of ancestors in which components will be started
	Extensions = {}, -- See Logger example above with the example for the Extension type
})

-- Optional if UpdateRenderStepped should use BindToRenderStep:
MyComponent.RenderPriority = Enum.RenderPriority.Camera.Value

function MyComponent:Construct()
end

function MyComponent:Start()
end

function MyComponent:Stop()
end

function MyComponent:HeartbeatUpdate(dt)
end

function MyComponent:SteppedUpdate(dt)
end

function MyComponent:RenderSteppedUpdate(dt)
end

MyComponent.Started:Connect(function(component)
	local robloxInstance: Instance = component.Instance
	print("Component is bound to " .. robloxInstance:GetFullName())

    component.Object = robloxInstance
    component.StoveEnabled = robloxInstance:GetAttribute("Enabled")
    component.playersDebounces = {}

    component._maid = Maid.new()
    
    component._maid:GiveTask(component.Object:GetAttributeChangedSignal("Enabled"):Connect(function()
        local stoveEnabled = robloxInstance:GetAttribute("Enabled")
        --print(stoveEnabled)
        for _,v in pairs(robloxInstance:GetChildren()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = stoveEnabled
            end
        end
    end))

    component._maid:GiveTask(component.Object.Touched:Connect(function(hit)
        if CollectionService:HasTag(hit, "CC_Food") then return end
        if component.StoveEnabled == true then
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if humanoid and player then
                if component.playersDebounces[player.UserId] == nil then
                    component.playersDebounces[player.UserId] = true
                    humanoid.Health -= 50
                    task.wait(1)
                    component.playersDebounces[player.UserId] = nil
                end
            end
        else
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if humanoid and player then
                if component.playersDebounces[player.UserId] == nil then
                    component.playersDebounces[player.UserId] = true
                    humanoid.Health -= 5
                    task.wait(1)
                    component.playersDebounces[player.UserId] = nil
                end
            end
        end
    end))
end)

MyComponent.Stopped:Connect(function(component) 
    local robloxInstance: Instance = component.Instance
	print("Component is not bound to " .. robloxInstance:GetFullName() .. " anymore")
    if component._maid then component._maid:Destroy() end
end)

return {}