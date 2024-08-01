rednet.open('left')
turtle.dig()
turtles = ...
for i = 1, tonumber(turtles), 1 do
    turtle.select(i)
    turtle.place()
    sleep(0.5)
    local child = peripheral.wrap('front')
    child.turnOn()
    rednet.receive()
    rednet.send(child.getID(), "Update!")
    rednet.receive()
    turtle.dig()
end
fs.delete('startup.lua')
shell.execute('wget', 'https://raw.githubusercontent.com/ShoddyShoe/CC-Tweaked-Scripts/main/Quarry/Leader/startup.lua')
print("All Turtles Updated!\nPress Enter to reboot.")
read()
os.reboot()
