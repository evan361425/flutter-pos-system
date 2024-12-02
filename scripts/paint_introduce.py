import os

from PIL import Image, ImageDraw, ImageFont


def pp(file):
    return os.path.join(os.path.dirname(__file__), file)


langs = [
    {"folder": "zh-TW", "titles": ["分析訂單", "點餐", "庫存系統"], "suffix": ".zh"},
    {"folder": "en-US", "titles": ["Analysis", "Checkout", "Inventory"], "suffix": ""},
]

for lang in langs:
    folder = lang["folder"]
    folder = pp(
        f"../android/fastlane/metadata/android/{folder}/images/phoneScreenshots"
    )
    space = 60

    images = [
        Image.open(f"{folder}/{x}")
        for x in ["1_analysis_chart.png", "4_order_action.png", "7_inventory.png"]
    ]
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
    for text, im in zip(lang["titles"], images):
        x, y, w, h = draw.textbbox(xy=(0, 0), text=text, font=font)
        draw.text(
            (x_offset + im.size[0] // 2 - w // 2, im.size[1] + 10),
            text,
            (220, 53, 69),
            font=font,
        )
        x_offset += im.size[0] + space

    suffix = lang["suffix"]
    new_im.save(os.path.join(pp(f"../docs/images/index-introduction{suffix}.png")))
