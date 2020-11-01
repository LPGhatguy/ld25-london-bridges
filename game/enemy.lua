local enemy = {}
enemy.pos_x = 0
enemy.pos_y = 0
enemy.type = 1
enemy.state = 1
enemy.quad = nil
enemy.dying = false
enemy.dead_left = 3

enemy.init = function(self, engine)
	engine.lib.oop:objectify(self)

	return self
end

return enemy