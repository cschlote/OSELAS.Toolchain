# -*-makefile-*-
# $Id: template 6655 2007-01-02 12:55:21Z rsc $
#
# Copyright (C) 2006 by Robert Schwebel
#		2007, 2008 by Marc Kleine-Budde
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_EGLIBC_FIRST) += eglibc-first

#
# Paths and names
#
EGLIBC_FIRST_BUILDDIR	= $(BUILDDIR)/$(EGLIBC)-first-build

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-first.get: $(STATEDIR)/eglibc.get
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-first.extract: $(STATEDIR)/eglibc.extract
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

EGLIBC_FIRST_PATH := PATH=$(CROSS_PATH)
EGLIBC_FIRST_ENV := \
	CC=$(CROSS_CC) \
	CXX=false \
	BUILD_CC=$(HOSTCC) \
	\
	libc_cv_c_cleanup=yes \
	libc_cv_forced_unwind=yes \
	libc_cv_fpie=yes \
	libc_cv_ssp=yes \
	libc_cv_visibility_attribute=yes \
	libc_cv_broken_visibility_attribute=no \
	libc_cv_z_relro=yes \
	\
	ac_cv_sizeof_long_double=$(PTXCONF_SIZEOF_LONG_DOUBLE)

EGLIBC_FIRST_MAKEVARS := AUTOCONF=no

EGLIBC_FIRST_AUTOCONF = \
	$(EGLIBC_AUTOCONF_COMMON) \
	--disable-debug \
	--disable-profile \

$(STATEDIR)/eglibc-first.prepare:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_FIRST_BUILDDIR))
	mkdir -p $(EGLIBC_FIRST_BUILDDIR)
	cd $(EGLIBC_FIRST_BUILDDIR) && \
		$(EGLIBC_FIRST_ENV) $(EGLIBC_FIRST_PATH) \
		$(EGLIBC_DIR)/configure $(EGLIBC_FIRST_AUTOCONF)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-first.compile:
	@$(call targetinfo)
	cd $(EGLIBC_FIRST_BUILDDIR) && $(EGLIBC_FIRST_PATH) $(MAKE) $(PARALLELMFLAGS) lib
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-first.install:
	@$(call targetinfo)
	cd $(EGLIBC_FIRST_BUILDDIR) && \
		$(EGLIBC_FIRST_PATH) $(MAKE) $(EGLIBC_FIRST_MAKEVARS) \
		install_root=$(SYSROOT) install-lib-all install-headers
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-first.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eglibc-first_clean:
	rm -rf $(STATEDIR)/eglibc-first.*
	rm -rf $(EGLIBC_FIRST_BUILDDIR)

# vim: syntax=make
