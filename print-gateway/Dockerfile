FROM python:3.12-slim

WORKDIR /app

# system deps (pdf render + image)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY app /app/app

ENV PYTHONUNBUFFERED=1

EXPOSE 8089
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8089"]

