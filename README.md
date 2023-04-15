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
docker run -it --rm -v ${KERNSRC}:/freebsd-rk3328 rk3328-freebsd-builder
```

The container will execute the build and release the resulting `kernel.bin` to `${KERNSRC}/obj`.
