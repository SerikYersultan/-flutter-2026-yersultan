"""Generate the app's original conversation illustration using stdlib only."""

from pathlib import Path
import struct
import zlib

WIDTH = 960
HEIGHT = 320

def rounded_box(x, y, left, top, right, bottom, radius):
    if not (left <= x <= right and top <= y <= bottom):
        return False
    center_x = min(max(x, left + radius), right - radius)
    center_y = min(max(y, top + radius), bottom - radius)
    return (x - center_x) ** 2 + (y - center_y) ** 2 <= radius ** 2

def pixel(x, y):
    progress = x / (WIDTH - 1)
    color = (
        int(32 + 20 * progress),
        int(58 + 24 * progress),
        int(86 + 30 * progress),
    )

    if (x - 780) ** 2 + (y - 40) ** 2 < 180 ** 2:
        color = (55, 101, 120)
    if (x - 200) ** 2 + (y - 340) ** 2 < 210 ** 2:
        color = (48, 83, 111)

    if rounded_box(x, y, 570, 52, 750, 155, 22):
        color = (222, 239, 239)
    if 595 <= x <= 620 and 155 < y <= 178 and x - 595 <= 178 - y:
        color = (222, 239, 239)

    if rounded_box(x, y, 715, 151, 902, 252, 22):
        color = (172, 211, 196)
    if 850 <= x <= 875 and 252 < y <= 275 and 875 - x <= 275 - y:
        color = (172, 211, 196)

    for center_x in (615, 660, 705):
        if (x - center_x) ** 2 + (y - 103) ** 2 <= 8 ** 2:
            color = (55, 101, 120)
    for center_x in (760, 805, 850):
        if (x - center_x) ** 2 + (y - 201) ** 2 <= 8 ** 2:
            color = (55, 101, 120)

    return bytes(color)

def chunk(kind, data):
    checksum = zlib.crc32(kind + data) & 0xFFFFFFFF
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", checksum)
    )

raw = bytearray()
for y in range(HEIGHT):
    raw.append(0)
    for x in range(WIDTH):
        raw.extend(pixel(x, y))

png = (
    b"\x89PNG\r\n\x1a\n"
    + chunk(b"IHDR", struct.pack(">IIBBBBB", WIDTH, HEIGHT, 8, 2, 0, 0, 0))
    + chunk(b"IDAT", zlib.compress(bytes(raw), level=9))
    + chunk(b"IEND", b"")
)

destination = (
    Path(__file__).resolve().parent.parent
    / "assets"
    / "images"
    / "session_header.png"
)
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_bytes(png)
print(f"Generated assets/images/session_header.png: {len(png)} bytes")
