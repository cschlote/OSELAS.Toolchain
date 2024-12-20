# -*-makefile-*-

#
# just quote removal
#
PTXCONF_TOOLCHAIN_CONFIG_SYSROOT		:= $(call remove_quotes, $(PTXCONF_TOOLCHAIN_CONFIG_SYSROOT))
PTXCONF_TOOLCHAIN_CONFIG_MULTILIB		:= $(call remove_quotes, $(PTXCONF_TOOLCHAIN_CONFIG_MULTILIB))

PTXCONF_GLIBC_HEADERS_FAKE_CROSS		:= $(call remove_quotes, $(PTXCONF_GLIBC_HEADERS_FAKE_CROSS))
PTXCONF_GLIBC_CONFIG_EXTRA			:= $(call remove_quotes, $(PTXCONF_GLIBC_CONFIG_EXTRA))
PTXCONF_GLIBC_CONFIG_EXTRA_CROSS		:= $(call remove_quotes, $(PTXCONF_GLIBC_CONFIG_EXTRA_CROSS))

PTXCONF_CROSS_GCC_CONFIG_EXTRA			:= $(call remove_quotes, $(PTXCONF_CROSS_GCC_CONFIG_EXTRA))
PTXCONF_CROSS_GCC_CONFIG_LIBC			:= $(call remove_quotes, $(PTXCONF_CROSS_GCC_CONFIG_LIBC))
PTXCONF_CROSS_GCC_CONFIG_CXA_ATEXIT		:= $(call remove_quotes, $(PTXCONF_CROSS_GCC_CONFIG_CXA_ATEXIT))
PTXCONF_CROSS_GCC_CONFIG_SJLJ_EXCEPTIONS	:= $(call remove_quotes, $(PTXCONF_CROSS_GCC_CONFIG_SJLJ_EXCEPTIONS))
PTXCONF_CROSS_GCC_CONFIG_LIBSSP			:= $(call remove_quotes, $(PTXCONF_CROSS_GCC_CONFIG_LIBSSP))
PTXCONF_CROSS_GCC_CONFIG_SHARED			:= $(call remove_quotes, $(PTXCONF_CROSS_GCC_CONFIG_SHARED))
PTXCONF_PREFIX_CROSS				:= $(call remove_quotes, $(PTXCONF_PREFIX_CROSS))

PTXCONF_ARCH					:= $(call remove_quotes, $(PTXCONF_ARCH))

#
# namespace cleanup
#
PTX_TOUPLE_TARGET				:= $(PTXCONF_GNU_TARGET)

PTX_HOST_CROSS_AUTOCONF_HOST			:= --host=$(GNU_HOST)
PTX_HOST_CROSS_AUTOCONF_BUILD			:= --build=$(GNU_HOST)
PTX_HOST_CROSS_AUTOCONF_TARGET			:= --target=$(PTX_TOUPLE_TARGET)

PTX_HOST_AUTOCONF_PREFIX			:= --prefix=
PTX_HOST_CROSS_AUTOCONF_PREFIX			:= --prefix=$(PTXCONF_PREFIX_CROSS)

PTX_HOST_AUTOCONF := \
	$(PTX_HOST_AUTOCONF_HOST) \
	$(PTX_HOST_AUTOCONF_PREFIX)

PTX_HOST_CROSS_AUTOCONF := \
	$(PTX_HOST_CROSS_AUTOCONF_BUILD) \
	$(PTX_HOST_CROSS_AUTOCONF_HOST) \
	$(PTX_HOST_CROSS_AUTOCONF_TARGET) \
	$(PTX_HOST_CROSS_AUTOCONF_PREFIX)

#
# overwrite to remove rpath
#
PTXDIST_HOST_LDFLAGS				:= -L${PTXDIST_PATH_SYSROOT_HOST_PREFIX}/lib

TOOLCHAIN_WORKSPACE_SYMLINK := $(subst $(PTXDIST_WORKSPACE),,$(call ptx/sh, realpath $(PTXDIST_WORKSPACE)))

define ptx/toolchain-map
$(1)=$(2) $(if $(TOOLCHAIN_WORKSPACE_SYMLINK),$(call ptx/sh, realpath $(1))=$(2))
endef

TOOLCHAIN_CROSS_DEBUG_MAP := \
	$(call ptx/toolchain-map,$(BUILDDIR)) \
	$(call ptx/toolchain-map,$(CROSS_BUILDDIR)) \
	$(call ptx/toolchain-map,$(PTXDIST_SYSROOT_CROSS))

PTXDIST_HOST_CPPFLAGS := \
	$(PTXDIST_HOST_CPPFLAGS) \
	$(addprefix -fdebug-prefix-map=,$(TOOLCHAIN_CROSS_DEBUG_MAP))

TOOLCHAIN_CROSS_DEBUG_FLAGS := \
	-O2 \
	-g3 \
	-gno-record-gcc-switches

define ptx/toolchain-cross-debug-map
$(if $(PTXCONF_TOOLCHAIN_DEBUG),$(call ptx/toolchain-map,$($(strip $(1))_DIR),$(PTXCONF_PREFIX_CROSS)/src/$($(strip $(1))))) \
$(TOOLCHAIN_CROSS_DEBUG_MAP)
endef
define ptx/toolchain-cross-debug-flags
$(TOOLCHAIN_CROSS_DEBUG_FLAGS) \
$(addprefix -ffile-prefix-map=,$(call ptx/toolchain-cross-debug-map,$(1)))
endef

#
# gcc-first
#
CROSS_GCC_FIRST_PREFIX	:= $(PTXDIST_PLATFORMDIR)/sysroot-target
CROSS_PATH		:= $(PTXDIST_SYSROOT_HOST)/usr/lib/wrapper:$(PTXDIST_SYSROOT_CROSS)$(PTXCONF_PREFIX_CROSS)/bin:$(subst $(PTXDIST_SYSROOT_HOST)/usr/lib/wrapper:,,$(PATH))
HOST_CROSS_PATH		:= $(CROSS_PATH)

#
# images
#

PTX_TOOLCHAIN_HOST_ARCH	:= $(shell uname -m)
ifeq ($(PTX_TOOLCHAIN_HOST_ARCH),x86_64)
PTX_TOOLCHAIN_HOST_ARCH	:= amd64
endif
ifeq ($(patsubst i%86,,$(PTX_TOOLCHAIN_HOST_ARCH)),)
PTX_TOOLCHAIN_HOST_ARCH	:= i386
endif
ifeq ($(PTX_TOOLCHAIN_HOST_ARCH),ppc)
PTX_TOOLCHAIN_HOST_ARCH	:= powerpc
endif

# vim: syntax=make
