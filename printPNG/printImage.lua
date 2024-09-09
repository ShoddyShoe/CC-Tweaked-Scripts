-- Find connected monitor
local monitor = peripheral.find("monitor")
if not monitor then
    print("No monitor found!")
    return
end

-- Set up monitor size
monitor.setTextScale(0.5)
monitor.clear()

-- Define ComputerCraft colors
local cc_colors = {
    [1] = colors.white,
    [2] = colors.orange,
    [3] = colors.magenta,
    [4] = colors.lightBlue,
    [5] = colors.yellow,
    [6] = colors.lime,
    [7] = colors.pink,
    [8] = colors.gray,
    [9] = colors.lightGray,
    [10] = colors.cyan,
    [11] = colors.purple,
    [12] = colors.blue,
    [13] = colors.brown,
    [14] = colors.green,
    [15] = colors.red,
    [16] = colors.black,
}

-- Function to draw the image from a file and center it on the screen
local function drawImageFromFile(file_path)
    -- Open the file
    local file = fs.open(file_path, "r")
    if not file then
        print("Failed to open image file!")
        return
    end

    -- Read image dimensions
    local width, height = string.match(file.readLine(), "(%d+) (%d+)")
    width = tonumber(width)
    height = tonumber(height)

    -- Get monitor size
    local monitor_width, monitor_height = monitor.getSize()

    -- Calculate the top-left corner position for centering the image
    local start_x = math.floor((monitor_width - width) / 2) + 1
    local start_y = math.floor((monitor_height - height) / 2) + 1

    -- Read and draw each pixel row
    for y = 1, height do
        local row = file.readLine()
        local pixels = {}
        for color in string.gmatch(row, "%d+") do
            table.insert(pixels, tonumber(color))
        end

        -- Draw row of pixels on the monitor
        for x = 1, width do
            monitor.setCursorPos(start_x + (x - 1), start_y + (y - 1))
            monitor.setBackgroundColor(cc_colors[pixels[x]])
            monitor.write(" ")  -- Draw a block of the selected color
        end
    end

    file.close()
end

-- Example usage:
drawImageFromFile("output_image.txt")
