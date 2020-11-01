local world = {}
local lib

world.audio = {}

world.reset = function(self)
	self.enemies = {}
	self.enemy_quad_cache = self.enemy_quad_cache or {}
	self.enemy_types = {
		{speed = 150, wobble = 0.1, wobble_speed = 7, fall_speed = 700, picked_up = "picked_up", falling = "falling"}, --regular people
		{speed = 200, wobble = 0.2, wobble_speed = 10, fall_speed = 700, picked_up = "picked_up", falling = "falling"}, --purple people
		{speed = 140, wobble = 0.3, wobble_speed = 3, fall_speed = 700, picked_up = "grunt_up", falling = "grunt_fall"}, --nondescript animals
		{speed = 100, wobble = 0.2, wobble_speed = 4, fall_speed = 900, picked_up = "grunt_up", falling = "grunt_fall"}, --grunts
		{speed = 200, wobble = 0.1, wobble_speed = 7, fall_speed = 400, picked_up = "bird_up", falling = "bird_fall"}, --birds
		{speed = 250, wobble = 0.3, wobble_speed = 15, fall_speed = 900, picked_up = "bird_up", falling = "bird_fall"}, --radiocative birds
	}
	self.enemy_free_batch = self.enemy_free_batch or {}
	self.maps = self.maps or {}
	self.levels = require("game.levels")
	self.health_max = 0
	self.health = self.health_max
	self.level = 1
	self.mouse_x = 0
	self.mouse_y = 0
	self.time = 0
	self.dragging = -1
	self.drag_start_x = 0
	self.drag_start_y = 0
end

world:reset()

world.play_sound = function(self, name, alt_name)
	local source = self.audio[name]
	local sound
	if (source) then
		sound = love.audio.newSource(source)
	else
		sound = love.audio.newSource(self.audio[alt_name])
	end
	sound:setVolume(0.3)
	sound:play()
	return sound
end

world.get_enemy_count = function(self)
	local count = 0
	for id, enemy in next, self.enemies do
		count = count + 1
	end
	return count
end

world.has_won_level = function(self)
	local current_level = self.levels[self.level]
	for spawn_id, spawn in next, current_level.spawns do
		if (not spawn.dead) then
			return false
		end
	end

	return self:get_enemy_count() == 0
end

world.has_lost_level = function(self)
	return self.health <= 0
end

world.enemy_spawner_tick = function(self, delta)
	local current_level = self.levels[self.level]
	for spawn_id, spawn in next, current_level.spawns do
		if (not spawn.dead) then
			spawn.build_up = spawn.build_up + delta
			if (spawn.build_up >= spawn.frequency) then
				for floor_id, floor in next, spawn.floors do
					self:spawn_enemy(-64, spawn.pos - 720 * floor + 720, spawn.enemies[math.random(1, #spawn.enemies)], 1)
					spawn.build_up = 0
				end
				spawn.spawned = spawn.spawned + 1
				if (spawn.spawned >= spawn.count) then
					spawn.dead = true
				end
			end
		end
	end
end

world.draw = function(self)
	love.graphics.push()

	love.graphics.translate(-math.ceil(self.camera.x), math.ceil(self.camera.y))
	love.graphics.scale(1, -1)

	self:draw_level(self.level)
	love.graphics.draw(self.enemy_batch)

	love.graphics.pop()
end

world.next_level = function(self)
	self:set_level(self.level + 1)
end

world.set_level = function(self, level)
	if (self.enemy_batch) then
		self.enemy_batch:clear()
		self.enemy_free_batch = {}
		self.enemies = {}
	end

	self.camera:set_map(1)
	self.level = level
	self.camera.maps = #self.levels[level].maps
	self.health_max = self.levels[self.level].health_max
	self.health = self.health_max
end

world.draw_level = function(self)
	for id, map in next, self.levels[self.level].maps do
		love.graphics.draw(self.maps[map], 0, -id * 720 + 720, 0, 10, -10)
	end
end

world.get_enemy_quad = function(self, e_type, state)
	local image = self.enemy_batch:getImage()
	local quad_cache = self.enemy_quad_cache
	local stated_cache = quad_cache[e_type] or {}
	quad_cache[e_type] = stated_cache

	if (stated_cache[state]) then
		return stated_cache[state]
	else
		local quad = love.graphics.newQuad(16 * state - 16, 32 * e_type - 32, 16, 32, image:getWidth(), image:getHeight())
		stated_cache[state] = quad
		return quad
	end
end

world.spawn_enemy = function(self, x, y, e_type, state)
	local enemy = lib.game.enemy:new()

	enemy.pos_x = x
	enemy.pos_y = y
	enemy.type = e_type
	enemy.state = state

	enemy.quad = self:get_enemy_quad(e_type, state)

	local id
	if (#self.enemy_free_batch == 0) then
		id = self.enemy_batch:addq(enemy.quad, x, y, 0, 3, -3)
	else
		id = self.enemy_free_batch[#self.enemy_free_batch]
		self.enemy_free_batch[#self.enemy_free_batch] = nil
		self.enemy_batch:setq(id, enemy.quad, x, y, 0, 3, -3)
	end
	self.enemies[id] = enemy

	return enemy
end

world.update_enemies = function(self, delta)
	self.enemy_batch:bind()
	for id, enemy in next, self.enemies do
		local e_type = self.enemy_types[enemy.type]
		local quad = enemy.quad

		if (id == self.dragging) then
			enemy.pos_x = self.mouse_x
			enemy.pos_y = self.mouse_y
			quad = self:get_enemy_quad(enemy.type, 2)
			self.enemy_batch:setq(id, quad, enemy.pos_x, enemy.pos_y, e_type.wobble * math.sin(self.time * e_type.wobble_speed * 3), 3, -3, 8, 16)
		elseif (enemy.dying) then
			enemy.pos_y = enemy.pos_y - (e_type.fall_speed * delta)
			quad = self:get_enemy_quad(enemy.type, 2)

			enemy.dead_left = enemy.dead_left - delta
			if (enemy.dead_left <= 0) then
				self.enemies[id] = nil
				self.enemy_free_batch[#self.enemy_free_batch + 1] = id
				self.enemy_batch:setq(id, quad, -500, -500)
			else
				self.enemy_batch:setq(id, quad, enemy.pos_x, enemy.pos_y, math.pi * math.sin(self.time * e_type.wobble_speed), 3, -3, 8, 16)
			end
		else
			enemy.pos_x = enemy.pos_x + (e_type.speed * delta)
			if (enemy.pos_x >= 1280) then
				self.enemies[id] = nil
				self.enemy_free_batch[#self.enemy_free_batch + 1] = id
				self.enemy_batch:setq(id, quad, -500, -500)
				self.health = self.health - 1
				self:play_sound("damaged")
			else
				self.enemy_batch:setq(id, quad, enemy.pos_x, enemy.pos_y, e_type.wobble * math.sin(self.time * e_type.wobble_speed), 3, -3, 8, 16)
			end
		end
	end
	self.enemy_batch:unbind()
end

world.mousedown = function(self, event)
	if (event.button == "l" or event.button == "r") then
		local wx, wy = self.camera.x + event.x, self.camera.y - event.y
		for id, enemy in next, self.enemies do
			if (wx > enemy.pos_x - 32 and wx < enemy.pos_x + 32
				and wy > enemy.pos_y - 48 and wy < enemy.pos_y + 48) then
				self.drag_start_x = enemy.pos_x
				self.drag_start_y = enemy.pos_y
				self.dragging = id
				self:play_sound(self.enemy_types[enemy.type].picked_up, "picked_up")
			end
		end
	end
end

world.mouseup = function(self, event)
	if (event.button == "l" or event.button == "r") then
		local enemy = self.enemies[self.dragging]
		if (enemy) then
			if (math.abs(self.camera.y - event.y - self.drag_start_y) > 70) then
				enemy.dying = true
				self:play_sound(self.enemy_types[enemy.type].falling, "falling")
			else
				enemy.pos_y = self.drag_start_y
			end
		end
		self.dragging = -1
	end
end

world.update = function(self, event)
	self.time = self.time + event.delta
	self.camera:update(event)
	self:update_enemies(event.delta)
	self:enemy_spawner_tick(event.delta)
	self.mouse_x = self.camera.x + love.mouse.getX()
	self.mouse_y = self.camera.y - love.mouse.getY()
end

world.init = function(self, engine)
	lib = engine.lib

	lib.oop:objectify(self)

	self.camera = lib.game.camera:new(0, 0)

	return self
end

return world