local logging = {}
local config
logging.log_history = {}
logging.__logger = true

logging.log_write = function(self, ...)
	local args = {...}
	for key, value in pairs(args) do
		args[key] = tostring(value)
	end

	if (config.log_history_enabled) then
		table.insert(self.log_history, table.concat(args, " "))
	end

	if (config.log_realtime_enabled) then
		print(...)
	end
end

logging.log_record = function(self, filename)
	if (not love.filesystem.exists(config.log_directory)) then
		love.filesystem.mkdir(config.log_directory)
	end

	local file_out = love.filesystem.newFile(config.log_directory .. "/" .. filename .. ".txt")
	file_out:open("w")

	local to_write = ""
	for key, line in next, self.log_history do
		to_write = to_write .. tostring(line) .. "\r\n"
	end

	file_out:write(to_write)

	file_out:close()
end

logging.init = function(self, engine)
	config = engine.config or config

	engine:inherit(self)
	engine:log_write("Start:", engine.start_date)

	return self
end

logging.close = function(self, engine)
	engine:log_write("End:", engine.end_date)
	if (engine.config.log_recording_enabled) then
		engine:log_record(engine.start_date:gsub("[:/ ]", "."))
	end
end

return logging