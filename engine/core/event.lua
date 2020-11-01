local event = {}
local lib = {}
local engine

event.events = {}
event.events_light = {}

function do_nothing()
end

event.event_get_handler_func = function(handler, event_name)
	return handler["event_" .. event_name] or (handler.event and handler.event[event_name]) or do_nothing
end

event.event_handler_sorter = function(first, second)
	if (type(first) == "table") then
		if (type(second) == "table") then
			return (first.priority or 0) > (second.priority or 0)
		else
			return true
		end
	elseif (type(second) == "table") then
		return false
	end
end

event.dict_to_array = function(dictionary)
	local array = {}
	local key = 1
	for key, value in pairs(dictionary) do
		array[key] = value
		key = key + 1
	end
	return array
end

event.event_sort_handlers = function(self, event_name)
	if (event_name) then
		table.sort(self.events[event_name], self.event_handler_sorter)
		table.sort(self.events_light[event_name], self.event_handler_sorter)
	else
		for name, events in next, self.events do
			table.sort(events, self.event_handler_sorter)
		end

		for name, events in next, self.events_light do
			table.sort(events, self.event_handler_sorter)
		end
	end
end

event.event_create = function(self, event_name)
	self.events[event_name] = self.events[even_name] or {}
end

event.event_create_batch = function(self, ...)
	for key, event_name in next, {...} do
		self:event_create(event_name)
	end
end

event.event_create_light = function(self, event_name)
	self.events_light[event_name] = self.events_light[event_name] or {}
end

event.event_create_batch_light = function(self, ...)
	for key, event_name in next, {...} do
		self:event_create_light(event_name)
	end
end

event.event_hook = function(self, event_name, handler, priority)
	if (type(event_name) == "table") then
		for key, value in next, event_name do
			self:event_hook(value, handler, priority)
		end
	end

	local handlers = self.events[event_name] or {}
	self.events[event_name] = handlers

	if (handler) then
		table.insert(handlers, priority or handler)
	end
end

event.event_hook_light = function(self, event_name, handler, priority)
	if (type(event_name) == "table") then
		for key, value in next, event_name do
			self:event_hook_light(value, handler, priority)
		end
	end

	local handlers = self.events_light[event_name] or {}
	self.events_light[event_name] = handlers

	if (handler) then
		table.insert(handlers, priority or handler)
	end
end

event.event_trigger = function(self, event_name, arguments)
	if (self.events_light[event_name]) then
		self:event_trigger_light(event_name, arguments)
	end
	if (self.events[event_name]) then
		return self:event_trigger_full(event_name, arguments)
	end
end

event.event_trigger_full = function(self, event_name, arguments)
	local event_pass = self.event_pass:new(event_name, arguments)
	local handlers = self.events[event_name]

	if (handlers) then
		for key, handler in next, handlers do
			if (type(handler) == "function") then
				handler(handler, event_pass)
			elseif (type(handler) == "table") then
				local handler_func = self.event_get_handler_func(handler, event_name)

				if (handler_func) then
					handler_func(handler, event_pass)
				else
					if (self.__logger) then
						self:log_write("Could not find handler for", key, "of full event", event_name)
					end
				end
			else
				if (self.__logger) then
					self:log_write("Unsupported handler type:", type(handler), "for", key, "of full event", event_name)
				end
			end

			if (event_pass.cancel) then
				break
			end
		end
	else
		if (self.__logger) then
			self:log_write("Could not find full event", event_name)
		end
	end

	return event_pass
end

event.event_trigger_light = function(self, event_name, arguments)
	local handlers = self.events_light[event_name]
	local arguments = arguments or {}

	if (handlers) then
		for key, handler in next, handlers do
			if (type(handler) == "function") then
				handler(handler, self.dict_to_array(arguments))
			elseif (type(handler) == "table") then
				local handler_func = self.event_get_handler_func(handler, event_name)

				if (handler_func) then
					handler_func(handler, self.dict_to_array(arguments))
				else
					if (self.__logger) then
						self:log_write("Could not find handler for", key, "of light event", event_name)
					end
				end
			else
				if (self.__logger) then
					self:log_write("Unsupported handler type:", type(handler), "for", key, "of light event", event_name)
				end
			end
		end
	else
		if (self.__logger) then
			self:log_write("Could not find light event", event_name)
		end
	end
end

event.event_pass = {}
event.event_pass.new = function(self, event_name, arguments)
	local pass = self:_new()

	lib.utility.table_merge(arguments, pass)
	pass.cancel = false

	return pass
end

event.init = function(self, engine)
	lib = engine.lib

	lib.oop:objectify(self.event_pass)
	engine:inherit(self)

	return self
end

event.close = function(self, engine)
end

return event