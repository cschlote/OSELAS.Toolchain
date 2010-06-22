# -*-makefile-*-
# $Id$
#
# Copyright (C) 2007-2008 by Marc Kleine-Budde <mkl@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
HOST_PACKAGES-$(PTXCONF_HOST_MPC) += host-mpc

#
# Paths and names
#
HOST_MPC_VERSION	:= 0.8.1
HOST_MPC		:= mpc-$(HOST_MPC_VERSION)
HOST_MPC_SUFFIX	:= tar.gz
HOST_MPC_SOURCE	:= $(SRCDIR)/$(HOST_MPC).$(HOST_MPC_SUFFIX)
HOST_MPC_DIR		:= $(HOST_BUILDDIR)/$(HOST_MPC)

HOST_MPC_URL		:= \
	http://www.multiprecision.org/mpc/download/$(HOST_MPC).$(HOST_MPC_SUFFIX) \
	http://www.mpc.org/mpc-$(HOST_MPC_VERSION)/$(HOST_MPC).$(HOST_MPC_SUFFIX) \
	http://cross-lfs.org/files/packages/svn/$(HOST_MPC).$(HOST_MPC_SUFFIX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(HOST_MPC_SOURCE):
	@$(call targetinfo)
	@$(call get, HOST_MPC)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/host-mpc.extract:
	@$(call targetinfo)
	@$(call clean, $(HOST_MPC_DIR))
	@$(call extract, HOST_MPC, $(HOST_BUILDDIR))
	@$(call patchin, HOST_MPC, $(HOST_MPC_DIR))
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

HOST_MPC_PATH	:= PATH=$(HOST_PATH)
HOST_MPC_ENV 	:= $(PTX_HOST_ENV)

#
# autoconf
#
HOST_MPC_AUTOCONF	:= \
	$(PTX_HOST_AUTOCONF) \
	--disable-shared \
	--enable-static

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

host-mpc_clean:
	rm -rf $(STATEDIR)/host-mpc.*
	rm -rf $(HOST_MPC_DIR)

# vim: syntax=make
