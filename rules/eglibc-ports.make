# -*-makefile-*-
# $Id$
#
# Copyright (C) 2006 by Robert Schwebel
#		2008 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_EGLIBC_PORTS) += eglibc-ports

#
# Paths and names
#
ifneq ($(call remove_quotes $(PTXCONF_EGLIBC_PORTS_VERSION)),)
EGLIBC_PORTS_VERSION	:= -$(call remove_quotes,$(PTXCONF_EGLIBC_PORTS_VERSION))
else
EGLIBC_PORTS_VERSION	:= -$(call remove_quotes,$(PTXCONF_EGLIBC_VERSION))
endif

ifneq ($(call remove_quotes $(PTXCONF_EGLIBC_PORTS_TIMESTAMP)),)
EGLIBC_PORTS_TIMESTAMP	:= -$(call remove_quotes,$(PTXCONF_EGLIBC_PORTS_TIMESTAMP))
EGLIBC_PORTS		:= eglibc$(EGLIBC_PORTS_VERSION)-ports$(EGLIBC_PORTS_TIMESTAMP)
else
EGLIBC_PORTS		:= eglibc-ports$(EGLIBC_PORTS_VERSION)
endif

EGLIBC_PORTS_SUFFIX	:= tar.bz2
EGLIBC_PORTS_SOURCE	:= $(SRCDIR)/$(EGLIBC_PORTS).$(EGLIBC_PORTS_SUFFIX)
EGLIBC_PORTS_DIR		:= $(BUILDDIR)/$(EGLIBC_PORTS)

EGLIBC_PORTS_URL		:= \
	$(PTXCONF_SETUP_GNUMIRROR)/eglibc/$(EGLIBC_PORTS).$(EGLIBC_PORTS_SUFFIX) \
	ftp://sources.redhat.com/pub/eglibc/snapshots/$(EGLIBC_PORTS).$(EGLIBC_PORTS_SUFFIX) \
	http://www.pengutronix.de/software/ptxdist/temporary-src/eglibc/$(EGLIBC_PORTS).$(EGLIBC_PORTS_SUFFIX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(EGLIBC_PORTS_SOURCE):
	@$(call targetinfo)
	@$(call get, EGLIBC_PORTS)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ifdef PTXCONF_EGLIBC_PORTS
$(STATEDIR)/eglibc.extract: $(STATEDIR)/eglibc-ports.extract
endif

$(STATEDIR)/eglibc-ports.extract:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_PORTS_DIR))
	@$(call extract, EGLIBC_PORTS, $(BUILDDIR))
	@$(call patchin, EGLIBC_PORTS, $(EGLIBC_PORTS_DIR))
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-ports.prepare:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-ports.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-ports.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc-ports.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eglibc-ports_clean:
	rm -rf $(STATEDIR)/eglibc-ports.*
	rm -rf $(EGLIBC_PORTS_DIR)

# vim: syntax=make
