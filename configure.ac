AC_INIT(PROJ, 0.1.0, mdsumner@gmail.com)
AC_CONFIG_SRCDIR(src/C_proj_trans.c)

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

# honor PKG_xx overrides
LIBS="${LIBS} ${PKG_LIBS}"
# for CPPFLAGS we will superfluously double R's flags
# since we'll set PKG_CPPFLAGS with this, but that shouldn't hurt
CPPFLAGS="${CPPFLAGS} ${PKG_CPPFLAGS}"

#AC_ARG_ENABLE([proj6],
#  AS_HELP_STRING(--enable-proj6, [use the new PROJ6 API even if PROJ4 API is available. The default is @<:@disable@:>@ since #PROJ6 API has issues, use with caution.]),
#  [with_proj6=$withval], [with_proj6=no])

with_proj6=yes
proj4ok=no
use6=yes

AC_CHECK_HEADERS(proj_api.h,,[
  AC_MSG_CHECKING([with ACCEPT_USE_OF_DEPRECATED_PROJ_API_H])
  AC_MSG_RESULT([])
  savCPPFLAGS="$CPPFLAGS"
  CPPFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1 $CPPFLAGS"
  unset ac_cv_header_proj_api_h
  AC_CHECK_HEADERS(proj_api.h,,[
    CPPFLAGS="$savCPPFLAGS"
    AC_CHECK_HEADERS(proj.h, use6=yes, proj4ok=no)
  ])
])

dnl changes needed for static PROJ 6
AC_LANG(C++)
LIBS="${LIBS} ${PKG_LIBS} -lsqlite3"

AC_CHECK_LIB(proj,pj_init_plus,,[
  use6=yes
  AC_CHECK_LIB(proj,proj_create_crs_to_crs,, proj4ok=no)
])

AC_MSG_CHECKING([whether to require PROJ6 API])
if test x"${with_proj6}" = xno; then
   AC_MSG_RESULT([no])
 else
  AC_MSG_RESULT([yes])
  use6=yes
  AC_CHECK_HEADERS(proj.h,, proj4ok=no)
  AC_CHECK_LIB(proj,proj_create_crs_to_crs,, proj4ok=no)
fi

AC_MSG_CHECKING([whether to use PROJ6 API])
AC_MSG_RESULT([$use6])
if test "x$use6" = xyes; then
   CPPFLAGS="${PKG_CPPFLAGS} -DUSE_PROJ6_API=1"
fi
#if test "${proj4ok}" = no; then
#   AC_MSG_ERROR([libproj and/or proj.h/proj_api.h not found in standard search locations.
#*** Install PROJ library and if necessary set PKG_CPPFLAGS/PKG_LIBS accordingly.])
#fi

AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT
