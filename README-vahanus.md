
# How-to-Compile for OSELAS-Toolchain

(Last updates 10.07.2023, csc)

## Host OS

### Debian/Ubuntu
- Install a recent Ubuntu or Debian LTS version - any GUI flavour possible
- Install the following packages:
``` 
$ apt-get install aptitude mc gedit geany joe \
   git-all autoconf libncurses5-dev flex bison texinfo \
   python-dev g++ fakeroot lzop default-jdk
```
### Arch/Manjaro
- Install a recent Arch/Manjaro LTS version - any GUI flavour possible
- Install the following packages:
``` 
$ pamac install \
   git-all autoconf libncurses5-dev flex bison texinfo \
   python-dev g++ fakeroot lzop default-jdk
```

## How to compile

- Checkout sources for toolchain, and update the git submodule for the embedded ptxdist:
``` 
$ git clone $repoUrlOfThisRepo
$ git submodule init
``` 
- Compile the reference ptxdist in the git submodule:
``` 
$ ./build_all_v2.mk compile-ptxd
$ ./build_all_v2.mk help
``` 

- Build all toolchains in a row, cleaning build files inbetween:
``` 
$ ./build_all_v2.mk clean \
 dist/oselas.toolchain-2013.12.2-arm-cortexm3-eabi-gcc-4.8.2-newlib-2.0.0-binutils-2.24_2013.12.2_amd64.deb
$ ./build_all_v2.mk clean \
 dist/oselas.toolchain-2013.12.2-arm-v7a-linux-gnueabi-gcc-4.8.3-glibc-2.18-binutils-2.24-kernel-3.12-sanitized_2013.12.2_amd64.deb
$ ./build_all_v2.mk clean \
 dist/oselas.toolchain-2013.12.2-arm-v7a-linux-gnueabihf-gcc-4.8.3-glibc-2.18-binutils-2.24-kernel-3.12-sanitized_2013.12.2_amd64.deb
$ ./build_all_v2.mk clean
``` 

- Install the toolchains:
``` 
$ dpkg -i dist/*.deb
``` 

- To remove all generated files:
``` 
$ ./build_all_v2.mk distclean
``` 

(Copy the debian packages to a safe place, if you intend to re-use them for further installations)
