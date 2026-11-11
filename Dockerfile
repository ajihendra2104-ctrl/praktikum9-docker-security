
FROM python:3.12-slim

# 1. Mengatur environment Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Memperbarui package sistem operasi untuk keamanan
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Menggunakan direktori aplikasi khusus
WORKDIR /app

# 3. Menyalin dependency terlebih dahulu
COPY requirements.txt .

# 4. Instalasi dependency tanpa cache
RUN pip install --no-cache-dir -r requirements.txt

# 5. Membuat user non-root
RUN useradd --no-create-home --shell /usr/sbin/nologin appuser

# 6. Menyalin aplikasi dengan kepemilikan user
COPY --chown=appuser:appuser app.py .

# 7. Mengatur permission file dan direktori
RUN chown appuser:appuser /app && \
    chmod 500 /app && \
    chmod 400 /app/app.py

# 8. Menjalankan aplikasi sebagai non-root
USER appuser

# 9. Mendokumentasikan port aplikasi
EXPOSE 5000

# 10. Memeriksa kesehatan aplikasi
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health')"

# 11. Menggunakan exec form
CMD ["python", "app.py"]
