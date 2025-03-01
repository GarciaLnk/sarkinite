ARG FEDORA_MAJOR_VERSION

FROM scratch AS ctx
COPY / /

FROM ghcr.io/ublue-os/kinoite-main:${FEDORA_MAJOR_VERSION} AS base

ARG AKMODS_FLAVOR
ARG FEDORA_MAJOR_VERSION
ARG IMAGE_NAME
ARG IMAGE_VENDOR
ARG KERNEL
ARG SHA_HEAD_SHORT
ARG IMAGE_TAG
ARG VERSION

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build-base.sh
