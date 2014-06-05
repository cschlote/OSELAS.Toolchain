#!/usr/bin/make -rRBf

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

PTXDIST			:= ./p --force
ARG			:= images

export PTXDIST_ENV_WHITELIST	:= CROSS_GDB_WITHOUT_PYTHON
export CROSS_GDB_WITHOUT_PYTHON	?= y

PTXDIST_VERSION_REQUIRED := $(shell ./fixup_ptxconfigs.sh --info)

ifdef BENICE
NICE			+= nice -n 19
endif

CONFIGDIR	:= ptxconfigs
CONFIGFILES	:= $(wildcard $(CONFIGDIR)/*.ptxconfig) $(wildcard $(CONFIGDIR)/*/*.ptxconfig)
CONFIGS		:= $(notdir $(basename $(CONFIGFILES)))
CONFIGS_	:= $(subst _,-,$(CONFIGS))

define gen_2configfile
$(eval 2CONFIGFILE_$(subst _,-,$(notdir $(basename $(1)))) := $(1))
endef
$(foreach cfgfile,$(CONFIGFILES),$(call gen_2configfile,$(cfgfile)))

STATEDIR	:= gstate
DISTDIR		:= dist

BUILDS		:= $(foreach config,$(CONFIGS_),$(addprefix $(STATEDIR)/,$(addsuffix .build,$(config))))
OLDCONFIGS	:= $(foreach config,$(CONFIGS_),$(addsuffix .oldconfig,$(config)))

all: $(BUILDS)

$(foreach config,$(CONFIGS_),$(eval $(STATEDIR)/$(config).build: $(2CONFIGFILE_$(config))))
$(STATEDIR)/%.build: | mkdirs $(STATEDIR)/ptxdist.build
	@echo "building ${*}"
	$(NICE) $(PTXDIST) $(ARG) --ptxconfig=$(2CONFIGFILE_$(*))
	@if [ "$(strip $(filter images,$(ARG)))" = "images" ]; then touch "$@"; fi

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

update-configs: compile-ptxd
	./fixup_ptxconfigs.sh

clean:
	-make -C ptxdist distclean
	-rm -rf platform-*
	-rm -rf $(STATEDIR) $(PTX_AUTOBUILD_DESTDIR)

distclean: clean
	-rm -rf $(DISTDIR)

help:
	@echo "Available make targets:"
	@echo "  all clean compile-ptxd distclean help mkdirs oldconfig"
	@echo "  update-configs update-ptxd"
	@echo ""
	@echo "Available build targets:"
	@for i in $(sort $(BUILDS)); do echo $$i; done;
