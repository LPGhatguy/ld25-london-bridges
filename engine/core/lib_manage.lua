local lib_manage = {}
local lib, engine_path

lib_manage.lib_get = function(self, path, name)
	if (lib[path]) then
		return lib[path]
	else
		return self:lib_load(path, name)
	end
end

lib_manage.lib_batch_get = function(self, libs)
	for key, library in next, libs do
		if (type(library) == "table") then
			local path, name = unpack(library)
			self:lib_get(path, name)
		else
			self:lib_get(library)
		end
	end
end

lib_manage.lib_load = function(self, path, name)
	local name = name or path
	local path = path:gsub("^:", engine_path)

	local loaded = require(path)
	if (loaded and loaded.init) then
		loaded = loaded:init(self)
		loaded.init = nil
	end

	if (string.match(name, "[%.]")) then
		local name = name:gsub(":", "")
		local lib_name = name:match("([^%.:]*)$")
		local store_in = lib
		for addition in string.gmatch(name, "([^%.]+)%.") do
			if (not store_in[addition]) then
				store_in[addition] = {}
			end
			store_in = store_in[addition]
		end

		store_in[lib_name] = loaded
	else
		lib[name] = loaded
	end

	return lib
end

lib_manage.lib_batch_load = function(self, libs, prefix)
	local prefix = prefix or ""

	for key, library in next, libs do
		if (type(library) == "table") then
			self:lib_load(unpack(library))
		else
			self:lib_load(prefix .. library)
		end
	end
end

lib_manage.init = function(self, engine)
	lib = engine.lib or lib
	engine_path = engine.config.engine_path or engine_path

	engine:inherit(self)

	return self
end

return lib_manage