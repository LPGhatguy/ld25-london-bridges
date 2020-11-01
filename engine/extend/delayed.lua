local delayed = {}
local lib

delayed.delay = 0
delayed.elapsed = 0
delayed.loop = false
delayed.set = true

delayed.action = function(self)
	print("Hello, world!")
end

delayed.step = function(self, delta)
	if (self.set) then
		self.elapsed = self.elapsed + delta
		if (self.elapsed > self.delay) then
			self:action()
			if (self.loop) then
				self.elapsed = self.elapsed - self.delay
			else
				self.set = false
			end
		end
	end
end

delayed.new = function(self, delay, action)
	local new = self:_new()
	new.delay = delay
	new.action = action

	return new
end

delayed.reset = function(self)
	self.elapsed = 0
end

delayed.init = function(self, engine)
	lib = engine.lib

	lib.oop:objectify(self)

	return self
end

return delayed