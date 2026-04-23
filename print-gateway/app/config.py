from __future__ import annotations

import os
from dataclasses import dataclass


def _env(name: str, default: str | None = None) -> str:
    value = os.getenv(name)
    if value is None:
        if default is None:
            raise RuntimeError(f"Missing required env var: {name}")
        return default
    return value


def _env_int(name: str, default: int) -> int:
    raw = os.getenv(name)
    if raw is None:
        return default
    return int(raw)

def _env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    raw = raw.strip().lower()
    if raw in ("1", "true", "yes", "y", "on"):
        return True
    if raw in ("0", "false", "no", "n", "off"):
        return False
    raise RuntimeError(f"Invalid boolean env var {name}={raw!r}")

def _env_opt_int(name: str) -> int | None:
    raw = os.getenv(name)
    if raw is None:
        return None
    raw = raw.strip()
    if raw == "":
        return None
    return int(raw)


@dataclass(frozen=True)
class Config:
    bind: str
    printer_ip: str
    printer_model: str
    dpi: int
    label_height_mm: int
    cut_compensation_mm: int
    crop_top_mm: int
    crop_bottom_mm: int
    trim_threshold: int
    trim_pad_px: int
    fit_mode: str
    vertical_fit: str
    side_padding_mm: int
    brother_label: str

    backend: str
    printer_uri: str

    dry_run: bool
    cut_mode: str
    feed_margin_dots: int | None


def load_config() -> Config:
    printer_ip = _env("PG_PRINTER_IP")
    backend = os.getenv("PG_BACKEND", "network").strip() or "network"
    printer_uri_raw = os.getenv("PG_PRINTER_URI")
    printer_uri = (printer_uri_raw.strip() if printer_uri_raw else "") or f"tcp://{printer_ip}:9100"

    return Config(
        bind=os.getenv("PG_BIND", "0.0.0.0:8089"),
        printer_ip=printer_ip,
        printer_model=os.getenv("PG_PRINTER_MODEL", "QL-810W"),
        dpi=_env_int("PG_DPI", 300),
        label_height_mm=_env_int("PG_LABEL_HEIGHT_MM", 30),
        cut_compensation_mm=_env_int("PG_CUT_COMPENSATION_MM", 0),
        crop_top_mm=_env_int("PG_CROP_TOP_MM", 0),
        crop_bottom_mm=_env_int("PG_CROP_BOTTOM_MM", 0),
        trim_threshold=_env_int("PG_TRIM_THRESHOLD", 245),
        trim_pad_px=_env_int("PG_TRIM_PAD_PX", 2),
        fit_mode=(os.getenv("PG_FIT_MODE", "width_fill").strip() or "width_fill"),
        vertical_fit=(os.getenv("PG_VERTICAL_FIT", "center_pad").strip() or "center_pad"),
        side_padding_mm=_env_int("PG_SIDE_PADDING_MM", 0),
        brother_label=os.getenv("PG_BROTHER_LABEL", "50"),
        backend=backend,
        printer_uri=printer_uri,
        dry_run=_env_bool("PG_DRY_RUN", False),
        cut_mode=(os.getenv("PG_CUT_MODE", "autocut").strip() or "autocut"),
        feed_margin_dots=_env_opt_int("PG_FEED_MARGIN_DOTS"),
    )
