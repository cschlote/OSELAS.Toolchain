# -*-makefile-*-
# $Id: template 6655 2007-01-02 12:55:21Z rsc $
#
# Copyright (C) 2006 by Robert Schwebel
#		2007, 2008 by Marc Kleine-Budde
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
PACKAGES-$(PTXCONF_EGLIBC) += eglibc

#
# Paths and names
#
ifneq ($(PTXCONF_EGLIBC_VERSION),"")
EGLIBC_VERSION	:= -$(call remove_quotes,$(PTXCONF_EGLIBC_VERSION))
endif
ifneq ($(PTXCONF_EGLIBC_SVNREV),"")
EGLIBC_SVNREV	:= -r $(call remove_quotes,$(PTXCONF_EGLIBC_SVNREV))
endif

EGLIBC			:= eglibc$(EGLIBC_VERSION)
EGLIBC_SUFFIX	:= svn
EGLIBC_SOURCE	:= $(SRCDIR)/$(EGLIBC).$(EGLIBC_SUFFIX)
EGLIBC_SOURCE_B	:= $(SRCDIR)/$(EGLIBC)
EGLIBC_DIR		:= $(BUILDDIR_DEBUG)/$(EGLIBC)
EGLIBC_BUILDDIR	:= $(BUILDDIR)/$(EGLIBC)-build

EGLIBC_URL	:= svn://svn.eglibc.org/branches/eglibc$(subst .,_,$(EGLIBC_VERSION))

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------
PHONY += $(EGLIBC_SOURCE_B)

$(EGLIBC_SOURCE): | $(EGLIBC_SOURCE_B)
	@$(call targetinfo)
	# @$(call get, EGLIBC)
	# See http://www.eglibc.org/archives/issues/msg00064.html

$(EGLIBC_SOURCE_B):
	if [ -d $(EGLIBC_SOURCE_B) ]; then \
	   svn update $(EGLIBC_SVNREV) $(EGLIBC_SOURCE_B);\
	else \
	   svn co $(EGLIBC_SVNREV) $(EGLIBC_URL)/libc $(EGLIBC_SOURCE_B); \
	fi; \
	if [ -d $(EGLIBC_SOURCE_B) ]; then \
	   rev1=`svnversion $(EGLIBC_SOURCE_B)`; \
	   rev2=`cat $(EGLIBC_SOURCE)`; \
	   if test "$$rev1" != "$$rev2"; then \
	      echo $$rev1 > $(EGLIBC_SOURCE); \
	      echo Touched $(EGLIBC_SOURCE) because of changes; \
	   fi; \
	else \
	   rm  $(EGLIBC_SOURCE); \
	fi

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc.extract:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_DIR))
	# @$(call extract, EGLIBC, $(BUILDDIR_DEBUG))
	# See http://www.eglibc.org/archives/issues/msg00064.html
	svn export $(EGLIBC_SOURCE_B) $(EGLIBC_DIR)
	@$(call patchin, EGLIBC, $(EGLIBC_DIR))

ifdef PTXCONF_EGLIBC_LINUXTHREADS
	cp -r $(EGLIBC_LINUXTHREADS_DIR)/linuxthreads $(EGLIBC_DIR)
	cp -r $(EGLIBC_LINUXTHREADS_DIR)/linuxthreads_db $(EGLIBC_DIR)
endif
ifdef PTXCONF_EGLIBC_PORTS
	mkdir -p $(EGLIBC_DIR)/ports
	cp -r $(EGLIBC_PORTS_DIR)/* $(EGLIBC_DIR)/ports
endif
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

EGLIBC_PATH := PATH=$(CROSS_PATH)
EGLIBC_ENV := \
	CC=$(CROSS_CC) \
	BUILD_CC=$(HOSTCC) \
	ac_cv_sizeof_long_double=$(PTXCONF_SIZEOF_LONG_DOUBLE)


EGLIBC_MAKEVARS := AUTOCONF=no

#
# autoconf
#
ifdef PTXCONF_EGLIBC_PORTS
EGLIBC_ADDONS	+= ports
endif
ifdef PTXCONF_EGLIBC_ADDON_NPTL
EGLIBC_ADDONS	+= nptl
endif
ifdef PTXCONF_EGLIBC_ADDON_LINUXTHREADS
EGLIBC_ADDONS	+= linuxthreads
endif

EGLIBC_AUTOCONF_COMMON := \
	--prefix=/usr \
	--host=$(PTXCONF_GNU_TARGET) \
	--target=$(PTXCONF_GNU_TARGET) \
	\
	--with-headers=$(SYSROOT)/usr/include \
	--enable-add-ons=$(subst $(space),$(comma),$(EGLIBC_ADDONS)) \
	\
	--without-cvs \
	--without-gd \
	--without-selinux \
	--disable-sanity-checks \
	\
	$(PTXCONF_EGLIBC_CONFIG_EXTRA)

ifdef PTXCONF_EGLIBC_TLS
EGLIBC_AUTOCONF_COMMON	+= --with-tls --with-__thread
else
EGLIBC_AUTOCONF_COMMON	+= --without-tls --without-__thread
endif

EGLIBC_AUTOCONF := \
	$(EGLIBC_AUTOCONF_COMMON) \
	\
	--enable-kernel=$(PTXCONF_EGLIBC_ENABLE_KERNEL) \
	--enable-debug \
	--enable-profile \
	--enable-shared \
	--enable-static-nss

$(STATEDIR)/eglibc.prepare:
	@$(call targetinfo)
	@$(call clean, $(EGLIBC_BUILDDIR))
	mkdir -p $(EGLIBC_BUILDDIR)
	cd $(EGLIBC_BUILDDIR) && \
		$(EGLIBC_ENV) $(EGLIBC_PATH) \
		$(EGLIBC_DIR)/configure $(EGLIBC_AUTOCONF)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc.compile:
	@$(call targetinfo)
	cd $(EGLIBC_BUILDDIR) && $(EGLIBC_PATH) $(MAKE) $(PARALLELMFLAGS)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc.install:
	@$(call targetinfo)
	cd $(EGLIBC_BUILDDIR) && \
		$(EGLIBC_PATH) $(MAKE) $(EGLIBC_MAKEVARS) \
		install_root=$(SYSROOT) install
#
# Fix a bug when linking statically
# see: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=76451
# see: http://www.sourceware.org/bugzilla/show_bug.cgi?id=631
#
	mv -- "$(SYSROOT)/usr/lib/libc.a" "$(SYSROOT)/usr/lib/libc_ns.a"
	echo '/* GNU ld script'											>  "$(SYSROOT)/usr/lib/libc.a"
	echo '   Use the static library, but some functions are in other strange'				>> "$(SYSROOT)/usr/lib/libc.a"
	echo '   libraries :-( So try them secondarily. */'							>> "$(SYSROOT)/usr/lib/libc.a"
	echo 'GROUP ( /usr/lib/libc_ns.a /usr/lib/libnss_files_pic.a /usr/lib/libnss_dns_pic.a /usr/lib/libresolv.a )'	>> "$(SYSROOT)/usr/lib/libc.a"
	@#echo 'GROUP ( /usr/lib/libc_ns.a /usr/lib/libnss_files.a /usr/lib/libnss_dns.a /usr/lib/libresolv.a )'	>> "$(SYSROOT)/usr/lib/libc.a"

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/eglibc.targetinstall:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eglibc_clean:
  ifeq ($(call remove_quotes $(PTXCONF_EGLIBC_SVNREV)),HEAD)
	rm -rf $(EGLIBC_SOURCE)
  endif
	rm -rf $(STATEDIR)/eglibc.*
	rm -rf $(EGLIBC_DIR)

# vim: syntax=make
