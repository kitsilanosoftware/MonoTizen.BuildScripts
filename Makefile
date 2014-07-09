# Copyright 2014 Kitsilano Software Inc.
#
# This file is part of MonoTizen.
#
# MonoTizen is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MonoTizen is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with MonoTizen.  If not, see <http://www.gnu.org/licenses/>.

MONO_TIZEN_RPM_VERSION = 3.6.0-0
MONO_TIZEN_ARCHS = armv7l i586
MONO_TIZEN_OS_RELEASE = 2.2.1
MONO_TIZEN_GC = sgen

RPM_NAMES =					\
	libmono-2_0-devel			\
	libmono$(MONO_TIZEN_GC)-2_0-1		\
	mono-core

ZIPS = $(foreach A,$(MONO_TIZEN_ARCHS),					\
		build/mono-tizen-$(MONO_TIZEN_RPM_VERSION).$(A).zip)

RPM_URL_BASE =								\
	http://phio.crosstwine.com/kitsilano/mono-tizen/tarballs/rpms

RPM_DIR_BASE =

RPM_STAGE =						\
	tmp/$(if $(RPM_DIR_BASE),links,downloads)

.PHONY: all clean

all: $(ZIPS)

build/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%.zip:			\
		tmp/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%/zip.stamp
	@mkdir -p $(dir $@)
	cd $(dir $<)/zip &&			\
		zip -r -9 $(abspath $@).tmp .
	@mv $@.tmp $@

tmp/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%/zip.stamp:			\
		tmp/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%/unpack.stamp
	rm -rf $(dir $@)zip
	mkdir -p $(dir $@)zip/lib/mono
	cp $(dir $@)unpack/usr/lib/libmono$(MONO_TIZEN_GC)-2.0.so.1.0.0	\
		$(dir $@)zip/lib/libmono$(MONO_TIZEN_GC)-2.0.so.1
	rsync -a $(dir $@)unpack/usr/include/mono-2.0/ $(dir $@)zip/inc/
	# Note: We copy links, and ignore some assemblies that are
	# missing from the .NET 4.5 profile (?)
	rsync -rLptgoD							 \
		--exclude I18N.CJK.dll					 \
		--exclude I18N.MidEast.dll				 \
		--exclude I18N.Other.dll				 \
		--exclude I18N.Rare.dll					 \
		--exclude IBM.Data.DB2.dll				 \
		--include '*.dll'					 \
		--exclude '*'						 \
		$(dir $@)unpack/usr/lib/mono/4.5/ $(dir $@)zip/lib/mono/
	touch $@

tmp/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%/unpack.stamp:		   \
		$(foreach N,$(RPM_NAMES),				   \
			$(RPM_STAGE)/$(N)-$(MONO_TIZEN_RPM_VERSION).%.rpm)
	rm -rf $(dir $@)unpack
	mkdir -p $(dir $@)unpack
	cd $(dir $@)unpack &&				\
		for R in $(abspath $^); do		\
			rpm2cpio $$R | cpio -i -d;	\
		done
	touch $@

tmp/downloads/%.armv7l.rpm:
	@mkdir -p $(dir $@)
	wget -O $@.tmp \
		$(RPM_URL_BASE)/$(MONO_TIZEN_OS_RELEASE)-armv7l/$(notdir $@)
	@mv $@.tmp $@

tmp/downloads/%.i586.rpm:
	@mkdir -p $(dir $@)
	wget -O $@.tmp \
		$(RPM_URL_BASE)/$(MONO_TIZEN_OS_RELEASE)-i686/$(notdir $@)
	@mv $@.tmp $@

tmp/links/%.armv7l.rpm:
	@mkdir -p $(dir $@)
	cd $(dir $@) && \
		ln -s $(abspath $(RPM_DIR_BASE)/$(MONO_TIZEN_OS_RELEASE)-armv7l/$(notdir $@))

tmp/links/%.i586.rpm:
	@mkdir -p $(dir $@)
	cd $(dir $@) && \
		ln -s $(abspath $(RPM_DIR_BASE)/$(MONO_TIZEN_OS_RELEASE)-i686/$(notdir $@))

clean:
	rm -rf build/

.PRECIOUS:							\
	build/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%.zip	\
	tmp/downloads/%.armv7l.rpm				\
	tmp/downloads/%.i586.rpm				\
	tmp/links/%.armv7l.rpm					\
	tmp/links/%.i586.rpm					\
	tmp/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%/unpack.stamp	\
	tmp/mono-tizen-$(MONO_TIZEN_RPM_VERSION).%/zip.stamp
