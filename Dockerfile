ARG BASE_IMAGE="ubuntu:22.04"
FROM $BASE_IMAGE as build

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        build-essential \
        git \
        cmake \
        ca-certificates \
        libpam0g-dev \
        libssl-dev \
        libx11-dev \
        libxext-dev \
        ninja-build \
        yasm \
    && update-ca-certificates \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG TURBOJPEG_BRANCH=2.1.2
RUN cd /tmp \
    && git clone --depth=1 --branch ${TURBOJPEG_BRANCH} https://github.com/libjpeg-turbo/libjpeg-turbo.git \
    && cd libjpeg-turbo \
    && mkdir build \
    && cd build \
    && cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . -j $(nproc) \
    && cmake --install .

ARG TURBOVNC_BRANCH=2.2.7
RUN cd /tmp \
    && git clone --depth=1 --branch ${TURBOVNC_BRANCH} https://github.com/TurboVNC/turbovnc.git \
    && cd turbovnc \
    && mkdir build \
    && cd build \
    && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DTVNC_DLOPENSSL=0 -DTVNC_BUILDVIEWER=0 -DTVNC_BUILDSERVER=1 -DTVNC_BUILDJAVA=0 -DTVNC_BUILDWEBSERVER=0 .. \
    && cmake --build . -j $(nproc) \
    && cmake --install .


FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        libc6 \
        libssl3 \
        libx11-6 \
        libxext6 \
        xauth \
        xkb-data \
        x11-xkb-utils \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=build /opt/TurboVNC /opt/TurboVNC
