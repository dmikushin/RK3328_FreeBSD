# FreeBSD building toolchain in Docker container

The idea is to have the FreeBSD building toolchain that can be called to compile the user-provided FreeBSD kernel source in Linux.

## Prerequisites

Build the toolchain Docker container:


```
docker build -t rk3328-freebsd-builder .
```

## Usage

Invoke the container with your FreeBSD kernel source tree path provided in ${KERNSRC} mounted to the volume:

```
docker run --rm -v ${KERNSRC}:/freebsd rk3328-freebsd-builder
```

The container will execute the build and release the resulting `kernel.bin` to `${KERNSRC}/obj`:

```
cp ./ThirdParty/freebsd-rk3328/obj/freebsd/arm64.aarch64/sys/RK3328/kernel.bin kernel.bin
```

