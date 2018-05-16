Ball = Class {}

function Ball:init(x, y, width, height)
	-- Initialize the ball's position, size, and velocity
	self.x = x
	self.y = y

	self.width = width
	self.height = height

	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(-50, 50)
end

function Ball:reset()
	-- Reset the ball's position and velocity
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2

	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(-50, 50)
	
end

function Ball:update(dt)
	-- Update the ball's position every dt
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:render()
	-- Draw the ball
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end