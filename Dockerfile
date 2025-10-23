# Stage 1: Build the static library with Rust *1.87*
FROM rust:1.87.0-slim-bullseye AS builder

ARG RELEASE=true
ARG STRIP=false

ENV CARGO_FLAGS=${RELEASE:+--release}
ENV TARGET_DIR=target/${RELEASE:+release}
ENV TARGET_DIR=${TARGET_DIR:-target/debug}

COPY . /app
WORKDIR /app

RUN cargo build -p rustlib ${CARGO_FLAGS}
# Copy library to a clean location
RUN cp "${TARGET_DIR}/librustlib.a" /librustlib.a
RUN if [ "$STRIP" = "true" ]; then ./strip.sh /librustlib.a; fi

# Export the library so we can copy it via `--target=export --output=path`
FROM scratch AS export
COPY --from=builder /librustlib.a /librustlib.a

# Stage 2: Build and link the caller with Rust 1.90
FROM rust:1.90-slim-bullseye

ARG RELEASE=true
ENV CARGO_FLAGS=${RELEASE:+--release}
ENV TARGET_DIR=${RELEASE:+target/release}
ENV TARGET_DIR=${TARGET_DIR:-target/debug}

COPY . /app
WORKDIR /app

# Copy the built static library from the first stage
RUN mkdir -p ${TARGET_DIR}
COPY --from=export /librustlib.a ${TARGET_DIR}/librustlib.a

RUN cargo build -p caller ${CARGO_FLAGS}