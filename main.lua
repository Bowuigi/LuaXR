--[[
	LuaXR, A X pager made with Love 2D
	By Bowuigi
	Registered under the GNU GPL v3
]]

function love.load(arg)
	-- Config variables
	FontSize = 16
	DefaultFont = love.graphics.newFont("Comfortaa-Light.ttf",FontSize)
	LineSpacing = 22
	KeyScrollStrength=50
	Keys = {
		--      | Standard  | Vi(m) | Misc     |
		up =    {"w", "up",    "k",  "backspace"},
		down =  {"s", "down",  "j",  "space"},
		left =  {"a", "left",  "h"},
		right = {"d", "right", "l"},
	}
	FileDropString = "Please drop a file here"

	-- Editor variables
	TextOffset = {x=0,y=0} -- Used for scroll
	Width, Height = love.graphics.getDimensions()

	Buffer = {}
	if arg[1] ~= nil then
		if arg[1] == "-" then
			Buffer = ReadFrom(io.stdin)
		else
			local fi = io.open(arg[1])
			Buffer = ReadFrom(fi)
			fi:close()
		end
	end
end

-- Update function
function love.update(dt)
	if (love.keyboard.isScancodeDown(Keys.up)) then
		TextOffset.y = TextOffset.y - dt*KeyScrollStrength
	elseif (love.keyboard.isScancodeDown(Keys.down)) then
		TextOffset.y = TextOffset.y + dt*KeyScrollStrength
	end

	if (love.keyboard.isScancodeDown(Keys.left)) then
		TextOffset.x = TextOffset.x + dt*KeyScrollStrength*4
	elseif (love.keyboard.isScancodeDown(Keys.right)) then
		TextOffset.x = TextOffset.x - dt*KeyScrollStrength*4
	end

	TextOffset.y = clamp(TextOffset.y,0,#Buffer-(Height/LineSpacing-10))
	TextOffset.x = clamp(TextOffset.x,-1e6,0)
end

function love.draw()
	love.graphics.setFont(DefaultFont)
	if Buffer[1]==nil then
		love.graphics.print(FileDropString,Width/2-(#FileDropString*FontSize/2)/2,Height/2-FontSize)
	else
		-- Printing the letters to the screen
		for i=1,Height,1 do
			love.graphics.print(Buffer[math.floor(i+TextOffset.y)] or "~",10+TextOffset.x,i*LineSpacing)
		end
	end
end

-- File (or standard input) reading function
function ReadFrom(stream)
	local tmp = {}
	for line in stream:lines() do
		tmp[#tmp+1] = line
	end
	return tmp
end

-- Detect scroll
function love.wheelmoved(x,y)
	TextOffset.y = TextOffset.y - y
end

-- Resizing compatible
function love.resize(w,h)
	Width, Height = w,h
end

function clamp(value,min,max)
	return math.max(math.min(value,max),min)
end

function love.filedropped(file)
	file:open("r")
	Buffer = ReadFrom(file)
	file:close()
	TextOffset = {x=0,y=0}
end