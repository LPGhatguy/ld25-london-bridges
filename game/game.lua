local game = {}
local engine, lib, delayed

local intro_quad = {
	person = love.graphics.newQuad(0, 0, 16, 32, 32, 512),
	bird = love.graphics.newQuad(0, 160, 16, 32, 32, 512)
}

game.time = 0
game.state = {
	main = "",
}
game.delayers = {}
game.temp = {}
game.world = nil

game.resource = {
	font = {},
	image = {},
	map = {},
	audio = {},
	sheets = {}
}

game.states = {
	main = {
		opening = {
			game_state_switched = function(self, event)
				self.temp.intro_time = 0
				self.delayers.opening = delayed:new(4, function()
					self:set_state("main", "title")
					self.delayers.opening = nil
				end)
			end,
			update = function(self, event)
				self.temp.intro_time = self.temp.intro_time + event.delta
			end,
			draw = function(self)
				love.graphics.setColor(255, 255, 255)
				love.graphics.setBackgroundColor(0, 0, 0)
				love.graphics.printf("Made with", -30, 200, 1280, "center")

				love.graphics.draw(self.resource.image.love2d_logo, 400, 232)
				love.graphics.printf("LÖVE 0.8.0", 330, 380, 256, "center")

				love.graphics.draw(self.resource.image.lua_logo, 690, 232, 0, 0.5, 0.5)
				love.graphics.printf(_VERSION, 630, 380, 256, "center")

				if (self.temp.intro_time > 2) then
					love.graphics.setColor(0, 0, 0, 255 * (self.temp.intro_time - 2) / 2)
					love.graphics.rectangle("fill", 0, 0, 1280, 720)
				end
			end
		},
		title = {
			game_state_switched = function(self, event)
				love.graphics.setColor(255, 255, 255)
				self.resource.audio.title_song:play()
			end,
			game_state_switching = function(self, event)
				self.resource.audio.title_song:stop()
				self:play_sound("ding")
			end,
			keydown = function(self, event)
				if (event.key == "escape") then
					love.event.push("quit")
				elseif (not game.temp.intro) then
					game.temp.intro = true

					self.delayers.intro = delayed:new(0.4, function()
						self:set_state("main", "intro")
						self.delayers.intro = nil
						game.temp.intro = false
					end)
				end
				event.cancel = true
			end,
			mousedown = function(self, event)
				self.delayers.intro = delayed:new(0.4, function()
					self:set_state("main", "intro")
					self.delayers.intro = nil
					game.temp.intro = false
				end)
			end,
			draw = function(self)
				love.graphics.draw(self.resource.image.title, -1020 + ((self.time * 120) % 1020), 0, 0, 10, 10)
				love.graphics.draw(self.resource.image.title, (self.time * 120) % 1020, 0, 0, 10, 10)

				love.graphics.draw(self.resource.image.title_text, 0, (3 * math.cos(self.time * 5)), 0, 10, 10)
				love.graphics.printf("Made in 48 hours for Ludum Dare 25", 0, 20, 1280, "center")
				love.graphics.printf("by Lucien Greathouse (LPGhatguy)", 0, 34, 1280, "center")
				love.graphics.printf("Press escape to quit", 0, 680 + (3 * math.sin(self.time * 5)), 1280, "center")
				love.graphics.printf("Press any other key or click to begin", 0, 694 + (3 * math.sin(self.time * 5)), 1280, "center")
			end
		},
		intro = {
			game_state_switched = function(self, event)
				self.resource.audio.intro_speech:play()
				self.resource.audio.intro_song:play()
				self.temp.intro_time = 0
				love.graphics.setBackgroundColor(0, 165, 228)
			end,
			game_state_switching = function(self, event)
				self.resource.audio.intro_speech:stop()
				self.resource.audio.intro_song:stop()
				self.world.camera:move(0, 0)
			end,
			draw = function(self)
				local elapsed = self.temp.intro_time

				if (elapsed < 1.5) then
					love.graphics.printf("You're a bridge.", 0, 360, 1280, "center")
				elseif (elapsed < 4.9) then
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)
					love.graphics.printf("Now now, this might sound crazy, but hear me out.", 0, 360, 1280, "center")
				elseif (elapsed < 9.9) then
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)
					love.graphics.printf("The inhabitants of this very world don't realize that your time is just about out.", 0, 360, 1280, "center")
				elseif (elapsed < 13.9) then
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)

					love.graphics.setColor(255, 0, 0)
					love.graphics.setLine(15, "rough")
					love.graphics.line(-30, 460, 1280, 720)
					love.graphics.line(1310, 460, 0, 720)

					love.graphics.setColor(255, 255, 255)
					love.graphics.printf("One more parade, and you'll be turned into a conglomerate of concrete and steel.", 0, 360, 1280, "center")
				elseif (elapsed < 16.9) then
					love.graphics.printf("You don't want to be a mush of building materials, do you?", 0, 360, 1280, "center")
				elseif (elapsed < 22.3) then
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)

					for num = 1, 15 do
						love.graphics.drawq(self.resource.image.enemies, intro_quad.person,
							math.floor((elapsed - 22.3) * 150) + 50 * num, 440, 0.1 * math.sin(elapsed * 5), 3, 3, 8, 16)
					end

					love.graphics.printf("Tomorrow, the humans have scheduled a parade of an appropriate magnitude to accomplish such a task.", 0, 360, 1280, "center")
				elseif (elapsed < 25.3) then
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)

					for num = 1, 15 do
						love.graphics.drawq(self.resource.image.enemies, intro_quad.person,
							math.floor((elapsed - 22.3) * 150) + 50 * num, 440 + elapsed * 10, 0.15 * math.sin(elapsed * 15), 3, 3)
					end

					love.graphics.printf("Throw them off the bridge before can they do too much damage.", 0, 360, 1280, "center")
				elseif (elapsed < 29.3) then
					love.graphics.printf("The whirlpool below you hasn't been red in a long time.", 0, 360, 1280, "center")
				else
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)
					love.graphics.printf("But, do it for yourself.", 0, 360, 1280, "center")
				end

				love.graphics.printf("Press any key or click to skip", 0, 690 + (3 * math.sin(self.time * 5)), 1280, "center")
			end,
			update = function(self, event)
				self.temp.intro_time = self.temp.intro_time + event.delta
				if (self.resource.audio.intro_speech:isStopped() and self.resource.audio.intro_song:isStopped()) then
					self:set_state("main", "instructions")
				end
			end,
			keydown = function(self, event)
				self:set_state("main", "instructions")
				event.cancel = true
			end,
			mousedown = function(self, event)
				self:set_state("main", "instructions")
			end
		},
		instructions = {
			draw = function(self)
				love.graphics.printf("Click and drag to throw people off the bridge!", 0, 300, 1280, "center")
				love.graphics.printf("Use W/S, arrow keys, or scroll wheel to change height. Most levels have 2 or 3 floors!", 0, 314, 1280, "center")
				love.graphics.printf("Everyone who crosses the bridge damages you!", 0, 328, 1280, "center")
				love.graphics.printf("Press any key or click to continue", 0, 690 + (3 * math.sin(self.time * 5)), 1280, "center")
			end,
			keydown = function(self, event)
				self:set_state("main", "game")
			end,
			mousedown = function(self, event)
				self:set_state("main", "game")
			end,
		},
		game = {
			game_state_switched = function(self, event)
				game.temp.winning = false
				self.resource.audio.game_song:play()
			end,
			game_state_switching = function(self, event)
				self.resource.audio.game_song:pause()
			end,
			keydown = function(self, event)
				if (event.key == "escape") then
					self:set_state("main", "paused")
				end

				event.cancel = true
			end,
			update = function(self, event)
				self.world:update(event)

				if (not game.temp.winning) then
					if (self.world:has_lost_level()) then
						game.temp.winning = true --loljk
						self.delayers.level_lost = delayed:new(1, function()
							self:set_state("main", "game_lose")
						end)
					elseif (self.world:has_won_level()) then
						game.temp.winning = true
						self.delayers.level_won = delayed:new(1, function()
							self:set_state("main", "level_win")
						end)
					end
				end
			end,
			keydown = function(self, event)
				if (event.key == "escape") then
					self:set_state("main", "paused")
				end

				if (event.key == "up" or event.key == "w") then
					self.world.camera:change_map(-1)
				elseif (event.key == "down" or event.key == "s") then
					self.world.camera:change_map(1)
				end

				if (event.key == " ") then
					self.world:spawn_enemy(0, -515, 1, 1)
				end
			end,
			mousedown = function(self, event)
				if (event.y < 50 or event.button == "wu") then
					self.world.camera:change_map(-1)
				elseif (event.y > 670 or event.button == "wd") then
					self.world.camera:change_map(1)
				end
				self.world:mousedown(event)
			end,
			mouseup = function(self, event)
				self.world:mouseup(event)
			end,
			draw = function(self, event)
				local g = 165 * (math.max(self.world.health, 0) / self.world.health_max)
				local b = 228 * (math.max(self.world.health, 0) / self.world.health_max)
				love.graphics.setBackgroundColor(0, g, b)

				love.graphics.draw(self.resource.image.clouds, (60 * self.time) % 1280, 0, 0, 10, 10)
				love.graphics.draw(self.resource.image.clouds, (60 * self.time) % 1280 - 1280, 0, 0, 10, 10)

				self.world:draw()

				if (#self.world.levels[self.world.level].maps > 1) then
					love.graphics.draw(self.resource.image.hud_bottom, 0, 0, 0, 10, 10)
				end

				love.graphics.print("LEVEL " .. self.world.level .. " OF " .. #self.world.levels, 0, 0)
				love.graphics.print("FLOOR " .. self.world.camera.map .. " OF " .. self.world.camera.maps, 0, 14)
				love.graphics.print("HEALTH " .. self.world.health .. "/" .. self.world.health_max, 0, 28)
			end
		},
		level_win = {
			game_state_switched = function(self, event)
				self.resource.audio.game_song:stop()
				self:play_sound("ding")
				self:play_sound("level_win")
				game.delayers.level_switch = delayed:new(2, function()
					if (self.world.level < #self.world.levels) then
						self.world:next_level()
						self:set_state("main", "game")
					else
						self:set_state("main", "game_win")
					end
				end)
			end,
			draw = function(self)
				love.graphics.printf("You won!", 0, 360, 1280, "center")
			end
		},
		game_win = {
			game_state_switched = function(self, event)
				self.temp.won_for = 0
				self.resource.audio.game_win:play()
				game.delayers.game_restart = delayed:new(8, function()
					self.world:reset()
					self.world:set_level(1)
					self:set_state("main", "title")
				end)
			end,
			update = function(self, event)
				self.temp.won_for = self.temp.won_for + event.delta
			end,
			draw = function(self)
				local percent = math.min(self.temp.won_for / 6, 1)
				local r = 220 * percent
				local g = 165 - (165 * percent)
				local b = 228 - (228 * percent)

				love.graphics.setBackgroundColor(r, g, b)

				love.graphics.printf("You've saved your own bridgework, but not without the cost of many lives.", 0, 360, 1280, "center")
				love.graphics.printf("Regardless, LONG LIVE BRIDGES!", 0, 374, 1280, "center")
				if (self.temp.won_for > 5.6) then
					love.graphics.draw(self.world.maps[1], 0, 0, 0, 10, 10)
				end
			end
		},
		game_lose = {
			game_state_switched = function(self, event)
				self:play_sound("level_lose")
				self.resource.audio.level_lose_song:play()
				game.delayers.game_restart = delayed:new(9, function()
					self.world:reset()
					self.world:set_level(1)
					self:set_state("main", "title")
				end)
			end,
			draw = function(self)
				love.graphics.printf("...and so the great bridge of London fell, a disgrace to all other bridges in the world...", 0, 360, 1280, "center")
			end
		},
		paused = {
			keydown = function(self, event)
				if (event.key == "escape") then
					self:set_state("main", "game")
				end

				event.cancel = true
			end,
			draw = function(self)
				love.graphics.setBackgroundColor(120, 120, 120)
				love.graphics.setColor(255, 255, 255)
				love.graphics.printf("Paused", 0, 360, 1280, "center")
			end
		}
	}
}

game.event = {
	game_state_switching = function(self, event_pass)
		self:fire_state_event("game_state_switching", event_pass)
	end,
	game_state_switched = function(self, event_pass)
		self:fire_state_event("game_state_switched", event_pass)
	end,
	update = function(self, event_pass)
		self.time = self.time + event_pass.delta
		self:fire_state_event("update", event_pass)
		for key, delayer in next, self.delayers do
			delayer:step(event_pass.delta)
		end
	end,
	keydown = function(self, event_pass)
		self:fire_state_event("keydown", event_pass)
	end,
	keyup = function(self, event_pass)
		self:fire_state_event("keyup", event_pass)
	end,
	mousedown = function(self, event_pass)
		self:fire_state_event("mousedown", event_pass)
	end,
	mouseup = function(self, event_pass)
		self:fire_state_event("mouseup", event_pass)
	end,
	draw = function(self)
		self:fire_state_event("draw")
	end
}

game.fire_state_event = function(self, event_name, event_pass)
	for key, value in next, self.state do
		local handler_object = self.states[key] and self.states[key][value]

		if (handler_object and handler_object[event_name]) then
			handler_object[event_name](self, event_pass)
		end
	end
end

game.set_state = function(self, key, value)
	local old = self.state[key]

	engine:event_trigger("game_state_switching", {
		from = old,
		to = value
	})

	self.state[key] = value

	engine:event_trigger("game_state_switched", {
		from = old,
		to = value
	})
end

game.play_sound = function(self, name, volume)
	local sound = love.audio.newSource(self.resource.audio[name])
	sound:setVolume(volume or 1)
	sound:play()
	return sound
end

game.init = function(self, g_engine)
	engine = g_engine
	lib = engine.lib
	delayed = lib.extend.delayed

	engine:event_create_batch("game_state_switching", "game_state_switched")

	self.world = lib.game.world:new()
	self.world:set_level(1)

	return self
end

game.load = function(self)
	love.graphics.setBackgroundColor(0, 165, 228)

	self.resource.image.love2d_logo = love.graphics.newImage("resource/image/love2d_logo.png")
	self.resource.image.lua_logo = love.graphics.newImage("resource/image/lua_logo.png")

	self.resource.image.enemies = love.graphics.newImage("resource/image/enemies.png")

	self.resource.image.title = love.graphics.newImage("resource/image/title.png")
	self.resource.image.title_text = love.graphics.newImage("resource/image/title_text.png")
	self.resource.image.hud_bottom = love.graphics.newImage("resource/image/hud_bottom.png")
	self.resource.image.clouds = love.graphics.newImage("resource/image/clouds.png")

	self.resource.audio.intro_speech = love.audio.newSource("resource/audio/intro_speech.ogg", "stream")
	self.resource.audio.intro_song = love.audio.newSource("resource/audio/intro_song.ogg", "stream")
	self.resource.audio.title_song = love.audio.newSource("resource/audio/title_song.ogg", "stream")
	self.resource.audio.title_song:setLooping(true)
	self.resource.audio.game_song = love.audio.newSource("resource/audio/game_song.ogg", "stream")
	self.resource.audio.game_song:setLooping(true)
	self.resource.audio.level_lose_song = love.audio.newSource("resource/audio/level_lose_song.ogg", "stream")
	self.resource.audio.level_lose_song:setVolume(0.3)
	self.resource.audio.game_win = love.audio.newSource("resource/audio/game_win.ogg", "stream")

	self.resource.audio.ding = love.sound.newSoundData("resource/audio/ding.mp3")
	self.resource.audio.falling = love.sound.newSoundData("resource/audio/falling.ogg")
	self.resource.audio.picked_up = love.sound.newSoundData("resource/audio/picked_up.ogg")
	self.resource.audio.level_win = love.sound.newSoundData("resource/audio/level_win.ogg")
	self.resource.audio.level_lose = love.sound.newSoundData("resource/audio/level_lose.ogg")
	self.resource.audio.damaged = love.sound.newSoundData("resource/audio/damaged.ogg")

	self.world.audio.damaged = self.resource.audio.damaged
	self.world.audio.falling = self.resource.audio.falling
	self.world.audio.picked_up = self.resource.audio.picked_up
	self.world.audio.grunt_up = love.sound.newSoundData("resource/audio/grunt_up.ogg")
	self.world.audio.grunt_fall = love.sound.newSoundData("resource/audio/grunt_fall.ogg")
	self.world.audio.bird_up = love.sound.newSoundData("resource/audio/bird_up.ogg")
	self.world.audio.bird_fall = love.sound.newSoundData("resource/audio/bird_fall.ogg")

	self.world.maps = {
		love.graphics.newImage("resource/map/map1.png"),
		love.graphics.newImage("resource/map/map2.png"),
		love.graphics.newImage("resource/map/map3.png")
	}
	self.world.enemy_batch = love.graphics.newSpriteBatch(self.resource.image.enemies, 300)
end

game.start = function(self)
	self:set_state("main", "opening")
end

return game