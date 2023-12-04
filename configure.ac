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
proj6api=yes


# check PROJ6 API - it is mandatory if use6=yes
AC_CHECK_HEADERS(proj.h,,proj6api=no)

AC_CHECK_LIB(proj, proj_get_source_crs,,[
    unset ac_cv_lib_proj_proj_get_source_crs
    ## try static
    AC_MSG_NOTICE([Retrying with pkg-config --static])
    PROJ_LIBS=`pkg-config --static --libs proj`
    LIBS="${LIBS_SAVE} ${PROJ_LIBS}"
])

vers_ge6=yes
## specifically this is not in 5
AC_CHECK_LIB(proj, proj_as_wkt, , proj6api=no)

#AC_MSG_NOTICE([PROJ4 API available: ${proj4api}])
AC_MSG_NOTICE([PROJ6 API available: ${proj6api}])


if test x$use6 = xyes -a x${proj6api} = xno; then
   AC_MSG_NOTICE([Cannot find working proj.h headers and library.
*** You may need to install libproj-dev or similar! ***
])
fi


AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_MSG_NOTICE([setting CCPFLAGS: ${CPPFLAGS}])
AC_MSG_NOTICE([setting PROJ_LIBS: ${PROJ_LIBS}])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT
