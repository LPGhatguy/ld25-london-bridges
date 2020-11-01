local definitions = {}
local lib

definitions.fire_keydown = function(self, key, unicode)
	return self:event_trigger("keydown", {
		key = key,
		unicode = unicode
	})
end

definitions.fire_keyup = function(self, key, unicode)
	return self:event_trigger("keyup", {
		key = key,
		unicode = unicode
	})
end

definitions.fire_update = function(self, delta)
	return self:event_trigger("update", {
		delta = delta
	})
end

definitions.fire_mousedown = function(self, x, y, button)
	return self:event_trigger("mousedown", {
		x = x,
		y = y,
		button = button
	})
end

definitions.fire_mouseup = function(self, x, y, button)
	return self:event_trigger("mouseup", {
		x = x,
		y = y,
		button = button
	})
end

definitions.fire_draw = function(self)
	return self:event_trigger("draw")
end

definitions.init = function(self, engine)
	lib = engine.lib

	engine:event_create_batch("update", "draw", "keydown", "keyup")
	engine:inherit(self)

	return self
end

return definitions