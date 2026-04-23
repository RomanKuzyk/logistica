from __future__ import annotations

import logging

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, HttpUrl

from .config import load_config
from .print_service import print_pdf_from_url

cfg = load_config()

logging.basicConfig(level=logging.INFO)

app = FastAPI(title="GlobalCars Print Gateway", version="0.1.0")


@app.get("/healthz")
def healthz() -> dict:
    return {"ok": True}


class PdfUrlJob(BaseModel):
    pdfUrl: HttpUrl


@app.post("/v1/print/pdf-url")
async def print_pdf_url(job: PdfUrlJob) -> dict:
    try:
        await print_pdf_from_url(
            cfg=cfg,
            pdf_url=str(job.pdfUrl),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e
    return {"ok": True}
