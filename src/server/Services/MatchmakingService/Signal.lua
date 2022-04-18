local connection = {}
connection.__index = connection

function connection:Create()
	return setmetatable({
		connections = {},
		waiting = {}
	}, connection)
end

function connection:Connect(Listener)
	table.insert(self.connections, Listener)
	return Listener
end

function connection:Fire(...)
	if self.connections[1] then  
		for i = #self.connections, 1, -1 do
			local newThread = coroutine.create(self.connections[i])
			coroutine.resume(newThread, ...)
		end
	end 

	if self.waiting[1] then
		for i = #self.waiting, 1, -1 do
			coroutine.resume(self.waiting[i], ...)
			self.waiting[i] = nil
		end
	end
end

function connection:Wait()
	local thread = coroutine.running()
	table.insert(self.waiting, thread)
	return coroutine.yield()
end

function connection:Disconnect(Listener)
	for i = 1, #self.connections, 1 do
		if Listener == self.connections[i] then
			table.remove(self.connections, i)
		end
	end
end

function connection:Delete()
	for i = 1, #self.connections, 1 do
		self.connections[i] = nil
	end

	for i = 1, #self.waiting, 1 do
		self.waiting[i] = nil
	end
end

return connection