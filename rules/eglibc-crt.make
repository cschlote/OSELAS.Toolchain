# -*-makefile-*-
# $Id$
#
# Copyright (C) 2006 by Robert Schwebel <r.schwebel@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_EGLIBC_CRT) += eglibc-crt

#
# Paths and names
#
EGLIBC_CRT_DIR	= $(BUILDDIR)/$(EGLIBC)-crt-build

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-crt.get: $(STATEDIR)/eglibc.get
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-crt.extract: $(STATEDIR)/eglibc.extract
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

EGLIBC_CRT_PATH := PATH=$(CROSS_PATH)
EGLIBC_CRT_ENV := \
	BUILD_CC=$(HOSTCC) \
	\
	ac_cv_path_GREP=grep \
	ac_cv_sizeof_long_double=$(PTXCONF_SIZEOF_LONG_DOUBLE) \
	libc_cv_c_cleanup=yes \
	libc_cv_forced_unwind=yes


#
# autoconf
#
EGLIBC_CRT_AUTOCONF = $(EGLIBC_AUTOCONF)

$(STATEDIR)/eglibc-crt.prepare:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_CRT_DIR))
	mkdir -p $(EGLIBC_CRT_DIR)
	cd $(EGLIBC_CRT_DIR) && eval \
		$(EGLIBC_CRT_PATH) $(EGLIBC_CRT_ENV) \
		$(EGLIBC_DIR)/configure $(EGLIBC_CRT_AUTOCONF)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-crt.compile:
	@$(call targetinfo)
	cd $(EGLIBC_CRT_DIR) && $(EGLIBC_CRT_PATH) \
		$(MAKE) $(PARALLELMFLAGS) csu/subdir_lib
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-crt.install:
	@$(call targetinfo)
	mkdir -p $(SYSROOT)/usr/lib
	for file in {S,}crt1.o crt{i,n}.o; do \
		$(INSTALL) -m 644 $(EGLIBC_CRT_DIR)/csu/$$file \
			$(SYSROOT)/usr/lib/$$file || exit 1; \
	done
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-crt.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eglibc-crt_clean:
	rm -rf $(STATEDIR)/eglibc-crt.*
	rm -rf $(EGLIBC_CRT_DIR)

# vim: syntax=make
