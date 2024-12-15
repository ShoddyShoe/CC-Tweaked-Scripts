function Clear()
    term.clear()
    term.setCursorPos(1, 1)
end

Clear()
turtle.select(1)
if turtle.getFuelLevel() < 1000 then
    repeat
        sleep(0.5)
        Clear()
        print("Turtle Is Hungry! D:\nFuel: " ..
        turtle.getFuelLevel() .. "/1000\n(Turtle likes to eat all wooden things, coal, and especially lava!)")
        if turtle.getItemCount() > 0 then
            local ok, err = turtle.refuel()
            if not ok then
                print("That's not a valid fuel source!")
            end
        end
    until turtle.getFuelLevel() > 999
end
repeat
    Clear()
    write(
    "Welcome to Shoddy's Mining Utility!\n\nFunctions:\n1: Start Quarry\n2: Update Children\n3: Feed Children\n4: Remote Control\n\nPick a function! (1/2/3/4):")
    Choice = read()
until Choice == "1" or Choice == "2" or Choice == "3" or Choice == "4" or Choice == "5"
Clear()

--Remote Control
if Choice == "4" then
    rednet.open('left')
    print("Waiting for remote to pair...")
    repeat 
        _, RemoteID, Pair = rednet.receive()
    until Pair == "Remote Pair!"
    rednet.send(RemoteID, "Paired!")
    Clear()
    repeat
        local posX, posY = term.getCursorPos()
        term.setCursorPos(1, 1)
        write("Remote paired!\n\nDebug:")
        term.setCursorPos(posX, posY)
        local _, control = rednet.receive()
        print(control)
        local controls = { w = turtle.forward, s = turtle.back, space = turtle.up, leftShift = turtle.down, a = turtle
        .turnLeft, d = turtle.turnRight, tab = turtle.dig }
        local action = controls[control]
        if action then action() end
    until control == "backspace"
    os.reboot()
end
--End of Remote Control

Clear()

--Turtle Check & Sort
function TurtSort()
    Clear()
    print("Please add turtles to my inventory now.")
    print("Press enter when ready!")
    read()
    turtles = 0
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            if turtle.getItemDetail(i)["name"] == "computercraft:turtle_normal" then
                turtles = turtles + 1
            else
                term.clear()
                term.setCursorPos(1, 1)
                print("Please remove", turtle.getItemDetail(i)["name"], "from slot", i)
                repeat sleep(0.2) until turtle.getItemCount(i) == 0
                print("Thank You!\n")
                sleep(0.5)
            end
        end
    end
    term.clear()
    term.setCursorPos(1, 1)
    write("Found " .. turtles .. " turtles, is this correct? (y/n):")
    if read():lower() ~= "y" then os.reboot() end
    term.clear()
    term.setCursorPos(1, 1)
    print("Sorting Turtles...")
    repeat
        local sorted = true
        for i = 1, 16, 1 do
            if turtle.getItemCount(i) > 0 then
                local turtNum = tonumber(turtle.getItemDetail(i, true)["displayName"])
                if turtNum ~= i then
                    sorted = false
                    if turtle.getItemCount(turtNum) ~= 0 then
                        for j = 16, 1, -1 do
                            if turtle.getItemCount(j) == 0 then
                                turtle.select(turtNum)
                                turtle.transferTo(j, 1)
                                turtle.select(i)
                                turtle.transferTo(turtNum)
                                break
                            end
                        end
                    else
                        turtle.select(i)
                        turtle.transferTo(turtNum, 1)
                    end
                end
            end
        end
    until sorted
    print("Done!")
end

TurtSort()
--End of Turtle Sorter

Clear()

--Turtle Fueling
if Choice == "3" then
    repeat
        term.clear()
        term.setCursorPos(1, 1)
        print(
        "\nPlease place Charcoal/Coal in the 16th (last) slot.\n\nCoal will be distributed equally, make sure you have at least 1 coal for each turtle!\n\nPress Enter when fuel has been added to Turtle inventory.")
        read()
        local str = turtle.getItemDetail(16)['name']
    until turtle.getItemDetail(16) and (str == "minecraft:coal" or str == "minecraft:charcoal" or str == "minecraft:coal_block") and turtle.getItemCount(16) > tonumber(turtles) - 1
    rednet.open('left')
    turtle.dig()
    local coalPerTurt = math.floor(turtle.getItemCount(16) / tonumber(turtles))
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
if Choice == "2" then
    print("Are You Sure You Want To Update The Children? (y/n)")
    if read():lower() == "y" then
        Clear()
        for i = 5, 0, -1 do
            print("TURN TURTLE OFF TO STOP UPDATE: ", i)
            sleep(1)
        end
        shell.execute("update", tostring(turtles))
        shell.exit()
    end
end
--End of Child Update System

--Mining Program Setup
Swap = false
if Choice == "1" then
    ::orientLoop::
    Clear()
    write("Make sure the turtle is placed in this orientation:\n" ..
    ("##########\n"):rep(4) ..
    (Swap == true and "#########^" or "^#########") ..
    "\n\n^ = Turtle\n# = Blocks To Be Mined\n\nIs it in position? (y/n/swap): ")
    local confirm = read()
    if confirm:lower() == "swap" then
        Swap = not Swap and true or false
        goto orientLoop
    elseif confirm:lower() ~= "y" then
        os.reboot()
    end
end
Clear()
print("Please add 2 Chests to Slot 16 (Bottom Right)")
repeat sleep(0.2) until turtle.getItemDetail(16) and turtle.getItemDetail(16)["name"] == "minecraft:chest" and turtle.getItemCount(16) == 2
print("Thank You!")
sleep(1)
function Dimension()
    ::dimensionStart::
    Clear()
    write("How far would you like each turtle to mine? (Blocks): ")
    Len = read()
    write("\nHow high would you like each turtle to mine? (Blocks): ")
    Height = read()
    local stacks = math.ceil(Len * Height * turtles * 3 / 64)
    if stacks > 45 then
        write("WARNING: Estimated block count is greater than " ..
        tostring(stacks > 54 and "all" or "5/6") ..
        " storage! (" ..
        tostring(stacks < 10000 and stacks or ">999") ..
        " Stacks)\n\n" ..
        tostring(stacks > 54 and
        "The chest cannot store the estimated number of items and will overflow and items will be dropped on the ground!" or
        "If you are in an area with a high variety of blocks, some blocks/items may not fit in the chest!") ..
        "\n\nDimensions:\nLength: " ..
        Len ..
        "\nHeight: " .. Height ..
        "\nDepth: " .. turtles * 3 .. " (3 Blocks Per Turtle)\nContinue with these settings? (y/n): ")
        if read():lower() ~= "y" then goto dimensionStart end
    end
end

Dimension()
Clear()
print("Starting Mining Program...\n")
sleep(0.5)
print("Please stand back! Starting In...")
for i = 3, 1, -1 do
    sleep(0.5)
    print(i)
end
local function breakFalling()
    while turtle.detect() do
        turtle.dig()
        sleep(0.5)
    end
end
local function digdig()
    breakFalling()
    turtle.forward()
    if turtle.detectUp() then turtle.digUp() end
end
local function swapTurn(direction)
    if direction == "right" then
        if Swap then turtle.turnRight() else turtle.turnLeft() end
    elseif direction == "left" then
        if Swap then turtle.turnLeft() else turtle.turnRight() end
    end
end
local function place()
    swapTurn("right")
    digdig()
    turtle.back()
    turtle.place()
    swapTurn("left")
end
--End of Mining Program Setup

Clear()

--Mining Program
rednet.open('left')
turtle.digUp()
turtle.select(16)
place()
digdig()
place()
for i = 1, turtles, 1 do
    if i ~= 1 then
        digdig()
    end
    swapTurn("left")
    breakFalling()
    turtle.select(i)
    turtle.place()
    swapTurn("right")
    local child = Swap and peripheral.wrap("left") or peripheral.wrap("right")
    child.turnOn()
    rednet.receive()
    rednet.send(child.getID(), Swap and "Swap!" or "false", Len .. "|" .. Height)
    for _ = 1, (i == turtles and 1 or 2), 1 do digdig() end
end
turtle.turnLeft()
turtle.turnLeft()
repeat turtle.forward() until peripheral.hasType(Swap and "left" or "right", "inventory")
turtle.forward()
swapTurn("left")
for i = 1, 16, 1 do
    if turtle.getItemCount(i) ~= 0 then
        turtle.select(i)
        turtle.drop()
    end
end
swapTurn("left")
turtle.select(1)
for i = turtles, 1, -1 do
    rednet.receive()
    turtle.dig()
end
swapTurn("left")
turtle.up()
turtle.back()