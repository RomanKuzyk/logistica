from __future__ import annotations

import struct

from brother_ql.backends.helpers import send
from brother_ql.conversion import convert
from brother_ql.raster import BrotherQLRaster
from PIL import Image

from .config import Config


def _patch_feed_margin(instructions: bytes, feed_margin_dots: int) -> bytes:
    # ESC i d + <H dots>
    marker = b"\x1B\x69\x64"
    out = bytearray()
    i = 0
    while True:
        j = instructions.find(marker, i)
        if j == -1:
            out += instructions[i:]
            break
        out += instructions[i:j]
        out += marker
        out += struct.pack("<H", feed_margin_dots)
        i = j + len(marker) + 2
    return bytes(out)


def _patch_cut_at_end(instructions: bytes) -> bytes:
    # ESC i K + flags
    marker = b"\x1B\x69\x4B"
    out = bytearray(instructions)
    idx = 0
    while True:
        j = instructions.find(marker, idx)
        if j == -1:
            break
        flags_pos = j + len(marker)
        if flags_pos < len(out):
            out[flags_pos] = out[flags_pos] | 0x08  # cut_at_end bit
        idx = flags_pos + 1
    return bytes(out)


def send_to_brother(cfg: Config, image: Image.Image) -> None:
    qlr = BrotherQLRaster(cfg.printer_model)
    qlr.exception_on_warning = True

    cut_mode = (cfg.cut_mode or "autocut").lower()
    if cut_mode not in ("autocut", "cut_at_end"):
        raise ValueError("PG_CUT_MODE must be one of: autocut, cut_at_end")

    instructions = convert(
        qlr=qlr,
        images=[image],
        label=cfg.brother_label,
        rotate="auto",
        threshold=70,
        dither=False,
        compress=True,
        red=False,
        cut=(cut_mode == "autocut"),
    )

    if cut_mode == "cut_at_end":
        instructions = _patch_cut_at_end(instructions)

    if cfg.feed_margin_dots is not None:
        instructions = _patch_feed_margin(instructions, cfg.feed_margin_dots)

    send(
        instructions=instructions,
        backend_identifier=cfg.backend,
        printer_identifier=cfg.printer_uri,
        blocking=True,
    )
