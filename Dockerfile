FROM debian:stable-slim AS builder

ARG BIRD_VERSION="3.0.1"
ARG BIRD_URL="https://bird.network.cz/download/bird-${BIRD_VERSION}.tar.gz"

RUN set -eux \
    && apt-get update -qyy \
    && apt-get install -qyy --no-install-recommends --no-install-suggests \
        ca-certificates \
        wget \
        build-essential \
        flex \
        bison \
        libncurses-dev \
        libreadline-dev \
        libssh-dev \
    && rm -rf /var/lib/apt/lists/* /var/log/* \
    \
    && wget -O bird.tar.gz ${BIRD_URL} \
    && tar -xzvf bird.tar.gz -C /usr/src/ \
    && rm -rf bird.tar.gz

RUN set -eux \
    && cd /usr/src/bird-${BIRD_VERSION}/ \
    && ./configure \
        --prefix=/usr/ \
        --sysconfdir=/etc/bird/ \
        --runstatedir=/run/bird \
        --enable-libssh \
    && make -j $(nproc) \
    && make install \
    && { find /usr/sbin/bird* -type f -executable -exec strip --strip-all "{}" +; }

######

FROM debian:stable-slim

COPY --from=builder /usr/sbin/bird* /usr/sbin/
COPY --from=builder /etc/bird/ /etc/bird/

RUN set -eux \
    && apt-get update -qyy \
    && apt-get install -qyy --no-install-recommends --no-install-suggests \
        iproute2 \
        libtinfo6 \
        libreadline8 \
        libssh-4 \
        iproute2 iputils-ping traceroute \
    && rm -rf /var/lib/apt/lists/* /var/log/* \
    && mkdir -p /run/bird

EXPOSE 179/tcp

CMD ["bird", "-f"]
