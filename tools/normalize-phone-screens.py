from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]


def normalize(directory: Path) -> None:
    for path in sorted(directory.glob("*.jpg"), key=lambda item: int(item.stem)):
        with Image.open(path) as source:
            image = source.convert("RGB")
            if image.size == (720, 1434):
                continue
            if image.size != (660, 1434):
                raise ValueError(f"Unexpected phone screenshot size: {path} {image.size}")

            canvas = Image.new("RGB", (720, 1434))
            # Extend a narrow strip from each existing background edge. This
            # preserves every UI pixel while bringing the image within Play's
            # 2:1 maximum long-edge ratio.
            left = image.crop((0, 0, 5, image.height)).resize((30, image.height))
            right = image.crop((image.width - 5, 0, image.width, image.height)).resize((30, image.height))
            canvas.paste(left, (0, 0))
            canvas.paste(image, (30, 0))
            canvas.paste(right, (690, 0))
            canvas.save(path, "JPEG", quality=95, optimize=True, progressive=True)


normalize(ROOT / "assets" / "screens")
normalize(ROOT / "assets" / "screens-en")

for feature_name in (
    "feature-graphic-zh-cn-1024x500.png",
    "feature-graphic-en-1024x500.png",
):
    feature_path = ROOT / "assets" / feature_name
    with Image.open(feature_path) as feature:
        if feature.mode != "RGB":
            feature.convert("RGB").save(feature_path, "PNG", optimize=True)
