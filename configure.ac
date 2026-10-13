AC_INIT([PROJ],[1.0],[mdsumner@gmail.com])
AC_CONFIG_SRCDIR(src/C_proj_crs_text.c)

# find R home and set correct compiler + flags
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  AC_MSG_ERROR([cannot determine R_HOME. Make sure you use R CMD INSTALL!])
fi
RBIN="${R_HOME}/bin/R"

# pick all flags for testing from R
: ${CC=`"${RBIN}" CMD config CC`}
: ${CFLAGS=`"${RBIN}" CMD config CFLAGS`}
: ${CPPFLAGS=`"${RBIN}" CMD config CPPFLAGS`}
: ${LDFLAGS=`"${RBIN}" CMD config LDFLAGS`}
: ${CPP="$CC -E"}
: ${CXX=`"${RBIN}" CMD config CXX`}
: ${CXXFLAGS=`"${RBIN}" CMD config CXXFLAGS`}

AC_LANG(C++)

# honor PKG_xx overrides
LIBS="${LIBS} ${PKG_LIBS}"
# for CPPFLAGS we will superfluously double R's flags
# since we'll set PKG_CPPFLAGS with this, but that shouldn't hurt
CPPFLAGS="${CPPFLAGS} ${PKG_CPPFLAGS}"
LIBS_SAVE=${LIBS}

pkgconfig=no
AC_MSG_CHECKING([whether pkg-config knows about proj])
if pkg-config proj; then
  AC_MSG_RESULT([yes])
  pkgconfig=yes
  AC_MSG_CHECKING([CFLAGS from pkg-config])
  PROJ_CPPFLAGS=`pkg-config --cflags proj`
  CPPFLAGS="$CPPFLAGS ${PROJ_CPPFLAGS}"
  AC_MSG_RESULT([$PROJ_CPPFLAGS])
  AC_MSG_CHECKING([LIBS from pkg-config])
  PROJ_LIBS=`pkg-config --libs proj`
  LIBS="${LIBS_SAVE} ${PROJ_LIBS}"
else
  AC_MSG_RESULT([no])
fi

# PROJ >= 8.2 is required (proj_factors() with a CRS, proj_context_errno_string())
AC_CHECK_HEADERS(proj.h,,[AC_MSG_ERROR([proj.h not found.
*** You may need to install libproj-dev or similar, or set PKG_CPPFLAGS. ***])])

AC_CHECK_LIB(proj, proj_get_source_crs,,[
    unset ac_cv_lib_proj_proj_get_source_crs
    ## try static
    AC_MSG_NOTICE([Retrying with pkg-config --static])
    PROJ_LIBS=`pkg-config --static --libs proj`
    LIBS="${LIBS_SAVE} ${PROJ_LIBS}"
    AC_CHECK_LIB(proj, proj_get_source_crs,,[AC_MSG_ERROR([libproj not found or not linkable.
*** You may need to install libproj-dev or similar, or set PKG_LIBS. ***])])
])

AC_MSG_CHECKING([PROJ version >= 8.2])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <proj.h>]],
  [[#if (PROJ_VERSION_MAJOR * 100 + PROJ_VERSION_MINOR) < 802
    #error PROJ too old
    #endif]])],
  [AC_MSG_RESULT([yes])],
  [AC_MSG_RESULT([no])
   AC_MSG_ERROR([PROJ >= 8.2.0 is required; the headers found report an older version.
*** Install a newer PROJ (Ubuntu 22.04 ships 8.2.1; ubuntugis-unstable or conda-forge have current releases) ***])])

# Optional local copy of the PROJ data directory into the package (inst/proj).
# Honoured either via the PROJ_GDAL_DATA_COPY environment variable (as sf,
# terra, gdalraster, vapour do; this is how CRAN's macOS binary builds get
# their proj.db) or via --with-data-copy=yes. The data comes from PROJ_LIB
# (or PROJ_DATA) if set, else --with-proj-data=DIR.
#
# Note the copy is a snapshot of one PROJ version's data; the package
# validates it at load against the linked libproj and ignores it if the
# database layout is incompatible (see R/zzz.R). Do not use this with a
# dynamically linked libproj that may later be upgraded.

data_copy=no
if test "${PROJ_GDAL_DATA_COPY}" ; then
    data_copy=yes
    AC_MSG_NOTICE([PROJ_GDAL_DATA_COPY used.])
else
    AC_ARG_WITH([data-copy],
        AS_HELP_STRING([--with-data-copy=yes/no],[local copy of PROJ data directory in package, default no]),
               [data_copy=$withval])
fi
if test "${data_copy}" = "yes" ; then
  proj_lib0="${PROJ_LIB}"
  if test -z "${proj_lib0}" ; then
    proj_lib0="${PROJ_DATA}"
  fi
  AC_ARG_WITH([proj-data],
    AS_HELP_STRING([--with-proj-data=DIR],[location of PROJ data directory]),
    [proj_lib1=$withval])
  if test -n "${proj_lib0}" ; then
    proj_lib="${proj_lib0}"
  else
    proj_lib="${proj_lib1}"
  fi
  if test -n "${proj_lib}" && test -d "${proj_lib}" && test -f "${proj_lib}/proj.db" ; then
    AC_MSG_NOTICE([Copying PROJ data from ${proj_lib} into package])
    mkdir -p "${R_PACKAGE_DIR}/proj"
    cp -r "${proj_lib}"/. "${R_PACKAGE_DIR}/proj/"
  else
    AC_MSG_ERROR([PROJ data directory (containing proj.db) not found; set PROJ_LIB=DIR or --with-proj-data=DIR.])
  fi
fi

AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_MSG_NOTICE([setting CCPFLAGS: ${CPPFLAGS}])
AC_MSG_NOTICE([setting PROJ_LIBS: ${PROJ_LIBS}])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT
