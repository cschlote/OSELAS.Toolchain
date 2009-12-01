# -*-makefile-*-
# $Id$
#
# Copyright (C) 2006 by Robert Schwebel
#		2008 by Marc Kleine-Budde <mkl@pengutronix.de>
#       2009 by Carsten Schlote
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

ifneq ($(call remove_quotes $(PTXCONF_EGLIBC_PORTS_SVNREV)),)
EGLIBC_PORTS_SVNREV	:= -r $(call remove_quotes,$(PTXCONF_EGLIBC_PORTS_SVNREV))
endif
EGLIBC_PORTS		:= eglibc-ports$(EGLIBC_PORTS_VERSION)

EGLIBC_PORTS_SUFFIX	:= svn
EGLIBC_PORTS_SOURCE	:= $(SRCDIR)/$(EGLIBC_PORTS).$(EGLIBC_PORTS_SUFFIX)
EGLIBC_PORTS_SOURCE_B := $(SRCDIR)/$(EGLIBC_PORTS)
EGLIBC_PORTS_DIR	:= $(BUILDDIR)/$(EGLIBC_PORTS)

EGLIBC_PORTS_URL	:= $(EGLIBC_URL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(EGLIBC_PORTS_SOURCE): | $(EGLIBC_PORTS_SOURCE_B)
	@$(call targetinfo)
	@#$(call get, EGLIBC_PORTS)
	# See http://www.eglibc.org/archives/issues/msg00064.html
	if [ -d $(EGLIBC_PORTS_SOURCE_B) ]; then \
	   rev1=`svnversion $(EGLIBC_PORTS_SOURCE_B)`; \
	   rev2=`cat $@`; \
	   if test "$$rev1" != "$$rev2"; then \
	      echo $$rev1 > $@; \
	      echo Touched $@ because of changes; \
	   fi; \
	else \
	   rm $@; \
	fi

$(EGLIBC_PORTS_SOURCE_B): 
	if [ -d $(EGLIBC_PORTS_SOURCE_B) ]; then \
	   svn update $(EGLIBC_PORTS_SVNREV) $(EGLIBC_PORTS_SOURCE_B);\
	else \
	   svn co $(EGLIBC_PORTS_SVNREV) $(EGLIBC_PORTS_URL)/ports $(EGLIBC_PORTS_SOURCE_B); \
	fi


# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ifdef PTXCONF_EGLIBC_PORTS
$(STATEDIR)/eglibc.extract: $(STATEDIR)/eglibc-ports.extract
endif

$(STATEDIR)/eglibc-ports.extract:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_PORTS_DIR))
	# @$(call extract, EGLIBC_PORTS, $(BUILDDIR))
	# See http://www.eglibc.org/archives/issues/msg00064.html
	svn export $(EGLIBC_PORTS_SOURCE_B) $(EGLIBC_PORTS_DIR)
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
  ifeq ($(call remove_quotes $(PTXCONF_EGLIBC_PORTS_SVNREV)),HEAD)
	rm -rf $(EGLIBC_PORTS_SOURCE)
  endif
	rm -rf $(STATEDIR)/eglibc-ports.*
	rm -rf $(EGLIBC_PORTS_DIR)

# vim: syntax=make
