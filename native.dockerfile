FROM python:3.12-trixie AS builder
LABEL previous-stage=builder

RUN apt update && apt install -y sudo docbook2x m4 build-essential autoconf flex bison libtool autopoint pkg-config libzstd-dev libssl-dev xxhash wget curl libssl-dev libtinfo-dev libreadline-dev libgmp-dev libmpfr-dev libexpat-dev liblzma-dev libffi-dev libbz2-dev libgdbm-dev libdb-dev uuid-dev

# We require aiohttp >= 3.12 (For client middleware support), which is newer than the currently
# available python3-aiohttp's version in Ubuntu.
RUN python3 -m pip install --break-system-packages aiohttp

RUN mkdir -p /build/ && mkdir -p /source/

COPY . /build/

RUN /build/src/compilation/build_native.sh  /build/  /source/

RUN strip  /build/packages/binutils-gdb/build-host-full/gdbserver/gdbserver

RUN strip  /build/packages/binutils-gdb/build-host-full/gdb/gdb

FROM busybox:latest

COPY --from=builder /build/packages/binutils-gdb/build-host-full/gdbserver/gdbserver  /opt/
COPY --from=builder /build/packages/binutils-gdb/build-host-full/gdb/gdb  /opt/

CMD ["/bin/bash"]
