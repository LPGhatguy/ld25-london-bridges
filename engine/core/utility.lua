local utility = {}

utility.get_engine_path = function()
	return debug.getinfo(1).short_src:match("([^%.]*)[\\/][^%.]*%..*$")
end

utility.table_copy = function(from, to)
	local to = to or {}

	for key, value in pairs(from) do
		if (type(value) == "table") then
			to[key] = utility.table_copy(value)
		else
			to[key] = value
		end
	end

	return to
end

utility.table_merge = function(from, to)
	if (from) then
		for key, value in pairs(from) do
			if (not to[key]) then
				if (type(value) == "table") then
					to[key] = utility.table_copy(value)
				else
					to[key] = value
				end
			end
		end
	end

	return to
end

utility.table_merge_adv = function(from, to, transform)
	for key, value in pairs(from) do
		if (not to[key]) then
			local key, value = transform(key, value)
			if (type(value) == "table") then
				to[key] = utility.table_copy(value)
			else
				to[key] = value
			end
		end
	end
end

utility.init = function(self, engine)
	return self
end

return utility