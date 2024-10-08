local STANDARD_GRAVITY <const> = 9.80665

local shakes = 0

local player <const> = playdate.sound.sampleplayer


Shaker = {}
Shaker.__index = Shaker

Shaker.kSensitivityLow = 10
Shaker.kSensitivityMedium = 14
Shaker.kSensitivityHigh = 20

function Shaker.new(callback, options)
	options = options or {}
	
	local shaker = {}
	setmetatable(shaker, Shaker)
	
	shaker.threshold = options.threshold or 0.5
	shaker.sensitivity = options.sensitivity or Shaker.kSensitivityMedium
	shaker.sample_size = options.samples or 20
	
	shaker.callback = callback
	shaker.enabled = false
	shaker.index = 0
	
	shaker:reset()
	
	return shaker
end

function Shaker:setEnabled(enable)
	self.enabled = enable
end

function Shaker:reset()
	if not self.shake_samples or #self.shake_samples > 0 then
		self.shake_samples = table.create(self.sample_size)
	end
	self.shake_sample_total = 0
end

function Shaker:update()
	if not self.enabled then
		return
	end
	
	if not playdate.accelerometerIsRunning() then
		self:reset()
		return
	end
	
	self:sample()
	
	-- Start testing for shakes once we have enough samples.
	if #self.shake_samples == self.sample_size then
		self:test()
	end
end

function Shaker:sample()
	local x, y, z = playdate.readAccelerometer()
	
	x *= STANDARD_GRAVITY
	y *= STANDARD_GRAVITY
	z *= STANDARD_GRAVITY
	
	local accel = x * x + y * y + z * z
	local accelerating = (accel > (self.sensitivity * self.sensitivity)) and 1 or 0
	
	self.index += 1
	if self.index>self.sample_size then
		self.index -= self.sample_size
	end
	
	if self.shake_samples[self.index] then
		self.shake_sample_total -= self.shake_samples[self.index]
	end
	
	self.shake_samples[self.index] = accelerating
	self.shake_sample_total += accelerating
end

function Shaker:numOfShakes()
	return shakes
end

function Shaker:resetShakes()
	shakes = 0
end

function Shaker:test()
	local average = self.shake_sample_total / #self.shake_samples
	if average > self.threshold then
		shakes += 1
		self:reset()
		self.callback()
	end
end