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

function Ball:collides(paddle)
	-- Check to make sure left/right edges aren't touching/overlapping
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then 
		return false
	end

	-- Check to make sure top/bottom edges aren't touching/overlapping
	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end

	-- Ball and paddle are colliding
	return true
end

function Ball:reset()
	-- Reset the ball's position and velocity
	self.x = (VIRTUAL_WIDTH / 2) - (BALL_SIZE / 2)
	self.y = (VIRTUAL_HEIGHT / 2) - (BALL_SIZE / 2)

	self.dx = math.random(2) == 1 and -450 or 450
	self.dy = math.random(BALL_DY_SERVE_MIN, BALL_DY_SERVE_MAX)
	
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