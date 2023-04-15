# Pass --bootstrap-toolchain to tools/build/make.py to build the in-tree LLVM and use it for the cross-build.
# This more closely matches building natively on FreeBSD (where the in-tree LLVM is used unless it is the same
# version as the existing system build of the in-tree LLVM).
FROM ubuntu:22.04 AS bootstrap_toolchain

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install --yes --no-install-recommends \
	git \
	ca-certificates \
	python3

WORKDIR /
RUN git clone https://github.com/dmikushin/freebsd-rk3328.git /freebsd-rk3328

RUN apt update && apt install --yes --no-install-recommends \
        clang \
	bzip2 \
	gzip \
	xz-utils \
	patch \
	time \
	libncurses-dev \
	libarchive-dev

WORKDIR /freebsd-rk3328
RUN MAKEOBJDIRPREFIX=/ python3 tools/build/make.py --bootstrap-toolchain kernel-toolchain TARGET=arm64 TARGET_ARCH=aarch64 -j8

RUN mkdir /host-objtop && \
	cp -rf /freebsd-rk3328/tmp /host-objtop/tmp && \
	find /host-objtop/tmp -name "*.o" -delete

# Create another slice for building and copy the bootstrapped toolchain into it
FROM ubuntu:22.04 AS building

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install --yes --no-install-recommends \
	vim \
	mc

RUN mkdir /host-objtop

COPY --from=bootstrap_toolchain /host-objtop/tmp/ /host-objtop/tmp/

ENV MAKEOBJDIRPREFIX=/freebsd-rk3328/obj

WORKDIR /freebsd-rk3328

CMD ["make", "buildkernel", "HOST_OBJTOP=/host-objtop", "TARGET=arm64", "TARGET_ARCH=aarch64", "KERNCONF=RK3328", "NOCLEAN=YES"]

