# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o vyosexporter

# Final stage
FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/vyosexporter .

# Add non root user and create necessary directories
RUN adduser -D -g '' appuser && \
    mkdir -p /proc/net && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

# Use environment variables with defaults
ENV ALLOWED_IPS=""
ENV PORT="8080"

# Create entrypoint script
RUN echo '#!/bin/sh\n\
exec ./vyosexporter --allowed-ips="$ALLOWED_IPS" --port="$PORT"' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Use JSON format with entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"] 