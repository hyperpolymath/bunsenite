# SPDX-License-Identifier: MPL-2.0
# ClusterFuzzLite build image for bunsenite.
#
# ClusterFuzzLite invokes `docker build -f .clusterfuzzlite/Dockerfile`,
# so this file must be named `Dockerfile`. It mirrors the OCI-neutral
# Containerfile in this directory (kept for podman-first local builds per
# the authority stack); keep the two in sync.
FROM gcr.io/oss-fuzz-base/base-builder-rust@sha256:73c1d5648db54100639339d411a5d192cbc8bf413ee91e843a07cf6f0e319dc7

# Copy only what the fuzz build reads, not the whole checkout: the crate
# manifest and lockfile, its sources and declared benches, the patched
# nickel-lang-vector crate, the fuzz crate, and this directory (build.sh
# reads per-target .options files from it).
COPY Cargo.toml Cargo.lock $SRC/bunsenite/
COPY src $SRC/bunsenite/src
COPY benches $SRC/bunsenite/benches
COPY crates $SRC/bunsenite/crates
COPY fuzz $SRC/bunsenite/fuzz
COPY .clusterfuzzlite $SRC/bunsenite/.clusterfuzzlite
WORKDIR $SRC/bunsenite

COPY .clusterfuzzlite/build.sh $SRC/
