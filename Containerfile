ARG FEDORA_MAJOR_VERSION
FROM ghcr.io/ublue-os/kinoite-main:${FEDORA_MAJOR_VERSION} AS base

ARG AKMODS_FLAVOR
ARG FEDORA_MAJOR_VERSION
ARG IMAGE_NAME
ARG IMAGE_VENDOR
ARG KERNEL
ARG SHA_HEAD_SHORT
ARG IMAGE_TAG
ARG VERSION

COPY system_files /
COPY build_scripts /var/tmp/build_scripts

RUN --mount=type=tmpfs,dst=/tmp \
    /var/tmp/build_scripts/build-base.sh
