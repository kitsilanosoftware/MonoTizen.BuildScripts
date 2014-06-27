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

include Makefile

# System.{Design,Drawing} fail to initialize because we are missing
# libgdiplus.  As does System.Web:
#
#    228) MonoTests.System.Web.UI.WebControls.WizardTest.Wizard_ViewState : System.TypeInitializationException : An exception was thrown by the type initializer for System.Drawing.KnownColors
#      ----> System.TypeInitializationException : An exception was thrown by the type initializer for System.Drawing.GDIPlus
#      ----> System.DllNotFoundException : /usr/lib/libgdiplus.so

MONO_TIZEN_CENTUM_IGNORE =			\
	class/System.Design			\
	class/System.Drawing			\
	class/System.Web

MONO_TIZEN_CENTUM_TESTS =			\
	$(if $($(PROFILE)_centum_tests),	\
		$($(PROFILE)_centum_tests),	\
		$(default_centum_tests))

%centum-tests.list:
	echo $(filter-out $(MONO_TIZEN_CENTUM_IGNORE),	\
		$(MONO_TIZEN_CENTUM_TESTS)) > $@.tmp
	@mv $@.tmp $@
