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

# Add non root user
RUN adduser -D -g '' appuser
USER appuser

EXPOSE 8080
CMD ["./vyosexporter"] 