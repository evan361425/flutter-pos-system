import os
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont


def pp(file):
    return os.path.join(os.path.dirname(__file__), file)


folder = pp(
    "../android/fastlane/metadata/android/zh-TW/images/phoneScreenshots",
)
space = 60

images = [
    Image.open("%s/%s" % (folder, x))
    for x in ["2_menu_product.png", "3_order.png", "5_stock.png"]
]
textList = ["設定產品", "點餐", "庫存系統"]
widths, heights = zip(*(i.size for i in images))

# with space between images and around
total_width = sum(widths) + (len(images) - 1) * space + space
max_height = max(heights)

# more space for text
new_im = Image.new("RGBA", (total_width, max_height + 100), (255, 0, 0, 0))

x_offset = space // 2
for im in images:
    new_im.paste(im, (x_offset, 0))
    x_offset += im.size[0] + space

draw = ImageDraw.Draw(new_im)
font = ImageFont.truetype(pp("Tra-Chi.ttf"), 50)
x_offset = space // 2
for text, im in zip(textList, images):
    w, h = draw.textsize(text, font=font)
    draw.text(
        (x_offset + im.size[0] // 2 - w // 2, im.size[1] + 10),
        text,
        (220, 53, 69),
        font=font,
    )
    x_offset += im.size[0] + space

new_im.save(os.path.join(pp("../docs/images/index-introduction.png")))
