FROM debian:stable-slim

RUN mkdir /run/bird

RUN apt-get update && \
    apt-get install -y bird2 iproute2 iputils-ping traceroute && \
    rm -rf /var/lib/apt/lists/* /var/log/*

EXPOSE 179/tcp

ENTRYPOINT ["/usr/sbin/bird", "-f"]
