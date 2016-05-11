tfx = require "termfx"
field = {}
xsize = 41
ysize = 21 
quit = false
exitgame = false
score = 0
level = 300
input = ""
print("Movement: Arrow keys")
print("Exit: ECS")
print("Choose yor level:")
print("1) Easy")
print("2) Medium")
print("3) Hard")
io.write("Your choose: ")
io.flush()
input = io.read()
if input == "1" then
	level = 500
elseif input == "2" then
	level = 300
elseif input == "3" then
	level = 100
else
	print("Input incorrect, level set to medium")
	os.execute("sleep 2")
end
os.execute("clear")
tfx.init()
item = {pos = {x=nil, y=nil}, exist = false}
snake = {direction = "right", ishead = true, pos = {y=11, x=4},
	     next = {pos = {y=11, x=3}, next = {pos = {y=11, x=2}}}}


function createfield()
	for i=1,ysize do
		table.insert(field, {})
		for j=1,xsize do
			table.insert(field[i], " ")
		end
	end
end 

function init()
	for i in pairs(field) do
		for j in pairs(field[i]) do
			if i == 1 or i == ysize or j == 1 or j == xsize then
				field[i][j] = "#"
			else 
				field[i][j] = " "
			end
		end
	end
end

function printfield()
	for i in pairs(field) do
		for j in pairs(field[i]) do
			tfx.setcell(j, i, field[i][j])
		end
	end
	tfx.printat(1, ysize+1, "Your score: " .. score)
	if quit == true then
		tfx.printat(1, ysize+2, "Game over")
		tfx.printat(1, ysize+3, "Thanks for playing")
		tfx.printat(1, ysize+4, "Press any key to quit")
	end
end

function deletetail()
	local segment = snake
	while segment.next.next do
		segment = segment.next
	end
	segment.next = nil
end

function addhead(y,x)
	local segment = snake
	local dir = snake.direction
	segment.ishead = nil
	segment.direction = nil
	snake = {direction = dir, ishead = true, pos = {y=y,x=x}, next = segment}
	deletetail()
end

function searchtail()
	local segment = snake
	while segment.next do
		segment = segment.next
	end
	return segment
end

function addtail()
	local segment = searchtail()
	segment.next = {pos = {y=segment.pos.y, x=segment.pos.x}} 
end

function rendersnake()
	local segment = snake
	while segment do
		field[segment.pos.y][segment.pos.x] = '0'
		segment = segment.next 
	end
end

function spawnitem()
	math.randomseed(os.time())
	local y
	local x
	local itemspawn = false
	while itemspawn == false do
		y = math.random(3, ysize-1)
		x = math.random(3, xsize-1)
		if field[y][x] == '0' then
			itemspawn = false
		else 
			itemspawn = true
			break
		end
	end
	if itemspawn == true then
		item.pos.y = y
		item.pos.x = x
		item.exist = true
	else
		quit = true
	end
end

function playeractions()
	local evt = tfx.pollevent(level)
	if evt then
		if evt.key == tfx.key.ARROW_UP and snake.direction ~= "down" then
			snake.direction = "up"
		elseif evt.key == tfx.key.ARROW_DOWN and snake.direction ~= "up" then
			snake.direction = "down"
		elseif evt.key == tfx.key.ARROW_RIGHT and snake.direction ~= "left" then
			snake.direction = "right"
		elseif evt.key == tfx.key.ARROW_LEFT and snake.direction ~= "right" then
			snake.direction = "left"
		elseif evt.key == tfx.key.ESC then
			exitgame = true
		end
	end
end

function renderitem()
	field[item.pos.y][item.pos.x] = '*'
end

function snakemove()
	if snake.direction == "up" then
		addhead(snake.pos.y-1, snake.pos.x)
	elseif snake.direction == "down" then
		addhead(snake.pos.y+1, snake.pos.x)
	elseif snake.direction == "right" then
		addhead(snake.pos.y, snake.pos.x+1)
	elseif snake.direction == "left" then
		addhead(snake.pos.y, snake.pos.x-1)
	end
	if snake.pos.x >= xsize then
		snake.pos.x = 2
	elseif snake.pos.y >= ysize then
		snake.pos.y = 2
	elseif snake.pos.x <= 1 then
		snake.pos.x = xsize-1
	elseif snake.pos.y <= 1 then
		snake.pos.y = ysize-1
	end
	if snake.pos.x == item.pos.x and snake.pos.y == item.pos.y then
		score = score+1
		item.exist = false
		addtail()
	end
	local segment = snake.next
	while segment do
		if segment.pos.y == snake.pos.y and segment.pos.x == snake.pos.x then
			quit = true
			break
		else
			segment = segment.next 
		end
	end
end
function main()
	createfield()
	while exitgame ~= true do
		playeractions()
		snakemove()
		tfx.clear()
		init()
		rendersnake()
		if item.exist == false then
			spawnitem()
		end
		renderitem()
		printfield()
		tfx.present()
		if quit == true then
			local evt = tfx.pollevent()
			if evt then
				exitgame = true
				tfx.shutdown()
			end
		end
	end
end
main()
