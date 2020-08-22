FROM alpine AS builder-base
# General Build System:
RUN apk update && apk upgrade && \
        apk -U add \
        git \
        build-base \
        autoconf \
        automake \
        libtool \
        dbus \
        su-exec \
        alsa-lib-dev \
        libdaemon-dev \
        popt-dev \
        mbedtls-dev \
        soxr-dev \
        avahi-dev \
        libconfig-dev \
        libsndfile-dev \
        pulseaudio-dev \
        mosquitto-dev \
        xmltoman

# ALAC Build System:
FROM builder-base AS builder-alac

RUN 	git clone https://github.com/mikebrady/alac
WORKDIR alac
RUN 	autoreconf -fi
RUN 	./configure
RUN 	make
RUN 	make install

# Shairport Sync Build System:
FROM 	builder-base AS builder-sps

# This may be modified by the Github Action Workflow.
ARG SHAIRPORT_SYNC_BRANCH=master

COPY 	--from=builder-alac /usr/local/lib/libalac.* /usr/local/lib/
COPY 	--from=builder-alac /usr/local/lib/pkgconfig/alac.pc /usr/local/lib/pkgconfig/alac.pc
COPY 	--from=builder-alac /usr/local/include /usr/local/include

RUN 	git clone https://github.com/mikebrady/shairport-sync
WORKDIR shairport-sync
RUN 	git checkout "$SHAIRPORT_SYNC_BRANCH"
RUN 	autoreconf -fi
RUN 	./configure \
              --with-alsa \
              --with-dummy \
              --with-pipe \
              --with-pa \
              --with-stdout \
              --with-avahi \
              --with-ssl=mbedtls \
              --with-soxr \
              --sysconfdir=/etc \
              --with-mqtt-client \
              --with-apple-alac \
              --with-convolution
RUN 	make -j $(nproc)
RUN 	make install

# Shairport Sync Runtime System:
FROM 	alpine

RUN 	apk update && apk upgrade && \
        apk add \
              alsa-lib \
              popt \
              glib \
              mbedtls \
              soxr \
              avahi \
              libconfig \
              libsndfile \
              libpulse \
              mosquitto-libs \
              libgcc \
              libgc++ && \
        rm -rf  /lib/apk/db/* && \
        addgroup -g 1000 shairport-sync && \
        adduser -D -u 1000 -G shairport-sync shairport-sync && \
        addgroup shairport-sync audio

COPY 	--from=builder-alac /usr/local/lib/libalac.* /usr/local/lib/
COPY 	--from=builder-sps /etc/shairport-sync* /etc/
COPY 	--from=builder-sps /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

CMD ["usr/local/bin/shairport-sync"]

