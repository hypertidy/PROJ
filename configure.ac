AC_INIT([PROJ],[1.0],[mdsumner@gmail.com])
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

AC_LANG(C++)

# honor PKG_xx overrides
LIBS="${LIBS} ${PKG_LIBS}"
# for CPPFLAGS we will superfluously double R's flags
# since we'll set PKG_CPPFLAGS with this, but that shouldn't hurt
CPPFLAGS="${CPPFLAGS} ${PKG_CPPFLAGS}"
LIBS_SAVE=${LIBS}

AC_ARG_ENABLE([proj6],
  AS_HELP_STRING(--enable-proj6, [use the new PROJ6 API even if PROJ4 API is available. The default is @<:@disable@:>@ since PROJ6 API has issues, use with caution.]),
  [with_proj6=$withval], [with_proj6=no])

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

# force PROJ 6 or above
use6=yes
proj4api=no
proj6api=yes

# check PROJ4 API
AC_CHECK_HEADERS(proj_api.h,,[
  # if it doesn't work, enable deprecated
  AC_MSG_CHECKING([with ACCEPT_USE_OF_DEPRECATED_PROJ_API_H])
  AC_MSG_RESULT([])
  savCPPFLAGS="$CPPFLAGS"
  CPPFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1 $CPPFLAGS"
  unset ac_cv_header_proj_api_h
  AC_CHECK_HEADERS(proj_api.h,,[
    # PROJ4 API is not available
    proj4api=no
    CPPFLAGS="$savCPPFLAGS"
  ])
])

if test x${proj4api} = xyes; then
   AC_CHECK_LIB(proj, pj_init_plus,, [
      unset ac_cv_lib_proj_pj_init_plus
      ## try static
      AC_MSG_NOTICE([Retrying with pkg-config --static])
      PROJ_LIBSS=`pkg-config --static --libs proj`
      LIBS="${LIBS_SAVE} ${PROJ_LIBSS}"
      AC_CHECK_LIB(proj, pj_init_plus, [
         PROJ_LIBS="${PROJ_LIBSS}"
      ], [
         LIBS="${LIBS_SAVE}"
	 proj4api=no
      ])
   ])
fi

# If p4 is available LIBS will have the proj4 flags
# so save it in case 6 doesn't work out
PRE6_LIBS=${LIBS}

# check PROJ6 API - it is mandatory if use6=yes
AC_CHECK_HEADERS(proj.h,,proj6api=no)

AC_CHECK_LIB(proj, proj_get_source_crs,,[
    unset ac_cv_lib_proj_proj_get_source_crs
    ## try static
    AC_MSG_NOTICE([Retrying with pkg-config --static])
    PROJ_LIBS=`pkg-config --static --libs proj`
    LIBS="${LIBS_SAVE} ${PROJ_LIBS}"
    AC_CHECK_LIB(proj, proj_get_source_crs,, [
        proj6api=no
        LIBS=${PRE6_LIBS}
    ])
])

AC_MSG_NOTICE([PROJ4 API available: ${proj4api}])
AC_MSG_NOTICE([PROJ6 API available: ${proj6api}])

AC_MSG_CHECKING([whether to require PROJ6 API])
if test x"${with_proj6}" = xno; then
   AC_MSG_RESULT([no])
else
   AC_MSG_RESULT([yes])
   use6=yes
fi

## fall back to 6 if 4 doesn't work
if test x${proj4api} = xno; then
   use6=yes
fi

if test x$use6 = xyes -a x${proj6api} = xno; then
   AC_MSG_ERROR([Cannot find working proj.h headers and library.
*** You may need to install libproj-dev or similar! ***
])
fi

if test x$use6 = xno -a x${proj4api} = xno; then
   AC_MSG_ERROR([Cannot find working proj_api.h headers and library.
*** You may need to install libproj-dev or similar! ***
])
fi

AC_MSG_CHECKING([whether to use PROJ6 API])
AC_MSG_RESULT([$use6])
if test "x$use6" = xyes; then
   CPPFLAGS="-DUSE_PROJ6_API=1 ${CPPFLAGS}"
fi

AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT
