# SPDX-License-Identifier: AGPL-3.0-or-later
# ClusterFuzzLite build environment for bunsenite
FROM gcr.io/oss-fuzz-base/base-builder-rust

COPY . $SRC/bunsenite
WORKDIR $SRC/bunsenite

COPY .clusterfuzzlite/build.sh $SRC/
