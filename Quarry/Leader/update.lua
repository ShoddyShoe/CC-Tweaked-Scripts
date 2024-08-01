rednet.open('left')
code, turtles = ...
turtles = tonumber(turtles)
turtle.dig()
for i = 1, turtles, 1 do
    turtle.select(i)
    turtle.place()
    sleep(1)
    local child = peripheral.wrap('front')
    child.turnOn()
    rednet.receive()
    rednet.send(child.getID(), code, "Update!")
    rednet.receive()
    turtle.dig()
end
print("All Turtles Updated!\nPress Enter to reboot.")
read()
os.reboot()
