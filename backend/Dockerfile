FROM python:3.10-slim

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Usar entrypoint.sh para inicializar la BD e iniciar Django
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
