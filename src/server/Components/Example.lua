local Component = require(game:GetService("ReplicatedStorage").Packages.Component)

local Logger = {}
function Logger.Constructing(component) print("Constructing", component) end
function Logger.Constructed(component) print("Constructed", component) end
function Logger.Starting(component) print("Starting", component) end
function Logger.Started(component) print("Started", component) end
function Logger.Stopping(component) print("Stopping", component) end
function Logger.Stopped(component) print("Stopped", component) end

local MyComponent = Component.new({
	Tag = "MyComponent",
	Ancestors = {workspace}, -- Optional array of ancestors in which components will be started
	Extensions = {Logger}, -- See Logger example above with the example for the Extension type
})

-- Optional if UpdateRenderStepped should use BindToRenderStep:
MyComponent.RenderPriority = Enum.RenderPriority.Camera.Value

function MyComponent:Construct()
	self.MyData = "Hello"
end

function MyComponent:Start()
    print(self.MyData)
end

function MyComponent:Stop()
	self.MyData = "Goodbye"
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
end)

MyComponent.Stopped:Connect(function(component) 
    local robloxInstance: Instance = component.Instance
	print("Component is not bound to " .. robloxInstance:GetFullName() .. " anymore")
end)

return {}