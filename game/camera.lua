local camera = {}
local lib
camera.x = 0
camera.y = 0
camera.tween_fx = 0
camera.tween_fy = 0
camera.tween_x = 0
camera.tween_y = 0
camera.tween_dx = 0
camera.tween_dy = 0
camera.tween_duration = 0
camera.tween_time = 0
camera.tweening = false
camera.map = 1
camera.maps = 3

camera.change_map = function(self, change)
	local target = self.map + change

	if (target > self.maps) then
		self.map = self.maps
	elseif (target < 1) then
		self.map = 1
	else 
		self.map = target
	end

	self:tween(0, -self.map * 720 + 720, 0.3)
end

camera.set_map = function(self, map)
	if (map < self.maps and map > 0) then
		self.map = map
		self:tween(0, -map * 720 + 720, 0.3)
	end
end

camera.move = function(self, x, y)
	self.x = x or self.x
	self.y = y or self.y

	return self
end

camera.pan = function(self, x, y)
	self.x = self.x + (x or 0)
	self.y = self.y + (y or 0)
	return self
end

camera.tween = function(self, x, y, time)
	if (not self.tweening) then
		self.tween_fx = self.x
		self.tween_fy = self.y
		self.tween_x = x
		self.tween_y = y
		self.tween_duration = time

		self.tween_dx = (self.tween_x - self.tween_fx)
		self.tween_dy = (self.tween_y - self.tween_fy)

		self.tween_time = 0
		self.tweening = true

		self.tween_fixer = lib.extend.delayed:new(time, function()
			self.x = self.tween_x
			self.y = self.tween_y
			self.tweening = false
		end)
	end
end

camera.tween_offset = function(self, x, y, time)
	self:tween(self.x + x, self.y + y, time)
end

camera.update = function(self, event)
	local delta = event.delta

	if (self.tweening) then
		self.tween_fixer:step(event.delta)
		self.tween_time = self.tween_time + delta
		local scale = self.tween_time / self.tween_duration

		self.x = self.tween_fx + self.tween_dx * scale
		self.y = self.tween_fy + self.tween_dy * scale

		if (math.abs(self.x - self.tween_x) <= math.abs(self.tween_dx * delta) and math.abs(self.y - self.tween_y) <= math.abs(self.tween_dy * delta)) then
			self.x = self.tween_x
			self.y = self.tween_y
			self.tweening = false
		end
	end
end

camera.new = function(self, x, y)
	local new = self:_new()
	new.x = x
	new.y = y

	return new
end

camera.init = function(self, engine)
	lib = engine.lib
	lib.oop:objectify(self)

	return self
end

return camera