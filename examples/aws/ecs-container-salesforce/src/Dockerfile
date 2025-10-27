FROM python:3.12-slim AS runtime

ARG AEMBIT_TENANT_ID
# Set Python to run in unbuffered/production mode
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

 # Create app dir and non-root user
WORKDIR /app

# --- Python deps installed into a venv as root (no --user) ---
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# Copy only requirements first for better layer caching
COPY requirements.txt .
RUN pip install -r requirements.txt

RUN curl "https://${AEMBIT_TENANT_ID}.aembit.io/api/v1/root-ca" -o "/usr/local/share/ca-certificates/aembit_root.crt"
RUN update-ca-certificates

RUN addgroup --system app && adduser --system --ingroup app --home /app app
USER app

# Copy your script(s)
COPY --chown=app:app whoami.py .

# Default envs (override in ECS Task Definition)
ENV SF_INSTANCE_URL="https://pwstest-dev-ed.my.salesforce.com" \
    SF_ACCESS_TOKEN="aembitManaged" \
    SF_API_VERSION="62.0" \
    PATH="/app/.local/bin:${PATH}"

# Run the script (override with CMD in task def if needed)
CMD ["python", "/app/whoami.py"]
