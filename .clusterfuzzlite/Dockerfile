# SPDX-License-Identifier: MPL-2.0
# ClusterFuzzLite build image for bunsenite.
#
# ClusterFuzzLite invokes `docker build -f .clusterfuzzlite/Dockerfile`,
# so this file must be named `Dockerfile`. It mirrors the OCI-neutral
# Containerfile in this directory (kept for podman-first local builds per
# the authority stack); keep the two in sync.
FROM gcr.io/oss-fuzz-base/base-builder-rust@sha256:73c1d5648db54100639339d411a5d192cbc8bf413ee91e843a07cf6f0e319dc7

COPY . $SRC/bunsenite
WORKDIR $SRC/bunsenite

COPY .clusterfuzzlite/build.sh $SRC/
