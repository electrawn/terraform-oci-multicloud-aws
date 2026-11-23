FROM python:3.11-slim AS builder

WORKDIR /build

COPY src/requirements.txt /tmp/requirements.txt
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir --prefix=/install -r /tmp/requirements.txt \
    && apt-get purge -y --auto-remove build-essential \
    && rm -rf /var/lib/apt/lists/*

FROM python:3.11-slim

ARG FUNCTION_SCRIPT=/function/src/func.py

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/function/src \
    FUNCTION_SCRIPT=${FUNCTION_SCRIPT}

WORKDIR /function

COPY --from=builder /install /usr/local

COPY src /function/src

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "exec fdk \"$FUNCTION_SCRIPT\" handler"]

