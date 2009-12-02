# -*-makefile-*-
# $Id: template 6001 2006-08-12 10:15:00Z mkl $
#
# Copyright (C) 2006 by Marc Kleine-Budde <mkl@pengutronix.de>
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
PACKAGES-$(PTXCONF_EGLIBC_LINUXTHREADS) += eglibc-linuxthreads

#
# Paths and names
#
EGLIBC_LINUXTHREADS_VERSION	:= $(call remove_quotes,$(PTXCONF_EGLIBC_LINUXTHREADS_VERSION))
EGLIBC_LINUXTHREADS		:= eglibc-linuxthreads-$(EGLIBC_LINUXTHREADS_VERSION)
EGLIBC_LINUXTHREADS_SUFFIX	:= svn
EGLIBC_LINUXTHREADS_URL		= $(EGLIBC_URL)
EGLIBC_LINUXTHREADS_SVNREV	= $(EGLIBC_SVNREV)
EGLIBC_LINUXTHREADS_SOURCE	:= $(SRCDIR)/$(EGLIBC_LINUXTHREADS).$(EGLIBC_LINUXTHREADS_SUFFIX)
EGLIBC_LINUXTHREADS_SOURCE_B := $(SRCDIR)/$(EGLIBC_LINUXTHREADS)
EGLIBC_LINUXTHREADS_DIR		:= $(BUILDDIR)/$(EGLIBC_LINUXTHREADS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(EGLIBC_LINUXTHREADS_SOURCE): | $(EGLIBC_LINUXTHREADS_SOURCE_B)
	@$(call targetinfo)
	# @$(call get, EGLIBC_LINUXTHREADS)
	# See http://www.eglibc.org/archives/issues/msg00064.html
	if [ -d $(EGLIBC_LINUXTHREADS_SOURCE_B) ]; then \
	   rev1=`svnversion $(EGLIBC_LINUXTHREADS_SOURCE_B)`; \
	   rev2=`cat $@`; \
	   if test "$$rev1" != "$$rev2"; then \
	      touch $@; \
	      echo Touched $@ because of changes; \
	   fi; \
	else \
	   rm -rf $@; \
	fi

$(EGLIBC_LINUXTHREADS_SOURCE_B):
	if [ -d $(EGLIBC_LINUXTHREADS_SOURCE_B) ]; then \
	   svn update $(EGLIBC_PORTS_SVNREV) $(EGLIBC_LINUXTHREADS_SOURCE_B);\
	else \
	   svn co $(EGLIBC_LINUXTHREADS_SVNREV) $(EGLIBC_LINUXTHREADS_URL)/linuxthreads $(EGLIBC_LINUXTHREADS_SOURCE_B); \
	fi

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ifdef PTXCONF_EGLIBC_LINUXTHREADS
$(STATEDIR)/eglibc.extract: $(STATEDIR)/eglibc-linuxthreads.extract
endif

$(STATEDIR)/eglibc-linuxthreads.extract:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_LINUXTHREADS_DIR))
	# @$(call extract, EGLIBC_LINUXTHREADS, $(EGLIBC_LINUXTHREADS_DIR))
	# See http://www.eglibc.org/archives/issues/msg00064.html
	svn export $(EGLIBC_LINUXTHREADS_SOURCE_B) $(EGLIBC_LINUXTHREADS_DIR)
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
  ifeq ($(call remove_quotes $(PTXCONF_EGLIBC_LINUXTHREADS_SVNREV)),HEAD)
	rm -rf $(EGLIBC_LINUXTHREADS_SOURCE)
  endif
	rm -rf $(STATEDIR)/eglibc-linuxthreads.*
	rm -rf $(EGLIBC_LINUXTHREADS_DIR)

# vim: syntax=make
