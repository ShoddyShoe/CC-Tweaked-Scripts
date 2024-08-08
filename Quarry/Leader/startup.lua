function Clear()
    term.clear()
    term.setCursorPos(1,1)
end
Clear()
turtle.select(1)
if turtle.getFuelLevel() < 1000 then
    repeat 
        sleep(0.5)
        Clear()
        print("Turtle Is Hungry! D:\nFuel: "..turtle.getFuelLevel().."/1000\n(Turtle likes to eat all wooden things, coal, and especially lava!)")
        if turtle.getItemCount() > 0 then
            local ok, err = turtle.refuel()
            if not ok then print("That's not a valid fuel source!")
        end end
    until turtle.getFuelLevel() > 999
end 
repeat
    Clear()
    write("Welcome to Shoddy's Mining Utility!\n\nFunctions:\n1: Start Quarry\n2: Update Children\n3: Feed Children\n4: Remote Control\n\nPick a function! (1/2/3/4):")
    choice = read()
until choice == "1" or choice == "2" or choice == "3" or choice == "4"
Clear()

--Remote Control
if choice == "4" then
    rednet.open('left')
    print("Waiting for remote to pair...")
    repeat id, remoteID, pair = rednet.receive() until pair == "Remote Pair!"
    rednet.send(remoteID, "Paired!")
    Clear()
    repeat
        posX, posY = term.getCursorPos()
        term.setCursorPos(1,1)
        write("Remote paired!\n\nDebug:")
        term.setCursorPos(posX, posY)
        id, control = rednet.receive()
        print(control)
        local controls = {w = turtle.forward, s = turtle.back, space = turtle.up, leftShift = turtle.down, a = turtle.turnLeft, d = turtle.turnRight, tab = turtle.dig}
        local action = controls[control]
        if action then action() end
    until control == "backspace"
    os.reboot()
end
--End of Remote Control

Clear()

--Turtle Check & Sort
function turtSort()
    Clear()
    print("Please add turtles to my inventory now.")
    print("Press enter when ready!")
    read()
    turtles = 0
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            if turtle.getItemDetail(i)["name"] == "computercraft:turtle_normal" then turtles = turtles + 1
            else
                term.clear()
                term.setCursorPos(1,1)
                print("Please remove",turtle.getItemDetail(i)["name"],"from slot", i)
                repeat sleep(0.2) until turtle.getItemCount(i) == 0
                print("Thank You!\n")
                sleep(0.5)
    end end end
    sorted = false
    term.clear()
    term.setCursorPos(1,1)
    write("Found "..turtles.." turtles, is this correct? (y/n):")
    if read():lower() == "n" then os.reboot() end
    term.clear()
    term.setCursorPos(1,1)
    print("Sorting Turtles...")
    repeat
    for i = 1, 16, 1 do
        turtle.select(i)
        if i == 16 then sorted = true end
        if turtle.getItemCount(i) > 0 then
            if tonumber(turtle.getItemDetail(i, true)["displayName"]) ~= i then
                if turtle.getItemCount(tonumber(turtle.getItemDetail(i, true)["displayName"])) then
                    turtle.transferTo(tonumber(turtle.getItemDetail(i, true)["displayName"]), 1) end
                for j = 16, 1, -1 do
                    if j ~= i and turtle.getItemCount(j) == 0 then
                        turtle.transferTo(j, 1)
                        break
    end end end end end
    until sorted
    print("Done!")
end
turtSort()
--End of Turtle Sorter

Clear()

--Turtle Fueling
if choice == "3" then
    repeat
    term.clear()
    term.setCursorPos(1,1)
    print("\nPlease place Charcoal/Coal in the 16th (last) slot.\n\nCoal will be distributed equally, make sure you have at least 1 coal for each turtle!\n\nPress Enter when fuel has been added to Turtle inventory.")
    read()
    str = turtle.getItemDetail(16)['name']
    until turtle.getItemDetail(16) and (str == "minecraft:coal" or str == "minecraft:charcoal" or str == "minecraft:coal_block") and turtle.getItemCount(16) > tonumber(turtles)-1
    rednet.open('left')
    turtle.dig()
    coalPerTurt = math.floor(turtle.getItemCount(16)/tonumber(turtles))
    for i = 1, turtles, 1 do
        turtle.select(i)
        turtle.place()
        sleep(0.5)
        local child = peripheral.wrap('front')
        turtle.select(16)
        turtle.drop(coalPerTurt)
        child.turnOn()
        rednet.receive()
        rednet.send(child.getID(), "Fuel!")
        rednet.receive()
        turtle.dig()
    end
    print("All Turtles Fueled!\nPress Enter to Reboot.")
    read()
    os.reboot()
end
--End of Child Ration Program

Clear()

--Update Program
if choice == "2" then
    print("Are You Sure You Want To Update The Children? (y/n)")
    if read():lower() == "y" then
        term.clear()
        term.setCursorPos(1,1)
        for i = 10, 0, -1 do
            print("TURN TURTLE OFF TO STOP UPDATE: ", i)
            sleep(1)
        end    
        shell.execute("update", tostring(turtles))
        shell.exit()
        sleep(1)
    end
end
--End of Child Update System

--Mining Program Setup
Swap = false
if choice == "1" then
    ::orientLoop::
    Clear()
    write("Make sure the turtle is placed in this orientation:\n" .. ("##########\n"):rep(4) .. Swap == true and "#########^" or "^#########" .. "\n\n^ = Turtle\n# = Blocks To Be Mined\n\nIs it in position? (y/n/swap): ")
    local confirm = read()
    if confirm:lower() == "swap" then 
        Swap = not Swap and true or false
        goto orientLoop
    elseif confirm:lower() ~= "y" then os.reboot() end
end
term.setCursorPos(1,1)
print("Please add 2 Chests to Slot 16 (Bottom Right)")
repeat sleep(0.2) until turtle.getItemDetail(16) and turtle.getItemDetail(16)["name"] == "minecraft:chest" and turtle.getItemCount(16) == 2
print("Thank You!")
sleep(1)
function dimensions()
    Clear()
    print("How far would you like each turtle to mine? (Blocks)")
    len = read()
    print("\nHow high would you like each turtle to mine? (Blocks)")
    height = read()
    print("\nThanks!")
    Clear()
    stacks = math.ceil(len*height*turtles*3/64)
    if stacks>45 then 
        print("WARNING: Estimated block count is greater than ".. tostring(stacks > 54 and "all" or "5/6") .." storage! (".. tostring(stacks < 10000 and stacks or ">999") .." Stacks)\n\n".. tostring(stacks > 54 and "The chest cannot store the estimated number of items and will overflow and items will be dropped on the ground!" or "If you are in an area with a high variety of blocks, some blocks/items may not fit in the chest!").."\n\nDimensions:\nLength: "..len.."\nHeight: "..height.."\nDepth: "..turtles*3 .." (3 Blocks Per Turtle)\n")
        write("Continue with these settings? (y/n): ")
        if read():lower() ~= "y" then dimensions() end
    end
end 
dimensions()
sleep(1)
Clear()
print("Starting Mining Program...\n")
sleep(1)
print("Please stand back! Starting In...")
sleep(1)
for i = 3, 1, -1 do
    print(i)
    sleep(1)
end
local function breakFalling()
    repeat
        turtle.dig()
        sleep(0.5)
    until not turtle.inspect() 
end
--End of Mining Program Setup

Clear()

--Mining Program
rednet.open('left')
turtle.digUp()
for i = 1, turtles, 1 do
    breakFalling()
    turtle.forward()
    turtle.digUp()
    if i == 1 then
        if swap then turtle.turnRight() else turtle.turnLeft() end
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        turtle.back()
        turtle.select(16)
        turtle.place()
        if swap then turtle.turnLeft() else turtle.turnRight() end
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        if swap then turtle.turnRight() else turtle.turnLeft() end
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        turtle.back()
        turtle.place()
        if swap then turtle.turnLeft() else turtle.turnRight() end
        turtle.back()
    end
    if swap then turtle.turnLeft() else turtle.turnRight() end
    breakFalling()
    turtle.select(i)
    turtle.place()
    if swap then turtle.turnRight() else turtle.turnLeft() end
    child = swap and peripheral.wrap("left") or peripheral.wrap("right")
    child.turnOn()
    rednet.receive()
    rednet.send(child.getID(), swap and "Swap!" or "false", len.."|"..height)
    if i ~= turtles then
        for i = 1, 2, 1 do
            breakFalling()
            turtle.forward()
            turtle.digUp()
        end
    else
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        turtle.up()
        turtle.back()
        turtle.back()
        for i = 0, turtles, 1 do
            turtle.back()
            turtle.back()
            turtle.back()
        end
        turtle.down()
    end
end
if swap then turtle.turnRight() else turtle.turnLeft() end
turtle.dig()
turtle.forward()
turtle.digUp()
if swap then turtle.turnLeft() else turtle.turnRight() end
for i = 1, 16, 1 do
    turtle.select(i)
    turtle.drop()
end
if swap then turtle.turnLeft() else turtle.turnRight() end
turtle.forward()
if swap then turtle.turnRight() else turtle.turnLeft() end
turtle.select(1)
for i = turtles, 1, -1 do
    rednet.receive()
    turtle.dig()
end
if swap then turtle.turnLeft() else turtle.turnRight() end
turtle.back()
