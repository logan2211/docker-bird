FROM debian:stable-slim

RUN mkdir /run/bird

RUN apt-get update && \
    apt-get install -y iproute2 bird2 && \
    rm -rf /var/lib/apt/lists/* /var/log/*

EXPOSE 179/tcp

ENTRYPOINT ["/usr/sbin/bird", "-f"]