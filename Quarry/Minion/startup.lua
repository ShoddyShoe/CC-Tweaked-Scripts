rednet.open('left')
leader = peripheral.wrap('back')
leaderID = leader.getID()
local message, command
rednet.send(leaderID, "ready!")
id, command, message = rednet.receive()
if command == "Update!" then
    shell.execute("update", tostring(id))
end
if command == "Fuel!" then
    turtle.refuel(64)
    rednet.send(leaderID, "Fueled!")
    os.shutdown()
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
    turtle.dig()
    turtle.turnLeft()
    turtle.turnLeft()
    if turtle.inspect() then
        repeat
            turtle.dig()
            sleep(0.5)
        until not turtle.inspect()
    end
    if i ~= tonumber(dist) then
        turtle.turnRight()
        turtle.dig()
        sleep(0.5)
        if turtle.inspect() then
            repeat
                turtle.dig()
                sleep(0.5)
            until not turtle.inspect()
        end
        turtle.forward()
    end
end
turtle.turnLeft()
for i = dist, 2, -1
do
    turtle.forward()
end
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
else
    turtle.forward()
end  
turtle.turnLeft()
repeat 
    turtle.forward()
    i, j = turtle.inspect() 
until i and j['name'] == "computercraft:turtle_advanced"
turtle.turnRight()
for i = 1, 16, 1 do
    turtle.select(i)
    turtle.drop()
end
rednet.send(leaderID, "Done!")