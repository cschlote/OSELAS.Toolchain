
# How-to-Compile for Vahanus OSELAS-Toolchain mod

(Last updates 05.12.2024, csc)

This is a modification of the OSELAS-Toolchain. It adds minor modification to the
upstream version:

- There were some extra configurations for a Cortex-A5 optimized toolchains.
- Added some more useful targets to build_all_v2.mk
- Small changes to build scripts to get it working in the GitLab CI
- ...

Some of the changes might be useful for upstream. Maybe I find some time and
motivation to setup the mail tools and to post the relevant changes to upstream.

## Host OS

### Debian/Ubuntu

- Install a recent Ubuntu or Debian version - any GUI flavour possible
- Install the following packages (dependancies to build ptxdist):

```sh
$ apt-get install aptitude mc gedit geany joe \
   git-all autoconf libncurses5-dev flex bison texinfo \
   python-dev g++ fakeroot lzop default-jdk
```

### Arch/Manjaro

- Install a recent Arch/Manjaro version - any GUI flavour possible
- Install the following packages (dependancies to build ptxdist):

```sh
$ pamac install \
   git-all autoconf libncurses5-dev flex bison texinfo \
   python-dev g++ fakeroot lzop default-jdk
```

## How to compile

- Checkout sources for toolchain, and update the git submodule for the embedded ptxdist repository:

```sh
$ git clone $repoUrlOfThisRepo
$ git submodule init
...
```

- Compile the reference ptxdist in the git submodule:

```sh
$ ./build_all_v2.mk compile-ptxd
$ ./build_all_v2.mk help
...
```

This will output the known targets to make, and the known targets for the cross compiler toolchains.

- Build all toolchains in a row, cleaning build files inbetween:

```sh
$ export BEQUIET={true|false}  # The default is 'false' and very chatty
$ ./build_all_v2.mk clean \
 dist/oselas.toolchain-2013.12.2-arm-cortexm3-eabi-gcc-4.8.2-newlib-2.0.0-binutils-2.24_2013.12.2_amd64.deb
$ ./build_all_v2.mk clean \
 dist/oselas.toolchain-2013.12.2-arm-v7a-linux-gnueabi-gcc-4.8.3-glibc-2.18-binutils-2.24-kernel-3.12-sanitized_2013.12.2_amd64.deb
$ ./build_all_v2.mk clean \
 dist/oselas.toolchain-2013.12.2-arm-v7a-linux-gnueabihf-gcc-4.8.3-glibc-2.18-binutils-2.24-kernel-3.12-sanitized_2013.12.2_amd64.deb
$ ./build_all_v2.mk clean
```

- Install the toolchains:

```sh
$ dpkg -i dist/*.deb
...
```

- To remove all generated files:

```sh
$ ./build_all_v2.mk distclean
...
```

(Copy the debian packages to a safe place, if you intend to re-use them for further installations)

# Open Issues

- Some changes should be sent to upstream
- Missing ARCH packages.
- Building all needs lots of space!
