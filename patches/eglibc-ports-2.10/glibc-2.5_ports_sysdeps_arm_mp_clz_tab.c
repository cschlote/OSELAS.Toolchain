---
 ports/sysdeps/arm/mp_clz_tab.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

Index: eglibc-ports-2.10/ports/sysdeps/arm/mp_clz_tab.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ eglibc-ports-2.10/ports/sysdeps/arm/mp_clz_tab.c	2009-12-01 13:00:57.000000000 +0100
@@ -0,0 +1,24 @@
+/* __clz_tab -- support for longlong.h
+   Copyright (C) 2004 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, write to the Free
+   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
+   02111-1307 USA.  */
+
+#if defined(__ARM_ARCH_5__) || defined(__ARM_ARCH_5T__) || defined(__ARM_ARCH_5TE__)
+/* Nothing required.  */
+#else
+#include <stdlib/mp_clz_tab.c>
+#endif
