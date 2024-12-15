rednet.open('left')
if peripheral.wrap('front') then
    turtle.turnLeft()
    turtle.turnLeft()
end
leader = peripheral.wrap('back')
leaderID = leader.getID()
local message, command
rednet.send(leaderID, "ready!")
id, command, message = rednet.receive()
if command == "Update!" then shell.execute("update", tostring(id))
elseif command == "Fuel!" then
    turtle.refuel(64)
    rednet.send(leaderID, "Fueled!")
    os.shutdown()
elseif command == "Swap!" then Swap = true end

local function breakFalling()
    while turtle.detect() do
        turtle.dig()
        sleep(0.5)
    end
end
dist = message:sub(1,string.find(message,"|")-1)
height = message:sub(string.find(message,"|")+1)
print("Mining for "..dist.." blocks.")
for i = 1, dist, 1 do
    turtle.turnLeft()
    for i = height, 1, -1 do
        turtle.dig()
        if i ~= 1 then
            turtle.digUp()
            turtle.up()
        end
    end
    turtle.turnRight()
    turtle.turnRight()
    for i = height, 2, -1 do
        turtle.dig()
        turtle.down()
    end
    breakFalling()
    turtle.turnLeft()
    turtle.turnLeft()
    if turtle.detect() then breakFalling() end
    if turtle.getItemCount(13) ~= 0 then
        for i = 1, 16, 1 do
            if turtle.getItemDetail(i)["name"] == "minecraft:netherrack" then
                turtle.select(i)
                turtle.drop()
            end
        end
    end
    if i ~= tonumber(dist) then
        turtle.turnRight()
        turtle.dig()
        sleep(0.5)
        if turtle.detect() then breakFalling() end
        turtle.forward()
    end
end
turtle.turnLeft()
for i = dist, 2, -1 do turtle.forward() end
i, j = turtle.inspect()
if i and j['tags']['computercraft:turtle'] then
    repeat
        sleep(0.5)
        turtle.forward()
        i, j = turtle.inspect()
    until not i or not j['tags']['computercraft:turtle']
elseif i and not j['tags']['computercraft:turtle'] and j['name'] ~= 'minecraft:chest' then
    turtle.dig()
    turtle.forward()
else turtle.forward() end  
if Swap then turtle.turnRight() else turtle.turnLeft() end
repeat 
    turtle.forward()
    i, j = turtle.inspect() 
until i and j['name'] == "computercraft:turtle_advanced"
if Swap then turtle.turnLeft() else turtle.turnRight() end
for i = 1, 16, 1 do
    turtle.select(i)
    turtle.drop()
end
rednet.send(leaderID, "Done!")