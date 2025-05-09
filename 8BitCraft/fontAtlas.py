from PIL import Image, ImageDraw, ImageFont

FONT_PATH = "FiraCode-Regular.ttf"
FONT_SIZE = 8
CHARS = "@%#*+=-:. "
PADDING = 0
COLUMNS = len(CHARS)
char_width = FONT_SIZE
char_height = FONT_SIZE
img_width = COLUMNS * (char_width + PADDING)
img_height = char_height
img = Image.new("RGBA", (img_width, img_height), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)
font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
for i, char in enumerate(CHARS):
    x = i * (char_width + PADDING)
    y = 0
    draw.text((x, y), char, font=font, fill=(255, 255, 255, 255))
img = img.resize((img_width * 4, img_height * 4), Image.NEAREST)
img.save("ascii.png")