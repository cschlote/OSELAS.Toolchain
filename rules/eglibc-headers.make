# -*-makefile-*-
# $Id$
#
# Copyright (C) 2006 by Robert Schwebel
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_EGLIBC_HEADERS) += eglibc-headers

#
# Paths and names
#
EGLIBC_HEADERS_DIR	= $(BUILDDIR)/$(EGLIBC)-headers-build

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-headers.get: $(STATEDIR)/eglibc.get
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-headers.extract: $(STATEDIR)/eglibc.extract
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

EGLIBC_HEADERS_PATH := PATH=$(CROSS_PATH)
#
# these various env variables are necessary, because we are using the host compiler
# it doesn't matter if we define ppc stuff during arm build
# they aren't tested :)
# no ifdefs for simplicity
#
EGLIBC_HEADERS_ENV  := \
	$(HOST_ENV) \
	CC="$${CC} $(PTXCONF_EGLIBC_HEADERS_FAKE_CROSS)" \
	\
	libc_cv_asm_symver_directive=yes \
	libc_cv_asm_protected_directive=yes \
	libc_cv_visibility_attribute=yes \
	libc_cv_broken_visibility_attribute=no \
	libc_cv_broken_alias_attribute=no \
	libc_cv_initfini_array=yes \
	libc_cv_z_nodelete=yes \
	libc_cv_z_nodlopen=yes \
	libc_cv_z_initfirst=yes \
	libc_cv_gcc___thread=yes \
	\
	libc_cv_386_tls=yes \
	\
	libc_cv_arm_tls=yes \
	\
	libc_cv_mips_tls=yes \
	libc_cv_have_sdata_section=yes \
	\
	libc_cv_powerpc32_tls=yes \
	libc_cv_powerpc64_tls=yes \
	libc_cv_mlong_double_128ibm=set \
	libc_cv_mlong_double_128=set \
	libc_cv_ppc_machine=yes \
	\
	ac_cv_path_GREP=grep

#
# autoconf
#
EGLIBC_HEADERS_AUTOCONF = \
	$(EGLIBC_AUTOCONF_COMMON) \
	\
	--enable-hacker-mode

$(STATEDIR)/eglibc-headers.prepare:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_HEADERS_DIR))
	mkdir -p $(EGLIBC_HEADERS_DIR)
	cd $(EGLIBC_HEADERS_DIR) && \
		$(EGLIBC_HEADERS_PATH) $(EGLIBC_HEADERS_ENV) \
		$(EGLIBC_DIR)/configure $(EGLIBC_HEADERS_AUTOCONF)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-headers.compile:
	@$(call targetinfo)
	cd $(EGLIBC_HEADERS_DIR) && \
		$(EGLIBC_HEADERS_PATH) $(EGLIBC_HEADERS_ENV) \
		$(MAKE) sysdeps/gnu/errlist.c

	mkdir -p $(EGLIBC_HEADERS_DIR)/stdio-common
	touch $(EGLIBC_HEADERS_DIR)/stdio-common/errlist-compat.c
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-headers.install:
	@$(call targetinfo)
	cd $(EGLIBC_HEADERS_DIR) && \
		$(EGLIBC_HEADERS_PATH) $(EGLIBC_HEADERS_ENV) \
		$(MAKE) cross_compiling=yes install_root=$(SYSROOT) install-headers

	mkdir -p $(SYSROOT)/usr/include/gnu
	touch $(SYSROOT)/usr/include/gnu/stubs.h

	cp $(EGLIBC_DIR)/include/features.h $(SYSROOT)/usr/include/features.h
	cp $(EGLIBC_HEADERS_DIR)/bits/stdio_lim.h $(SYSROOT)/usr/include/bits/stdio_lim.h
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-headers.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eglibc-headers_clean:
	rm -rf $(STATEDIR)/eglibc-headers.*
	rm -rf $(EGLIBC_HEADERS_DIR)

# vim: syntax=make
