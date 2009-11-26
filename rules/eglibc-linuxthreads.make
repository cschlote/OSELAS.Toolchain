# -*-makefile-*-
# $Id: template 6001 2006-08-12 10:15:00Z mkl $
#
# Copyright (C) 2006 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_EGLIBC_LINUXTHREADS) += eglibc-linuxthreads

#
# Paths and names
#
EGLIBC_LINUXTHREADS_VERSION	:= $(call remove_quotes,$(PTXCONF_EGLIBC_LINUXTHREADS_VERSION))
EGLIBC_LINUXTHREADS		:= eglibc-linuxthreads-$(EGLIBC_LINUXTHREADS_VERSION)
EGLIBC_LINUXTHREADS_SUFFIX	:= tar.bz2
EGLIBC_LINUXTHREADS_URL		:= $(PTXCONF_SETUP_GNUMIRROR)/eglibc/$(EGLIBC_LINUXTHREADS).$(EGLIBC_LINUXTHREADS_SUFFIX)
EGLIBC_LINUXTHREADS_SOURCE	:= $(SRCDIR)/$(EGLIBC_LINUXTHREADS).$(EGLIBC_LINUXTHREADS_SUFFIX)
EGLIBC_LINUXTHREADS_DIR		:= $(BUILDDIR)/$(EGLIBC_LINUXTHREADS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(EGLIBC_LINUXTHREADS_SOURCE):
	@$(call targetinfo)
	@$(call get, EGLIBC_LINUXTHREADS)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ifdef PTXCONF_EGLIBC_LINUXTHREADS
$(STATEDIR)/eglibc.extract: $(STATEDIR)/eglibc-linuxthreads.extract
endif

$(STATEDIR)/eglibc-linuxthreads.extract:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_LINUXTHREADS_DIR))
	@$(call extract, EGLIBC_LINUXTHREADS, $(EGLIBC_LINUXTHREADS_DIR))
	@$(call patchin, EGLIBC_LINUXTHREADS, $(EGLIBC_LINUXTHREADS_DIR))
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-linuxthreads.prepare:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-linuxthreads.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-linuxthreads.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-linuxthreads.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eglibc-linuxthreads_clean:
	rm -rf $(STATEDIR)/eglibc-linuxthreads.*
	rm -rf $(EGLIBC_LINUXTHREADS_DIR)

# vim: syntax=make
