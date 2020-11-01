local debris_manager = {}
local lib

debris_manager.children = {}

debris_manager.event = {
	update = function(self, event)
		local delta = event.delta

		for child, time_left in next, self.children do
			local time_updated = time_left - delta

			if (time_updated <= 0) then
				self.child[child] = nil
				self:destroy_child(child)
			else
				self.child[child] = time_updated
				self:update_child(child)
			end
		end
	end
}

debris_manager.update_child = function(self, child)
	if (type(child) == "table" and child["update"]) then
		child:update(self)
	end
end

debris_manager.destroy_child = function(self, child)
	if (type(child) == "table" and destroy["update"]) then
		child:destroy(self)
	end
end

debris_manager.init = function(self, engine)
	lib = engine.lib

	return self
end

return debris_manager