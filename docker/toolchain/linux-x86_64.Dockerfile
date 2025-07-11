# syntax=docker/dockerfile:1.4
FROM rust:1.82.0 AS base

# Install dependencies
RUN apt-get update && apt-get install -y \
    musl-tools \
    libssl-dev \
    pkg-config \
    protobuf-compiler \
    ca-certificates \
    git-lfs \
    musl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install musl targets
RUN rustup target add x86_64-unknown-linux-musl

# Set environment variables
ENV CARGO_INCREMENTAL=0 \
    RUSTFLAGS="--cfg tokio_unstable" \
    CARGO_NET_GIT_FETCH_WITH_CLI=true

# Set working directory
WORKDIR /build

# Build for x86_64
FROM base AS x86_64-builder

# Set up OpenSSL for x86_64 musl target
ENV SSL_VER=1.1.1w
RUN wget https://www.openssl.org/source/openssl-$SSL_VER.tar.gz \
    && tar -xzf openssl-$SSL_VER.tar.gz \
    && cd openssl-$SSL_VER \
    && ./Configure no-shared no-async --prefix=/musl --openssldir=/musl/ssl linux-x86_64 \
    && make -j$(nproc) \
    && make install_sw \
    && cd .. \
    && rm -rf openssl-$SSL_VER*

# Configure OpenSSL env vars for the build
ENV OPENSSL_DIR=/musl \
    OPENSSL_INCLUDE_DIR=/musl/include \
    OPENSSL_LIB_DIR=/musl/lib \
    PKG_CONFIG_ALLOW_CROSS=1

# Copy the source code
COPY . .

# Build for Linux with musl (static binary) - x86_64
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/build/target \
    cargo build --bin rivet --release --target x86_64-unknown-linux-musl -v && \
    mkdir -p /artifacts && \
    cp target/x86_64-unknown-linux-musl/release/rivet /artifacts/rivet-x86_64-unknown-linux-musl

# Default command to show help
CMD ["ls", "-la", "/artifacts"]