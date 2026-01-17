# SPDX-License-Identifier: PMPL-1.0 OR Palimpsest-0.8
# SPDX-FileCopyrightText: 2025 hyperpolymath

FROM rust:1.85-slim-bookworm AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y \
    pkg-config \
    libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock* ./
COPY src/ src/
COPY benches/ benches/

RUN cargo build --release --bin bunsenite

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libreadline8 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/bunsenite /usr/local/bin/bunsenite

ENTRYPOINT ["bunsenite"]
CMD ["--help"]
