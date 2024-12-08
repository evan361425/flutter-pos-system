import os

from PIL import Image, ImageDraw, ImageFont

LANGS = [
    {"folder": "zh-TW", "titles": ["分析訂單", "出單機", "庫存系統"], "suffix": ".zh"},
    {"folder": "en-US", "titles": ["Analysis", "Printer", "Inventory"], "suffix": ""},
]
FIRST_ROW_IMAGES = ["1_analysis_chart", "8_printer", "7_inventory"]
RWD_IMAGES = ["rwd", "4_order_action"]
SPACE = 60
FONT_ROW_HEIGHT = 100
RWD_PHONE_BELOW_OFFSET = 60


def pp(file):
    return os.path.join(os.path.dirname(__file__), file)


def open_img(folder: str, file: str) -> Image.Image:
    prefix = file.split("_")[0]
    try:
        int(prefix)
        f = f"../android/fastlane/metadata/android/{folder}/images/phoneScreenshots"
        return Image.open(pp(f"{f}/{file}.png"))
    except ValueError:
        f = f"../docs/images/lang/{folder}"
        return Image.open(pp(f"{f}/{file}.png"))


def resize_img(img: Image.Image, width: int = None, height: int = None) -> Image.Image:
    w, h = img.size
    if width is not None:
        h = h * width // w
        w = width
    if height is not None:
        w = w * height // h
        h = height
    return img.resize((w, h))


def main():
    for lang in LANGS:
        first_images = [open_img(lang["folder"], x) for x in FIRST_ROW_IMAGES]
        widths, heights = zip(*(i.size for i in first_images))

        # with space between images and around
        total_width = sum(widths) + (len(first_images) - 1) * SPACE + SPACE

        rwd_tablet, rwd_phone = [open_img(lang["folder"], x) for x in RWD_IMAGES]
        rwd_tablet = resize_img(rwd_tablet, width=int(total_width * 0.7))
        rwd_phone = resize_img(rwd_phone, height=int(rwd_tablet.height * 0.8))

        # two rows images
        y_second_offset = max(heights) + FONT_ROW_HEIGHT
        total_height = (
            y_second_offset
            + rwd_tablet.height
            + RWD_PHONE_BELOW_OFFSET
            + FONT_ROW_HEIGHT
        )

        new_im = Image.new("RGBA", (total_width, total_height), (255, 0, 0, 0))

        x_offset = SPACE // 2
        for im in first_images:
            new_im.paste(im, (x_offset, 0))
            x_offset += im.size[0] + SPACE
        new_im.paste(rwd_tablet, (int(total_width * 0.15), y_second_offset))
        new_im.paste(
            rwd_phone,
            (
                int(total_width * 0.9 - rwd_phone.width),
                int(y_second_offset + 0.2 * rwd_tablet.height + RWD_PHONE_BELOW_OFFSET),
            ),
        )

        draw = ImageDraw.Draw(new_im)
        font = ImageFont.truetype(pp("Tra-Chi.ttf"), 50)
        x_offset = SPACE // 2
        for text, im in zip(lang["titles"], first_images):
            w = draw.textbbox(xy=(0, 0), text=text, font=font)[2]
            draw.text(
                (x_offset + im.size[0] // 2 - w // 2, im.size[1] + 10),
                text,
                (220, 53, 69),
                font=font,
            )
            x_offset += im.size[0] + SPACE
        w = draw.textbbox(xy=(0, 0), text="Responsive Width Design", font=font)[2]
        draw.text(
            ((total_width - w) // 2, y_second_offset + rwd_tablet.height + 10),
            "Responsive Width Design",
            (220, 53, 69),
            font=font,
        )

        suffix = lang["suffix"]
        new_im.save(os.path.join(pp(f"../docs/images/index-introduction{suffix}.png")))


if __name__ == "__main__":
    main()
