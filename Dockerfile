FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x /app/docker/entrypoint.sh
RUN mkdir -p /app/Media /app/staticfiles

EXPOSE 8000

ENTRYPOINT ["/app/docker/entrypoint.sh"]
