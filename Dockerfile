# ---------------------------------------------------
# Stage 1: Build the application binary
# ---------------------------------------------------
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy dependency definitions and application source
COPY go.mod ./
COPY main.go ./

# Compile a purely static binary
# CGO_ENABLED=0 prevents dynamic linking against the host C library (musl/glibc)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server .

# ---------------------------------------------------
# Stage 2: Final Distroless Runtime
# ---------------------------------------------------
# The :nonroot tag runs as an unprivileged user (UID 65532)
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/server /app/server

# Expose the application port
EXPOSE 8080

# Execute the binary directly (JSON exec form is required; no shell exists to parse strings)
ENTRYPOINT ["/app/server"]