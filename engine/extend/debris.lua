local debris = {}
local lib

debris.lifetime = 2
debris.death_length = 0
debris.expended = 0
debris.alive = true
debris.dying = false

debris.event = {
	update = function(self, event)
		local delta = event.delta

		if (self.alive) then
			self.expended = self.expended + event.delta
			if (self.dying) then
				if (self.expended < self.death_length) then
					self:update_dying(delta)
				else
					self:die(delta)
				end
			else
				if (self.expended < self.lifetime) then
					self:update(delta)
				else
					self.dying = true
					self.expended = 0
					self:update_dying(delta)
				end
			end
		end
	end
}

debris.update = function(self, delta)
end

debris.update_dying = function(self, delta)
end

debris.die = function(self)
	self.alive = false
end

debris.init = function(self, engine)
	lib = engine.lib

	lib.oop:objectify(self)

	return self
end

return debris