# Stage 1: Build the static library with Rust *1.87*
FROM rust:1.87.0-slim-bullseye AS builder

ARG RELEASE=true

COPY . /app
WORKDIR /app

RUN cargo build -p rustlib $(if [ "$RELEASE" = "true" ]; then echo "--release"; fi)

# Stage 2: Build and link the caller with Rust 1.90
FROM rust:1.90-slim-bullseye

ARG RELEASE=true

COPY . /app
WORKDIR /app

# Copy the built static library from the first stage
RUN mkdir -p target/$(if [ "$RELEASE" = "true" ]; then echo "release"; else echo "debug"; fi)
COPY --from=builder /app/target/ ./target/

RUN cargo build -p caller $(if [ "$RELEASE" = "true" ]; then echo "--release"; fi)