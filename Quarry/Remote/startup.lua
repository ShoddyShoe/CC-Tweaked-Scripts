turtleID = 4
rednet.open('back')
print("Pairing...")
sleep(1)
function pair() 
    repeat
        sleep(1) 
        rednet.send(turtleID, os.getComputerID(), "Remote Pair!") 
    until paired
end
parallel.waitForAny(pair, rednet.receive)
paired = true
term.clear()
term.setCursorPos(1,1)
print("Turtle Paired!\n")
sleep(2)
repeat
    if not debugMode then
        posY = 4
        term.clear()
        term.setCursorPos(1,1)
        print("Controls:\nForward   | W\nBackward  | S\nTurn Left | A\nTurn Right| D\nGo Up     | Spacebar\nGo Down   | Left Shift\nDig       | Tab\nQuit      | Backspace") 
    end
    local event, key, is_held = os.pullEvent("key")
    key = keys.getName(key)
    if key == 'grave' then
        term.clear()
        term.setCursorPos(1,1)
        debugMode = debugMode == false and true or false
    end 
    if debugMode then
        print(key)
        for i = 1, 3, 1 do
            term.setCursorPos(1, i)
            term.clearLine()
        end
        term.setCursorPos(1,1)
        write("Press Grave/Tilde (`/~) to exit Debug Mode")
        term.setCursorPos(1, posY)
        posY = posY > 19 and 20 or posY + 1
    end
    rednet.send(turtleID, key)
until key == "backspace"
term.clear()
term.setCursorPos(1,1)
print("Connection Lost...\n\nPress Enter to re-pair.")
read()
os.reboot()
