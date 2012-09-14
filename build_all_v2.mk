#!/usr/bin/make -f

#
# Makefile to build all ptxconfigs
# Copyright (C) 2007 Carsten Schlote <c.schlote@konzeptpark.de>
#               2008, 2011 Marc Kleine-Budde <mkl@pengutronix.de>
#

SHELL		:= /bin/bash

#
# config
#
PTX_AUTOBUILD_DESTDIR	:= ${PWD}/inst
export PTX_AUTOBUILD_DESTDIR

BENICE			:= true

BUILDDATE	:= $(shell date +%y%m%d-%H%M)

VERSION		:= $(shell ./scripts/setlocalversion ./.tarball-version)

ARCH		:= $(shell			\
	case "$$(uname -m)" in			\
		(x86_64)	echo amd64;;	\
		(i[1-9]86)	echo i386;;	\
		(ppc)		echo powerpc;;	\
		(*)		;;		\
	esac					\
)

ifeq ($(ARCH),)
$(error failed to detect arch, or arch is unsupported)
endif

PTXDIST			:= ./p --force
PTXDIST_VERSION_REQUIRED := $(shell ./fixup_ptxconfigs.sh --info)

ifdef BENICE
NICE			+= nice -n 19
endif

CONFIGDIR	:= ptxconfigs
CONFIGFILES	:= $(wildcard $(CONFIGDIR)/*.ptxconfig) $(wildcard $(CONFIGDIR)/*/*.ptxconfig)
CONFIGS		:= $(notdir $(basename $(CONFIGFILES)))
CONFIGS_	:= $(subst _,-,$(CONFIGS))

define gen_2config
$(eval 2CONFIG_$(subst _,-,$(1)) := $(1))
endef

define gen_2configfile
$(eval 2CONFIGFILE_$(subst _,-,$(notdir $(basename $(1)))) := $(1))
endef

define gen_2instdir
$(eval 2INSTDIR_$(subst _,-,$(notdir $(basename $(1)))) := \
	$(shell PTX_AUTOBUILD_DESTDIR='' source "$(1)" && echo "$${PTXCONF_SYSROOT_CROSS}"))
endef


$(foreach cfg,$(CONFIGS),$(call gen_2config,$(cfg)))
$(foreach cfgfile,$(CONFIGFILES),$(call gen_2configfile,$(cfgfile)))
$(foreach cfgfile,$(CONFIGFILES),$(call gen_2instdir,$(cfgfile)))

STATEDIR	:= gstate
DISTDIR		:= dist

PREFIX		:= $(DISTDIR)/oselas.toolchain-$(VERSION)-
CONFIGS_PREFIX	:= $(foreach config,$(CONFIGS_),$(addprefix $(PREFIX),$(config)))

DEB_PREFIX	:= $(PREFIX)
DEB_SUFFIX	:= _$(VERSION)_$(ARCH).deb

TBZ2_PREFIX	:= $(PREFIX)
TBZ2_SUFFIX	:= _$(ARCH).tar.bz2

DEBS		:= $(foreach config,$(CONFIGS_PREFIX),$(addsuffix $(DEB_SUFFIX),$(config)))
TBZ2S		:= $(foreach config,$(CONFIGS_PREFIX),$(addsuffix $(TBZ2_SUFFIX),$(config)))
OLDCONFIGS	:= $(foreach config,$(CONFIGS_),$(addsuffix .oldconfig,$(config)))

all: $(TBZ2S) $(DEBS)

$(DEB_PREFIX)%$(DEB_SUFFIX): $(STATEDIR)/%.build | compile-ptxd mkdirs
	@scripts/make_deb.sh -d "$(@)" -s "$(PTX_AUTOBUILD_DESTDIR)/$(2INSTDIR_$(*))"

$(TBZ2_PREFIX)%$(TBZ2_SUFFIX): $(STATEDIR)/%.build | compile-ptxd mkdirs
	@echo Creating $(notdir $@) ...
	@echo 'tar -C "$(PTX_AUTOBUILD_DESTDIR)/opt" --exclude=gcc-first -cjf "$(@)" "$(patsubst /opt/%,%,$(2INSTDIR_$(*)))"' | fakeroot

$(foreach config,$(CONFIGS_),$(eval $(STATEDIR)/$(config).build: $(2CONFIGFILE_$(config))))
$(STATEDIR)/%.build: | mkdirs
	@echo "building ${*}"
	$(NICE) $(PTXDIST) go --ptxconfig=$(2CONFIGFILE_$(*))
	@find "`source "$(2CONFIGFILE_$(*))" && echo "$${PTXCONF_SYSROOT_CROSS}"`" -depth -type d -print0 | xargs -r -0 -- rmdir --ignore-fail-on-non-empty --
	find \
		"`source "$(2CONFIGFILE_$(*))" && echo "$${PTXCONF_SYSROOT_CROSS}"`/libexec/" \
		"`source "$(2CONFIGFILE_$(*))" && echo "$${PTXCONF_SYSROOT_CROSS}"`/bin/" \
		"`source "$(2CONFIGFILE_$(*))" && echo "$${PTXCONF_SYSROOT_CROSS}"`/"*/bin/ \
		-type f \( -executable -o -name "*.so*" \) \
		| xargs strip || true
	@touch "$@"


$(STATEDIR)/%.pkgs: $(DEB_PREFIX)%$(DEB_SUFFIX) $(TBZ2_PREFIX)%$(TBZ2_SUFFIX) | mkdirs
	@:

oldconfig: $(OLDCONFIGS)

%.oldconfig:
	$(PTXDIST) oldconfig --ptxconfig=$(2CONFIGFILE_$(*))

$(STATEDIR)/ptxdist.build:
	@git submodule update || (echo "Unable to update GIT submodules"; false )
	@./p --version 2&> /dev/null || ( \
		echo "building ptxdist binary in subdir 'ptxdist'."; \
		cd ptxdist; ./autogen.sh; ./configure --prefix=`pwd`; \
		make; \
		cd ..; )
	@./p --version 2&> /dev/null || (echo "Unable to build ptxdist."; false)
	@./p --version 2&> $@
	@if [ "`cat $@`" != $(PTXDIST_VERSION_REQUIRED) ]; then \
		echo -en "\nRelease mismatch!\n\n"; \
		echo "Required ptxdist version:" $(PTXDIST_VERSION_REQUIRED); \
		echo "Compiled ptxdist version:" `cat $@`; \
		echo -en "\n\nUpdate ptxdist submodule to required version\n"; \
		echo -en "Use ./build_all_v2.sh update-ptxd\n"; \
	fi
	@echo -e "\n\nSuccessfully prepared ptxdist $(PTXDIST_VERSION_REQUIRED) for\nOSELAS.Toolchain-$(VERSION) build.\n\n"

mkdirs:
	@mkdir -p $(STATEDIR) $(DISTDIR)

print-%:
	@echo "$* is \"$($(*))\""


compile-ptxd: mkdirs $(STATEDIR)/ptxdist.build

update-ptxd: mkdirs
	-make -C ptxdist distclean
	rev=`./fixup_ptxconfigs.sh --info`; \
	cd ptxdist && git checkout ptxdist-$$rev
	git add ptxdist
	git citool

help:
	@echo -e "\nAvailable DPKG targets:\n"
	@for i in $(sort $(DEBS)); do echo $$i; done;
	@echo -e "\nAvailable tarball targets:\n"
	@for i in $(sort $(TBZ2S)); do echo $$i; done;
