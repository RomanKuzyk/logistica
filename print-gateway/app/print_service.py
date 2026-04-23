from __future__ import annotations

import tempfile
import logging

import httpx
from PIL import Image
import pypdfium2 as pdfium

from brother_ql.labels import LabelsManager

from .brother_backend import send_to_brother
from .config import Config

logger = logging.getLogger(__name__)


def _mm_to_px(mm: int, dpi: int) -> int:
    return int(round(mm / 25.4 * dpi))


def _label_printable_width_dots(label_id: str) -> int:
    lm = LabelsManager()
    for label in lm.iter_elements():
        if label.identifier == label_id:
            # dots_printable are defined for 300dpi
            return int(label.dots_printable[0])
    raise ValueError(f"Unknown Brother label id: {label_id!r}")


def _render_first_page(pdf_bytes: bytes, dpi: int) -> Image.Image:
    # pypdfium2 найстабільніше працює з шляхом до файлу (Linux/Windows/Alpine нюанси).
    with tempfile.NamedTemporaryFile(suffix=".pdf") as fp:
        fp.write(pdf_bytes)
        fp.flush()

        pdf = pdfium.PdfDocument(fp.name)
        page = pdf[0]
        try:
            # scale 1.0 -> 72dpi. we want dpi.
            scale = dpi / 72.0
            bitmap = page.render(scale=scale).to_pil()
        finally:
            try:
                page.close()
            except Exception:
                pass
            try:
                pdf.close()
            except Exception:
                pass

    if bitmap.mode not in ("RGB", "L"):
        bitmap = bitmap.convert("RGB")
    return bitmap


def _crop_vertical_mm(
    img: Image.Image,
    *,
    top_mm: int,
    bottom_mm: int,
    dpi: int,
) -> Image.Image:
    if top_mm <= 0 and bottom_mm <= 0:
        return img

    top_px = _mm_to_px(max(0, top_mm), dpi)
    bottom_px = _mm_to_px(max(0, bottom_mm), dpi)

    if top_px + bottom_px >= img.height - 1:
        return img

    return img.crop((0, top_px, img.width, img.height - bottom_px))


def _trim_whitespace(img: Image.Image, *, threshold: int, pad_px: int) -> Image.Image:
    """
    Обрізає порожні (майже білі) поля навколо контенту, щоб при зміні `out_h`
    ми менше "ламали масштаб" (не зменшували barcode), а забирали саме whitespace.
    """
    rgb = img.convert("RGB")
    gray = rgb.convert("L")
    # mask: True where pixel is "ink"
    ink = gray.point(lambda x: 255 if x < threshold else 0, mode="L")
    bbox = ink.getbbox()
    if not bbox:
        return rgb

    left, top, right, bottom = bbox
    left = max(0, left - pad_px)
    top = max(0, top - pad_px)
    right = min(rgb.width, right + pad_px)
    bottom = min(rgb.height, bottom + pad_px)
    return rgb.crop((left, top, right, bottom))


def _scale_to_width(img: Image.Image, out_w: int) -> Image.Image:
    img = img.convert("RGB")
    if img.width == out_w:
        return img
    scale = out_w / float(img.width)
    out_h = max(1, int(round(img.height * scale)))
    return img.resize((out_w, out_h), Image.Resampling.LANCZOS)


def _scale_to_box(img: Image.Image, out_w: int, out_h: int) -> Image.Image:
    """
    Пропорційно масштабує під box (out_w x out_h), без crop.
    Результат завжди має розмір out_w x out_h (centered on white canvas).
    """
    img = img.convert("RGB")
    if img.width <= 0 or img.height <= 0:
        return Image.new("RGB", (out_w, out_h), (255, 255, 255))

    scale = min(out_w / float(img.width), out_h / float(img.height))
    new_w = max(1, int(round(img.width * scale)))
    new_h = max(1, int(round(img.height * scale)))
    resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)

    canvas = Image.new("RGB", (out_w, out_h), (255, 255, 255))
    x = (out_w - new_w) // 2
    y = (out_h - new_h) // 2
    canvas.paste(resized, (x, y))
    return canvas


def _pad_or_crop_height(img: Image.Image, out_h: int) -> Image.Image:
    img = img.convert("RGB")
    if img.height == out_h:
        return img

    if img.height > out_h:
        # center-crop vertically
        top = (img.height - out_h) // 2
        return img.crop((0, top, img.width, top + out_h))

    canvas = Image.new("RGB", (img.width, out_h), (255, 255, 255))
    y = (out_h - img.height) // 2
    canvas.paste(img, (0, y))
    return canvas


def _fit_height(img: Image.Image, out_h: int, *, mode: str) -> Image.Image:
    img = img.convert("RGB")
    mode = (mode or "center_pad").strip().lower()
    if mode not in ("center_pad", "stretch"):
        raise ValueError("PG_VERTICAL_FIT must be one of: center_pad, stretch")

    if img.height == out_h:
        return img

    if mode == "stretch":
        # Non-uniform scale (Y only) to match the requested height without
        # touching X (barcode quiet zones stay intact).
        return img.resize((img.width, out_h), Image.Resampling.LANCZOS)

    if img.height > out_h:
        top = (img.height - out_h) // 2
        return img.crop((0, top, img.width, top + out_h))

    canvas = Image.new("RGB", (img.width, out_h), (255, 255, 255))
    y = (out_h - img.height) // 2
    canvas.paste(img, (0, y))
    return canvas


def _paste_center(canvas_w: int, canvas_h: int, img: Image.Image, *, x: int, y: int) -> Image.Image:
    canvas = Image.new("RGB", (canvas_w, canvas_h), (255, 255, 255))
    canvas.paste(img, (x, y))
    return canvas


async def print_pdf_from_url(cfg: Config, pdf_url: str) -> None:
    async with httpx.AsyncClient(timeout=60, follow_redirects=True) as client:
        resp = await client.get(pdf_url)
        resp.raise_for_status()
        pdf_bytes = resp.content

    if cfg.dpi != 300:
        raise ValueError("Only PG_DPI=300 is supported for Brother QL (for now).")

    render = _render_first_page(pdf_bytes, dpi=cfg.dpi)
    cropped = _crop_vertical_mm(
        render,
        top_mm=cfg.crop_top_mm,
        bottom_mm=cfg.crop_bottom_mm,
        dpi=cfg.dpi,
    )
    out_w = _label_printable_width_dots(cfg.brother_label)
    effective_h_mm = max(1, cfg.label_height_mm - cfg.cut_compensation_mm)
    out_h = _mm_to_px(effective_h_mm, cfg.dpi)

    trimmed = _trim_whitespace(
        cropped,
        threshold=cfg.trim_threshold,
        pad_px=cfg.trim_pad_px,
    )
    fit_mode = (cfg.fit_mode or "width_fill").strip().lower()
    if fit_mode not in ("width_fill", "contain"):
        raise ValueError("PG_FIT_MODE must be one of: width_fill, contain")

    pad_px = _mm_to_px(max(0, cfg.side_padding_mm), cfg.dpi)
    if pad_px * 2 >= out_w:
        pad_px = 0

    if fit_mode == "contain":
        scaled = _scale_to_box(trimmed, out_w=out_w, out_h=out_h)
        label_img = scaled
    else:
        effective_w = out_w - (pad_px * 2)
        scaled = _scale_to_width(trimmed, out_w=effective_w)
        fitted = _fit_height(scaled, out_h=out_h, mode=cfg.vertical_fit)
        if pad_px > 0:
            label_img = _paste_center(out_w, out_h, fitted, x=pad_px, y=0)
        else:
            label_img = fitted

    logger.info(
        "print_job: label=%s dpi=%s target_h_mm=%s cut_comp_mm=%s effective_h_mm=%s out_dots=%sx%s "
        "render=%sx%s crop_mm=%s+%s cropped=%sx%s trim_thr=%s trim_pad=%s trimmed=%sx%s "
        "side_pad_mm=%s pad_px=%s scaled=%sx%s fit=%s vfit=%s dry_run=%s cut_mode=%s feed_margin_dots=%s url=%s",
        cfg.brother_label,
        cfg.dpi,
        cfg.label_height_mm,
        cfg.cut_compensation_mm,
        effective_h_mm,
        label_img.width,
        label_img.height,
        render.width,
        render.height,
        cfg.crop_top_mm,
        cfg.crop_bottom_mm,
        cropped.width,
        cropped.height,
        cfg.trim_threshold,
        cfg.trim_pad_px,
        trimmed.width,
        trimmed.height,
        cfg.side_padding_mm,
        pad_px,
        scaled.width,
        scaled.height,
        cfg.fit_mode,
        cfg.vertical_fit,
        cfg.dry_run,
        cfg.cut_mode,
        cfg.feed_margin_dots,
        pdf_url,
    )

    if cfg.dry_run:
        return

    send_to_brother(cfg=cfg, image=label_img)
