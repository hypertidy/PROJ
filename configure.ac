AC_INIT(PROJ, 0.2.0, mdsumner@gmail.com)
AC_CONFIG_SRCDIR(src/init.c)

# find R home and set correct compiler + flags
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  AC_MSG_ERROR([cannot determine R_HOME. Make sure you use R CMD INSTALL!])
fi
RBIN="${R_HOME}/bin/R"

# pick all flags for testing from R
: ${CC=`"${RBIN}" CMD config CC`}
: ${CXX=`"${RBIN}" CMD config CXX`}
: ${CFLAGS=`"${RBIN}" CMD config CFLAGS`}
: ${CPPFLAGS=`"${RBIN}" CMD config CPPFLAGS`}
: ${LDFLAGS=`"${RBIN}" CMD config LDFLAGS`}

#
# PROJ
#

PROJ_CONFIG="pkg-config proj"

if `$PROJ_CONFIG --exists` ; then
  AC_MSG_NOTICE([pkg-config proj exists, will use it])
  proj_config_ok=yes
else
  proj_config_ok=no
fi

AC_ARG_WITH([proj-include],
    AC_HELP_STRING([--with-proj-include=DIR],
                   [location of proj header files]),
    [proj_include_path=$withval])
if test [ -n "$proj_include_path" ] ; then
   AC_SUBST([PROJ_CPPFLAGS],["-I${proj_include_path}"])
else
  if test "${proj_config_ok}" = yes; then
    PROJ_INCLUDE_PATH=`${PROJ_CONFIG} --cflags`
    AC_SUBST([PROJ_CPPFLAGS],["${PROJ_INCLUDE_PATH}"])
  fi
fi


PROJ6="no"
PROJH="no"
if test "${proj_config_ok}" = yes; then
  PROJ_VERSION=`${PROJ_CONFIG} --modversion`
  PROJV1=`echo "${PROJ_VERSION}" | cut -c 1`
  if test "${PROJV1}" -ge 6; then
    PROJ6="yes"
    PROJ_CPPFLAGS="${PROJ_CPPFLAGS} -DHAVE_PROJ6_API"
    AC_MSG_NOTICE([using proj.h.])
    PROJH="yes"
  fi
else
  if test "${PROJH}" = no ; then
    PROJH=yes
    AC_CHECK_HEADERS(proj.h,,PROJH=no)
    if test "${PROJH}" = yes; then
      PROJ6="yes"
      PROJ_CPPFLAGS="${PROJ_CPPFLAGS} -DHAVE_PROJ6_API"
    fi
  fi
fi


if test "${PROJ6}" = no
then
   AC_MSG_NOTICE([PROJ version 6 (>=6.1.0) not available, package will install but has no capabilities for the PROJ library.])
   AC_MSG_NOTICE([This limitation is by design, please use the reproj package for more general support.])
fi

if test "${PROJ6}" = yes
then
  # do we copy the data in (MacOS yes, Windows yes but via /tools)
  AC_ARG_WITH([proj-lib],
      AC_HELP_STRING([--with-proj-lib=LIB_PATH],
                 [the location of proj libraries]),
                 [proj_lib_path=$withval])
  if test [ -n "$proj_lib_path" ] ; then
      AC_SUBST([PROJ_LIBS], ["-L${proj_lib_path} ${INPKG_LIBS} -lproj"])
  else
    if test "${proj_config_ok}" = yes; then
      PROJ_LIB_PATH=`${PROJ_CONFIG} --libs`
      AC_SUBST([PROJ_LIBS], ["${PROJ_LIB_PATH} ${INPKG_LIBS}"])
  	proj_version=`${PROJ_CONFIG} --modversion`
  	AC_MSG_NOTICE([PROJ: ${proj_version}])
    else
      PROJ_LIBS="${PKG_LIBS} -lproj"
    fi
  fi
fi


LIBS="${PROJ_LIBS} ${INLIBS}"

CPPFLAGS="${PKG_CPPFLAGS} ${PROJ_CPPFLAGS}"

## DATA COPY (PROJ_LIB)

data_copy=no
AC_ARG_WITH([data-copy],
    AC_HELP_STRING([--with-data-copy=yes/no],
               [local copy of data directories in package, default no]),
               [data_copy=$withval])
if test "${data_copy}" = "yes" ; then
AC_MSG_NOTICE([Copy data for:])
  proj_lib0="${PROJ_LIB}"
  AC_ARG_WITH([proj-data],
    AC_HELP_STRING([--with-proj-data=DIR],
                   [location of PROJ data directory]),
    [proj_lib1=$withval])
  if test -n "${proj_lib0}" ; then
    proj_lib="${proj_lib0}"
  else
    proj_lib="${proj_lib1}"
  fi
  if test -n "${proj_lib}" ; then
    if test -d "${proj_lib}" ; then
      cp -r "${proj_lib}" "${R_PACKAGE_DIR}"
      AC_MSG_NOTICE([  PROJ lib: ${proj_lib}])
    else
      AC_MSG_NOTICE([PROJ data files not found; set environment variable PROJ_LIB=DIR or --with-proj-data=DIR.])
    fi
  else
      AC_MSG_NOTICE([PROJ data files not found; set environment variable PROJ_LIB=DIR or --with-proj-data=DIR.])
  fi
fi

AC_ARG_VAR([PKG_CPPFLAGS],[custom C preprocessor flags for packages compilation])
AC_ARG_VAR([PKG_LIBS],[custom libraries for package compilation])

AC_CONFIG_FILES(src/Makevars)
AC_OUTPUT

