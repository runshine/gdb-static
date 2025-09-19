FROM python:3.12-trixie AS builder
LABEL previous-stage=builder

RUN apt update && apt install -y docbook2x m4 build-essential autoconf flex bison libtool autopoint pkg-config libzstd-dev libssl-dev xxhash wget curl sudo libssl-dev libtinfo-dev libreadline-dev

# We require aiohttp >= 3.12 (For client middleware support), which is newer than the currently
# available python3-aiohttp's version in Ubuntu.
RUN python3 -m pip install --break-system-packages aiohttp

RUN mkdir -p /build/

COPY . /build/

RUN /build/src/compilation/build_native.sh  /build/build  /build/source

FROM busybox:latest

COPY --from=builder /build/packages/binutils-gdb/build-host-full/gdbserver/gdbserver  /opt/
COPY --from=builder /build/packages/binutils-gdb/build-host-full/gdb/gdb  /opt/

CMD ["/bin/bash"]
