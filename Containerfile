ARG FEDORA_MAJOR_VERSION="41"

FROM scratch AS ctx
COPY / /

## sarkinite image section
FROM ghcr.io/ublue-os/kinoite-main:${FEDORA_MAJOR_VERSION} AS base

ARG AKMODS_FLAVOR="coreos-stable"
ARG FEDORA_MAJOR_VERSION="41"
ARG IMAGE_NAME="sarkinite"
ARG IMAGE_VENDOR="garcialnk"
ARG KERNEL="6.10.10-200.fc40.x86_64"
ARG SHA_HEAD_SHORT="dedbeef"
ARG UBLUE_IMAGE_TAG="stable"
ARG VERSION=""

# Build, cleanup, commit.
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build-base.sh
