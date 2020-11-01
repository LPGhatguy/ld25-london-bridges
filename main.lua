local libs = {"camera", "world", "enemy"}

local engine = require("engine.core")
engine:init()
engine:lib_batch_load(libs, "game.")

local game = require("game.game")
game:init(engine)

local game_hooks = {}

for key, value in next, game.event do
	game_hooks[#game_hooks + 1] = key
end

function love.load()
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	love.graphics.setIcon(love.graphics.newImage("icon.bmp"))

	game:load()

	engine:event_hook(game_hooks, game)

	game:start()
end

function love.keypressed(key, unicode)
	engine:fire_keydown(key, unicode)
end

function love.mousepressed(x, y, button)
	engine:fire_mousedown(x, y, button)
end

function love.mousereleased(x, y, button)
	engine:fire_mouseup(x, y, button)
end

function love.update(delta)
	engine:fire_update(delta)
end

function love.draw()
	engine:event_trigger("draw")
end

function love.quit()
	engine:close()
end