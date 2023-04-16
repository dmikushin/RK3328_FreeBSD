# Pass --bootstrap-toolchain to tools/build/make.py to build the in-tree LLVM and use it for the cross-build.
# This more closely matches building natively on FreeBSD (where the in-tree LLVM is used unless it is the same
# version as the existing system build of the in-tree LLVM).
FROM ubuntu:22.04 AS bootstrap_toolchain

ENV DEBIAN_FRONTEND noninteractive
ENV TARGET arm64
ENV TARGET_ARCH aarch64

RUN apt update && apt install --yes --no-install-recommends \
	git \
	ca-certificates \
	python3

WORKDIR /
RUN git clone https://github.com/dmikushin/freebsd-rk3328.git /host-objtop

RUN apt update && apt install --yes --no-install-recommends \
	clang \
	bzip2 \
	gzip \
	xz-utils \
	patch \
	time \
	libncurses-dev \
	libarchive-dev

WORKDIR /host-objtop
RUN MAKEOBJDIRPREFIX=/ python3 tools/build/make.py --bootstrap-toolchain kernel-toolchain TARGET=${TARGET} TARGET_ARCH=${TARGET_ARCH} -j8

RUN find /host-objtop/tmp -name "*.o" -delete

# Create another slice for building and copy the bootstrapped toolchain into it
FROM ubuntu:22.04 AS building

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install --yes --no-install-recommends \
	bzip2 \
	gzip \
	xz-utils \
	patch \
	time \
	libncurses-dev \
	libarchive-dev \
	vim \
	mc

RUN mkdir /host-objtop

COPY --from=bootstrap_toolchain /host-objtop/tmp/ /host-objtop/tmp/

ENV PATH="/host-objtop/tmp/legacy/bin:/host-objtop/tmp/usr/bin:$PATH"
ENV MAKEOBJDIRPREFIX=/freebsd/obj
ENV TARGET arm64
ENV TARGET_ARCH aarch64
ENV KERNCONF RK3328

WORKDIR /freebsd

CMD ["sh", "-c", "mkdir -p /freebsd/obj/freebsd/${TARGET}.${TARGET_ARCH} && ln -sf /host-objtop/tmp /freebsd/obj/freebsd/${TARGET}.${TARGET_ARCH}/tmp && make buildkernel TARGET=${TARGET} TARGET_ARCH=${TARGET_ARCH} KERNCONF=${KERNCONF} NOCLEAN=YES -j8"]

