from PIL import Image


cc_colors = [
    (255, 255, 255),  # white
    (255, 128, 0),    # orange
    (255, 0, 255),    # magenta
    (0, 255, 255),    # light blue
    (255, 255, 0),    # yellow
    (0, 255, 0),      # lime
    (255, 192, 192),  # pink
    (128, 128, 128),  # gray
    (192, 192, 192),  # light gray
    (0, 255, 255),    # cyan
    (128, 0, 128),    # purple
    (0, 0, 255),      # blue
    (128, 64, 0),     # brown
    (0, 128, 0),      # green
    (255, 0, 0),      # red
    (0, 0, 0),        # black
]

def find_closest_color(r, g, b):
    min_dist = float('inf')
    closest_color_index = 0
    for i, (cr, cg, cb) in enumerate(cc_colors):
        dist = (cr - r) ** 2 + (cg - g) ** 2 + (cb - b) ** 2
        if dist < min_dist:
            min_dist = dist
            closest_color_index = i
    return closest_color_index + 1

def convert_image_to_cc_format(image_path, output_path):
    img = Image.open(image_path).convert('RGB')

    width, height = img.size

    with open(output_path, 'w') as file:
        file.write(f"{width} {height}\n")

        for y in range(height):
            row = []
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                closest_color = find_closest_color(r, g, b)
                row.append(str(closest_color))
            file.write(" ".join(row) + "\n")

    print(f"Image converted and saved to {output_path}")

convert_image_to_cc_format('input_image.png', 'output_image.txt')
